import type { Usuario, Rol } from '../interfaces/auth'
import type { 
  ProductoInventario, 
  ClienteDetallado, 
  TasaVenta, 
  MetodoPagoCompleto, 
  VentaCompleta 
} from '../interfaces/ventas'
import type { Lugar, Banco } from '../interfaces/common'

// Configuración base de la API
const API_URL = 'http://127.0.0.1:3000' // URL Base para todos los endpoints
const API_BASE_URL = `${API_URL}/api` // URL para los endpoints bajo /api

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
  },

  // Guardar privilegios de un rol (PUT)
  async saveRolePrivileges(payload: { cod_rol: number, priv_agre: number[], priv_elim: number[] }): Promise<ApiResponse<void>> {
    return apiRequest<void>(
      '/gestion_privilegios',
      {
        method: 'PUT',
        body: JSON.stringify(payload),
      }
    )
  },
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

// ===== SERVICIOS GENÉRICOS =====

/**
 * Obtiene todos los datos de una tabla específica usando el endpoint /quick/:table
 * @param tableName El nombre de la tabla a consultar
 */
export const getTableData = async (tableName: string): Promise<any[]> => {
  try {
    const response = await fetch(`${API_URL}/quick/${tableName}`);
    if (!response.ok) {
      throw new Error(`Error al obtener datos de la tabla ${tableName}`);
    }
    return await response.json();
  } catch (error) {
    console.error(`Error fetching table ${tableName}:`, error);
    return [];
  }
};

// ===== SERVICIOS PARA EL MÓDULO DE VENTAS =====

/**
 * Obtiene todos los productos del inventario para el punto de venta
 */
