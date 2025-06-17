"use client"

import type React from "react"
import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import type { Usuario, Rol, Privilegio } from "../interfaces"

export interface LoginCredentials {
  username: string
  password: string
}

export interface AuthContextType {
  user: Usuario | null
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

// Datos de ejemplo para roles y privilegios
const rolesEjemplo: Rol[] = [
  {
    cod_rol: 1,
    nombre_rol: "Administrador",
    descripcion_rol: "Acceso completo al sistema",
  },
  {
    cod_rol: 2,
    nombre_rol: "Vendedor",
    descripcion_rol: "Acceso a ventas e inventario",
  },
  {
    cod_rol: 3,
    nombre_rol: "Empleado",
    descripcion_rol: "Acceso básico",
  },
]

const privilegiosEjemplo: Privilegio[] = [
  { cod_priv: 1, nombre_priv: "ventas", descripcion_priv: "Gestión de ventas" },
  { cod_priv: 2, nombre_priv: "inventario", descripcion_priv: "Gestión de inventario" },
  { cod_priv: 3, nombre_priv: "reportes", descripcion_priv: "Acceso a reportes" },
  { cod_priv: 4, nombre_priv: "usuarios", descripcion_priv: "Gestión de usuarios" },
]

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<Usuario | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const savedUser = localStorage.getItem("acaucab_user")
    if (savedUser) {
      setUser(JSON.parse(savedUser))
    }
    setIsLoading(false)
  }, [])

  const login = async (credentials: LoginCredentials) => {
    setIsLoading(true)
    try {
      // Simulación de autenticación
      let mockUser: Usuario | null = null

      if (credentials.username === "admin" && credentials.password === "admin123") {
        mockUser = {
          cod_usua: 1,
          username_usua: "admin",
          contra_usua: "", // No almacenar contraseña en el frontend
          fk_rol: 1,
        }
      } else if (credentials.username === "vendedor" && credentials.password === "vend123") {
        mockUser = {
          cod_usua: 2,
          username_usua: "vendedor",
          contra_usua: "",
          fk_rol: 2,
        }
      } else if (credentials.username === "empleado" && credentials.password === "emp123") {
        mockUser = {
          cod_usua: 3,
          username_usua: "empleado",
          contra_usua: "",
          fk_rol: 3,
        }
      }

      if (mockUser) {
        setUser(mockUser)
        localStorage.setItem("acaucab_user", JSON.stringify(mockUser))
      } else {
        throw new Error("Credenciales inválidas")
      }
    } catch (error) {
      throw new Error("Credenciales inválidas")
    } finally {
      setIsLoading(false)
    }
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem("acaucab_user")
  }

  const hasPermission = (privilegio: string): boolean => {
    if (!user) return false

    // Simulación de verificación de privilegios basada en rol
    const userRole = rolesEjemplo.find((rol) => rol.cod_rol === user.fk_rol)
    if (!userRole) return false

    // Admin tiene todos los privilegios
    if (userRole.nombre_rol === "Administrador") return true

    // Vendedor tiene acceso a ventas e inventario
    if (userRole.nombre_rol === "Vendedor") {
      return ["ventas", "inventario"].includes(privilegio)
    }

    // Empleado solo tiene acceso a ventas
    if (userRole.nombre_rol === "Empleado") {
      return privilegio === "ventas"
    }

    return false
  }

  const value: AuthContextType = {
    user,
    login,
    logout,
    isLoading,
    hasPermission,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
