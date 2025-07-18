"use client"

import type React from "react"
import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { useNavigate } from "react-router-dom"
import type { UsuarioFront } from "../interfaces/auth"
import { authService } from "../services/api"

export interface LoginCredentials {
  username: string
  password: string
}

export interface AuthContextType {
  user: UsuarioFront | null
  login: (credentials: LoginCredentials) => Promise<void>
  logout: () => void
  isLoading: boolean
  hasPermission: (permission: string) => boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}

interface AuthProviderProps {
  children: ReactNode
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<UsuarioFront | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    const initializeAuth = () => {
      try {
        const token = localStorage.getItem("acaucab_token")
        const savedUser = localStorage.getItem("acaucab_user")
        
        if (token && savedUser) {
          const parsedUser: UsuarioFront = JSON.parse(savedUser)
          setUser(parsedUser)
        }
      } catch (error) {
        console.error("Failed to initialize auth:", error)
        localStorage.removeItem("acaucab_user")
        localStorage.removeItem("acaucab_token")
      } finally {
        setIsLoading(false)
      }
    }
    initializeAuth()
  }, [])

  const hasPermission = (permission: string): boolean => {
    // La única comprobación de permisos que queda es para el rol de administrador.
    // El resto de la lógica de privilegios ha sido eliminada.
    if (permission === 'admin_only') {
      return user?.rol === 'Administrador'
    }
    // Para todo lo demás, se concede el acceso.
    return true
  };

  const login = async (credentials: LoginCredentials) => {
    setIsLoading(true)
    try {
      const response = await authService.login(credentials.username, credentials.password)
      if (response.success && response.data?.authenticated) {
        const { token, user: userData } = response.data
        const userToStore: UsuarioFront = {
          username: userData.username,
          rol: userData.rol,
        }
        localStorage.setItem("acaucab_token", token)
        localStorage.setItem("acaucab_user", JSON.stringify(userToStore))
        setUser(userToStore)
        navigate("/dashboard", { replace: true })
      } else {
        throw new Error(response.error || "Credenciales inválidas")
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "Error de conexión"
      console.error("Login failed:", errorMessage)
      throw new Error(errorMessage)
    } finally {
      setIsLoading(false)
    }
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem("acaucab_user")
    localStorage.removeItem("acaucab_token")
    navigate("/login", { replace: true })
  }

  const value: AuthContextType = {
    user,
    login,
    logout,
    isLoading,
    hasPermission
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
