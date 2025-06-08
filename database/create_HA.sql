CREATE TABLE Ingrediente (
    cod_ingr serial,
    nombre_ingr varchar(40) NOT NULL,
    PRIMARY KEY (cod_ingr)
);

CREATE TABLE Receta (
    cod_rece serial,
    nombre_rece varchar(40) NOT NULL,
    PRIMARY KEY (cod_rece)
);

CREATE TABLE Instruccion (
    cod_inst serial,
    nombre_inst varchar(40) NOT NULL,
    fk_receta serial NOT NULL,
    PRIMARY KEY (cod_inst),
    CONSTRAINT instruye FOREIGN KEY (fk_receta) REFERENCES Receta (cod_rece)
);

CREATE TABLE Tipo_Cerveza (
    cod_tipo_cerv serial,
    nombre_tipo_cerv varchar(40) NOT NULL,
    fk_receta serial NOT NULL,
    fk_tipo_cerv serial,
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
    fk_tipo_cerv serial NOT NULL,
    PRIMARY KEY (cod_cerv),
    CONSTRAINT clasificado FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE Presentacion (
    cod_pres serial,
    nombre_pres varchar(40) NOT NULL,
    capacidad_pres numeric NOT NULL,
    PRIMARY KEY (cod_pres)
);

CREATE TABLE Lugar (
    cod_luga serial,
    nombre_luga varchar(40) NOT NULL,
    tipo_luga varchar(40) NOT NULL, -- TODO: AGREGARLE EL CHECK A LUGAR
    fk_luga serial,
    PRIMARY KEY (cod_luga),
    CONSTRAINT esta FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Tienda (
    cod_tien serial,
    nombre_tien varchar(40) NOT NULL,
    fecha_apertura_tien date,
    direccion_tien text NOT NULL,
    fk_luga serial NOT NULL,
    PRIMARY KEY (cod_tien),
    CONSTRAINT asignado FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Lugar_Tienda (
    cod_luga_tien serial,
    nombre_luga_tien varchar(40) NOT NULL,
    tipo_luga_tien varchar(40) NOT NULL,
    fk_luga_tien serial,
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
    capacidad_even numeric NOT NULL,
    descripcion_even text NOT NULL,
    precio_entrada_even numeric,
    cant_entradas_evento numeric NOT NULL,
    fk_tipo_even serial NOT NULL,
    fk_luga serial NOT NULL,
    PRIMARY KEY (cod_even),
    CONSTRAINT es FOREIGN KEY (fk_tipo_even) REFERENCES Tipo_Evento (cod_tipo_even),
    CONSTRAINT desarrollado FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Empleado (
    cod_empl serial,
    ci_empl numeric NOT NULL,
    primer_nom_empl varchar(40) NOT NULL,
    segundo_nom_empl varchar(40),
    primer_ape_empl varchar(40) NOT NULL,
    segundo_ape_empl varchar(40),
    salario_base_empl numeric NOT NULL,
    PRIMARY KEY (cod_empl)
);

CREATE TABLE Cargo (
    cod_carg serial,
    nombre_carg varchar(40) NOT NULL,
    PRIMARY KEY (cod_carg)
);

CREATE TABLE Miembro (
    rif_miem numeric,
    razon_social_miem varchar(40) NOT NULL,
    denom_comercial_miem varchar(40) NOT NULL,
    direccion_fiscal_miem text NOT NULL,
    pag_web_miem text,
    fk_luga_1 serial NOT NULL,
    fk_luga_2 serial,
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
    fk_miem numeric,
    PRIMARY KEY (cod_pers),
    CONSTRAINT cuenta_con FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Beneficio (
    cod_bene serial,
    nombre_bene varchar(40) NOT NULL,
    cantidad_bene numeric NOT NULL,
    PRIMARY KEY (cod_bene)
);

CREATE TABLE Departamento (
    cod_depa serial,
    fk_tien serial,
    PRIMARY KEY (cod_depa, fk_tien),
    CONSTRAINT formada FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien)
);

CREATE TABLE EMPL_CARG (
    fk_empl serial,
    fk_carg serial,
    fecha_ini date NOT NULL,
    fecha_fin date,
    cantidad_total_salario numeric NOT NULL,
    fk_depa_1 serial,
    fk_depa_2 serial,
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
    fk_empl_carg_1 serial NOT NULL,
    fk_empl_carg_2 serial NOT NULL,
    PRIMARY KEY (cod_vaca),
    CONSTRAINT goza FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg)
);

CREATE TABLE Asistencia (
    cod_asis serial,
    fecha_hora_ini_asis timestamp NOT NULL,
    fecha_hora_fin_asis timestamp NOT NULL,
    fk_empl_carg_1 serial NOT NULL,
    fk_empl_carg_2 serial NOT NULL,
    PRIMARY KEY (cod_asis),
    CONSTRAINT asiste FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg)
);

CREATE TABLE Horario (
    cod_hora serial,
    hora_ini_hora time NOT NULL,
    hora_fin_hora time NOT NULL,
    dia_hora varchar(20) NOT NULL, -- TODO: CHECK DIA DE LA SEMANA
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
    tasa_dolar_bcv numeric NOT NULL,
    tasa_punto numeric NOT NULL,
    fecha_ini_tasa date NOT NULL,
    fecha_fin_tasa date, -- TODO: ESTO DEBERIA SER NOT NULL CREEEEO
    PRIMARY KEY (cod_tasa)
);

CREATE TABLE Juez (
    cod_juez serial,
    primar_nom_juez varchar(40) NOT NULL,
    segundo_nom_juez varchar(40),
    primar_ape_juez varchar(40) NOT NULL,
    segundo_ape_juez varchar(40),
    ci_juez numeric NOT NULL,
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
    precio_cuot numeric NOT NULL,
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
    fecha_comp date NOT NULL, -- TODO: ESTO DEBERIA SER NULL SI LA COMPRA ES UN PEDIDO (NO SE HA TERMINADO)
    iva_comp numeric NOT NULL,
    base_imponible_comp numeric NOT NULL,
    total_comp numeric NOT NULL,
    fk_tien serial,
    fk_miem numeric,
    PRIMARY KEY (cod_comp),
    CONSTRAINT registra FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT realiza FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE CERV_PRES (
    fk_cerv serial,
    fk_pres serial,
    precio_pres_cerv numeric NOT NULL,
    fk_miem numeric NOT NULL,
    PRIMARY KEY (fk_cerv, fk_pres),
    CONSTRAINT empaqueta FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    CONSTRAINT empaquetada FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    CONSTRAINT distribuye FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Detalle_Compra (
    cod_deta_comp serial,
    cant_deta_comp numeric NOT NULL,
    precio_unitario_comp numeric NOT NULL,
    fk_cerv_pres_1 serial NOT NULL,
    fk_cerv_pres_2 serial NOT NULL,
    fk_comp serial NOT NULL,
    PRIMARY KEY (cod_deta_comp),
    CONSTRAINT obtenido FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT necesita FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp)
);

CREATE TABLE Cliente (
    rif_clie numeric,
    direccion_fiscal_clie text NOT NULL,
    direccion_fisica_clie text NOT NULL,
    fk_luga_1 serial NOT NULL,
    fk_luga_2 serial NOT NULL, -- TODO: ESTO NO DEBERIA SER NULL ? (porque es la secundaria)
    PRIMARY KEY (rif_clie),
    CONSTRAINT domiciliado FOREIGN KEY (fk_luga_1) REFERENCES Lugar (cod_luga),
    CONSTRAINT ubicado FOREIGN KEY (fk_luga_2) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Cliente_Natural (
    fk_clie serial,
    primer_nom_natu varchar(40) NOT NULL,
    segundo_nom_natu varchar(40),
    primer_ape_natu varchar(40) NOT NULL,
    segundo_ape_natu varchar(40),
    ci_natu numeric NOT NULL,
    PRIMARY KEY (fk_clie),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie)
);

CREATE TABLE Cliente_Juridico (
    fk_clie serial,
    razon_social_juri varchar(40) NOT NULL,
    denom_comercial_juri varchar(40) NOT NULL,
    capital_juri numeric NOT NULL,
    pag_web_juri text,
    PRIMARY KEY (fk_clie),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie)
);

CREATE TABLE Venta (
    cod_vent serial,
    fecha_vent date NOT NULL,
    iva_vent numeric NOT NULL,
    base_imponible_vent numeric NOT NULL,
    total_vent numeric NOT NULL,
    online boolean,
    fk_clie numeric,
    fk_miem numeric,
    PRIMARY KEY (cod_vent),
    -- Arco entre fk_clie - fk_miem
    CONSTRAINT compra FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT comercializa FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    CHECK ((fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_miem IS NOT NULL AND fk_clie IS NULL)),
    fk_even serial,
    fk_tien serial,
    fk_cuot serial,
    -- Arco entre fk_even - fk_tien - fk_cuot
    CONSTRAINT promociona FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT hace FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT cobra FOREIGN KEY (fk_cuot) REFERENCES Cuota (cod_cuot),
    CHECK ((fk_even IS NOT NULL AND fk_tien IS NULL AND fk_cuot IS NULL) OR (fk_tien IS NOT NULL AND fk_cuot IS NULL AND fk_even IS NULL) OR (fk_cuot IS NOT NULL AND fk_even IS NULL AND fk_tien IS NULL))
);

CREATE TABLE Usuario (
    cod_usua serial,
    contra_usua text NOT NULL,
    fk_rol serial NOT NULL,
    fk_empl serial,
    fk_miem numeric,
    fk_clie numeric,
    PRIMARY KEY (cod_usua),
    CONSTRAINT ejecuta FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol),
    CONSTRAINT transformado FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT adaptado FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT convertido FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco entre fk_empl - fk_miem - fk_clie
    CHECK ((fk_empl IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL) OR (fk_miem IS NOT NULL AND fk_clie IS NULL AND fk_empl IS NULL) OR (fk_clie IS NOT NULL AND fk_empl IS NULL AND fk_miem IS NULL))
);

CREATE TABLE Inventario_Tienda (
    fk_cerv_pres_1 serial,
    fk_cerv_pres_2 serial,
    fk_tien serial,
    fk_luga_tien serial NOT NULL,
    cant_pres numeric NOT NULL,
    precio_actual_pres numeric NOT NULL,
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien),
    CONSTRAINT conformado FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT posicionado FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT engloba FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE Inventario_Evento (
    fk_cerv_pres_1 serial,
    fk_cerv_pres_2 serial,
    fk_even serial,
    cant_pres numeric NOT NULL,
    precio_actual_pres numeric NOT NULL,
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_even),
    CONSTRAINT dispone FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT administra FOREIGN KEY (fk_even) REFERENCES Evento (cod_even)
);

