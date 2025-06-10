/**
 * @interface Empleado
 * @description Interfaz para la tabla 'Empleado'.
 * Almacena información personal de los empleados.
 */
export interface Empleado {
  cod_empl: number;
  ci_empl: number;
  primer_nom_empl: string;
  segundo_nom_empl?: string | null;
  primer_ape_empl: string;
  segundo_ape_empl?: string | null;
  salario_base_empl: number; // numeric(8, 2)
}

/**
 * @interface Cargo
 * @description Interfaz para la tabla 'Cargo'.
 * Define los roles o posiciones de los empleados.
 */
export interface Cargo {
  cod_carg: number;
  nombre_carg: string;
}

/**
 * @interface Beneficio
 * @description Interfaz para la tabla 'Beneficio'.
 * Define los beneficios que pueden recibir los empleados.
 */
export interface Beneficio {
  cod_bene: number;
  nombre_bene: string;
  cantidad_bene: number; // integer
}

/**
 * @interface Horario
 * @description Interfaz para la tabla 'Horario'.
 * Define los horarios de trabajo.
 */
export interface Horario {
  cod_hora: number;
  hora_ini_hora: string; // time (e.g., "HH:MM:SS")
  hora_fin_hora: string; // time
  dia_hora: 'Lunes' | 'Martes' | 'Miercoles' | 'Jueves' | 'Viernes' | 'Sabado' | 'Domingo';
}

// Interfaces para tablas de relación Muchos a Muchos (M-M) en este dominio

/**
 * @interface EmplCarg
 * @description Interfaz para la tabla 'EMPL_CARG'.
 * Relaciona empleados con sus cargos a lo largo del tiempo.
 */
export interface EmplCarg {
  fk_empl: number;
  fk_carg: number;
  fecha_ini: string; // date
  fecha_fin?: string | null; // date
  cantidad_total_salario: number; // integer (considerar si debería ser numeric)
  fk_depa_1?: number | null; // Foreign Key to Departamento (cod_depa)
  fk_depa_2?: number | null; // Foreign Key to Departamento (fk_tien)
}

/**
 * @interface Vacacion
 * @description Interfaz para la tabla 'Vacacion'.
 * Registra los periodos de vacaciones de los empleados.
 */
export interface Vacacion {
  cod_vaca: number;
  fecha_ini_vaca: string; // date
  fecha_fin_vaca: string; // date
  pagada?: boolean | null;
  fk_empl_carg_1: number; // Part of composite FK to EMPL_CARG
  fk_empl_carg_2: number; // Part of composite FK to EMPL_CARG
}

/**
 * @interface Asistencia
 * @description Interfaz para la tabla 'Asistencia'.
 * Registra la asistencia de los empleados.
 */
export interface Asistencia {
  cod_asis: number;
  fecha_hora_ini_asis: string; // timestamp
  fecha_hora_fin_asis: string; // timestamp
  fk_empl_carg_1: number; // Part of composite FK to EMPL_CARG
  fk_empl_carg_2: number; // Part of composite FK to EMPL_CARG
}

/**
 * @interface EmplHora
 * @description Interfaz para la tabla 'EMPL_HORA'.
 * Asocia horarios de trabajo con asignaciones de empleado-cargo.
 */
export interface EmplHora {
  fk_hora: number;
  fk_empl_carg_1: number; // Part of composite FK to EMPL_CARG
  fk_empl_carg_2: number; // Part of composite FK to EMPL_CARG
}

/**
 * @interface EmplBene
 * @description Interfaz para la tabla 'EMPL_BENE'.
 * Relaciona empleados con los beneficios que disfrutan.
 */
export interface EmplBene {
  fk_empl_carg_1: number; // Part of composite FK to EMPL_CARG
  fk_empl_carg_2: number; // Part of composite FK to EMPL_CARG
  fk_bene: number; // Foreign Key to Beneficio
  monto_bene?: number | null; // numeric(8, 2)
}