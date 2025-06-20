import type { ApiResponse, LoginResponse } from './api';

const API_BASE_URL = 'http://localhost:3000/api' // Esto depende de la configuración del backend porfa cambialo

/**
 * ! ESTE ARCHIVO ES UN EJEMPLO QUE NO DEBE USARSE EN PRODUCCIÓN HASTA QUE LOS ENDPOINTS ESTÉN IMPLEMENTADOS
 */

/**
 * Ejemplo de la estructura que debería tener un usuario cuando se obtiene
 * desde el endpoint GET /api/users_with_details.
 * 
 * Incluye el objeto 'rol' anidado, y dentro de 'rol', la lista
 * de 'privilegios'.
 */
interface UserWithDetails {
  cod_usua: number;
  username_usua: string;
  fk_rol: number;
  rol: {
    cod_rol: number;
    nombre_rol: string;
    descripcion_rol: string;
    privilegios: Array<{
      cod_priv: number;
      nombre_priv: string;
      descripcion_priv: string;
    }>;
  };
}

// Función helper para hacer peticiones HTTP (copiada de api.ts)
async function apiRequestExample<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        headers: { 'Content-Type': 'application/json', ...options.headers },
        ...options
    });

    if (endpoint === '/hello') {
        // Simulación para el ejemplo específico que pediste
        console.log('Request a /hello:', { hola: 'mundo' });
        const mockResponse = { adios: 'mundo' };
        console.log('Response de /hello:', mockResponse);
        return { success: true, data: mockResponse as T };
    }

    if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || `Error ${response.status}`);
    }
    return response.json();
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Error desconocido';
    console.error('API Error:', message);
    return { success: false, error: message };
  }
}

/**
 * Este es un servicio de EJEMPLO que consume el endpoint ideal
 * para obtener usuarios con sus roles y privilegios en una sola llamada.
 */
export const exampleUserService = {
  /**
   * Obtiene todos los usuarios con su información de rol y privilegios anidada.
   * Backend debe implementar: GET /api/users_with_details
   */
  async getUsersWithDetails(): Promise<ApiResponse<UserWithDetails[]>> {
    // Cuando el backend esté listo, esta será la llamada real
    // return apiRequestExample<UserWithDetails[]>('/users_with_details');

    // Por ahora, devolvemos datos de ejemplo para ilustrar la estructura
    console.log('Ejecutando servicio de ejemplo: getUsersWithDetails');
    return Promise.resolve({
        success: true,
        data: [
            {
                cod_usua: 1,
                username_usua: 'admin_ejemplo',
                fk_rol: 1,
                rol: {
                    cod_rol: 1,
                    nombre_rol: 'Administrador',
                    descripcion_rol: 'Rol con todos los permisos',
                    privilegios: [
                        { cod_priv: 1, nombre_priv: 'gestion_total', descripcion_priv: 'Todo el CRUD' }
                    ]
                }
            }
        ]
    });
  },

  /**
   * Ejemplo de una ruta simple que recibe y devuelve un objeto.
   * Backend debe implementar: POST /api/hello
   */
  async sayHello(): Promise<ApiResponse<{ adios: string }>> {
    return apiRequestExample<{ adios: string }>('/hello', {
        method: 'POST',
        body: JSON.stringify({ hola: 'mundo' })
    });
  }
};

// Para probarlo, avisame para poner esto en algun componente:
/*
useEffect(() => {
  const testApi = async () => {
    console.log('--- Probando API de ejemplo ---');
    
    const usersResponse = await exampleUserService.getUsersWithDetails();
    console.log('Respuesta de usuarios con detalles (ejemplo):', usersResponse.data);

    const helloResponse = await exampleUserService.sayHello();
    console.log('Respuesta de /hello (ejemplo):', helloResponse.data);

    console.log('--- Fin de la prueba de API de ejemplo ---');
  };
  testApi();
}, []);
*/ 