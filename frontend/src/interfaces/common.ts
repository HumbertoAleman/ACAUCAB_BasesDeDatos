/**
 * @interface Lugar
 * @description Interfaz para la tabla 'Lugar'.
 * Define ubicaciones geográficas jerárquicas.
 */
export interface Lugar {
  cod_luga: number;
  nombre_luga: string;
  tipo_luga: 'Estado' | 'Municipio' | 'Parroquia';
  fk_luga?: number | null; // Self-referencing FK for hierarchy
}

/**
 * @interface Tasa
 * @description Interfaz para la tabla 'Tasa'.
 * Almacena las tasas de cambio.
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
 * Define los diferentes estados de las entidades.
 */
export interface Estatus {
  cod_esta: number;
  nombre_esta: string;
  descripcion_esta?: string | null; // text
}

/**
 * @interface Banco
 * @description Interfaz para la tabla 'Banco'.
 * Almacena información de bancos.
 */
export interface Banco {
  cod_banc: number;
  nombre_banc: string;
}

/**
 * @interface Cuota
 * @description Interfaz para la tabla 'Cuota'.
 * Define planes de pago o cuotas.
 */
export interface Cuota {
  cod_cuot: number;
  nombre_plan_cuot: string;
  precio_cuot: number; // numeric(8, 2)
}

/**
 * @interface Juez
 * @description Interfaz para la tabla 'Juez'.
 * Almacena información de los jueces.
 */
export interface Juez {
  cod_juez: number;
  primar_nom_juez: string;
  segundo_nom_juez?: string | null;
  primar_ape_juez: string;
  segundo_ape_juez?: string | null;
  ci_juez: number; // integer
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