export const getProductosInventario = async (): Promise<ProductoInventario[]> => {
  try {
    const response = await fetch(`${API_BASE_URL}/inventory`);
    if (!response.ok) {
      throw new Error('Error al obtener productos del inventario');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching productos inventario:', error);
    // Datos de ejemplo para desarrollo
    return [
      {
        fk_cerv_pres_1: 1,
        fk_cerv_pres_2: 1,
        fk_tien: 1,
        fk_luga_tien: 1,
        nombre_cerv: "IPA Artesanal",
        nombre_pres: "Botella 330ml",
        capacidad_pres: 330,
        tipo_cerveza: "IPA",
        miembro_proveedor: "Cervecería Tovar",
        cant_pres: 100,
        precio_actual_pres: 5.50,
        lugar_tienda: "Estante A1",
        estado: "Disponible"
      },
      {
        fk_cerv_pres_1: 2,
        fk_cerv_pres_2: 2,
        fk_tien: 1,
        fk_luga_tien: 2,
        nombre_cerv: "Stout Imperial",
        nombre_pres: "Lata 473ml",
        capacidad_pres: 473,
        tipo_cerveza: "Stout",
        miembro_proveedor: "Cervecería Destilo",
        cant_pres: 15,
        precio_actual_pres: 6.00,
        lugar_tienda: "Nevera Principal",
        estado: "Bajo Stock"
      },
      {
        fk_cerv_pres_1: 3,
        fk_cerv_pres_2: 3,
        fk_tien: 1,
        fk_luga_tien: 3,
        nombre_cerv: "Lager Premium",
        nombre_pres: "Barril 5L",
        capacidad_pres: 5000,
        tipo_cerveza: "Lager",
        miembro_proveedor: "Cervecería Regional",
        cant_pres: 0,
        precio_actual_pres: 45.00,
        lugar_tienda: "Almacén Frío",
        estado: "Agotado"
      }
    ];
  }
};

/**
 * Obtiene todos los clientes con información detallada
 */
export const getClientesDetallados = async (): Promise<ClienteDetallado[]> => {
  try {
    const response = await fetch(`${API_BASE_URL}/clientes`);
    if (!response.ok) {
      throw new Error('Error al obtener clientes');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching clientes:', error);
    // Datos de ejemplo para desarrollo
    return [
      {
        rif_clie: "12345678",
        tipo_clie: "Natural",
        primer_nom_natu: "Juan",
        primer_ape_natu: "Pérez",
        direccion_fiscal_clie: "Caracas, Venezuela",
        direccion_fisica_clie: "Caracas, Venezuela",
        fk_luga_1: 1,
        fk_luga_2: 1,
        fecha_ingr_clie: "2024-01-15",
        telefonos: ["+58-212-555-0123"],
        correos: ["juan.perez@email.com"],
        puntos_acumulados: 150
      },
      {
        rif_clie: "87654321",
        tipo_clie: "Juridico",
        razon_social_juri: "Restaurante El Parador C.A.",
        denom_comercial_juri: "El Parador",
        capital_juri: 50000,
        direccion_fiscal_clie: "Valencia, Venezuela",
        direccion_fisica_clie: "Valencia, Venezuela",
        fk_luga_1: 2,
        fk_luga_2: 2,
        fecha_ingr_clie: "2024-02-20",
        telefonos: ["+58-241-555-0456"],
        correos: ["contacto@elparador.com"],
        puntos_acumulados: 500
      }
    ];
  }
};

/**
 * Obtiene la tasa de cambio actual
 */
export const getTasaActual = async (): Promise<TasaVenta[]> => {
  try {
    const response = await fetch(`${API_BASE_URL}/tasa`);
    if (!response.ok) {
      throw new Error('Error al obtener tasa actual');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching tasa actual:', error);
    // Tasa de ejemplo para desarrollo
    return [{
      cod_tasa: 1,
      tasa_dolar_bcv: 35.50,
      tasa_punto: 35.50,
      fecha_ini_tasa: new Date().toISOString().split('T')[0],
      fecha_fin_tasa: undefined
    }];
  }
};

/**
 * Obtiene los bancos disponibles
 */
export const getBancos = async (): Promise<Banco[]> => {
  try {
    const response = await fetch(`${API_BASE_URL}/bancos`);
    if (!response.ok) {
      throw new Error('Error al obtener bancos');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching bancos:', error);
    // Bancos de ejemplo para desarrollo
    return [
      { cod_banc: 1, nombre_banc: "Banco de Venezuela" },
      { cod_banc: 2, nombre_banc: "Bancamiga" },
      { cod_banc: 3, nombre_banc: "Banesco" },
      { cod_banc: 4, nombre_banc: "Banco Mercantil" },
      { cod_banc: 5, nombre_banc: "Banco Nacional de Crédito (BNC)" },
      { cod_banc: 6, nombre_banc: "Banco del Tesoro" },
      { cod_banc: 7, nombre_banc: "Banco Exterior" },
      { cod_banc: 8, nombre_banc: "Banco Provincial" },
      { cod_banc: 9, nombre_banc: "Banco Caroní" },
      { cod_banc: 10, nombre_banc: "Banco Sofitasa" },
      { cod_banc: 11, nombre_banc: "Banca Amiga" },
      { cod_banc: 12, nombre_banc: "Banco Agrícola de Venezuela" },
      { cod_banc: 13, nombre_banc: "Banco Bicentenario" },
      { cod_banc: 14, nombre_banc: "Banco del Caribe" }
    ];
  }
};

/**
 * Obtiene los métodos de pago disponibles
 */
export const getMetodosPago = async (): Promise<MetodoPagoCompleto[]> => {
  try {
    const response = await fetch(`${API_BASE_URL}/metodos_pago`);
    if (!response.ok) {
      throw new Error('Error al obtener métodos de pago');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching métodos de pago:', error);
    // Métodos de pago de ejemplo para desarrollo
    return [
      {
        cod_meto_pago: 1,
        tipo: "Efectivo",
        denominacion_efec: "USD"
      },
      {
        cod_meto_pago: 2,
        tipo: "Tarjeta",
        credito: true
      },
      {
        cod_meto_pago: 3,
        tipo: "Punto_Canjeo"
      },
      {
        cod_meto_pago: 4,
        tipo: "Cheque"
      }
    ];
  }
};

/**
 * Procesa una venta completa
 */
export const procesarVenta = async (venta: VentaCompleta): Promise<{ success: boolean; cod_vent?: number; message?: string }> => {
  try {
    // Lógica para enviar la venta al backend
    // Aquí es donde realizarías la petición POST al endpoint /venta
    // Ejemplo usando fetch:
    console.log("Enviando venta al backend:", venta);


    const response = await fetch(`${API_BASE_URL}/venta`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(venta),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.message || 'Error al procesar la venta');
    }

    const result = await response.json();
    return { success: true, cod_vent: result.cod_vent };
  } catch (error) {
    console.error('Error processing venta:', error);
    return { 
      success: false, 
      message: error instanceof Error ? error.message : 'Error desconocido al procesar la venta' 
    };
  }
};

/**
 * Actualiza el stock de un producto después de una venta
 */
export const actualizarStockProducto = async (
  fk_cerv_pres_1: number,
  fk_cerv_pres_2: number,
  fk_tien: number,
  fk_luga_tien: number,
  cantidad_vendida: number
): Promise<boolean> => {
  try {
    const response = await fetch(`${API_BASE_URL}/inventario/actualizar-stock`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        fk_cerv_pres_1,
        fk_cerv_pres_2,
        fk_tien,
        fk_luga_tien,
        cantidad_vendida
      }),
    });

    return response.ok;
  } catch (error) {
    console.error('Error updating stock:', error);
    return false;
  }
};

/**
 * Actualiza los datos de un usuario (nombre o rol).
 * @param userData Un objeto que debe contener cod_usua y puede contener username_usua y/o fk_rol.
 */
export const updateUser = async (userData: { cod_usua: number; username_usua?: string; fk_rol?: number }): Promise<boolean> => {
  try {
    const response = await fetch(`${API_BASE_URL}/user`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    });
    if (!response.ok) {
      throw new Error('Error al actualizar el usuario');
    }
    return true;
  } catch (error) {
    console.error('Error updating user:', error);
    return false;
  }
};

