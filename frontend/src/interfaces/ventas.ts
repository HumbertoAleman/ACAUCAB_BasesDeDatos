import type { Lugar, Tasa, Estatus } from './'; // Import common interfaces
import type { CervPres } from './'; // Import ICervPres
import type { InventarioTienda } from './'; // Import InventarioTienda
import type { InventarioEvento } from './'; // Import InventarioEvento

/**
 * @interface Compra
 * @description Interfaz para la tabla 'Compra'.
 * Registra las transacciones de compra de productos.
 */
export interface Compra {
  cod_comp: number;
  fecha_comp: string; // date
  iva_comp: number; // numeric(8, 2)
  base_imponible_comp: number; // numeric(8, 2)
  total_comp: number; // numeric(8, 2)
  fk_tien?: number | null; // Foreign Key to Tienda
  fk_miem?: string | null; // Foreign Key to Miembro
}

/**
 * @interface DetalleCompra
 * @description Interfaz para la tabla 'Detalle_Compra'.
 * Detalla los ítems incluidos en una compra.
 */
export interface DetalleCompra {
  cod_deta_comp: number;
  cant_deta_comp: number; // integer
  precio_unitario_comp: number; // numeric(8, 2)
  fk_cerv_pres_1: number; // Part of composite FK to CERV_PRES (fk_cerv)
  fk_cerv_pres_2: number; // Part of composite FK to CERV_PRES (fk_pres)
  fk_comp: number; // Foreign Key to Compra
}

/**
 * @interface Cliente
 * @description Interfaz para la tabla 'Cliente'.
 * Almacena información de clientes naturales o jurídicos.
 */
