CREATE TABLE Ingrediente (
    cod_ingr serial,
    nombre_ingr varchar(50) NOT NULL,
    PRIMARY KEY (cod_ingr)
);

CREATE TABLE Receta (
    cod_rece serial,
    instrucciones_rece text NOT NULL,
    PRIMARY KEY (cod_rece)
);

CREATE TABLE Tipo_Cerveza (
    cod_tipo_cerv serial,
    nombre_tipo_cerv varchar(50) NOT NULL,
    fk_rece serial NOT NULL UNIQUE,
    fk_tipo_cerv serial,
    PRIMARY KEY (cod_tipo_cerv) FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece),
    FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE Cerveza (
    cod_cerv serial,
    nombre_cerv varchar(50) NOT NULL,
    precio_miem_cerv numeric(10, 2) NOT NULL,
    fk_tipo_cerv serial NOT NULL,
    fk_miem varchar(20) NOT NULL,
    PRIMARY KEY (cod_cerv),
    FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Miembro (
    rif_miem varchar(20),
    razon_social_miem varchar(50) NOT NULL,
    denom_comercial_miem varchar(50) NOT NULL,
    direccion_fiscal_principal_miem varchar(50) NOT NULL,
    direccion_fiscal_secundario_miem varchar(50),
    pag_web_miem text,
    fk_luga serial NOT NULL,
    PRIMARY KEY (rif_miem),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Lugar (
    cod_luga serial,
    nombre_luga text NOT NULL,
    tipo_luga varchar(15) NOT NULL CHECK (tipo_luga IN ('Pais', 'Estado', 'Ciudad', 'Parroquia')),
    fk_luga serial,
    PRIMARY KEY (cod_luga),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Caracteristica (
    cod_cara serial,
    nombre_cara varchar(20) NOT NULL,
    PRIMARY KEY (cod_cara)
);

CREATE TABLE Descuento (
    cod_desc serial,
    porcentaje_desc numeric(3, 2) NOT NULL,
    PRIMARY KEY (cod_desc)
);

CREATE TABLE Presentacion (
    cod_pres serial,
    nombre_pres varchar(20) NOT NULL,
    cantidad_pres numeric(3) NOT NULL,
    PRIMARY KEY (cod_pres)
);

CREATE TABLE Tienda (
    cod_tien serial,
    nombre_tien varchar(50) NOT NULL,
    fecha_apretura_tien date,
    fk_luga serial NOT NULL,
    PRIMARY KEY (cod_tien),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Departamento (
    cod_depa serial,
    nombre_depa varchar(50) NOT NULL,
    fk_tien serial,
    PRIMARY KEY (cod_depa, fk_tien),
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien)
);

CREATE TABLE Empleado (
    cod_empl serial,
    CI_empl varchar(20) NOT NULL,
    primer_nombre_empl varchar(50) NOT NULL,
    segundo_nombre_empl varchar(50),
    primer_apellido_empl varchar(50) NOT NULL,
    segundo_apellido_empl varchar(50),
    salario_base_empl numeric(6, 2) NOT NULL,
    fk_depa_1 serial NOT NULL,
    fk_depa_2 serial NOT NULL,
    PRIMARY KEY (cod_empl),
    FOREIGN KEY (fk_depa_1, fk_depa_2) REFERENCES Departamento (cod_depa, fk_tien)
);

CREATE TABLE Cargo (
    cod_carg serial,
    nombre_carg varchar(20) NOT NULL,
    PRIMARY KEY (cod_carg)
);

CREATE TABLE Vacacion (
    cod_vaca serial,
    fecha_inicio_vaca date NOT NULL,
    fecha_fin_vaca date NOT NULL,
    pagada boolean,
    fk_empl serial NOT NULL,
    fk_carg serial NOT NULL,
    PRIMARY KEY (cod_vaca),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg)
);

CREATE TABLE Beneficio (
    cod_bene serial,
    nombre_bene varchar(20) NOT NULL,
    cantidad_bene numeric(6, 2) NOT NULL,
    PRIMARY KEY (cod_bene)
);

CREATE TABLE Evento (
    cod_even serial,
    nombre_even varchar(20) NOT NULL,
    fecha_hora_inicio_even timestamp NOT NULL,
    fecha_hora_fin_even timestamp NOT NULL,
    direccion_even varchar(255) NOT NULL,
    capacidad_even numeric(5, 0) NOT NULL,
    descripcion_even text,
    precio_entrada_even numeric(4, 2),
    fk_tipo_even serial NOT NULL,
    fk_luga serial NOT NULL,
    PRIMARY KEY (cod_even),
    FOREIGN KEY (fk_tipo_even) REFERENCES Tipo_Evento (cod_tipo_even),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga),
);

CREATE TABLE Tipo_Evento (
    cod_tipo_even serial,
    nombre_tipo_even varchar(20) NOT NULL,
    PRIMARY KEY (cod_tipo_even)
);

CREATE TABLE Contacto (
    cod_cont serial,
    primer_nombre_cont varchar(20) NOT NULL,
    segundo_nombre_cont varchar(20),
    primer_apellido_cont varchar(20) NOT NULL,
    segundo_apellido_cont varchar(20),
    fk_miem varchar(20) NOT NULL,
    PRIMARY KEY (cod_cont),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Rol (
    cod_rol serial,
    nombre_rol varchar(20) NOT NULL,
    descripcion_rol text NOT NULL,
    PRIMARY KEY (cod_rol)
);

CREATE TABLE Privilegio (
    cod_priv serial,
    nombre_priv varchar(20) NOT NULL,
    descripcion_priv text NOT NULL,
    PRIMARY KEY (cod_priv)
);

CREATE TABLE Cliente (
    rif_clie varchar(20),
    direccion_fiscal_principal_clie text NOT NULL,
    direccion_fiscal_secundaria_clie text,
    fk_luga serial NOT NULL,
    PRIMARY KEY (rif_clie),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (fk_luga)
);

CREATE TABLE Cliente_Natural (
    cod_natu serial,
    primer_nombre_natu varchar(20) NOT NULL,
    segundo_nombre_natu varchar(20),
    primer_apellido_natu varchar(20) NOT NULL,
    segundo_apellido_natu varchar(20),
    ci_natu varchar(20) NOT NULL,
    fk_clie varchar(20),
    PRIMARY KEY (cod_natu, fk_clie),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie)
);

CREATE TABLE Cliente_Juridico (
    cod_juri serial,
    razon_social_juri varchar(20) NOT NULL,
    denom_comercial_juri varchar(20) NOT NULL,
    capital_juri numeric(9, 2) NOT NULL,
    pag_web_juri text,
    fk_clie varchar(20),
    PRIMARY KEY (cod_juri, fk_clie),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie)
);