// ===== SERVICIOS DE UBICACIÓN =====

/**
 * Obtiene todas las parroquias y estados desde el endpoint /api/parroquias
 */
export const getParroquias = async (): Promise<Lugar[]> => {
  try {
    const response = await fetch(`${API_BASE_URL}/parroquias`);
    if (!response.ok) {
      throw new Error('Error al obtener parroquias');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching parroquias:', error);
    return [];
  }
};

/**
 * Registra un cliente natural
 */
export const registrarClienteNatural = async (cliente: any): Promise<ApiResponse<any>> => {
  return apiRequest<any>('/natural', {
    method: 'POST',
    body: JSON.stringify(cliente),
  });
};

/**
 * Registra un cliente jurídico
 */
export const registrarClienteJuridico = async (cliente: any): Promise<ApiResponse<any>> => {
  return apiRequest<any>('/juridico', {
    method: 'POST',
    body: JSON.stringify(cliente),
  });
};

/**
 * Actualiza la cantidad de un producto en el inventario
 */
export const updateInventarioItem = async (item: {
  fk_cerv_pres_1: number,
  fk_cerv_pres_2: number,
  fk_tien: number,
  fk_luga_tien: number,
  cant_pres: number
}): Promise<ApiResponse<any>> => {
  return apiRequest<any>('/inventory', {
    method: 'PUT',
    body: JSON.stringify(item),
  });
};

/**
 * Crea un usuario cliente (jurídico o natural)
 */
export const createUsuarioCliente = async (data: {
  username_usua: string,
  contra_usua: string,
  fk_clie: string,
  tipo_clie: string
}): Promise<ApiResponse<any>> => {
  return apiRequest<any>('/user', {
    method: 'POST',
    body: JSON.stringify(data),
  });
};

// Obtener todas las compras
export const getCompras = async (): Promise<any[]> => {
  try {
    const token = localStorage.getItem('acaucab_token');
    const response = await fetch('http://127.0.0.1:3000/api/compra', {
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
      },
    });
    const data = await response.json();
    if (Array.isArray(data)) return data;
    if (data && Array.isArray(data.data)) return data.data;
    return [];
  } catch (e) {
    return [];
  }
};

export const setCompraPagada = async (fk_comp: number): Promise<boolean> => {
  try {
    const token = localStorage.getItem('acaucab_token');
    const response = await fetch('http://127.0.0.1:3000/api/set_compra_pagada', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
      },
      body: JSON.stringify({ fk_comp }),
    });
    return response.ok;
  } catch (e) {
    return false;
  }
};

// ===== SERVICIOS DE CARRITO =====

/**
 * Guarda el carrito del usuario
 */
export const saveCarrito = async (carrito: any): Promise<{ success: boolean; id?: number; message?: string }> => {
  try {
    const response = await fetch(`${API_BASE_URL}/carrito`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(carrito),
    });
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.message || 'Error al guardar el carrito');
    }
    const result = await response.json();
    return { success: true, id: result.id };
  } catch (error) {
    console.error('Error saving carrito:', error);
    return { success: false, message: error instanceof Error ? error.message : 'Error desconocido al guardar el carrito' };
  }
};

/**
 * Obtiene el carrito del usuario actual
 */
export const getCarritoUsuario = async (usuario: string): Promise<any> => {
  try {
    const response = await fetch(`${API_BASE_URL}/carrito`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ usuario }),
    });
    if (!response.ok) {
      throw new Error('Error al obtener el carrito');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching carrito:', error);
    return null;
  }
}; 