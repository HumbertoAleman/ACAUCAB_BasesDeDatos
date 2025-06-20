"use client"

import type React from "react"
import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { useNavigate, useLocation } from "react-router-dom"
import type { UsuarioFront, RolFront } from "../interfaces/auth"
import { authService } from "../services/api"

export interface LoginCredentials {
  username: string
  password: string
}

export interface AuthContextType {
  user: UsuarioFront | null
  role: string | null
  login: (credentials: LoginCredentials) => Promise<void>
  logout: () => void
  isLoading: boolean
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
  const [role, setRole] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    const initializeAuth = async () => {
      const savedUser = localStorage.getItem("acaucab_user")
      const savedRole = localStorage.getItem("acaucab_role")
      const token = localStorage.getItem("acaucab_token")

      if (savedUser && savedRole && token) {
        try {
          const response = await authService.verifyToken()
          if (response.success && response.data) {
            setUser({ username: response.data.user.username_usua })
            setRole(response.data.role.nombre_rol)
          } else {
            localStorage.removeItem("acaucab_user")
            localStorage.removeItem("acaucab_role")
            localStorage.removeItem("acaucab_token")
          }
        } catch (error) {
          localStorage.removeItem("acaucab_user")
          localStorage.removeItem("acaucab_role")
          localStorage.removeItem("acaucab_token")
        }
      } else {
        if (savedUser) {
          const parsedUser = JSON.parse(savedUser)
          setUser(parsedUser && parsedUser.username ? parsedUser : { username: parsedUser.username_usua })
        }
        if (savedRole) {
          const parsedRole = JSON.parse(savedRole)
          setRole(parsedRole && typeof parsedRole === 'string' ? parsedRole : parsedRole.nombre_rol)
        }
      }
      setIsLoading(false)
    }
    initializeAuth()
  }, [])

  const login = async (credentials: LoginCredentials) => {
    setIsLoading(true)
    try {
      const response = await authService.login(credentials.username, credentials.password)
      if (response.success && response.data) {
        const { user, role, token } = response.data
        const userFront = { username: user.username_usua }
        const roleFront = role.nombre_rol
        localStorage.setItem("acaucab_user", JSON.stringify(userFront))
        localStorage.setItem("acaucab_role", JSON.stringify(roleFront))
        if (token) {
          localStorage.setItem("acaucab_token", token)
        }
        setUser(userFront)
        setRole(roleFront)
        const from = (location.state as any)?.from?.pathname || "/dashboard"
        navigate(from, { replace: true })
      } else {
        throw new Error(response.error || "Credenciales inválidas")
      }
    } catch (error) {
      throw new Error(error instanceof Error ? error.message : "Error de conexión")
    } finally {
      setIsLoading(false)
    }
  }

  const logout = async () => {
    try {
      await authService.logout()
    } catch (error) {
      // Ignorar error
    } finally {
      setUser(null)
      setRole(null)
      localStorage.removeItem("acaucab_user")
      localStorage.removeItem("acaucab_role")
      localStorage.removeItem("acaucab_token")
      navigate("/login", { replace: true })
    }
  }

  const value: AuthContextType = {
    user,
    role,
    login,
    logout,
    isLoading,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
