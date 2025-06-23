import type { Lugar } from './'; // Import ILugar
import type { CervPres } from './'; // Import ICervPres

/**
 * @interface Tienda
 * @description Interfaz para la tabla 'Tienda'.
 * Almacena información de las tiendas físicas.
 */
export interface Tienda {
  cod_tien: number;
  nombre_tien: string;
  fecha_apertura_tien?: string | null; // date
  direccion_tien: string; // text
  fk_luga: number; // Foreign Key to Lugar
}

/**
 * @interface Departamento
 * @description Interfaz para la tabla 'Departamento'.
 * Representa departamentos dentro de una tienda.
 */
export interface Departamento {
  cod_depa: number;
  fk_tien: number; // Foreign Key to Tienda (part of composite PK)
}

/**
 * @interface LugarTienda
 * @description Interfaz para la tabla 'Lugar_Tienda'.
 * Define las ubicaciones específicas dentro de una tienda.
 */
export interface LugarTienda {
  cod_luga_tien: number;
  nombre_luga_tien: string;
  tipo_luga_tien: 'Almacen' | 'Pasillo' | 'Anaquel';
  fk_luga_tien?: number | null; // Self-referencing FK
}

/**
 * @interface InventarioTienda
 * @description Interfaz para la tabla 'Inventario_Tienda'.
 * Representa el inventario de cervezas en una tienda específica.
 */
export interface InventarioTienda {
  fk_cerv_pres_1: number; // Part of composite FK to CERV_PRES (fk_cerv)
  fk_cerv_pres_2: number; // Part of composite FK to CERV_PRES (fk_pres)
  fk_tien: number; // Foreign Key to Tienda
  fk_luga_tien: number; // Foreign Key to LugarTienda
  cant_pres: number; // integer
  precio_actual_pres: number; // numeric(8, 2)
}
