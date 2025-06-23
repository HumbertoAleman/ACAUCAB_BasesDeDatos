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
  rif_clie: string; // varchar(20) - Cambiado de number a string
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
  fecha_ingr_clie?: string; // date DEFAULT CURRENT_DATE
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
 * @interface Venta
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
  fk_clie?: string | null; // Arc to Cliente (cambiado de number a string)
  fk_miem?: string | null; // Arc to Miembro
  fk_even?: number | null; // Arc to Evento
  fk_tien?: number | null; // Arc to Tienda
  fk_cuot?: number | null; // Arc to Cuota
}

/**
 * @interface DetalleVenta
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
  fk_inve_tien_4?: number | null; // Part of composite FK to InventarioTienda (fk_luga_tien)
  fk_inve_even_1?: number | null; // Part of composite FK to InventarioEvento (fk_cerv_pres_1)
  fk_inve_even_2?: number | null; // Part of composite FK to InventarioEvento (fk_cerv_pres_2)
  fk_inve_even_3?: number | null; // Part of composite FK to InventarioEvento (fk_even)
}

/**
 * @interface MetodoPago
 * @description Interfaz para la tabla 'Metodo_Pago'.
 * Supertipo para los métodos de pago.
 */
export interface MetodoPago {
  cod_meto_pago: number;
}

/**
 * @interface Tarjeta
 * @description Interfaz para la tabla 'Tarjeta'.
 * Subtipo de MetodoPago para pagos con tarjeta.
 */
export interface Tarjeta {
  fk_meto_pago: number; // PK and FK to MetodoPago
  numero_tarj: number; // numeric(21, 0)
  fecha_venci_tarj: string; // date
  cvv_tarj: number; // integer
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
  numero_cheque: number; // numeric(21, 0)
  numero_cuenta_cheque: number; // numeric(21, 0)
  fk_banc: number; // Foreign Key to Banco
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
  denominacion_efec: string; // varchar(10)
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
 * @interface Descuento
 * @description Interfaz para la tabla 'Descuento'.
 * Define los descuentos aplicables.
 */
export interface Descuento {
  cod_desc: number;
  descripcion_desc: string;
  fecha_ini_desc: string; // date
  fecha_fin_desc: string; // date
}

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
 * @interface EstaEven
 * @description Interfaz para la tabla 'ESTA_EVEN'.
 * Registra el historial de estatus de un evento.
 */
export interface EstaEven {
  cod_esta_even: number;
  fk_esta: number; // Foreign Key to Estatus (part of composite PK)
  fk_even: number; // Foreign Key to Evento (part of composite PK)
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
 * Registra los puntos de los clientes.
 */
export interface PuntClie {
  cod_punt_clie: number;
  fk_clie: string; // Part of composite PK, FK to Cliente (cambiado de number a string)
  fk_meto_pago?: number | null; // FK to PuntoCanjeo
  fk_tasa: number; // Foreign Key to Tasa
  fk_vent: number; // Foreign Key to Venta (unique constraint in DB)
  cant_puntos_acum?: number | null; // numeric(10, 2)
  cant_puntos_canj?: number | null; // numeric(10, 2)
  fecha_transaccion: string; // date
}

/**
 * @interface DescCerv
 * @description Interfaz para la tabla 'DESC_CERV'.
 * Relaciona descuentos con cervezas y presentaciones.
 */
export interface DescCerv {
  fk_desc: number; // Foreign Key to Descuento (part of composite PK)
  fk_cerv_pres_1: number; // Part of composite FK to CERV_PRES (fk_cerv)
  fk_cerv_pres_2: number; // Part of composite FK to CERV_PRES (fk_pres)
  porcentaje_desc: number; // numeric(5, 2)
}

// ===== INTERFACES ESPECÍFICAS PARA EL FRONTEND =====

/**
 * @interface ProductoInventario
 * @description Interfaz para productos del inventario que se muestran en el punto de venta
 * Basada en JOIN de Inventario_Tienda, CERV_PRES, Cerveza, Presentacion, Tipo_Cerveza, Miembro, Lugar_Tienda
 */
export interface ProductoInventario {
  // IDs de la base de datos (Inventario_Tienda)
  fk_cerv_pres_1: number; // ID de la cerveza
  fk_cerv_pres_2: number; // ID de la presentación
  fk_tien: number; // ID de la tienda
  fk_luga_tien: number; // ID del lugar en la tienda
  
  // Información del producto (JOIN con Cerveza, Presentacion, Tipo_Cerveza)
  nombre_cerv: string;
  nombre_pres: string;
  capacidad_pres: number;
  tipo_cerveza: string;
  
