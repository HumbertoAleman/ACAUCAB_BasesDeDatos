import type { Lugar } from './'; // Import ILugar as it's a FK

/**
 * @interface Miembro
 * @description Interfaz para la tabla 'Miembro'.
 * Almacena información de los miembros de la asociación.
 */
export interface Miembro {
  rif_miem: string; // varchar(20) - Cambiado de number a string
  razon_social_miem: string;
  denom_comercial_miem: string;
  direccion_fiscal_miem: string; // text
  pag_web_miem?: string | null; // text
  fk_luga_1: number; // Foreign Key to Lugar
  fk_luga_2?: number | null; // Foreign Key to Lugar
}

/**
 * @interface Contacto
 * @description Interfaz para la tabla 'Contacto'.
 * Almacena información de contacto de los miembros.
 */
export interface Contacto {
  cod_pers: number;
  primer_nom_pers: string;
  segundo_nom_pers?: string | null;
  primer_ape_pers: string;
  segundo_ape_pers?: string | null;
  fk_miem?: string | null; // Foreign Key to Miembro (cambiado de number a string)
}
