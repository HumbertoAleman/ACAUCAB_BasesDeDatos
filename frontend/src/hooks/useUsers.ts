import { useState, useEffect } from 'react'
import { userService, roleService, privilegeService, type ApiResponse } from '../services/api'
import type { Usuario, Rol, Privilegio } from '../interfaces'

export interface UserWithRole extends Usuario {
  role?: Rol
  privileges?: Privilegio[]
}

export interface UseUsersReturn {
  users: UserWithRole[]
  roles: Rol[]
  privileges: Privilegio[]
  loading: boolean
  error: string | null
  createUser: (userData: Partial<Usuario>) => Promise<boolean>
  updateUser: (id: number, userData: Partial<Usuario>) => Promise<boolean>
  deleteUser: (id: number) => Promise<boolean>
  refreshUsers: () => Promise<void>
  refreshRoles: () => Promise<void>
  refreshPrivileges: () => Promise<void>
}

export const useUsers = (): UseUsersReturn => {
  const [users, setUsers] = useState<UserWithRole[]>([])
  const [roles, setRoles] = useState<Rol[]>([])
  const [privileges, setPrivileges] = useState<Privilegio[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchUsers = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await userService.getUsers()
      if (response.success && response.data) {
        // Enriquecer usuarios con información de roles
        const usersWithRoles = await Promise.all(
          response.data.map(async (user: Usuario) => {
            try {
              const roleResponse = await roleService.getRoleById(user.fk_rol)
              const privilegesResponse = await roleService.getRolePrivileges(user.fk_rol)
              
              return {
                ...user,
                role: roleResponse.success ? roleResponse.data : undefined,
                privileges: privilegesResponse.success ? privilegesResponse.data : []
              }
            } catch (error) {
              console.error(`Error fetching role for user ${user.cod_usua}:`, error)
              return user
            }
          })
        )
        
        setUsers(usersWithRoles)
      } else {
        setError(response.error || 'Error al cargar usuarios')
      }
    } catch (error) {
      setError('Error de conexión al cargar usuarios')
      console.error('Error fetching users:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchRoles = async () => {
    try {
      const response = await roleService.getRoles()
      if (response.success && response.data) {
        setRoles(response.data)
      } else {
        console.error('Error loading roles:', response.error)
      }
    } catch (error) {
      console.error('Error fetching roles:', error)
    }
  }

  const fetchPrivileges = async () => {
    try {
      const response = await privilegeService.getPrivileges()
      if (response.success && response.data) {
        setPrivileges(response.data)
      } else {
        console.error('Error loading privileges:', response.error)
      }
    } catch (error) {
      console.error('Error fetching privileges:', error)
    }
  }

  const createUser = async (userData: Partial<Usuario>): Promise<boolean> => {
    try {
      setError(null)
      const response = await userService.createUser(userData)
      
      if (response.success) {
        await fetchUsers() // Recargar la lista
        return true
      } else {
        setError(response.error || 'Error al crear usuario')
        return false
      }
    } catch (error) {
      setError('Error de conexión al crear usuario')
      console.error('Error creating user:', error)
      return false
    }
  }

  const updateUser = async (id: number, userData: Partial<Usuario>): Promise<boolean> => {
    try {
      setError(null)
      const response = await userService.updateUser(id, userData)
      
      if (response.success) {
        await fetchUsers() // Recargar la lista
        return true
      } else {
        setError(response.error || 'Error al actualizar usuario')
        return false
      }
    } catch (error) {
      setError('Error de conexión al actualizar usuario')
      console.error('Error updating user:', error)
      return false
    }
  }

  const deleteUser = async (id: number): Promise<boolean> => {
    try {
      setError(null)
      const response = await userService.deleteUser(id)
      
      if (response.success) {
        await fetchUsers() // Recargar la lista
        return true
      } else {
        setError(response.error || 'Error al eliminar usuario')
        return false
      }
    } catch (error) {
      setError('Error de conexión al eliminar usuario')
      console.error('Error deleting user:', error)
      return false
    }
  }

  const refreshUsers = async () => {
    await fetchUsers()
  }

  const refreshRoles = async () => {
    await fetchRoles()
  }

  const refreshPrivileges = async () => {
    await fetchPrivileges()
  }

  useEffect(() => {
    const initializeData = async () => {
      await Promise.all([
        fetchUsers(),
        fetchRoles(),
        fetchPrivileges()
      ])
    }
    
    initializeData()
  }, [])

  return {
    users,
    roles,
    privileges,
    loading,
    error,
    createUser,
    updateUser,
    deleteUser,
    refreshUsers,
    refreshRoles,
    refreshPrivileges
  }
} 