CREATE TABLE Correo (
    cod_corr serial,
    prefijo_corr varchar(20) NOT NULL,
    dominio_corr varchar(20) NOT NULL,
    fk_miem varchar(20),
    fk_cont serial,
    fk_clie varchar(20),
    PRIMARY KEY (cod_corr),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_cont) REFERENCES Contacto (cod_cont),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    -- Arco exclusivo
    CHECK ((fk_miem IS NOT NULL AND fk_cont IS NULL AND fk_clie IS NULL) OR (fk_cont IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL) OR (fk_clie IS NOT NULL AND fk_cont IS NULL AND fk_miem IS NULL))
);

CREATE TABLE Telefono (
    cod_tele serial,
    cod_area_tele numeric(3, 0) NOT NULL,
    num_tele varchar(20) NOT NULL,
    fk_miem varchar(20),
    fk_cont serial,
    fk_clie varchar(20),
    PRIMARY KEY (cod_tele),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_cont) REFERENCES Contacto (cod_cont),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    -- Arco exclusivo
    CHECK ((fk_miem IS NOT NULL AND fk_cont IS NULL AND fk_clie IS NULL) OR (fk_cont IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL) OR (fk_clie IS NOT NULL AND fk_cont IS NULL AND fk_miem IS NULL))
);

