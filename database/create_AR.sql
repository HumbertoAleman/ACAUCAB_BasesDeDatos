CREATE TABLE Ingrediente (
    cod_ingr serial PRIMARY KEY,
    nombre_ingr varchar(50) NOT NULL
);

CREATE TABLE Receta (
    cod_rece serial PRIMARY KEY,
    nombre_rece varchar(50) NOT NULL
);

CREATE TABLE Presentacion (
    cod_pres serial PRIMARY KEY,
    nombre_pres varchar(50) NOT NULL,
    capacidad_pres numeric(5) NOT NULL
);

CREATE TABLE Caracteristica (
    cod_cara serial PRIMARY KEY,
    nombre_cara varchar(50) NOT NULL
);

CREATE TABLE Descuento (
    cod_desc serial PRIMARY KEY,
    descripcion_desc text NOT NULL,
    fecha_ini_desc date NOT NULL,
    fecha_fin_desc date NOT NULL,
    CHECK (fecha_fin_desc >= fecha_ini_desc)
);

CREATE TABLE Tipo_Evento (
    cod_tipo_even serial PRIMARY KEY,
    nombre_tipo_even varchar(50) NOT NULL
);

CREATE TABLE Juez (
    cod_juez serial PRIMARY KEY,
    primer_nom_juez varchar(20) NOT NULL,
    segundo_nom_juez varchar(20),
    primer_ape_juez varchar(20) NOT NULL,
    segundo_ape_juez varchar(20),
    CI_juez varchar(20) NOT NULL
);

CREATE TABLE Tasa (
    cod_tasa serial PRIMARY KEY,
    tasa_dolar_bcv numeric(10, 2) NOT NULL,
    tasa_punto numeric(10, 2) NOT NULL,
    fecha_ini_tasa date NOT NULL,
    fecha_fin_tasa date NOT NULL,
    CHECK (fecha_fin_tasa >= fecha_ini_tasa)
);

CREATE TABLE Banco (
    cod_banc serial PRIMARY KEY,
    nombre_banc varchar(50) NOT NULL
);

CREATE TABLE Metodo_Pago (
    cod_meto_pago serial PRIMARY KEY
);

CREATE TABLE Empleado (
    cod_empl serial PRIMARY KEY,
    CI_empl varchar(20) NOT NULL,
    primer_nom_empl varchar(20) NOT NULL,
    segundo_nom_empl varchar(20),
    primer_ape_empl varchar(20) NOT NULL,
    segundo_ape_empl varchar(20),
    salario_base_empl numeric(10, 2) NOT NULL
);

CREATE TABLE Cargo (
    cod_carg serial PRIMARY KEY,
    nombre_carg varchar(50) NOT NULL
);

CREATE TABLE Beneficio (
    cod_bene serial PRIMARY KEY,
    nombre_bene varchar(50) NOT NULL,
    cant_bene numeric(10, 2) NOT NULL
);

CREATE TABLE Rol (
    cod_rol serial PRIMARY KEY,
    nombre_rol varchar(50) NOT NULL,
    descripcion_rol text NOT NULL
);

CREATE TABLE Privilegio (
    cod_priv serial PRIMARY KEY,
    nombre_priv varchar(50) NOT NULL,
    descripcion_priv text NOT NULL
);

