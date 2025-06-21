// Configuración base de la API
const API_BASE_URL = 'http://127.0.0.1:3000/api' // Ajusta según tu configuración del backend

// Interfaces para las respuestas de la API
export interface ApiResponse<T> {
  success: boolean
  data?: T
  message?: string
  error?: string
}

export interface AuthResponse {
  authenticated: boolean;
  token: string;
  user: {
    username: string;
    rol: string;
    privileges: string[];
  };
}

// Función helper para hacer peticiones HTTP
async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  try {
    const token = localStorage.getItem('acaucab_token')
    
    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
        ...options.headers,
      },
      ...options,
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, config)
    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.message || `Error ${response.status}: ${response.statusText}`)
    }

    return data
  } catch (error) {
    console.error('API Error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Error desconocido',
    }
  }
}

// Servicios de autenticación
export const authService = {
  // Login de usuario
  async login(username: string, password: string): Promise<ApiResponse<AuthResponse>> {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password }),
    });
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || `Error ${response.status}: ${response.statusText}`)
    }

    if (data.authenticated) {
      return { success: true, data: data };
    } else {
      return { success: false, error: "Authentication failed" };
    }
  },

  // Logout
  async logout(): Promise<ApiResponse<void>> {
    return apiRequest<void>('/auth/logout', {
      method: 'POST',
    })
  },

  // Verificar token actual
  async verifyToken(): Promise<ApiResponse<AuthResponse>> {
    return apiRequest<AuthResponse>('/auth/verify')
  },
}

// Servicios de usuarios
export const userService = {
  // Obtener todos los usuarios
  async getUsers(): Promise<ApiResponse<any[]>> {
    return apiRequest<any[]>('/users_with_details')
  },

  // Obtener usuario por ID
  async getUserById(id: number): Promise<ApiResponse<any>> {
    return apiRequest<any>(`/users/${id}`)
  },

  // Crear nuevo usuario
  async createUser(userData: any): Promise<ApiResponse<any>> {
    return apiRequest<any>('/users', {
      method: 'POST',
      body: JSON.stringify(userData),
    })
  },

  // Actualizar usuario
  async updateUser(id: number, userData: any): Promise<ApiResponse<any>> {
    return apiRequest<any>(`/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(userData),
    })
  },

  // Eliminar usuario
  async deleteUser(id: number): Promise<ApiResponse<void>> {
    return apiRequest<void>(`/users/${id}`, {
      method: 'DELETE',
    })
  },

  // Obtener todos los usuarios con sus roles y privilegios
  async getUsersWithRoles(): Promise<ApiResponse<any[]>> {
    // This endpoint needs to be created in the backend.
    // It should return a list of users, including their roles and current privileges.
    return apiRequest<any[]>('/users_with_details'); 
  }
}

// Servicios de roles
export const roleService = {
  // Obtener todos los roles
  async getRoles(): Promise<ApiResponse<any[]>> {
    return apiRequest<any[]>('/roles')
  },

  // Obtener rol por ID
  async getRoleById(id: number): Promise<ApiResponse<any>> {
    return apiRequest<any>(`/roles/${id}`)
  },

  // Obtener privilegios de un rol
  async getRolePrivileges(roleId: number): Promise<ApiResponse<any[]>> {
    return apiRequest<any[]>(`/roles/${roleId}/privileges`)
  },

  // Crear nuevo rol
  async createRole(roleData: any): Promise<ApiResponse<any>> {
    return apiRequest<any>('/roles', {
      method: 'POST',
      body: JSON.stringify(roleData),
    })
  },

  // Actualizar rol
  async updateRole(id: number, roleData: any): Promise<ApiResponse<any>> {
    return apiRequest<any>(`/roles/${id}`, {
      method: 'PUT',
      body: JSON.stringify(roleData),
    })
  },

  // Eliminar rol
  async deleteRole(id: number): Promise<ApiResponse<void>> {
    return apiRequest<void>(`/roles/${id}`, {
      method: 'DELETE',
    })
  },
}

// Servicios de privilegios
export const privilegeService = {
  // Obtener todos los privilegios
  async getPrivileges(): Promise<ApiResponse<any[]>> {
    return apiRequest<any[]>('/privileges')
  },

  // Asignar privilegio a rol
  async assignPrivilegeToRole(roleId: number, privilegeId: number): Promise<ApiResponse<void>> {
    return apiRequest<void>(`/roles/${roleId}/privileges`, {
      method: 'POST',
      body: JSON.stringify({ privilegeId }),
    })
  },

  // Remover privilegio de rol
  async removePrivilegeFromRole(roleId: number, privilegeId: number): Promise<ApiResponse<void>> {
    return apiRequest<void>(`/roles/${roleId}/privileges/${privilegeId}`, {
      method: 'DELETE',
    })
  },

  // Actualizar los privilegios de un usuario
  async updateUserPrivileges(userId: number, privileges: string[]): Promise<ApiResponse<void>> {
    return apiRequest<void>(`/users/${userId}/privileges`, {
      method: 'PUT',
      body: JSON.stringify({ privileges }),
    });
  }
}

// Función helper para manejar errores de autenticación
export const handleAuthError = (error: any) => {
  if (error?.message?.includes('401') || error?.message?.includes('token')) {
    localStorage.removeItem('acaucab_token')
    localStorage.removeItem('acaucab_user')
    window.location.href = '/login'
  }
  throw error
} 