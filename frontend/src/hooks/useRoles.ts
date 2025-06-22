import { useState, useEffect } from 'react'
import { roleService, privilegeService, type ApiResponse } from '../services/api'
import type { Rol, Privilegio, PrivRol } from '../interfaces'

export interface RoleWithPrivileges extends Rol {
  privileges?: Privilegio[]
}

export interface UseRolesReturn {
  roles: RoleWithPrivileges[]
  privileges: Privilegio[]
  loading: boolean
  error: string | null
  createRole: (roleData: Partial<Rol>) => Promise<boolean>
  updateRole: (id: number, roleData: Partial<Rol>) => Promise<boolean>
  deleteRole: (id: number) => Promise<boolean>
  assignPrivilege: (roleId: number, privilegeId: number) => Promise<boolean>
  removePrivilege: (roleId: number, privilegeId: number) => Promise<boolean>
  refreshRoles: () => Promise<void>
  refreshPrivileges: () => Promise<void>
}

export const useRoles = (): UseRolesReturn => {
  const [roles, setRoles] = useState<RoleWithPrivileges[]>([])
  const [privileges, setPrivileges] = useState<Privilegio[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchRoles = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await roleService.getRoles()
      if (response.success && response.data) {
        // Enriquecer roles con información de privilegios
        const rolesWithPrivileges = await Promise.all(
          response.data.map(async (role: Rol) => {
            try {
              const privilegesResponse = await roleService.getRolePrivileges(role.cod_rol)
              
              return {
                ...role,
                privileges: privilegesResponse.success ? privilegesResponse.data : []
              }
            } catch (error) {
              console.error(`Error fetching privileges for role ${role.cod_rol}:`, error)
              return role
            }
          })
        )
        
        setRoles(rolesWithPrivileges)
      } else {
        setError(response.error || 'Error al cargar roles')
      }
    } catch (error) {
      setError('Error de conexión al cargar roles')
      console.error('Error fetching roles:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchPrivileges = async () => {
    try {
      const response = await privilegeService.getPrivileges()
      console.log("Respuesta de /api/privileges:", response)

      // Corregido: Manejar respuesta como array directo
      if (Array.isArray(response)) {
        setPrivileges(response)
        console.log("Privilegios seteados en el estado:", response)
      } else {
        // Manejar el caso de una respuesta con error envuelta
        console.error('Error loading privileges:', (response as ApiResponse<any>).error)
      }
    } catch (error) {
      console.error('Error fetching privileges:', error)
    }
  }

  const createRole = async (roleData: Partial<Rol>): Promise<boolean> => {
    try {
      setError(null)
      const response = await roleService.createRole(roleData)
      
      if (response.success) {
        await fetchRoles() // Recargar la lista
        return true
      } else {
        setError(response.error || 'Error al crear rol')
        return false
      }
    } catch (error) {
      setError('Error de conexión al crear rol')
      console.error('Error creating role:', error)
      return false
    }
  }

  const updateRole = async (id: number, roleData: Partial<Rol>): Promise<boolean> => {
    try {
      setError(null)
      const response = await roleService.updateRole(id, roleData)
      
      if (response.success) {
        await fetchRoles() // Recargar la lista
        return true
      } else {
        setError(response.error || 'Error al actualizar rol')
        return false
      }
    } catch (error) {
      setError('Error de conexión al actualizar rol')
      console.error('Error updating role:', error)
      return false
    }
  }

  const deleteRole = async (id: number): Promise<boolean> => {
    try {
      setError(null)
      const response = await roleService.deleteRole(id)
      
      if (response.success) {
        await fetchRoles() // Recargar la lista
        return true
      } else {
        setError(response.error || 'Error al eliminar rol')
        return false
      }
    } catch (error) {
      setError('Error de conexión al eliminar rol')
      console.error('Error deleting role:', error)
      return false
    }
  }

  const assignPrivilege = async (roleId: number, privilegeId: number): Promise<boolean> => {
    try {
      setError(null)
      const response = await privilegeService.assignPrivilegeToRole(roleId, privilegeId)
      
      if (response.success) {
        await fetchRoles() // Recargar la lista para actualizar privilegios
        return true
      } else {
        setError(response.error || 'Error al asignar privilegio')
        return false
      }
    } catch (error) {
      setError('Error de conexión al asignar privilegio')
      console.error('Error assigning privilege:', error)
      return false
    }
  }

  const removePrivilege = async (roleId: number, privilegeId: number): Promise<boolean> => {
    try {
      setError(null)
      const response = await privilegeService.removePrivilegeFromRole(roleId, privilegeId)
      
      if (response.success) {
        await fetchRoles() // Recargar la lista para actualizar privilegios
        return true
      } else {
        setError(response.error || 'Error al remover privilegio')
        return false
      }
    } catch (error) {
      setError('Error de conexión al remover privilegio')
      console.error('Error removing privilege:', error)
      return false
    }
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
        fetchRoles(),
        fetchPrivileges()
      ])
    }
    
    initializeData()
  }, [])

  return {
    roles,
    privileges,
    loading,
    error,
    createRole,
    updateRole,
    deleteRole,
    assignPrivilege,
    removePrivilege,
    refreshRoles,
    refreshPrivileges
  }
} 