export interface Cliente {
  rif_clie: number;
  direccion_fiscal_clie: string;
  direccion_fisica_clie: string;
  fk_luga_1: number; // Foreign Key to Lugar for fiscal address
  fk_luga_2: number; // Foreign Key to Lugar for physical address
  tipo_clie: 'Natural' | 'Juridico'; // CHECK constraint
  primer_nom_natu?: string | null;
  segundo_nom_natu?: string | null;
  primer_ape_natu?: string | null;
  segundo_ape_natu?: string | null;
  ci_natu?: number | null;
  razon_social_juri?: string | null;
  denom_comercial_juri?: string | null;
  capital_juri?: number | null; // numeric(8, 2)
  pag_web_juri?: string | null;
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
 * @interface IVenta
 * @description Interfaz para la tabla 'Venta'.
 * Registra las transacciones de venta.
 */
export interface Venta {
  cod_vent: number;
  fecha_vent: string; // date
  iva_vent: number; // numeric(8, 2)
  base_imponible_vent: number; // numeric(8, 2)
  total_vent: number; // numeric(8, 2)
  online?: boolean | null;
  fk_clie?: number | null; // Arc to Cliente
  fk_miem?: string | null; // Arc to Miembro
  fk_even?: number | null; // Arc to Evento
  fk_tien?: number | null; // Arc to Tienda
  fk_cuot?: number | null; // Arc to Cuota
}

/**
 * @interface IDetalleVenta
 * @description Interfaz para la tabla 'Detalle_Venta'.
 * Detalla los ítems incluidos en una venta.
 */
export interface DetalleVenta {
  cod_deta_vent: number;
  cant_deta_vent: number; // integer
  precio_unitario_vent: number; // numeric(8, 2)
  fk_vent: number; // Foreign Key to Venta
  fk_inve_tien_1?: number | null; // Part of composite FK to InventarioTienda (fk_cerv_pres_1)
  fk_inve_tien_2?: number | null; // Part of composite FK to InventarioTienda (fk_cerv_pres_2)
  fk_inve_tien_3?: number | null; // Part of composite FK to InventarioTienda (fk_tien)
  fk_inve_even_1?: number | null; // Part of composite FK to InventarioEvento (fk_cerv_pres_1)
  fk_inve_even_2?: number | null; // Part of composite FK to InventarioEvento (fk_cerv_pres_2)
  fk_inve_even_3?: number | null; // Part of composite FK to InventarioEvento (fk_even)
}

/**
 * @interface IMetodoPago
 * @description Interfaz para la tabla 'Metodo_Pago'.
 * Supertipo para los métodos de pago.
 */
export interface MetodoPago {
  cod_meto_pago: number;
}

/**
 * @interface ITarjeta
 * @description Interfaz para la tabla 'Tarjeta'.
 * Subtipo de MetodoPago para pagos con tarjeta.
 */
export interface Tarjeta {
  fk_meto_pago: number; // PK and FK to MetodoPago
  numero_tarj: number; // integer (consider storing as string for leading zeros or large numbers)
  fecha_venci_tarj: string; // date
  cvv_tarj: number; // integer (should not be stored in real apps)
  nombre_titu_tarj: string;
  credito?: boolean | null;
}

/**
 * @interface PuntoCanjeo
 * @description Interfaz para la tabla 'Punto_Canjeo'.
 * Subtipo de MetodoPago para canje de puntos.
 */
export interface PuntoCanjeo {
  fk_meto_pago: number; // PK and FK to MetodoPago
}

/**
 * @interface Cheque
 * @description Interfaz para la tabla 'Cheque'.
 * Subtipo de MetodoPago para pagos con cheque.
 */
export interface Cheque {
  fk_meto_pago: number; // PK and FK to MetodoPago
  numero_cheque: number; // integer
  numero_cuenta_cheque: number; // integer
  fk_banc: number; // Foreign Key to Banco (defined below)
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
 * @interface Efectivo
 * @description Interfaz para la tabla 'Efectivo'.
 * Subtipo de MetodoPago para pagos en efectivo.
 */
export interface Efectivo {
  fk_meto_pago: number; // PK and FK to MetodoPago
  denominacion_efec: string; // char
}

/**
 * @interface Pago
 * @description Interfaz para la tabla 'Pago'.
 * Registra los pagos de una venta.
 */
export interface Pago {
  fk_vent: number; // Part of composite PK, FK to Venta
  fk_meto_pago: number; // Part of composite PK, FK to MetodoPago
  monto_pago: number; // numeric(8, 2)
  fecha_pago: string; // date
  fk_tasa: number; // Foreign Key to Tasa
}

/**
 * @interface IDescuento
 * @description Interfaz para la tabla 'Descuento'.
 * Define los descuentos aplicables.
 */
export interface Descuento {
  cod_desc: number;
  descripcion_desc: string;
  fecha_ini_desc: string; // date
  fecha_fin_desc: string; // date
}

// Interfaces para estatus de compras y ventas
/**
 * @interface EstaComp
 * @description Interfaz para la tabla 'ESTA_COMP'.
 * Registra el historial de estatus de una compra.
 */
export interface EstaComp {
  cod_esta_comp: number;
  fk_esta: number; // Foreign Key to Estatus (part of composite PK)
  fk_comp: number; // Foreign Key to Compra (part of composite PK)
  fecha_ini: string; // date
  fecha_fin?: string | null; // date
}

/**
 * @interface EstaVent
 * @description Interfaz para la tabla 'ESTA_VENT'.
 * Registra el historial de estatus de una venta.
 */
export interface EstaVent {
  cod_esta_vent: number;
  fk_esta: number; // Foreign Key to Estatus (part of composite PK)
  fk_vent: number; // Foreign Key to Venta (part of composite PK)
  fecha_ini: string; // date
  fecha_fin?: string | null; // date
}

/**
 * @interface PuntClie
 * @description Interfaz para la tabla 'PUNT_CLIE'.
 * Registra las transacciones de puntos de lealtad de los clientes.
 */
export interface PuntClie {
  cod_punt_clie: number;
  fk_clie: number; // Part of composite PK, FK to Cliente
  fk_meto_pago: number; // Part of composite PK, FK to PuntoCanjeo
  fk_tasa: number; // Foreign Key to Tasa
  fk_vent: number; // Foreign Key to Venta (unique constraint in DB)
  cant_puntos_acum?: number | null; // numeric(10, 2)
  cant_puntos_canj?: number | null; // numeric(10, 2)
  fecha_transaccion: string; // date
  canjeado?: boolean | null;
}

// Interfaces para relaciones M-M de descuento
/**
 * @interface DescCerv
 * @description Interfaz para la tabla 'DESC_CERV'.
 * Relaciona descuentos con presentaciones de cerveza.
 */
export interface DescCerv {
  fk_desc: number; // Foreign Key to Descuento (part of composite PK)
  fk_cerv_pres_1: number; // Part of composite FK to CERV_PRES (fk_cerv)
  fk_cerv_pres_2: number; // Part of composite FK to CERV_PRES (fk_pres)
  porcentaje_desc: number; // numeric(3, 2)
}