CREATE TABLE Usuario (
    cod_usua serial,
    contra_usua varchar(255) NOT NULL,
    fk_rol serial NOT NULL,
    fk_empl serial,
    fk_clie varchar(20),
    fk_miem varchar(20),
    PRIMARY KEY (cod_usua),
    FOREIGN KEY (fk_empl) REFERENCES Miembro (cod_empl),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    -- Arco exclusivo
    CHECK ((fk_empl IS NOT NULL AND fk_clie IS NULL AND fk_miem IS NULL) OR (fk_empl IS NULL AND fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_empl IS NULL AND fk_clie IS NULL AND fk_miem IS NOT NULL))
);

CREATE TABLE Horario (
    cod_hora serial,
    hora_inicio time,
    hora_fin time,
    hora_dia varchar(20) CHECK (hora_dia IN ("lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo")),
    PRIMARY KEY (cod_hora)
);

CREATE TABLE Juez (
    cod_juez serial,
    nombre_juez varchar(20) NOT NULL,
    apellido_juez varchar(20) NOT NULL,
    ci_juez varchar(20) NOT NULL,
    PRIMARY KEY (cod_juez)
);

CREATE TABLE Tasa (
    cod_tasa serial,
    tasa_dolar_bcv numeric(10, 2) NOT NULL,
    tasa_punto numeric(10, 2) NOT NULL,
    fecha_tasa date NOT NULL,
);

CREATE TABLE Metodo_Pago (
    cod_meto_pago serial,
    PRIMARY KEY (cod_meto_pago)
);

