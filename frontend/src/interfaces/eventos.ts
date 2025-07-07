// src/interfaces/eventos.ts
import type { Lugar } from './'; // Import ILugar
import type { CervPres } from './'; // Import ICervPres

/**
 * @interface TipoEvento
 * @description Interfaz para la tabla 'Tipo_Evento'.
 * Define los tipos de eventos que se pueden realizar.
 */
export interface TipoEvento {
  cod_tipo_even: number;
  nombre_tipo_even: string; // varchar(60)
}

/**
 * @interface Evento
 * @description Interfaz para la tabla 'Evento'.
 * Almacena información de los eventos organizados.
 */
export interface Evento {
  cod_even: number;
  nombre_even: string; // varchar(255)
  fecha_hora_ini_even: string; // timestamp
  fecha_hora_fin_even: string; // timestamp
  direccion_even: string; // text
  capacidad_even: number; // integer
  descripcion_even: string; // text
  precio_entrada_even?: number | null; // numeric(8, 2)
  cant_entradas_evento: number; // integer
  fk_tipo_even: number; // Foreign Key to TipoEvento
  fk_luga: number; // Foreign Key to Lugar
}

/**
 * @interface Juez
 * @description Interfaz para la tabla 'Juez'.
 * Almacena información de los jueces de eventos/competiciones.
 */
export interface Juez {
  cod_juez: number;
  primar_nom_juez: string;
  segundo_nom_juez?: string | null;
  primar_ape_juez: string;
  segundo_ape_juez?: string | null;
  ci_juez: number;
}

/**
 * @interface InventarioEvento
 * @description Interfaz para la tabla 'Inventario_Evento'.
 * Representa el inventario de cervezas disponible en un evento.
 */
export interface InventarioEvento {
  fk_cerv_pres_1: number; // Part of composite FK to CERV_PRES (fk_cerv)
  fk_cerv_pres_2: number; // Part of composite FK to CERV_PRES (fk_pres)
  fk_even: number; // Foreign Key to Evento
  cant_pres: number; // integer
  precio_actual_pres: number; // numeric(8, 2)
}

/**
 * @interface RegistroEvento
 * @description Interfaz para la tabla 'Registro_Evento'.
 * Registra la participación de jueces, clientes o miembros en eventos.
 */
export interface RegistroEvento {
  cod_regi_even: number;
  fk_even: number; // Foreign Key to Evento (part of composite PK)
  fk_juez?: number | null; // Foreign Key to Juez (arc)
  fk_clie?: string | null; // Foreign Key to Cliente (arc) - RIF del cliente
  fk_miem?: string | null; // Foreign Key to Miembro (arc)
  fecha_hora_regi_even: string; // timestamp
}

// Interfaces para estatus de eventos
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
