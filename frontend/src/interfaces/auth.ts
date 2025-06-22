/**
 * @interface Rol
 * @description Interfaz para la tabla 'Rol'.
 * Define los roles de usuario en el sistema.
 */
export interface Rol {
  cod_rol: number;
  nombre_rol: string;
  descripcion_rol: string; // text
}

/**
 * @interface Privilegio
 * @description Interfaz para la tabla 'Privilegio'.
 * Define los privilegios o permisos del sistema.
 */
export interface Privilegio {
  cod_priv: number;
  nombre_priv: string;
  descripcion_priv: string; // text
}

/**
 * @interface Usuario
 * @description Interfaz para la tabla 'Usuario'.
 * Almacena información de autenticación de usuarios.
 */
export interface Usuario {
  cod_usua: number;
  contra_usua: string; // text
  username_usua: string;
  fk_rol: number; // Foreign Key to Rol
  fk_empl?: number | null; // Arc to Empleado
  fk_miem?: string | null; // Arc to Miembro (cambiado de number a string)
  fk_clie?: string | null; // Arc to Cliente (cambiado de number a string)
  // Añadido para compatibilidad con backend users_with_details
  rol?: {
    cod_rol: number;
    nombre_rol: string;
    descripcion_rol: string;
    privileges?: Privilegio[];
  }
}

// Interfaces para tablas de relación Muchos a Muchos (M-M) en este dominio

/**
 * @interface PrivRol
 * @description Interfaz para la tabla 'PRIV_ROL'.
 * Relaciona roles con privilegios (Muchos a Muchos).
 */
export interface PrivRol {
  fk_rol: number; // Part of composite PK, FK to Rol
  fk_priv: number; // Part of composite PK, FK to Privilegio
}

export interface UsuarioFront {
  username: string;
  rol: string;
}

export interface RolFront {
  nombre: string;
}
