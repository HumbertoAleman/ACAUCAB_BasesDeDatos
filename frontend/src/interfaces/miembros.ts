import type { Lugar } from './'; // Import ILugar as it's a FK

/**
 * @interface IMiembro
 * @description Interfaz para la tabla 'Miembro'.
 * Representa a los miembros de la asociación o socios comerciales.
 */
export interface Miembro {
  rif_miem: string;
  razon_social_miem: string;
  denom_comercial_miem: string;
  direccion_fiscal_miem: string;
  direccion_fisica_miem: string;
  pag_web_miem?: string | null;
  fk_luga_1: number; // Foreign Key to Lugar for primary fiscal address
  fk_luga_2: number; // Foreign Key to Lugar for primary physical address
}

/**
 * @interface IContacto
 * @description Interfaz para la tabla 'Contacto'.
 * Representa a las personas de contacto asociadas a los miembros.
 */
export interface Contacto {
  cod_pers: number;
  primer_nom_pers: string;
  segundo_nom_pers?: string | null;
  primer_ape_pers: string;
  segundo_ape_pers?: string | null;
  fk_miem?: string | null; // Foreign Key to Miembro
}