CREATE TABLE Detalle_Venta (
    cod_deta_vent serial,
    cant_deta_vent numeric NOT NULL,
    precio_unitario_vent numeric NOT NULL,
    fk_vent serial NOT NULL,
    fk_inve_tien_1 serial,
    fk_inve_tien_2 serial,
    fk_inve_tien_3 serial,
    fk_inve_even_1 serial,
    fk_inve_even_2 serial,
    fk_inve_even_3 serial,
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
    fk_meto_pago serial,
    numero_tarj numeric NOT NULL,
    fecha_venci_tarj date NOT NULL,
    cvv_tarj numeric NOT NULL,
    nombre_titu_tarj varchar(40) NOT NULL,
    credito boolean,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Punto_Canjeo (
    fk_meto_pago serial,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Cheque (
    fk_meto_pago serial,
    numero_cheque numeric NOT NULL,
    numero_cuenta_cheque numeric NOT NULL,
    fk_banc serial NOT NULL,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    CONSTRAINT emite FOREIGN KEY (fk_banc) REFERENCES Banco (cod_banc)
);

CREATE TABLE Efectivo (
    fk_meto_pago serial,
    denominacion_efec char NOT NULL,
    PRIMARY KEY (fk_meto_pago),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Pago (
    fk_vent serial,
    fk_meto_pago serial,
    monto_pago numeric NOT NULL,
    fecha_pago date NOT NULL,
    fk_tasa serial NOT NULL,
    PRIMARY KEY (fk_vent, fk_meto_pago),
    CONSTRAINT formada FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CONSTRAINT usa FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    CONSTRAINT calculado FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa)
);

CREATE TABLE Telefono (
    cod_tele serial,
    cod_area_tele numeric NOT NULL,
    num_tele numeric NOT NULL,
    fk_clie numeric UNIQUE,
    fk_pers serial UNIQUE,
    fk_miem numeric,
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
    fk_clie numeric UNIQUE,
    fk_empl serial UNIQUE,
    fk_pers serial UNIQUE,
    fk_miem numeric,
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
    fk_even serial,
    fk_juez serial,
    fk_clie numeric,
    fk_miem numeric,
    PRIMARY KEY (fk_even),
    CONSTRAINT genera FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT forma_parte FOREIGN KEY (fk_juez) REFERENCES Juez (cod_juez),
    CONSTRAINT participa FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT asiste FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco entre Juez - Cliente - Miembro
    CHECK ((fk_juez IS NOT NULL AND fk_clie IS NULL AND fk_miem IS NULL) OR (fk_juez IS NULL AND fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_juez IS NULL AND fk_clie IS NULL AND fk_miem IS NOT NULL))
);

-- MUCHOS A MUCHOS
CREATE TABLE DESC_CERV (
    fk_desc serial,
    fk_cerv_pres_1 serial,
    fk_cerv_pres_2 serial,
    porcentaje_desc numeric NOT NULL,
    PRIMARY KEY (fk_desc, fk_cerv_pres_1, fk_cerv_pres_2),
    CONSTRAINT aplica FOREIGN KEY (fk_desc) REFERENCES Descuento (cod_desc),
    CONSTRAINT aplicado FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres)
);

CREATE TABLE PRIV_ROL (
    fk_rol serial,
    fk_priv serial,
    PRIMARY KEY (fk_rol, fk_priv),
    CONSTRAINT otorgado FOREIGN KEY (fk_priv) REFERENCES Privilegio (cod_priv),
    CONSTRAINT otorga FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol)
);