  // Información del proveedor (JOIN con Miembro)
  miembro_proveedor: string;
  
  // Información de inventario (Inventario_Tienda)
  cant_pres: number; // Stock disponible
  precio_actual_pres: number; // Precio en USD
  
  // Información de ubicación (JOIN con Lugar_Tienda)
  lugar_tienda: string;
  
  // Estado calculado
  estado: "Disponible" | "Bajo Stock" | "Agotado";
}

/**
 * @interface ClienteDetallado
 * @description Interfaz para clientes con información completa incluyendo contactos y puntos
 * Basada en JOIN de Cliente, Telefono, Correo, PUNT_CLIE
 */
export interface ClienteDetallado {
  // Campos de Cliente
  rif_clie: string;
  tipo_clie: "Natural" | "Juridico";
  
  // Campos para persona natural
  primer_nom_natu?: string;
  segundo_nom_natu?: string;
  primer_ape_natu?: string;
  segundo_ape_natu?: string;
  ci_natu?: number;
  
  // Campos para persona jurídica
  razon_social_juri?: string;
  denom_comercial_juri?: string;
  capital_juri?: number;
  pag_web_juri?: string;
  
  // Campos comunes
  direccion_fiscal_clie: string;
  direccion_fisica_clie: string;
  fk_luga_1: number;
  fk_luga_2: number;
  fecha_ingr_clie: string;
  
  // Información de contacto (JOIN con Telefono, Correo)
  telefonos?: string[];
  correos?: string[];
  
  // Puntos acumulados (JOIN con PUNT_CLIE)
  puntos_acumulados?: number;

  // Nombre a mostrar (agregado por el frontend)
  display_name?: string;
}

/**
 * @interface TasaVenta
 * @description Interfaz para las tasas de cambio
 * Basada en la tabla Tasa
 */
export interface TasaVenta {
  cod_tasa: number;
  tasa_dolar_bcv: number; // numeric(8, 2) - Tasa del BCV
  tasa_punto: number; // numeric(8, 2) - Tasa del punto
  fecha_ini_tasa: string; // date
  fecha_fin_tasa?: string; // date
}

/**
 * @interface MetodoPagoCompleto
 * @description Interfaz para métodos de pago con información específica
 * Basada en Metodo_Pago + subtipos (Tarjeta, Cheque, Efectivo, Punto_Canjeo)
 */
export interface MetodoPagoCompleto {
  cod_meto_pago: number;
  tipo: "Efectivo" | "Tarjeta" | "Punto_Canjeo" | "Cheque";
  
  // Campos específicos para tarjeta
  numero_tarj?: number;
  fecha_venci_tarj?: string;
  cvv_tarj?: number;
  nombre_titu_tarj?: string;
  credito?: boolean;
  
  // Campos específicos para cheque
  numero_cheque?: number;
  numero_cuenta_cheque?: number;
  fk_banc?: number;
  nombre_banco?: string; // JOIN con Banco
  
  // Campos específicos para efectivo
  denominacion_efec?: string;
}

/**
 * @interface ItemVenta
 * @description Interfaz para items en el carrito de venta
 */
export interface ItemVenta {
  producto: ProductoInventario;
  cantidad: number;
  precio_unitario: number;
  subtotal: number;
}

/**
 * @interface PagoVenta
 * @description Interfaz para pagos múltiples en una venta
 * Basada en la tabla Pago
 */
export interface PagoVenta {
  metodo_pago: MetodoPagoCompleto;
  monto: number;
  fecha_pago: string;
  fk_tasa: number;
}

/**
 * @interface VentaCompleta
 * @description Interfaz para una venta completa
 * Basada en Venta + Detalle_Venta + Pago
 */
export interface VentaCompleta {
  cod_vent?: number;
  fecha_vent: string;
  iva_vent: number;
  base_imponible_vent: number;
  total_vent: number;
  online: boolean;
  
  // Cliente o Miembro
  fk_clie?: string;
  fk_miem?: string;
  
  // Ubicación de la venta
  fk_tien?: number;
  fk_even?: number;
  fk_cuot?: number;
  
  // Items de la venta
  items: ItemVenta[];
  
  // Pagos múltiples
  pagos: PagoVenta[];
  
  // Información adicional
  tasa_dia?: TasaVenta;
  puntos_generados?: number;
  total_usd?: number;
  total_bs?: number;
}

/**
 * @interface ResumenVenta
 * @description Interfaz para el resumen de la venta en el carrito
 */
export interface ResumenVenta {
  subtotal: number;
  iva: number;
  total: number;
  total_usd: number;
  total_bs: number;
  tasa_actual: number;
  puntos_generados: number;
  fecha_venta: string;
}
