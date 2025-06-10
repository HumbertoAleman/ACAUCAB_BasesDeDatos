/**
 * @interface Lugar
 * @description Interfaz para la tabla 'Lugar'.
 * Representa una ubicación geográfica jerárquica (Estado, Municipio, Parroquia).
 */
export interface Lugar {
  cod_luga: number;
  nombre_luga: string;
  tipo_luga: "Estado" | "Municipio" | "Parroquia"; // CHECK constraint
  fk_luga?: number | null; // Self-referencing FK to parent Lugar
}

/**
 * @interface Tasa
 * @description Interfaz para la tabla 'Tasa'.
 * Registra tasas de cambio de divisas.
 */
export interface Tasa {
  cod_tasa: number;
  tasa_dolar_bcv: number; // numeric(8, 2)
  tasa_punto: number; // numeric(8, 2)
  fecha_ini_tasa: string; // date
  fecha_fin_tasa?: string | null; // date
}

/**
 * @interface Estatus
 * @description Interfaz para la tabla 'Estatus'.
 * Define diferentes estados para transacciones, eventos, etc.
 */
export interface Estatus {
  cod_esta: number;
  nombre_esta: string;
  descripcion_esta?: string | null;
}

/**
 * @interface Telefono
 * @description Interfaz para la tabla 'Telefono'.
 * Almacena números de teléfono y los asocia a Clientes, Contactos o Miembros.
 */
export interface Telefono {
  cod_tele: number;
  cod_area_tele: number;
  num_tele: number;
  fk_clie?: number | null; // Arc to Cliente
  fk_pers?: number | null; // Arc to Contacto
  fk_miem?: string | null; // Arc to Miembro
}

/**
 * @interface Correo
 * @description Interfaz para la tabla 'Correo'.
 * Almacena direcciones de correo electrónico y las asocia a Clientes, Empleados, Contactos o Miembros.
 */
export interface Correo {
  cod_corr: number;
  prefijo_corr: string;
  dominio_corr: string;
  fk_clie?: number | null; // Arc to Cliente
  fk_empl?: number | null; // Arc to Empleado
  fk_pers?: number | null; // Arc to Contacto
  fk_miem?: string | null; // Arc to Miembro
}