CREATE TABLE EMPL_HORA (
    fk_hora serial,
    fk_empl_carg_1 serial,
    fk_empl_carg_2 serial,
    PRIMARY KEY (fk_empl_carg_1, fk_empl_carg_2, fk_hora),
    CONSTRAINT cumple FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg),
    CONSTRAINT cumplido FOREIGN KEY (fk_hora) REFERENCES Horario (cod_hora)
);

CREATE TABLE EMPL_BENE (
    fk_empl_carg_1 serial,
    fk_empl_carg_2 serial,
    fk_bene serial,
    monto_bene numeric,
    PRIMARY KEY (fk_empl_carg_1, fk_empl_carg_2, fk_bene),
    CONSTRAINT disfruta FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg),
    CONSTRAINT disfrutado FOREIGN KEY (fk_bene) REFERENCES Beneficio (cod_bene)
);

CREATE TABLE CERV_CARA (
    fk_cerv serial,
    fk_cara serial,
    valor_cara varchar(40) NOT NULL,
    PRIMARY KEY (fk_cerv, fk_cara),
    CONSTRAINT caracteriza FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara),
    CONSTRAINT caracterizada FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv)
);

CREATE TABLE TIPO_CARA (
    fk_tipo_cerv serial,
    fk_cara serial,
    valor_cara varchar(50) NOT NULL,
    PRIMARY KEY (fk_tipo_cerv, fk_cara),
    CONSTRAINT estiliza FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara),
    CONSTRAINT estilizada FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE RECE_INGR (
    fk_rece serial,
    fk_ingr serial,
    cant_ingr varchar(50) NOT NULL,
    PRIMARY KEY (fk_rece, fk_ingr),
    CONSTRAINT compone FOREIGN KEY (fk_ingr) REFERENCES Ingrediente (cod_ingr),
    CONSTRAINT compuesto FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE ESTA_COMP (
    fk_esta serial,
    fk_comp serial,
    fecha_ini date NOT NULL,
    fecha_fin date,
    PRIMARY KEY (fk_esta, fk_comp),
    CONSTRAINT ensena FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp),
    CONSTRAINT ensenado FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE ESTA_EVEN (
    fk_esta serial,
    fk_even serial,
    fecha_ini date NOT NULL,
    fecha_fin date,
    PRIMARY KEY (fk_esta, fk_even),
    CONSTRAINT muestra FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT mostrado FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE ESTA_VENT (
    fk_esta serial,
    fk_vent serial,
    fecha_ini date NOT NULL,
    fecha_fin date,
    PRIMARY KEY (fk_esta, fk_vent),
    CONSTRAINT refleja FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CONSTRAINT reflejado FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE PUNT_CLIE (
    fk_clie numeric,
    fk_meto_pago serial,
    fk_tasa serial NOT NULL,
    fk_vent serial NOT NULL,
    PRIMARY KEY (fk_clie, fk_meto_pago),
    CONSTRAINT guarda FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT reformado FOREIGN KEY (fk_meto_pago) REFERENCES Punto_Canjeo (fk_meto_pago),
    CONSTRAINT cambia FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa),
    CONSTRAINT generado FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent)
);
