"use client"

import type React from "react"
import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { useNavigate, useLocation } from "react-router-dom"
import type { Usuario, Rol, Privilegio } from "../interfaces"
import { authService, type LoginResponse } from "../services/api"

export interface LoginCredentials {
  username: string
  password: string
}

export interface AuthContextType {
  user: Usuario | null
  role: Rol | null
  privileges: Privilegio[]
  login: (credentials: LoginCredentials) => Promise<void>
  logout: () => void
  isLoading: boolean
  hasPermission: (privilegio: string) => boolean
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
  const [user, setUser] = useState<Usuario | null>(null)
  const [role, setRole] = useState<Rol | null>(null)
  const [privileges, setPrivileges] = useState<Privilegio[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    const initializeAuth = async () => {
      const savedUser = localStorage.getItem("acaucab_user")
      const savedRole = localStorage.getItem("acaucab_role")
      const savedPrivileges = localStorage.getItem("acaucab_privileges")
      const token = localStorage.getItem("acaucab_token")

      if (savedUser && savedRole && savedPrivileges && token) {
        try {
          // Verificar si el token sigue siendo válido
          const response = await authService.verifyToken()
          if (response.success && response.data) {
            setUser(response.data.user)
            setRole(response.data.role)
            setPrivileges(response.data.privileges)
          } else {
            // Token inválido, limpiar datos
            localStorage.removeItem("acaucab_user")
            localStorage.removeItem("acaucab_role")
            localStorage.removeItem("acaucab_privileges")
            localStorage.removeItem("acaucab_token")
          }
        } catch (error) {
          console.error("Error verificando token:", error)
          // Limpiar datos en caso de error
          localStorage.removeItem("acaucab_user")
          localStorage.removeItem("acaucab_role")
          localStorage.removeItem("acaucab_privileges")
          localStorage.removeItem("acaucab_token")
        }
      } else {
        // Usar datos guardados si no hay token (fallback)
        if (savedUser) {
          setUser(JSON.parse(savedUser))
        }
        if (savedRole) {
          setRole(JSON.parse(savedRole))
        }
        if (savedPrivileges) {
          setPrivileges(JSON.parse(savedPrivileges))
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
        const { user, role, privileges, token } = response.data
        
        // Guardar datos en localStorage
        localStorage.setItem("acaucab_user", JSON.stringify(user))
        localStorage.setItem("acaucab_role", JSON.stringify(role))
        localStorage.setItem("acaucab_privileges", JSON.stringify(privileges))
        if (token) {
          localStorage.setItem("acaucab_token", token)
        }
        
        // Actualizar estado
        setUser(user)
        setRole(role)
        setPrivileges(privileges)
        
        // Redirigir a la página original o al dashboard
        const from = (location.state as any)?.from?.pathname || "/dashboard"
        navigate(from, { replace: true })
      } else {
        throw new Error(response.error || "Credenciales inválidas")
      }
    } catch (error) {
      console.error("Error en login:", error)
      throw new Error(error instanceof Error ? error.message : "Error de conexión")
    } finally {
      setIsLoading(false)
    }
  }

  const logout = async () => {
    try {
      // Intentar hacer logout en el backend
      await authService.logout()
    } catch (error) {
      console.error("Error en logout:", error)
    } finally {
      // Limpiar datos locales independientemente del resultado del backend
      setUser(null)
      setRole(null)
      setPrivileges([])
      localStorage.removeItem("acaucab_user")
      localStorage.removeItem("acaucab_role")
      localStorage.removeItem("acaucab_privileges")
      localStorage.removeItem("acaucab_token")
      
      // Redirigir al login después del logout
      navigate("/login", { replace: true })
    }
  }

  const hasPermission = (privilegio: string): boolean => {
    if (!user || !privileges.length) return false

    // Verificar si el usuario tiene el privilegio específico
    return privileges.some(priv => priv.nombre_priv === privilegio)
  }

  const value: AuthContextType = {
    user,
    role,
    privileges,
    login,
    logout,
    isLoading,
    hasPermission,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