CREATE TABLE Tarjeta (
    cod_tarj serial,
    numero_tarj numeric(20, 0),
    fecha_vence_tarj_mes numeric(2, 0) NOT NULL,
    fecha_vence_tarj_ano numeric(4, 0) NOT NULL,
    cvv_tarj numeric(3, 0) NOT NULL,
    nombre_titu_tarj varchar(50) NOT NULL,
    credito boolean,
    fk_meto_pago serial,
    PRIMARY KEY (cod_tarj, fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Punto_Canjeo (
    cod_punt_canj serial,
    fk_meto_pago serial,
    PRIMARY KEY (cod_punt_pago, fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Cheque (
    cod_cheq serial,
    numero_cheq varchar(20) NOT NULL,
    numero_cuenta_banc varchar(20) NOT NULL,
    fk_banc serial NOT NULL,
    fk_meto_pago serial,
    PRIMARY KEY (cod_cheq, fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    FOREIGN KEY (fk_banc) REFERENCES Banco (cod_banc)
);

CREATE TABLE Banco (
    cod_banc serial,
    nombre_banc varchar(20) NOT NULL,
    PRIMARY KEY (cod_banc)
);

CREATE TABLE Efectivo (
    cod_efec serial,
    denominacion_efec char NOT NULL CHECK (denominacion_efec IN ('B', 'D', 'E')),
    fk_meto_pago serial,
    PRIMARY KEY (cod_efec, fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
);

CREATE TABLE Lugar_Tienda (
    cod_luga_tien serial,
    nombre_luga_tien varchar(20) NOT NULL,
    tipo_luga_tien varchar(20) NOT NULL CHECK (nombre_luga_tien IN ('Almacen', 'Pasillo', 'Anaquel')),
    fk_luga_tien serial,
    PRIMARY KEY (cod_luga_tien),
    FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (fk_luga_tien)
);

CREATE TABLE Venta (
    cod_vent serial,
    fecha_vent date NOT NULL,
    total_vent numeric(9, 2) NOT NULL,
    total_vent_sin_iva numeric(9, 2) NOT NULL,
    online boolean,
    fk_clie varchar(20),
    fk_miem varchar(20),
    fk_tien serial,
    fk_even serial,
    -- TODO: Figure out how to reference N to N relations
    -- PUNT_CLIE specifically
    fk_punt_clie_1 serial,
    fk_punt_clie_2 varchar(20),
    -- Arco Cliente | Miembro
    CHECK ((fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_miem IS NOT NULL AND fk_clie IS NULL)),
    -- Arco Tienda | Evento
    CHECK ((fk_tien IS NOT NULL AND fk_even IS NULL) OR (fk_even IS NOT NULL AND fk_tien IS NULL)),
    -- Miembro -> SOLO Tienda (por la membresia)
    CHECK (fk_miem IS NOT NULL AND fk_tien IS NOT NULL AND fk_even IS NULL),
    PRIMARY KEY (cod_vent),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    -- TODO: Figure out how to reference N to N relations
    -- PUNT_CLIE specifically
);

CREATE TABLE Compra (
    cod_comp serial,
    fk_miem varchar(20),
    PRIMARY KEY (cod_comp),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Cuota (
    cod_cuot serial,
    nombre_plan_cuot varchar(50),
    precio_cuot numeric(6, 2) NOT NULL,
);

CREATE TABLE Detalle (
    cod_deta serial,
    cantidad_deta numeric(3, 0) NOT NULL,
    precio_unitario_deta numeric(6, 2) NOT NULL,
    -- ARCO COMPRA | VENTA
    fk_comp serial,
    fk_vent serial,
    -- INVENTARIO TIENDA
    fk_inve_tien_1 serial, -- Cerveza
    fk_inve_tien_2 serial, -- Presentacion
    fk_inve_tien_3 serial, -- Tienda
    -- INVENTARIO EVENTO
    fk_inve_even_1 serial, -- Cerveza
    fk_inve_even_2 serial, -- Presentacion
    fk_inve_even_3 serial, -- Evento
    -- CUOTA DE AFILIACION
    fk_cuot serial,
    -- ENTRADA A EVENTO
    fk_regi_even_1 serial, -- Evento
    fk_regi_even_2 varchar(20), -- Miembro
    fk_regi_even_3 varchar(20), -- Cliente
    fk_regi_even_4 serial, -- Juez
    -- CONSTRAINTS
    PRIMARY KEY (cod_deta),
    -- ARCO COMPRA | VENTA
    FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp),
    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CHECK ((fk_comp IS NOT NULL AND fk_vent IS NULL) OR (fk_vent IS NOT NULL AND fk_comp IS NULL)),
    -- ARCO COMPRA | LO QUE SE COMPRO
    FOREIGN KEY (fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_3) REFERENCES Inventario_Tienda (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien),
    FOREIGN KEY (fk_inve_even_1, fk_inve_even_2, fk_inve_even_3) REFERENCES Inventario_Evento (fk_cerv_pres_1, fk_cerv_pres_2, fk_even),
    FOREIGN KEY (fk_cuot) REFERENCES Cuota (cod_cuot),
    FOREIGN KEY (fk_regi_even_1 fk_regi_even_2 fk_regi_even_3 fk_regi_even_4) REFERENCES Registro_Evento (fk_even, fk_miem, fk_clie, fk_juez,)
    -- TODO: HACER EL ARCO EXCLUSIVO ENTRE ESTE MAMARRO DE COSAS
);

CREATE TABLE Estatus (
    cod_esta serial,
    nombre_esta varchar(20) NOT NULL,
    descripcion_esta text NOT NULL,
    PRIMARY KEY (cod_esta),
);

-- Relaciones N a N --
CREATE TABLE RECE_INGR (
    fk_ingr serial,
    fk_rece serial,
    cantidad_ingr numeric(4, 2) NOT NULL,
    PRIMARY KEY (fk_ingr, fk_rece),
    FOREIGN KEY (fk_ingr) REFERENCES Ingrediente (cod_ingr),
    FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE CERV_CARA (
    fk_cerv serial,
    fk_cara serial,
    valor_cara varchar(20) NOT NULL,
    PRIMARY KEY (fk_cerv, fk_cara),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara)
);

CREATE TABLE DESC_CERV (
    fk_cerv serial,
    fk_desc serial,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    PRIMARY KEY (fk_cerv, fk_desc),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_desc) REFERENCES Descuento (cod_desc)
);

CREATE TABLE CERV_PRES (
    fk_cerv serial,
    fk_pres serial,
    PRIMARY KEY (fk_cerv, fk_pres),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres)
);

CREATE TABLE EMPL_CARG (
    fk_empl serial,
    fk_carg serial,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    cantidad_total_salario numeric(6, 2),
    PRIMARY KEY (fk_empl, fk_carg),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg)
);

CREATE TABLE EMPL_CARG_BENE (
    fk_empl_carg_1 serial,
    fk_empl_carg_2 serial,
    fk_bene serial,
    monto_bene numeric(6, 2) NOT NULL,
    PRIMARY KEY (fk_empl_carg_1, fk_empl_carg_2, fk_bene),
    FOREIGN KEY (fk_empl_carg_1) REFERENCES EMPL_CARG (fk_empl),
    FOREIGN KEY (fk_empl_carg_2) REFERENCES EMPL_CARG (fk_carg),
    FOREIGN KEY (fk_bene) REFERENCES Beneficio (cod_bene)
);

CREATE TABLE Inventario_Evento (
    fk_cerv_pres_1 serial,
    fk_cerv_pres_2 serial,
    fk_even serial,
    cantidad_pres numeric(6),
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_even),
    FOREIGN KEY (fk_cerv_pres_1) REFERENCES CERV_PRES (fk_cerv),
    FOREIGN KEY (fk_cerv_pres_2) REFERENCES CERV_PRES (fk_pres),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even)
);

CREATE TABLE Inventario_Tienda (
    fk_cerv_pres_1 serial,
    fk_cerv_pres_2 serial,
    fk_tien serial,
    fk_luga_tien serial,
    cantidad_pres numeric(6),
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien),
    FOREIGN KEY (fk_cerv_pres_1) REFERENCES CERV_PRES (fk_cerv),
    FOREIGN KEY (fk_cerv_pres_2) REFERENCES CERV_PRES (fk_pres),
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE PRIV_ROL (
    fk_priv serial,
    fk_rol serial,
    PRIMARY KEY (fk_priv, fk_rol),
    FOREIGN KEY (fk_priv) REFERENCES Privilegio (cod_priv),
    FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol)
);

