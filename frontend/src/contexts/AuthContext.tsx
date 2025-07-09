"use client"

import type React from "react"
import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { useNavigate } from "react-router-dom"
import type { UsuarioFront } from "../interfaces/auth"
import { authService, userService } from "../services/api"

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

  const hasPermission = (_permission: string): boolean => {
    return !!user;
  };

  const login = async (credentials: LoginCredentials) => {
    setIsLoading(true)
    try {
      const response = await authService.login(credentials.username, credentials.password)
      if (response.success && response.data?.authenticated) {
        const { token, user: userData } = response.data
        
        // Obtener el fk_rol del usuario usando el endpoint de usuarios con detalles
        const usersResponse = await userService.getUsersWithRoles()
        let fk_rol: number | null = null
        
        if (usersResponse.success && usersResponse.data) {
          const currentUser = usersResponse.data.find((u: any) => u.username_usua === userData.username)
          if (currentUser && currentUser.fk_rol) {
            fk_rol = currentUser.fk_rol
          }
        }
        
        // Si no se pudo obtener el fk_rol, continuar sin él
        console.log('User fk_rol:', fk_rol)
        
        const userToStore: UsuarioFront = {
          username: userData.username,
          rol: userData.rol,
          fk_rol: fk_rol, // Agregar el fk_rol al usuario
          fk_clie: 'fk_clie' in userData ? (userData.fk_clie !== undefined && userData.fk_clie !== null ? String(userData.fk_clie) : null) : null,
          fk_empl: 'fk_empl' in userData ? (userData.fk_empl !== undefined && userData.fk_empl !== null ? Number(userData.fk_empl) : null) : null,
          fk_miem: 'fk_miem' in userData ? (userData.fk_miem !== undefined && userData.fk_miem !== null ? String(userData.fk_miem) : null) : null
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
