CREATE TABLE Ingrediente (
    cod_ingr serial,
    nombre_ingr varchar(40) NOT NULL,
    PRIMARY KEY (cod_ingr)
);

CREATE TABLE Receta (
    cod_rece serial,
    nombre_rece varchar(80) NOT NULL,
    PRIMARY KEY (cod_rece)
);

CREATE TABLE Instruccion (
    cod_inst serial,
    nombre_inst text NOT NULL,
    fk_receta integer NOT NULL,
    PRIMARY KEY (cod_inst),
    CONSTRAINT instruye FOREIGN KEY (fk_receta) REFERENCES Receta (cod_rece)
);

CREATE TABLE Tipo_Cerveza (
    cod_tipo_cerv serial,
    nombre_tipo_cerv varchar(40) NOT NULL,
    fk_receta integer NOT NULL,
    fk_tipo_cerv integer,
    PRIMARY KEY (cod_tipo_cerv),
    CONSTRAINT sigue FOREIGN KEY (fk_receta) REFERENCES Receta (cod_rece),
    CONSTRAINT categorizado FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE Caracteristica (
    cod_cara serial,
    nombre_cara varchar(40) NOT NULL,
    PRIMARY KEY (cod_cara)
);

CREATE TABLE Cerveza (
    cod_cerv serial,
    nombre_cerv varchar(40) NOT NULL,
    fk_tipo_cerv integer NOT NULL,
    PRIMARY KEY (cod_cerv),
    CONSTRAINT clasificado FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE Presentacion (
    cod_pres serial,
    nombre_pres varchar(40) NOT NULL,
    capacidad_pres integer NOT NULL,
    PRIMARY KEY (cod_pres)
);

CREATE TABLE Lugar (
    cod_luga serial,
    nombre_luga varchar(40) NOT NULL,
    tipo_luga varchar(40) NOT NULL CHECK (tipo_luga IN ('Estado', 'Ciudad', 'Parroquia')),
    fk_luga integer,
    PRIMARY KEY (cod_luga),
    CONSTRAINT esta FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Tienda (
    cod_tien serial,
    nombre_tien varchar(40) NOT NULL,
    fecha_apertura_tien date,
    direccion_tien text NOT NULL,
    fk_luga integer NOT NULL,
    PRIMARY KEY (cod_tien),
    CONSTRAINT asignado FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Lugar_Tienda (
    cod_luga_tien serial,
    nombre_luga_tien varchar(40) NOT NULL,
    tipo_luga_tien varchar(40) NOT NULL,
    fk_luga_tien integer,
    PRIMARY KEY (cod_luga_tien),
    CONSTRAINT localizado FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE Tipo_Evento (
    cod_tipo_even serial,
    nombre_tipo_even varchar(40) NOT NULL,
    PRIMARY KEY (cod_tipo_even)
);

CREATE TABLE Evento (
    cod_even serial,
    nombre_even varchar(40) NOT NULL,
    fecha_hora_ini_even timestamp NOT NULL,
    fecha_hora_fin_even timestamp NOT NULL,
    direccion_even text NOT NULL,
    capacidad_even integer NOT NULL,
    descripcion_even text NOT NULL,
    precio_entrada_even numeric(8, 2),
    cant_entradas_evento integer NOT NULL,
    fk_tipo_even integer NOT NULL,
    fk_luga integer NOT NULL,
    PRIMARY KEY (cod_even),
    CONSTRAINT es FOREIGN KEY (fk_tipo_even) REFERENCES Tipo_Evento (cod_tipo_even),
    CONSTRAINT desarrollado FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Empleado (
    cod_empl serial,
    ci_empl integer NOT NULL,
    primer_nom_empl varchar(40) NOT NULL,
    segundo_nom_empl varchar(40),
    primer_ape_empl varchar(40) NOT NULL,
    segundo_ape_empl varchar(40),
    salario_base_empl numeric(8, 2) NOT NULL,
    PRIMARY KEY (cod_empl)
);

CREATE TABLE Cargo (
    cod_carg serial,
    nombre_carg varchar(40) NOT NULL,
    PRIMARY KEY (cod_carg)
);

CREATE TABLE Miembro (
    rif_miem integer,
    razon_social_miem varchar(40) NOT NULL,
    denom_comercial_miem varchar(40) NOT NULL,
    direccion_fiscal_miem text NOT NULL,
    pag_web_miem text,
    fk_luga_1 integer NOT NULL,
    fk_luga_2 integer,
    PRIMARY KEY (rif_miem),
    CONSTRAINT encontrado FOREIGN KEY (fk_luga_1) REFERENCES Lugar (cod_luga),
    CONSTRAINT proveniente FOREIGN KEY (fk_luga_2) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Contacto (
    cod_pers serial,
    primer_nom_pers varchar(40) NOT NULL,
    segundo_nom_pers varchar(40),
    primer_ape_pers varchar(40) NOT NULL,
    segundo_ape_pers varchar(40),
    fk_miem integer,
    PRIMARY KEY (cod_pers),
    CONSTRAINT cuenta_con FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Beneficio (
    cod_bene serial,
    nombre_bene varchar(40) NOT NULL,
    cantidad_bene integer NOT NULL,
    PRIMARY KEY (cod_bene)
);

CREATE TABLE Departamento (
    cod_depa serial,
    fk_tien integer,
    PRIMARY KEY (cod_depa, fk_tien),
    CONSTRAINT formada FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien)
);

CREATE TABLE EMPL_CARG (
    fk_empl integer,
    fk_carg integer,
    fecha_ini date NOT NULL,
    fecha_fin date,
    cantidad_total_salario integer NOT NULL,
    fk_depa_1 integer,
    fk_depa_2 integer,
    PRIMARY KEY (fk_empl, fk_carg),
    CONSTRAINT desempena FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT desempenado FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg),
    CONSTRAINT contiene FOREIGN KEY (fk_depa_1, fk_depa_2) REFERENCES Departamento (cod_depa, fk_tien)
);

CREATE TABLE Vacacion (
    cod_vaca serial,
    fecha_ini_vaca date NOT NULL,
    fecha_fin_vaca date NOT NULL,
    pagada boolean,
    fk_empl_carg_1 integer NOT NULL,
    fk_empl_carg_2 integer NOT NULL,
    PRIMARY KEY (cod_vaca),
    CONSTRAINT goza FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg)
);

CREATE TABLE Asistencia (
    cod_asis serial,
    fecha_hora_ini_asis timestamp NOT NULL,
    fecha_hora_fin_asis timestamp NOT NULL,
    fk_empl_carg_1 integer NOT NULL,
    fk_empl_carg_2 integer NOT NULL,
    PRIMARY KEY (cod_asis),
    CONSTRAINT asiste FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg)
);

CREATE TABLE Horario (
    cod_hora serial,
    hora_ini_hora time NOT NULL,
    hora_fin_hora time NOT NULL,
    dia_hora varchar(20) NOT NULL CHECK (dia_hora IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')),
    PRIMARY KEY (cod_hora)
);

CREATE TABLE Rol (
    cod_rol serial,
    nombre_rol varchar(40) NOT NULL,
    descripcion_rol text NOT NULL,
    PRIMARY KEY (cod_rol)
);

CREATE TABLE Privilegio (
    cod_priv serial,
    nombre_priv varchar(40) NOT NULL,
    descripcion_priv text NOT NULL,
    PRIMARY KEY (cod_priv)
);

CREATE TABLE Tasa (
    cod_tasa serial,
    tasa_dolar_bcv numeric(8, 2) NOT NULL,
    tasa_punto numeric(8, 2) NOT NULL,
    fecha_ini_tasa date NOT NULL,
    fecha_fin_tasa date,
    PRIMARY KEY (cod_tasa)
);

CREATE TABLE Juez (
    cod_juez serial,
    primar_nom_juez varchar(40) NOT NULL,
    segundo_nom_juez varchar(40),
    primar_ape_juez varchar(40) NOT NULL,
    segundo_ape_juez varchar(40),
    ci_juez integer NOT NULL,
    PRIMARY KEY (cod_juez)
);

CREATE TABLE Banco (
    cod_banc serial,
    nombre_banc varchar(40) NOT NULL,
    PRIMARY KEY (cod_banc)
);

CREATE TABLE Cuota (
    cod_cuot serial,
    nombre_plan_cuot varchar(40) NOT NULL,
    precio_cuot numeric(8, 2) NOT NULL,
    PRIMARY KEY (cod_cuot)
);

CREATE TABLE Estatus (
    cod_esta serial,
    nombre_esta varchar(40) NOT NULL,
    descripcion_esta text,
    PRIMARY KEY (cod_esta)
);

CREATE TABLE Compra (
    cod_comp serial,
    fecha_comp date NOT NULL,
    iva_comp numeric(8, 2) NOT NULL,
    base_imponible_comp numeric(8, 2) NOT NULL,
    total_comp numeric(8, 2) NOT NULL,
    fk_tien integer,
    fk_miem integer,
    PRIMARY KEY (cod_comp),
    CONSTRAINT registra FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT realiza FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE CERV_PRES (
    fk_cerv integer,
    fk_pres integer,
    precio_pres_cerv numeric(8, 2) NOT NULL,
    fk_miem integer NOT NULL,
    PRIMARY KEY (fk_cerv, fk_pres),
    CONSTRAINT empaqueta FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    CONSTRAINT empaquetada FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    CONSTRAINT distribuye FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Detalle_Compra (
    cod_deta_comp serial,
    cant_deta_comp integer NOT NULL,
    precio_unitario_comp numeric(8, 2) NOT NULL,
    fk_cerv_pres_1 integer NOT NULL,
    fk_cerv_pres_2 integer NOT NULL,
    fk_comp integer NOT NULL,
    PRIMARY KEY (cod_deta_comp),
    CONSTRAINT obtenido FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT necesita FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp)
);

CREATE TABLE Cliente (
    rif_clie integer,
    direccion_fiscal_clie text NOT NULL,
    direccion_fisica_clie text NOT NULL,
    fk_luga_1 integer NOT NULL,
    fk_luga_2 integer NOT NULL,
    tipo_clie varchar(10) NOT NULL CHECK (tipo_clie IN ('Natural', 'Juridico')),
    primer_nom_natu varchar(40),
    segundo_nom_natu varchar(40),
    primer_ape_natu varchar(40),
    segundo_ape_natu varchar(40),
    ci_natu integer,
    razon_social_juri varchar(40),
    denom_comercial_juri varchar(40),
    capital_juri numeric(8, 2),
    pag_web_juri text,
    PRIMARY KEY (rif_clie),
    CONSTRAINT domiciliado FOREIGN KEY (fk_luga_1) REFERENCES Lugar (cod_luga),
    CONSTRAINT ubicado FOREIGN KEY (fk_luga_2) REFERENCES Lugar (cod_luga),
    -- Check supertipo
    CHECK ((tipo_clie = 'Natural' AND primer_nom_natu IS NOT NULL AND primer_ape_natu IS NOT NULL AND ci_natu IS NOT NULL AND razon_social_juri IS NULL AND denom_comercial_juri IS NULL AND capital_juri IS NULL AND pag_web_juri IS NULL) OR (tipo_clie = 'Juridico' AND razon_social_juri IS NOT NULL AND denom_comercial_juri IS NOT NULL AND capital_juri IS NOT NULL AND primer_nom_natu IS NULL AND segundo_nom_natu IS NULL AND primer_ape_natu IS NULL AND segundo_ape_natu IS NULL AND ci_natu IS NULL))
);

CREATE TABLE Venta (
    cod_vent serial,
    fecha_vent date NOT NULL,
    iva_vent numeric(8, 2) NOT NULL,
    base_imponible_vent numeric(8, 2) NOT NULL,
    total_vent numeric(8, 2) NOT NULL,
    online boolean,
    fk_clie integer,
    fk_miem integer,
    fk_even integer,
    fk_tien integer,
    fk_cuot integer,
    PRIMARY KEY (cod_vent),
    -- Arco entre fk_clie - fk_miem
    CONSTRAINT compra FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT comercializa FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    CHECK ((fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_miem IS NOT NULL AND fk_clie IS NULL)),
    -- Arco entre fk_even - fk_tien - fk_cuot
    CONSTRAINT promociona FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT hace FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT cobra FOREIGN KEY (fk_cuot) REFERENCES Cuota (cod_cuot),
    CHECK ((fk_even IS NOT NULL AND fk_tien IS NULL AND fk_cuot IS NULL) OR (fk_tien IS NOT NULL AND fk_cuot IS NULL AND fk_even IS NULL) OR (fk_cuot IS NOT NULL AND fk_even IS NULL AND fk_tien IS NULL))
);

CREATE TABLE Usuario (
    cod_usua serial,
    contra_usua text NOT NULL,
    username_usua varchar(40) NOT NULL,
    fk_rol integer NOT NULL,
    fk_empl integer,
    fk_miem integer,
    fk_clie integer,
    PRIMARY KEY (cod_usua),
    CONSTRAINT ejecuta FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol),
    CONSTRAINT transformado FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT adaptado FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT convertido FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco entre fk_empl - fk_miem - fk_clie
    CHECK ((fk_empl IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL) OR (fk_miem IS NOT NULL AND fk_clie IS NULL AND fk_empl IS NULL) OR (fk_clie IS NOT NULL AND fk_empl IS NULL AND fk_miem IS NULL))
);

CREATE TABLE Inventario_Tienda (
    fk_cerv_pres_1 integer,
    fk_cerv_pres_2 integer,
    fk_tien integer,
    fk_luga_tien integer NOT NULL,
    cant_pres integer NOT NULL,
    precio_actual_pres numeric(8, 2) NOT NULL,
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien),
    CONSTRAINT conformado FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT posicionado FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT engloba FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE Inventario_Evento (
    fk_cerv_pres_1 integer,
    fk_cerv_pres_2 integer,
    fk_even integer,
    cant_pres integer NOT NULL,
    precio_actual_pres numeric(8, 2) NOT NULL,
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_even),
    CONSTRAINT dispone FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT administra FOREIGN KEY (fk_even) REFERENCES Evento (cod_even)
);

CREATE TABLE Detalle_Venta (
    cod_deta_vent serial,
    cant_deta_vent integer NOT NULL,
    precio_unitario_vent numeric(8, 2) NOT NULL,
    fk_vent integer NOT NULL,
    fk_inve_tien_1 integer,
    fk_inve_tien_2 integer,
    fk_inve_tien_3 integer,
    fk_inve_even_1 integer,
    fk_inve_even_2 integer,
    fk_inve_even_3 integer,
    CONSTRAINT incluye FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CONSTRAINT sustrae FOREIGN KEY (fk_inve_even_1, fk_inve_even_2, fk_inve_even_3) REFERENCES Inventario_Evento (fk_cerv_pres_1, fk_cerv_pres_2, fk_even),
    CONSTRAINT vincula FOREIGN KEY (fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_3) REFERENCES Inventario_Tienda (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien),
    -- Arco Inventario_Tienda - Inventario_Evento
    CHECK (((fk_inve_tien_1 IS NOT NULL AND fk_inve_tien_2 IS NOT NULL AND fk_inve_tien_3 IS NOT NULL) AND (fk_inve_even_1 IS NULL AND fk_inve_even_2 IS NULL AND fk_inve_even_3 IS NULL)) OR ((fk_inve_tien_1 IS NULL AND fk_inve_tien_2 IS NULL AND fk_inve_tien_3 IS NULL) AND (fk_inve_even_1 IS NOT NULL AND fk_inve_even_2 IS NOT NULL AND fk_inve_even_3 IS NOT NULL)))
);

CREATE TABLE Metodo_Pago (
    cod_meto_pago serial,
    PRIMARY KEY (cod_meto_pago)
);

CREATE TABLE Tarjeta (
    fk_meto_pago integer,
    numero_tarj integer NOT NULL,
    fecha_venci_tarj date NOT NULL,
    cvv_tarj integer NOT NULL,
    nombre_titu_tarj varchar(40) NOT NULL,
    credito boolean,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Punto_Canjeo (
    fk_meto_pago integer,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Cheque (
    fk_meto_pago integer,
    numero_cheque integer NOT NULL,
    numero_cuenta_cheque integer NOT NULL,
    fk_banc integer NOT NULL,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    CONSTRAINT emite FOREIGN KEY (fk_banc) REFERENCES Banco (cod_banc)
);

CREATE TABLE Efectivo (
    fk_meto_pago integer,
    denominacion_efec char NOT NULL,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Pago (
    fk_vent integer,
    fk_meto_pago integer,
    monto_pago numeric(8, 2) NOT NULL,
    fecha_pago date NOT NULL,
    fk_tasa integer NOT NULL,
    PRIMARY KEY (fk_vent, fk_meto_pago),
    CONSTRAINT formada FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CONSTRAINT usa FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    CONSTRAINT calculado FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa)
);

CREATE TABLE Telefono (
    cod_tele serial,
    cod_area_tele integer NOT NULL,
    num_tele integer NOT NULL,
    fk_clie integer UNIQUE,
    fk_pers integer UNIQUE,
    fk_miem integer,
    PRIMARY KEY (cod_tele),
    CONSTRAINT asocia FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT tiene FOREIGN KEY (fk_pers) REFERENCES Contacto (cod_pers),
    CONSTRAINT utiliza FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    CHECK ((fk_clie IS NOT NULL AND fk_pers IS NULL AND fk_miem IS NULL) OR (fk_miem IS NOT NULL AND fk_clie IS NULL AND fk_pers IS NULL) OR (fk_pers IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL))
);

CREATE TABLE Correo (
    cod_corr serial,
    prefijo_corr varchar(40) NOT NULL,
    dominio_corr varchar(40) NOT NULL,
    fk_clie integer UNIQUE,
    fk_empl integer UNIQUE,
    fk_pers integer UNIQUE,
    fk_miem integer,
    PRIMARY KEY (cod_corr),
    CONSTRAINT relaciona FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT identifica FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT conecta FOREIGN KEY (fk_pers) REFERENCES Contacto (cod_pers),
    CONSTRAINT vincula FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco Cliente - Empleado - Contacto - Miembro
    CHECK ((fk_clie IS NOT NULL AND fk_empl IS NULL AND fk_pers IS NULL AND fk_miem IS NULL) OR (fk_clie IS NULL AND fk_empl IS NOT NULL AND fk_pers IS NULL AND fk_miem IS NULL) OR (fk_clie IS NULL AND fk_empl IS NULL AND fk_pers IS NOT NULL AND fk_miem IS NULL) OR (fk_clie IS NULL AND fk_empl IS NULL AND fk_pers IS NULL AND fk_miem IS NOT NULL))
);

CREATE TABLE Descuento (
    cod_desc serial,
    descripcion_desc text NOT NULL,
    fecha_ini_desc date NOT NULL,
    fecha_fin_desc date NOT NULL,
    PRIMARY KEY (cod_desc)
);

CREATE TABLE Registro_Evento (
    cod_regi_even serial,
    fk_even integer NOT NULL,
    fk_juez integer,
    fk_clie integer,
    fk_miem integer,
    fecha_hora_regi_even timestamp NOT NULL,
    PRIMARY KEY (cod_regi_even, fk_even),
    CONSTRAINT genera FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT forma_parte FOREIGN KEY (fk_juez) REFERENCES Juez (cod_juez),
    CONSTRAINT participa FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT asiste FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco entre Juez - Cliente - Miembro
    CHECK ((fk_juez IS NOT NULL AND fk_clie IS NULL AND fk_miem IS NULL) OR (fk_juez IS NULL AND fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_juez IS NULL AND fk_clie IS NULL AND fk_miem IS NOT NULL))
);

-- MUCHOS A MUCHOS
CREATE TABLE DESC_CERV (
    fk_desc integer,
    fk_cerv_pres_1 integer,
    fk_cerv_pres_2 integer,
    porcentaje_desc numeric(3, 2) NOT NULL,
    PRIMARY KEY (fk_desc, fk_cerv_pres_1, fk_cerv_pres_2),
    CONSTRAINT aplica FOREIGN KEY (fk_desc) REFERENCES Descuento (cod_desc),
    CONSTRAINT aplicado FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres)
);

CREATE TABLE PRIV_ROL (
    fk_rol integer,
    fk_priv integer,
    PRIMARY KEY (fk_rol, fk_priv),
    CONSTRAINT otorgado FOREIGN KEY (fk_priv) REFERENCES Privilegio (cod_priv),
    CONSTRAINT otorga FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol)
);

CREATE TABLE EMPL_HORA (
    fk_hora integer,
    fk_empl_carg_1 integer,
    fk_empl_carg_2 integer,
    PRIMARY KEY (fk_empl_carg_1, fk_empl_carg_2, fk_hora),
    CONSTRAINT cumple FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg),
    CONSTRAINT cumplido FOREIGN KEY (fk_hora) REFERENCES Horario (cod_hora)
);

CREATE TABLE EMPL_BENE (
    fk_empl_carg_1 integer,
    fk_empl_carg_2 integer,
    fk_bene integer,
    monto_bene numeric(8, 2),
    PRIMARY KEY (fk_empl_carg_1, fk_empl_carg_2, fk_bene),
    CONSTRAINT disfruta FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg),
    CONSTRAINT disfrutado FOREIGN KEY (fk_bene) REFERENCES Beneficio (cod_bene)
);

CREATE TABLE CERV_CARA (
    fk_cerv integer,
    fk_cara integer,
    valor_cara varchar(40) NOT NULL,
    PRIMARY KEY (fk_cerv, fk_cara),
    CONSTRAINT caracteriza FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara),
    CONSTRAINT caracterizada FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv)
);