CREATE TABLE Horario (
    cod_hora serial PRIMARY KEY,
    hora_ini_hora time NOT NULL,
    hora_fin_hora time NOT NULL,
    dia_hora varchar(10) NOT NULL CHECK (dia_hora IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')),
    CHECK (hora_fin_hora > hora_ini_hora)
);

CREATE TABLE Estatus (
    cod_esta serial PRIMARY KEY,
    nombre_esta varchar(50) NOT NULL,
    descripcion_esta text
);

CREATE TABLE Cuota (
    cod_cuot serial PRIMARY KEY,
    nombre_plan_cuot varchar(50) NOT NULL,
    precio_cuot numeric(10, 2) NOT NULL
);

-- DEPENDENCIAS SIMPLES

CREATE TABLE Lugar (
    cod_luga serial PRIMARY KEY,
    nombre_luga text NOT NULL,
    tipo_luga varchar(15) NOT NULL CHECK (tipo_luga IN ('Pais', 'Estado', 'Ciudad', 'Parroquia')),
    fk_luga integer,
    CONSTRAINT esta FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Tipo_Cerveza (
    cod_tipo_cerv serial PRIMARY KEY,
    nombre_tipo_cerv varchar(50) NOT NULL,
    fk_rece integer NOT NULL,
    fk_tipo_cerv integer,
    CONSTRAINT sigue FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece),
    CONSTRAINT categorizado FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);


CREATE TABLE Instruccion (
    cod_inst serial PRIMARY KEY,
    nombre_inst varchar(50) NOT NULL,
    fk_rece integer NOT NULL,
    CONSTRAINT instruye FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE Cerveza (
    cod_cerv serial PRIMARY KEY,
    nombre_cerv varchar(50) NOT NULL,
    fk_tipo_cerv integer NOT NULL,
    CONSTRAINT clasificado FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE Punto_Canjeo (
    fk_meto_pago integer PRIMARY KEY,
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Tarjeta (
    fk_meto_pago integer PRIMARY KEY,
    num_tarj varchar(16) NOT NULL,
    fecha_venci_tarj date NOT NULL,
    cvv_tarj varchar(4) NOT NULL,
    nombre_titu_tarj varchar(50) NOT NULL,
    credito boolean NOT NULL,
    fk_meto_pago integer NOT NULL,
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Cheque (
    fk_meto_pago integer PRIMARY KEY,
    num_cheq varchar(50) NOT NULL,
    num_cuenta_cheq varchar(50) NOT NULL,
    fk_banc integer NOT NULL,
    fk_meto_pago integer NOT NULL,
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    CONSTRAINT emite FOREIGN KEY (fk_banc) REFERENCES Banco (cod_banc)
);

CREATE TABLE Efectivo (
    fk_meto_pago integer PRIMARY KEY,
    denominacion_efect numeric(10, 2) NOT NULL,
    fk_meto_pago integer NOT NULL,
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Asistencia (
    cod_asis serial PRIMARY KEY,
    fecha_hora_ini_asis timestamp NOT NULL,
    fecha_hora_fin_asis timestamp NOT NULL,
    fk_empl_carg_1 integer NOT NULL,
    fk_empl_carg_2 integer NOT NULL,
    CONSTRAINT asiste FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg)
);

CREATE TABLE Vacacion (
    cod_vaca serial PRIMARY KEY,
    fecha_ini_vaca date NOT NULL,
    fecha_fin_vaca date NOT NULL,
    pagada boolean,
    fk_empl_carg_1 integer NOT NULL,
    fk_empl_carg_2 integer NOT NULL,
    CONSTRAINT goza FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg)
    CHECK (fecha_fin_vac >= fecha_ini_vac)
);

CREATE TABLE Tienda (
    cod_tien serial PRIMARY KEY,
    nombre_tien varchar(50) NOT NULL,
    fecha_apertura_tien date NOT NULL,
    direccion_tien varchar(100) NOT NULL,
    fk_luga integer NOT NULL,
    CONSTRAINT asignado FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Departamento (
    cod_depa serial,
    nombre_depa varchar(50) NOT NULL,
    fk_tien integer NOT NULL,
    PRIMARY KEY (cod_depa, fk_tien),
    CONSTRAINT formada FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien)
);

CREATE TABLE Compra (
    cod_comp serial PRIMARY KEY,
    fecha_comp date NOT NULL,
    iva_comp numeric(10, 2) NOT NULL,
    base_imponible_comp numeric(10, 2) NOT NULL,
    total_comp numeric(10, 2) NOT NULL,
    fk_tien integer NOT NULL,
    fk_miem varchar(20) NOT NULL,
    CONSTRAINT registra FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT realiza FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Lugar_Tienda (
    cod_luga_tien serial PRIMARY KEY,
    nombre_luga_tien varchar(50) NOT NULL,
    tipo_luga_tien varchar(15) NOT NULL CHECK (tipo_luga_tien IN ('Almacen', 'Pasillo', 'Anaquel')),
    fk_luga_tien integer,
    CONSTRAINT localizado FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE PRIV_ROL (
    fk_priv integer NOT NULL,
    fk_rol integer NOT NULL,
    PRIMARY KEY (fk_priv, fk_rol),
    CONSTRAINT otorgado FOREIGN KEY (fk_priv) REFERENCES Privilegio (cod_priv),
    CONSTRAINT otorga FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol)
);

CREATE TABLE EMPL_CARG (
    fecha_ini date NOT NULL,
    fecha_fin date,
    cant_total_salario numeric(10, 2) NOT NULL,
    fk_empl integer NOT NULL,
    fk_carg integer NOT NULL,
    fk_depa_1 integer,
    fk_depa_2 integer,
    PRIMARY KEY (fk_empl, fk_carg),
    CONSTRAINT desempena FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT desempenado FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg),
    CONSTRAINT contiene FOREIGN KEY (fk_depa_1, fk_depa_2) REFERENCES Departamento (cod_depa, fk_tien)
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
    monto_bene numeric(10, 2) NOT NULL,
    fk_empl_carg_1 integer,
    fk_empl_carg_2 integer,
    fk_bene integer,
    PRIMARY KEY (fk_empl_carg_1, fk_empl_carg_2, fk_bene),
    CONSTRAINT disfruta FOREIGN KEY (fk_empl_carg_1, fk_empl_carg_2) REFERENCES EMPL_CARG (fk_empl, fk_carg),
    CONSTRAINT disfrutado FOREIGN KEY (fk_bene) REFERENCES Beneficio (cod_bene)
);

-- HERENCIA

CREATE TABLE Cliente (
    RIF_clie varchar(20) PRIMARY KEY,
    tipo_clie varchar(10) NOT NULL CHECK (tipo_clie IN ('Natural', 'Juridico')),

    primer_nom_clie varchar(20),
    segundo_nom_clie varchar(20),
    primer_ape_clie varchar(20),
    segundo_ape_clie varchar(20),
    CI_clie varchar(20),

    razon_social_clie varchar(50),
    denom_comercial_clie varchar(50),
    capital_clie numeric(9, 2),
    pag_web_clie text,

    direccion_fiscal_clie varchar(100) NOT NULL,
    direccion_fisica_clie varchar(100) NOT NULL,
    fk_luga_fiscal integer NOT NULL,
    fk_luga_fisica integer NOT NULL,

    CONSTRAINT domiciliado FOREIGN KEY (fk_luga_fiscal) REFERENCES Lugar (cod_luga),
    CONSTRAINT ubicado FOREIGN KEY (fk_luga_fisica) REFERENCES Lugar (cod_luga),

    CHECK (
        (tipo_clie = 'Natural' AND primer_nom_clie IS NOT NULL AND primer_ape_clie IS NOT NULL AND CI_clie IS NOT NULL AND razon_social_clie IS NULL AND denom_comercial_clie IS NULL AND capital_clie IS NULL AND pag_web_clie IS NULL)
        OR
        (tipo_clie = 'Juridico' AND razon_social_clie IS NOT NULL AND denom_comercial_clie IS NOT NULL AND capital_clie IS NOT NULL AND primer_nom_clie IS NULL AND segundo_nom_clie IS NULL AND primer_ape_clie IS NULL AND segundo_ape_clie IS NULL AND CI_clie IS NULL)
    )
);

-- DEPENDENCIAS INTERMEDIAS

CREATE TABLE Miembro (
    rif_miem varchar(20) PRIMARY KEY,
    razon_social_miem varchar(50) NOT NULL,
    denom_comercial_miem varchar(50) NOT NULL,
    direccion_fiscal_miem varchar(100) NOT NULL,
    direccion_fisica_miem varchar(100) NOT NULL,
    pag_web_miem text,
    fk_luga_fiscal integer NOT NULL,
    fk_luga_fisica integer NOT NULL,
    CONSTRAINT encontrado FOREIGN KEY (fk_luga_fiscal) REFERENCES Lugar (cod_luga),
    CONSTRAINT proveniente FOREIGN KEY (fk_luga_fisica) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Contacto (
    cod_pers serial PRIMARY KEY,
    primer_nom_pers varchar(20) NOT NULL,
    segundo_nom_pers varchar(20),
    primer_ape_pers varchar(20) NOT NULL,
    segundo_ape_pers varchar(20),
    fk_miem varchar(20) NOT NULL,
    CONSTRAINT cuenta_con FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Evento (
    cod_even serial PRIMARY KEY,
    nombre_even varchar(50) NOT NULL,
    fecha_hora_ini_even timestamp NOT NULL,
    fecha_hora_fin_even timestamp NOT NULL,
    direccion_even varchar(100) NOT NULL,
    capacidad_even numeric(5) NOT NULL,
    descripcion_even text,
    precio_entrada_even numeric(10, 2),
    cant_entradas_even numeric(5) NOT NULL,
    fk_luga integer NOT NULL,
    fk_tipo_even integer NOT NULL,
    CONSTRAINT es FOREIGN KEY (fk_tipo_even) REFERENCES Tipo_Evento (cod_tipo_even),
    CONSTRAINT desarrollado FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
    CHECK (fecha_hora_fin_even >= fecha_hora_ini_even)
);

CREATE TABLE Telefono (
    cod_tele serial PRIMARY KEY,
    cod_area_tele varchar(10) NOT NULL,
    num_tele varchar(15) NOT NULL,
    fk_miem varchar(20),
    fk_pers integer,
    fk_clie varchar(20),
    CONSTRAINT asocia FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT tiene FOREIGN KEY (fk_pers) REFERENCES Contacto (cod_pers),
    CONSTRAINT utiliza FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco Exclusivo: Un teléfono pertenece a un Miembro, un Contacto O un Cliente.
    CHECK (
        (fk_miem IS NOT NULL AND fk_pers IS NULL AND fk_clie IS NULL) OR
        (fk_pers IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL) OR
        (fk_clie IS NOT NULL AND fk_miem IS NULL AND fk_pers IS NULL)
    )
);

CREATE TABLE Correo (
    cod_corr serial PRIMARY KEY,
    prefijo_corr varchar(50) NOT NULL,
    dominio_corr varchar(50) NOT NULL,
    fk_miem varchar(20),
    fk_pers integer,
    fk_clie varchar(20),
    fk_empl integer,
    CONSTRAINT relaciona FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT identifica FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT conecta FOREIGN KEY (fk_pers) REFERENCES Contacto (cod_pers),
    CONSTRAINT vincula FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco Exclusivo: Un correo pertenece a un Miembro, un Contacto, un Cliente O un Empleado.
    CHECK (
        (fk_miem IS NOT NULL AND fk_pers IS NULL AND fk_clie IS NULL AND fk_empl IS NULL) OR
        (fk_pers IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL AND fk_empl IS NULL) OR
        (fk_clie IS NOT NULL AND fk_pers IS NULL AND fk_miem IS NULL AND fk_empl IS NULL) OR
        (fk_empl IS NOT NULL AND fk_pers IS NULL AND fk_miem IS NULL AND fk_clie IS NULL)
    )
);

CREATE TABLE Usuario (
    cod_usua serial PRIMARY KEY,
    contra_usua varchar(255) NOT NULL,
    username_usua varchar(50) NOT NULL,
    fk_rol integer NOT NULL,
    fk_empl integer,
    fk_clie varchar(20),
    fk_miem varchar(20),
    CONSTRAINT ejecuta FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol),
    CONSTRAINT transformado FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    CONSTRAINT adaptado FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT convertido FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco Exclusivo: Un usuario está asociado a un Empleado, un Cliente O un Miembro.
    CHECK (
        (fk_empl IS NOT NULL AND fk_clie IS NULL AND fk_miem IS NULL) OR
        (fk_empl IS NULL AND fk_clie IS NOT NULL AND fk_miem IS NULL) OR
        (fk_empl IS NULL AND fk_clie IS NULL AND fk_miem IS NOT NULL)
    )
);

CREATE TABLE Registro_Evento (
    cod_regi serial PRIMARY KEY,
    fecha_hora_regi timestamp NOT NULL,
    fk_even integer NOT NULL,
    fk_juez integer,
    fk_clie varchar(20),
    fk_miem varchar(20),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    FOREIGN KEY (fk_juez) REFERENCES Juez (cod_juez),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    -- Arco Exclusivo: Un registro de evento es para un Juez, un Cliente O un Miembro.
    CHECK (
        (fk_juez IS NOT NULL AND fk_clie IS NULL AND fk_miem IS NULL) OR
        (fk_clie IS NOT NULL AND fk_juez IS NULL AND fk_miem IS NULL) OR
        (fk_miem IS NOT NULL AND fk_juez IS NULL AND fk_clie IS NULL)
    )
);

-- RELACIONES N A N

CREATE TABLE RECE_INGR (
    cant_ingr numeric(10, 2) NOT NULL,
    fk_rece integer NOT NULL,
    fk_ingr integer NOT NULL,
    PRIMARY KEY (fk_rece, fk_ingr),
    CONSTRAINT compone FOREIGN KEY (fk_ingr) REFERENCES Ingrediente (cod_ingr),
    CONSTRAINT compuesto FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE CERV_CARA (
    valor_cara_cerv numeric(10, 2) NOT NULL,
    fk_cerv integer NOT NULL,
    fk_cara integer NOT NULL,
    PRIMARY KEY (fk_cerv, fk_cara),
    CONSTRAINT caracteriza FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara),
    CONSTRAINT caracterizada FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv)
);

CREATE TABLE TIPO_CARA (
    valor_tipo_cara numeric(10, 2) NOT NULL,
    fk_tipo_cerv integer NOT NULL,
    fk_cara integer NOT NULL,
    PRIMARY KEY (fk_tipo_cerv, fk_cara),
    CONSTRAINT estiliza FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara),
    CONSTRAINT estilizada FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE CERV_PRES (
    precio_pres_cerv numeric(10, 2) NOT NULL,
    fk_pres integer NOT NULL,
    fk_cerv integer NOT NULL,
    fk_miem varchar(20) NOT NULL,
    PRIMARY KEY (fk_pres, fk_cerv),
    CONSTRAINT empaqueta FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    CONSTRAINT empaquetada FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    CONSTRAINT distribuye FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE DESC_CERV (
    porcentaje_desc numeric(5, 2) NOT NULL,
    fk_desc integer NOT NULL,
    fk_cerv_pres_1 integer NOT NULL,
    fk_cerv_pres_2 integer NOT NULL,
    PRIMARY KEY (fk_desc, fk_cerv_pres_1, fk_cerv_pres_2),
    CONSTRAINT aplica FOREIGN KEY (fk_desc) REFERENCES Descuento (cod_desc),
    CONSTRAINT aplicado FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres)
);

CREATE TABLE Inventario_Tienda (
    cant_pres numeric(5) NOT NULL,
    precio_actual_pres numeric(10, 2) NOT NULL,
    fk_tien integer NOT NULL,
    fk_luga_tien integer,
    fk_cerv_pres_1 integer,
    fk_cerv_pres_2 integer,    
    PRIMARY KEY (fk_tien, fk_pres, fk_cerv),
    CONSTRAINT conformado FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT posicionado FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT engloba FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE Inventario_Evento (
    cant_pres numeric(5) NOT NULL,
    precio_actual_pres numeric(10, 2) NOT NULL,
    fk_even integer NOT NULL,
    fk_cerv_pres_1 integer,
    fk_cerv_pres_2 integer,
    PRIMARY KEY (fk_cerv_pres_1, fk_cerv_pres_2, fk_even),
    CONSTRAINT dispone FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT administra FOREIGN KEY (fk_even) REFERENCES Evento (cod_even)
);

CREATE TABLE Pago (
    monto_pago numeric(10, 2) NOT NULL,
    fecha_pago date NOT NULL,
    fk_vent integer NOT NULL,
    fk_meto_pago integer NOT NULL,
    fk_tasa integer NOT NULL,
    PRIMARY KEY (fk_vent, fk_meto_pago),
    CONSTRAINT formada FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    CONSTRAINT usa FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    CONSTRAINT calculado FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa)
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

CREATE TABLE Detalle_Compra (
    cod_deta_comp serial PRIMARY KEY,
    cant_deta_comp numeric(10, 2) NOT NULL,
    precio_unitario_comp numeric(10, 2) NOT NULL,
    fk_cerv_pres_1 integer NOT NULL,
    fk_cerv_pres_2 integer NOT NULL,
    fk_comp integer NOT NULL,
    PRIMARY KEY (cod_deta_comp),
    CONSTRAINT obtenido FOREIGN KEY (fk_cerv_pres_1, fk_cerv_pres_2) REFERENCES CERV_PRES (fk_cerv, fk_pres),
    CONSTRAINT necesita FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp)
    CONSTRAINT UQ_DetalleCompra (fk_comp, fk_pres, fk_cerv)
);

CREATE TABLE Venta (
    cod_vent serial PRIMARY KEY,
    fecha_vent date NOT NULL,
    iva_vent numeric(10, 2) NOT NULL,
    base_imponible_vent numeric(10, 2) NOT NULL,
    total_vent numeric(10, 2) NOT NULL,
    online boolean NOT NULL,
    fk_clie varchar(20),
    fk_miem varchar(20),
    fk_even integer,
    fk_tien integer,
    fk_cuot integer,
    CONSTRAINT compra FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT comercializa FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    CONSTRAINT promociona FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    CONSTRAINT hace FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    CONSTRAINT cobra FOREIGN KEY (fk_cuot) REFERENCES Cuota (cod_cuot),
    -- Arco Exclusivo: A quien se hace la venta (Cliente O Miembro)
    CHECK ((fk_clie IS NOT NULL AND fk_miem IS NULL) OR (fk_clie IS NULL AND fk_miem IS NOT NULL)),
    -- Arco Exclusivo: De donde sale la venta (Evento O Tienda O Cuota)
    CHECK (
        (fk_even IS NOT NULL AND fk_tien IS NULL AND fk_cuot IS NULL) OR
        (fk_even IS NULL AND fk_tien IS NOT NULL AND fk_cuot IS NULL) OR
        (fk_even IS NULL AND fk_tien IS NULL AND fk_cuot IS NOT NULL)
    )
);

CREATE TABLE Detalle_Venta (
    cod_deta_vent serial PRIMARY KEY,
    cant_deta_vent numeric(10, 2) NOT NULL,
    precio_unitario_vent numeric(10, 2) NOT NULL,
    
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

    -- Arco Exclusivo: Un detalle de venta proviene de Inventario_Tienda O Inventario_Evento
    CHECK (((fk_inve_tien_1 IS NOT NULL AND fk_inve_tien_2 IS NOT NULL AND fk_inve_tien_3 IS NOT NULL) AND (fk_inve_even_1 IS NULL AND fk_inve_even_2 IS NULL AND fk_inve_even_3 IS NULL)) OR ((fk_inve_tien_1 IS NULL AND fk_inve_tien_2 IS NULL AND fk_inve_tien_3 IS NULL) AND (fk_inve_even_1 IS NOT NULL AND fk_inve_even_2 IS NOT NULL AND fk_inve_even_3 IS NOT NULL)))
);

-- PUNTO CANJEO

CREATE TABLE PUNT_CLIE (
    cod_punt_clie serial PRIMARY KEY,
    cant_puntos_acum numeric(10, 2),
    cant_puntos_canj numeric(10, 2),
    fecha_transaccion date NOT NULL,
    canjeado boolean NOT NULL,
    fk_clie integer,
    fk_meto_pago integer,
    fk_tasa integer NOT NULL,
    fk_vent integer NOT NULL,
    CONSTRAINT guarda FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    CONSTRAINT reformado FOREIGN KEY (fk_meto_pago) REFERENCES Punto_Canjeo (fk_meto_pago),
    CONSTRAINT cambia FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa),
    CONSTRAINT generado FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent)
);