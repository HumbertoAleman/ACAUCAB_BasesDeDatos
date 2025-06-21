/**
 * @interface Rol
 * @description Interfaz para la tabla 'Rol'.
 * Define los roles de usuario en el sistema.
 */
export interface Rol {
  cod_rol: number;
  nombre_rol: string;
  descripcion_rol: string;
  privileges: Privilegio[];
}

/**
 * @interface Privilegio
 * @description Interfaz para la tabla 'Privilegio'.
 * Define los privilegios específicos dentro del sistema.
 */
export interface Privilegio {
  cod_priv: number;
  nombre_priv: string;
  descripcion_priv: string;
}

/**
 * @interface Usuario
 * @description Interfaz para la tabla 'Usuario'.
 * Almacena las credenciales de los usuarios y su asociación a una entidad.
 */
export interface Usuario {
  cod_usua: number;
  contra_usua?: string; // Password (optional for security - not sent from backend)
  username_usua: string;
  fk_rol: number; // Foreign Key to Rol
  fk_empl?: number | null; // Arc to Empleado
  fk_miem?: string | null; // Arc to Miembro
  fk_clie?: string | null; // Arc to Cliente (changed to string to match DB)
  rol: Rol;
}

// Interfaces para tablas de relación Muchos a Muchos (M-M) en este dominio

/**
 * @interface PrivRol
 * @description Interfaz para la tabla 'PRIV_ROL'.
 * Asigna privilegios a roles.
 */
export interface PrivRol {
  fk_rol: number;
  fk_priv: number;
}

export interface UsuarioFront {
  username: string;
  rol: string;
}

export interface RolFront {
  nombre: string;
}