CREATE TABLE TIPO_CARA (
    fk_tipo_cerv integer,
    fk_cara integer,
    valor_cara varchar(50) NOT NULL,
    PRIMARY KEY (fk_tipo_cerv, fk_cara),
    CONSTRAINT estiliza FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara),
    CONSTRAINT estilizada FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE RECE_INGR (
    fk_rece integer,
    fk_ingr integer,
    cant_ingr varchar(50) NOT NULL,
    PRIMARY KEY (fk_rece, fk_ingr),
    CONSTRAINT compone FOREIGN KEY (fk_ingr) REFERENCES Ingrediente (cod_ingr),
    CONSTRAINT compuesto FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE ESTA_COMP (
    cod_esta_comp serial,
    fk_esta integer,
    fk_comp integer,
    fecha_ini date NOT NULL,
    fecha_fin date,
    PRIMARY KEY (cod_esta_comp, fk_esta, fk_comp),
    CONSTRAINT ensena FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp),
    CONSTRAINT ensenado FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE ESTA_EVEN (
    cod_esta_even serial,
    fk_esta integer,
    fk_even integer,
    fecha_ini date NOT NULL,
    fecha_fin date,
    PRIMARY KEY (cod_esta_even, fk_esta, fk_even),
    CONSTRAINT muestra FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT mostrado FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE ESTA_VENT (
    cod_esta_vent serial,
    fk_esta integer,
    fk_vent integer,
    fecha_ini date NOT NULL,
    fecha_fin date,
    PRIMARY KEY (cod_esta_vent, fk_esta, fk_vent),
    CONSTRAINT refleja FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CONSTRAINT reflejado FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE PUNT_CLIE (
    cod_punt_clie serial,
    fk_clie integer,
    fk_meto_pago integer,
    fk_tasa integer NOT NULL,
    fk_vent integer NOT NULL UNIQUE,
    cant_puntos_acum numeric(10, 2),
    cant_puntos_canj numeric(10, 2),
    fecha_transaccion date NOT NULL,
    canjeado boolean,
    PRIMARY KEY (cod_punt_clie, fk_clie, fk_meto_pago),
    CONSTRAINT guarda FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT reformado FOREIGN KEY (fk_meto_pago) REFERENCES Punto_Canjeo (fk_meto_pago),
    CONSTRAINT cambia FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa),
    CONSTRAINT generado FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent)
);
