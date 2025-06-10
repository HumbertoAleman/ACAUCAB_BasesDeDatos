/**
 * @interface Ingrediente
 * @description Interfaz para la tabla 'Ingrediente'.
 * Almacena información sobre los ingredientes de las recetas.
 */
export interface Ingrediente {
  cod_ingr: number;
  nombre_ingr: string;
}

/**
 * @interface Receta
 * @description Interfaz para la tabla 'Receta'.
 * Almacena información de las recetas de cerveza.
 */
export interface Receta {
  cod_rece: number;
  nombre_rece: string;
}

/**
 * @interface Instruccion
 * @description Interfaz para la tabla 'Instruccion'.
 * Detalla los pasos de una receta.
 */
export interface Instruccion {
  cod_inst: number;
  nombre_inst: string;
  fk_receta: number; // Foreign Key to Receta
}

/**
 * @interface TipoCerveza
 * @description Interfaz para la tabla 'Tipo_Cerveza'.
 * Define los estilos o tipos de cerveza.
 */
export interface TipoCerveza {
  cod_tipo_cerv: number;
  nombre_tipo_cerv: string;
  fk_receta: number; // Foreign Key to Receta
  fk_tipo_cerv?: number | null; // Self-referencing FK for sub-types
}

/**
 * @interface Caracteristica
 * @description Interfaz para la tabla 'Caracteristica'.
 * Define atributos que describen cervezas o tipos de cerveza.
 */
export interface Caracteristica {
  cod_cara: number;
  nombre_cara: string;
}

/**
 * @interface Cerveza
 * @description Interfaz para la tabla 'Cerveza'.
 * Representa un producto de cerveza específico.
 */
export interface Cerveza {
  cod_cerv: number;
  nombre_cerv: string;
  fk_tipo_cerv: number; // Foreign Key to TipoCerveza
}

/**
 * @interface Presentacion
 * @description Interfaz para la tabla 'Presentacion'.
 * Define los formatos de empaque de las cervezas.
 */
export interface Presentacion {
  cod_pres: number;
  nombre_pres: string;
  capacidad_pres: number; // integer
}

// Interfaces para tablas de relación Muchos a Muchos (M-M) en este dominio

/**
 * @interface ReceIngr
 * @description Interfaz para la tabla 'RECE_INGR'.
 * Relaciona recetas con sus ingredientes y cantidades.
 */
export interface ReceIngr {
  fk_rece: number;
  fk_ingr: number;
  cant_ingr: string; // varchar(50) - asume string para cantidades variadas
}

/**
 * @interface CervCara
 * @description Interfaz para la tabla 'CERV_CARA'.
 * Asocia características a cervezas específicas con su valor.
 */
export interface CervCara {
  fk_cerv: number;
  fk_cara: number;
  valor_cara: string; // varchar(40)
}

/**
 * @interface TipoCara
 * @description Interfaz para la tabla 'TIPO_CARA'.
 * Asocia características a tipos de cerveza con su valor.
 */
export interface TipoCara {
  fk_tipo_cerv: number;
  fk_cara: number;
  valor_cara: string; // varchar(50)
}

/**
 * @interface CervPres
 * @description Interfaz para la tabla 'CERV_PRES'.
 * Relaciona cervezas con sus presentaciones y el miembro distribuidor.
 */
export interface CervPres {
  fk_cerv: number;
  fk_pres: number;
  precio_pres_cerv: number; // numeric(8, 2)
  fk_miem: number; // Foreign Key to Miembro (defined in miembros.ts)
}