CREATE TABLE Asistencia (
    -- NOTE: Preguntarle a la profe como hacer esto
);

CREATE TABLE Registro_Evento (
    fk_even serial,
    fk_miem varchar(20),
    fk_clie varchar(20),
    fk_juez serial,
    PRIMARY KEY (fk_even, fk_miem, fk_clie, fk_juez),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_juez) REFERENCES Juez (cod_juez),
    -- Arco Exclusivo fk_miem | fk_clie | fk_juez
    CHECK ((fk_miem IS NOT NULL AND fk_clie IS NULL AND fk_juez IS NULL) OR (fk_miem IS NULL AND fk_clie IS NOT NULL AND fk_juez IS NULL) OR (fk_miem IS NULL AND fk_clie IS NULL AND fk_juez IS NOT NULL))
);

CREATE TABLE PUNT_CLIE (
    fk_clie varchar(20),
    fk_punt_canj_1 serial,
    fk_punt_canj_2 serial,
    fk_tasa serial NOT NULL,
    PRIMARY KEY (fk_clie, fk_punt_canj_1, fk_punt_canj_2),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_punt_canj_1, fk_punt_canj_2) REFERENCES Punto_Canjeo (cod_meto_pago, cod_punt_canj),
    FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa)
);

CREATE TABLE Pago (
    fk_meto_pago serial,
    fk_vent serial,
    fk_tasa serial,
    monto_pago numeric(6, 2),
    PRIMARY KEY (fk_meto_pago, fk_vent),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa)
);

CREATE TABLE ESTA_COMP (
    fk_esta serial,
    fk_comp serial,
    fecha_inicio timestamp NOT NULL,
    fecha_fin timestamp,
    PRIMARY KEY (fk_esta, fk_comp),
    FOREIGN KEY (fk_esta) REFERENCES Estado (cod_esta),
    FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp)
);

CREATE TABLE ESTA_VENT (
    fk_esta serial,
    fk_vent serial,
    fecha_inicio timestamp NOT NULL,
    fecha_fin timestamp,
    PRIMARY KEY (fk_esta, fk_vent),
    FOREIGN KEY (fk_esta) REFERENCES Estado (cod_esta),
    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent)
);

CREATE TABLE ESTA_EVEN (
    fk_esta serial,
    fk_even serial,
    fecha_inicio timestamp NOT NULL,
    fecha_fin timestamp,
    PRIMARY KEY (fk_esta, fk_even),
    FOREIGN KEY (fk_esta) REFERENCES Estado (cod_esta),
    FOREIGN KEY (fk_even) REFERENCES Venta (cod_even)
);
