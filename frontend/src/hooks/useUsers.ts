import { useState, useEffect, useCallback } from 'react'
import { userService } from '../services/api'
import type { Usuario } from '../interfaces'

export interface UseUsersReturn {
  users: Usuario[]
  loading: boolean
  error: string | null
  createUser: (userData: Partial<Usuario>) => Promise<boolean>
  updateUser: (id: number, userData: Partial<Usuario>) => Promise<boolean>
  deleteUser: (id: number) => Promise<boolean>
  refreshUsers: () => Promise<void>
}

export const useUsers = (): UseUsersReturn => {
  const [users, setUsers] = useState<Usuario[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchUsers = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response: any = await userService.getUsersWithRoles() // Usar el endpoint que trae todo
      
      // La API puede devolver un array directamente en caso de éxito.
      if (Array.isArray(response)) {
        setUsers(response)
      } else {
        // Si no es un array, es un objeto de error de nuestra envoltura de API.
        const errorMessage = `Error al cargar usuarios: ${response.error || 'Respuesta inesperada del servidor.'}`
        setError(errorMessage)
        console.error(errorMessage)
      }
    } catch (error) {
      const errorMessage = `Error de conexión: ${error instanceof Error ? error.message : String(error)}`
      setError(errorMessage)
      console.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [])

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
      return false
    }
  }

  const refreshUsers = async () => {
    await fetchUsers()
  }

  useEffect(() => {
    fetchUsers()
  }, [fetchUsers])

  return {
    users,
    loading,
    error,
    createUser,
    updateUser,
    deleteUser,
    refreshUsers,
  }
} 