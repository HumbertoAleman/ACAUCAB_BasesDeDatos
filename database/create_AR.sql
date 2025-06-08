CREATE TABLE Ingrediente (
    cod_ingr serial PRIMARY KEY,
    nombre_ingr varchar(50) NOT NULL UNIQUE
);

CREATE TABLE Receta (
    cod_rece serial PRIMARY KEY,
    nombre_rece varchar(50) NOT NULL UNIQUE
);

CREATE TABLE Presentacion (
    cod_pres serial PRIMARY KEY,
    nombre_pres varchar(50) NOT NULL UNIQUE,
    capacidad_pres numeric(5) NOT NULL 
);

CREATE TABLE Caracteristica (
    cod_cara serial PRIMARY KEY,
    nombre_cara varchar(50) NOT NULL UNIQUE
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
    nombre_tipo_even varchar(50) NOT NULL UNIQUE
);

CREATE TABLE Juez (
    cod_juez serial PRIMARY KEY,
    primer_nom_juez varchar(20) NOT NULL,
    segundo_nom_juez varchar(20),
    primer_ape_juez varchar(20) NOT NULL,
    segundo_ape_juez varchar(20),
    CI_juez varchar(20) NOT NULL UNIQUE
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
    nombre_banc varchar(50) NOT NULL UNIQUE 
);

CREATE TABLE Metodo_Pago (
    cod_meto_pago serial PRIMARY KEY
);

CREATE TABLE Empleado (
    cod_empl serial PRIMARY KEY,
    CI_empl varchar(20) NOT NULL UNIQUE, 
    primer_nom_empl varchar(20) NOT NULL,
    segundo_nom_empl varchar(20),
    primer_ape_empl varchar(20) NOT NULL,
    segundo_ape_empl varchar(20),
    salario_base_empl numeric(10, 2) NOT NULL
);

CREATE TABLE Cargo (
    cod_carg serial PRIMARY KEY,
    nombre_carg varchar(50) NOT NULL UNIQUE 
);

CREATE TABLE Beneficio (
    cod_bene serial PRIMARY KEY,
    nombre_bene varchar(50) NOT NULL UNIQUE, 
    cant_bene numeric(10, 2) NOT NULL 
);

CREATE TABLE Rol (
    cod_rol serial PRIMARY KEY,
    nombre_rol varchar(50) NOT NULL UNIQUE, 
    descripcion_rol text NOT NULL
);

CREATE TABLE Privilegio (
    cod_priv serial PRIMARY KEY,
    nombre_priv varchar(50) NOT NULL UNIQUE, 
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
    nombre_esta varchar(50) NOT NULL UNIQUE, 
    descripcion_esta text
);

CREATE TABLE Cuota (
    cod_cuot serial PRIMARY KEY,
    nombre_plan_cuot varchar(50) NOT NULL UNIQUE,
    precio_cuot numeric(10, 2) NOT NULL
);

-- DEPENDENCIAS SIMPLES

CREATE TABLE Lugar (
    cod_luga serial PRIMARY KEY,
    nombre_luga text NOT NULL,
    tipo_luga varchar(15) NOT NULL CHECK (tipo_luga IN ('Pais', 'Estado', 'Ciudad', 'Parroquia')),
    fk_luga serial,
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Tipo_Cerveza (
    cod_tipo_cerv serial PRIMARY KEY,
    nombre_tipo_cerv varchar(50) NOT NULL UNIQUE,
    fk_rece serial NOT NULL UNIQUE,
    fk_tipo_cerv_padre serial,
    FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece),
    FOREIGN KEY (fk_tipo_cerv_padre) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);


CREATE TABLE Instruccion (
    cod_inst serial PRIMARY KEY,
    nombre_inst varchar(50) NOT NULL,
    fk_rece serial NOT NULL,
    FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE Cerveza (
    cod_cerv serial PRIMARY KEY,
    nombre_cerv varchar(50) NOT NULL UNIQUE,
    fk_tipo_cerv serial NOT NULL,
    FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv)
);

CREATE TABLE Punto_Canjeo (
    cod_punt_canj serial PRIMARY KEY,
    fk_meto_pago serial NOT NULL UNIQUE,
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Tarjeta (
    cod_tarj serial PRIMARY KEY,
    numero_tarj varchar(16) NOT NULL UNIQUE,
    fecha_venci_tarj date NOT NULL,
    cvv_tarj varchar(4) NOT NULL,
    nombre_titu_tarj varchar(50) NOT NULL,
    credito boolean NOT NULL, 
    fk_meto_pago serial NOT NULL UNIQUE,
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Cheque (
    cod_cheq serial PRIMARY KEY, 
    numero_cheq varchar(50) NOT NULL UNIQUE, 
    numero_cuenta_cheq varchar(50) NOT NULL, 
    fk_banc serial NOT NULL, 
    fk_meto_pago serial NOT NULL UNIQUE, 
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    FOREIGN KEY (fk_banc) REFERENCES Banco (cod_banc)
);

CREATE TABLE Efectivo (
    cod_efec serial PRIMARY KEY, 
    denominacion_efect numeric(10, 2) NOT NULL, 
    fk_meto_pago serial NOT NULL UNIQUE, 
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago)
);

CREATE TABLE Asistencia (
    cod_asis serial PRIMARY KEY,
    fecha_hora_ent_asis timestamp NOT NULL,
    fecha_hora_sal_asis timestamp, 
    fk_empl serial NOT NULL, 
    fk_carg serial NOT NULL, 
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg)
);

CREATE TABLE Vacacion (
    cod_vac serial PRIMARY KEY,
    fecha_ini_vac date NOT NULL,
    fecha_fin_vac date NOT NULL,
    pagada boolean NOT NULL, 
    fk_empl serial NOT NULL, 
    fk_carg serial NOT NULL,
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg),
    CHECK (fecha_fin_vac >= fecha_ini_vac)
);

CREATE TABLE Tienda (
    cod_tien serial PRIMARY KEY,
    nombre_tien varchar(50) NOT NULL UNIQUE,
    fecha_apertura_tien date NOT NULL,
    direccion_tien varchar(100) NOT NULL, 
    fk_luga serial NOT NULL,
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Departamento (
    cod_depa serial,
    nombre_depa varchar(50) NOT NULL UNIQUE, -
    fk_tien serial NOT NULL, 
    PRIMARY KEY (cod_depa, fk_tien), 
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien)
);

CREATE TABLE Compra (
    cod_comp serial PRIMARY KEY,
    fecha_comp date NOT NULL,
    iva_comp numeric(10, 2) NOT NULL,
    base_imponible_comp numeric(10, 2) NOT NULL,
    total_comp numeric(10, 2) NOT NULL,
    fk_tien serial NOT NULL, 
    fk_miem varchar(20) NOT NULL, 
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Lugar_Tienda (
    cod_luga_tien serial PRIMARY KEY,
    nombre_luga_tien varchar(50) NOT NULL UNIQUE,
    tipo_luga_tien varchar(15) NOT NULL CHECK (tipo_luga_tien IN ('Almacen', 'Pasillo', 'Anaquel')),
    fk_luga_tien_padre serial,
    FOREIGN KEY (fk_luga_tien_padre) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE Priv_Rol (
    fk_priv serial NOT NULL,
    fk_rol serial NOT NULL,
    PRIMARY KEY (fk_priv, fk_rol), 
    FOREIGN KEY (fk_priv) REFERENCES Privilegio (cod_priv),
    FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol)
);

CREATE TABLE EMPL_CARG (
    fecha_ini date NOT NULL,
    fecha_fin date, 
    cant_total_salario numeric(10, 2) NOT NULL,
    fk_empl serial NOT NULL,
    fk_carg serial NOT NULL,
    fk_depa serial NOT NULL,
    PRIMARY KEY (fk_empl, fk_carg), 
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg),
    FOREIGN KEY (fk_depa) REFERENCES Departamento (cod_depa, fk_tien)
);

CREATE TABLE EMPL_HORA (
    fk_empl serial NOT NULL,
    fk_carg serial NOT NULL,
    fk_hora serial NOT NULL,
    PRIMARY KEY (fk_empl, fk_carg, fk_hora), 
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg),
    FOREIGN KEY (fk_hora) REFERENCES Horario (cod_hora)
);

CREATE TABLE EMPL_BENE (
    monto_bene numeric(10, 2) NOT NULL,
    fk_empl serial NOT NULL,
    fk_carg serial NOT NULL,
    fk_bene serial NOT NULL,
    PRIMARY KEY (fk_empl, fk_carg, fk_bene),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_bene) REFERENCES Beneficio (cod_bene),
    FOREIGN KEY (fk_carg) REFERENCES Cargo (cod_carg)
);

-- HERENCIA

CREATE TABLE Cliente (
    RIF_clie varchar(20) PRIMARY KEY,
    tipo_clie varchar(10) NOT NULL CHECK (tipo_clie IN ('Natural', 'Juridico')),

    primer_nom_clie varchar(20),
    segundo_nom_clie varchar(20),
    primer_ape_clie varchar(20),
    segundo_ape_clie varchar(20),
    CI_clie varchar(20) UNIQUE,

    razon_social_clie varchar(50) UNIQUE,
    denom_comercial_clie varchar(50),
    capital_clie numeric(9, 2),
    pag_web_clie text,

    direccion_fiscal_clie varchar(100) NOT NULL,
    direccion_fisica_clie varchar(100) NOT NULL,
    fk_luga_fiscal serial NOT NULL,
    fk_luga_fisica serial NOT NULL,

    FOREIGN KEY (fk_luga_fiscal) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_luga_fisica) REFERENCES Lugar (cod_luga),

    CHECK (
        (tipo_clie = 'Natural' AND primer_nom_clie IS NOT NULL AND primer_ape_clie IS NOT NULL AND CI_clie IS NOT NULL AND razon_social_clie IS NULL AND denom_comercial_clie IS NULL AND capital_clie IS NULL AND pag_web_clie IS NULL)
        OR
        (tipo_clie = 'Juridico' AND razon_social_clie IS NOT NULL AND denom_comercial_clie IS NOT NULL AND capital_clie IS NOT NULL AND primer_nom_clie IS NULL AND segundo_nom_clie IS NULL AND primer_ape_clie IS NULL AND segundo_ape_clie IS NULL AND CI_clie IS NULL)
    )
);

-- DEPENDENCIAS INTERMEDIAS

CREATE TABLE Miembro (
    rif_miem varchar(20) PRIMARY KEY,
    razon_social_miem varchar(50) NOT NULL UNIQUE,
    denom_comercial_miem varchar(50) NOT NULL,
    direccion_fiscal_miem varchar(100) NOT NULL,
    direccion_fisica_miem varchar(100) NOT NULL,
    pag_web_miem text,
    fk_luga_fiscal serial NOT NULL, 
    fk_luga_fisica serial NOT NULL, 
    FOREIGN KEY (fk_luga_fiscal) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_luga_fisica) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Contacto (
    cod_pers serial PRIMARY KEY, 
    primer_nom_pers varchar(20) NOT NULL,
    segundo_nom_pers varchar(20),
    primer_ape_pers varchar(20) NOT NULL,
    segundo_ape_pers varchar(20),
    fk_miem varchar(20) NOT NULL, 
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE Evento (
    cod_even serial PRIMARY KEY,
    nombre_even varchar(50) NOT NULL UNIQUE,
    fecha_hora_ini_even timestamp NOT NULL, 
    fecha_hora_fin_even timestamp NOT NULL,
    direccion_even varchar(100) NOT NULL,
    capacidad_even numeric(5) NOT NULL,
    descripcion_even text,
    precio_entrada_even numeric(10, 2), 
    cant_entradas_even numeric(5) NOT NULL,
    fk_luga serial NOT NULL, 
    fk_tipo_even serial NOT NULL, 
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_tipo_even) REFERENCES Tipo_Evento (cod_tipo_even),
    CHECK (fecha_hora_fin_even >= fecha_hora_ini_even)
);

CREATE TABLE Telefono (
    cod_tele serial PRIMARY KEY,
    cod_area_tele varchar(10) NOT NULL, 
    num_tele varchar(15) NOT NULL, 
    fk_miem varchar(20),
    fk_pers serial,
    fk_clie varchar(20),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_pers) REFERENCES Contacto (cod_pers),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    -- Arco Exclusivo: Un teléfono pertenece a un Miembro, un Contacto O un Cliente.
    CHECK (
        (fk_miem IS NOT NULL AND fk_cont IS NULL AND fk_clie IS NULL) OR
        (fk_cont IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL) OR
        (fk_clie IS NOT NULL AND fk_miem IS NULL AND fk_cont IS NULL)
    )
);

CREATE TABLE Correo (
    cod_corr serial PRIMARY KEY,
    prefijo_corr varchar(50) NOT NULL,
    dominio_corr varchar(50) NOT NULL,
    fk_miem varchar(20),
    fk_pers serial, 
    fk_clie varchar(20),
    fk_empl serial,
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_pers) REFERENCES Contacto (cod_pers), 
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    -- Arco Exclusivo: Un correo pertenece a un Miembro, un Contacto, un Cliente O un Empleado.
    CHECK (
        (fk_miem IS NOT NULL AND fk_cont IS NULL AND fk_clie IS NULL AND fk_empl IS NULL) OR
        (fk_cont IS NOT NULL AND fk_miem IS NULL AND fk_clie IS NULL AND fk_empl IS NULL) OR
        (fk_clie IS NOT NULL AND fk_cont IS NULL AND fk_miem IS NULL AND fk_empl IS NULL) OR
        (fk_empl IS NOT NULL AND fk_cont IS NULL AND fk_miem IS NULL AND fk_clie IS NULL)
    )
);

CREATE TABLE Usuario (
    cod_usua serial PRIMARY KEY,
    contra_usua varchar(255) NOT NULL, 
    username_usua varchar(50) NOT NULL UNIQUE, 
    fk_rol serial NOT NULL, 
    fk_empl serial UNIQUE, 
    fk_clie varchar(20) UNIQUE, 
    fk_miem varchar(20) UNIQUE, 
    FOREIGN KEY (fk_rol) REFERENCES Rol (cod_rol),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl),
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
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
    fk_even serial NOT NULL, 
    fk_juez serial UNIQUE, 
    fk_clie varchar(20) UNIQUE, 
    fk_miem varchar(20) UNIQUE,
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
    fk_rece serial NOT NULL,
    fk_ingr serial NOT NULL,
    PRIMARY KEY (fk_rece, fk_ingr),
    FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece),
    FOREIGN KEY (fk_ingr) REFERENCES Ingrediente (cod_ingr)
);

CREATE TABLE CERV_CARA (
    valor_cara_cerv numeric(10, 2) NOT NULL, 
    fk_cerv serial NOT NULL,
    fk_cara serial NOT NULL,
    PRIMARY KEY (fk_cerv, fk_cara),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara)
);

CREATE TABLE TIPO_CARA (
    valor_tipo_cara numeric(10, 2) NOT NULL,
    fk_tipo_cerv serial NOT NULL,
    fk_cara serial NOT NULL,
    PRIMARY KEY (fk_tipo_cerv, fk_cara),
    FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv),
    FOREIGN KEY (fk_cara) REFERENCES Caracteristica (cod_cara)
);

CREATE TABLE CERV_PRES (
    precio_pres_cerv numeric(10, 2) NOT NULL, 
    fk_pres serial NOT NULL,
    fk_cerv serial NOT NULL,
    fk_miem varchar(20) NOT NULL,
    PRIMARY KEY (fk_pres, fk_cerv),
    FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem)
);

CREATE TABLE DESC_CERV (
    porcentaje_desc numeric(5, 2) NOT NULL,
    fk_desc serial NOT NULL,
    fk_cerv serial NOT NULL,
    fk_pres serial NOT NULL,
    PRIMARY KEY (fk_desc, fk_cerv, fk_pres),
    FOREIGN KEY (fk_desc) REFERENCES Descuento (cod_desc),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres)
);

CREATE TABLE Inventario_Tienda (
    cant_pres numeric(5) NOT NULL, 
    precio_actual_pres numeric(10, 2) NOT NULL,
    fk_tien serial NOT NULL,
    fk_pres serial NOT NULL,
    fk_cerv serial NOT NULL,
    fk_luga_tien serial,
    PRIMARY KEY (fk_tien, fk_pres, fk_cerv),
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    FOREIGN KEY (fk_luga_tien) REFERENCES Lugar_Tienda (cod_luga_tien)
);

CREATE TABLE Inventario_Evento (
    cant_pres numeric(5) NOT NULL, 
    precio_actual_pres numeric(10, 2) NOT NULL,
    fk_even serial NOT NULL,
    fk_pres serial NOT NULL,
    fk_cerv serial NOT NULL,
    PRIMARY KEY (fk_even, fk_pres, fk_cerv),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
);

CREATE TABLE Pago (
    monto_pago numeric(10, 2) NOT NULL,
    fecha_pago date NOT NULL,
    fk_vent serial NOT NULL,
    fk_meto_pago serial NOT NULL,
    fk_tasa serial NOT NULL,
    PRIMARY KEY (fk_vent, fk_meto_pago), 
    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    FOREIGN KEY (fk_meto_pago) REFERENCES Metodo_Pago (cod_meto_pago),
    FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa)
);

CREATE TABLE ESTA_EVEN (
    fecha_ini date NOT NULL,
    fecha_fin date,
    fk_even serial NOT NULL,
    fk_esta serial NOT NULL,
    PRIMARY KEY (fk_even, fk_esta),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE ESTA_COMP (
    fecha_ini date NOT NULL,
    fecha_fin date,
    fk_comp serial NOT NULL,
    fk_esta serial NOT NULL,
    PRIMARY KEY (fk_comp, fk_esta),
    FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp),
    FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE ESTA_VENT (
    fecha_ini date NOT NULL,
    fecha_fin date,
    fk_vent serial NOT NULL,
    fk_esta serial NOT NULL,
    PRIMARY KEY (fk_vent, fk_esta),
    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    FOREIGN KEY (fk_esta) REFERENCES Estatus (cod_esta)
);

CREATE TABLE Detalle_Compra (
    cod_deta_comp serial PRIMARY KEY,
    cant_deta_comp numeric(10, 2) NOT NULL,
    precio_unitario_comp numeric(10, 2) NOT NULL,
    fk_comp serial NOT NULL,
    fk_pres serial NOT NULL,
    fk_cerv serial NOT NULL,
    FOREIGN KEY (fk_comp) REFERENCES Compra (cod_comp),
    FOREIGN KEY (fk_pres) REFERENCES Presentacion (cod_pres),
    FOREIGN KEY (fk_cerv) REFERENCES Cerveza (cod_cerv),
    CONSTRAINT UQ_DetalleCompra UNIQUE (fk_comp, fk_pres, fk_cerv)
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
    fk_even serial,
    fk_tien serial,
    fk_cuot serial,
    FOREIGN KEY (fk_clie) REFERENCES Cliente (rif_clie),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (rif_miem),
    FOREIGN KEY (fk_even) REFERENCES Evento (cod_even),
    FOREIGN KEY (fk_tien) REFERENCES Tienda (cod_tien),
    FOREIGN KEY (fk_cuot) REFERENCES Cuota (cod_cuot),
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
    fk_vent serial NOT NULL,

    fk_inv_tien_tien serial,
    fk_inv_tien_pres serial, 
    fk_inv_tien_cerv serial, 

    fk_inv_even_even serial,
    fk_inv_even_pres serial,
    fk_inv_even_cerv serial,

    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent),
    FOREIGN KEY (fk_inv_tien_tien, fk_inv_tien_pres, fk_inv_tien_cerv) REFERENCES Inventario_Tienda (fk_tien, fk_pres, fk_cerv),
    FOREIGN KEY (fk_inv_even_even, fk_inv_even_pres, fk_inv_even_cerv) REFERENCES Inventario_Evento (fk_even, fk_pres, fk_cerv),

    -- Arco Exclusivo: Un detalle de venta proviene de Inventario_Tienda O Inventario_Evento
    CHECK (
        (fk_inv_tien_tien IS NOT NULL AND fk_inv_tien_pres IS NOT NULL AND fk_inv_tien_cerv IS NOT NULL AND fk_inv_even_even IS NULL AND fk_inv_even_pres IS NULL AND fk_inv_even_cerv IS NULL) OR
        (fk_inv_tien_tien IS NULL AND fk_inv_tien_pres IS NULL AND fk_inv_tien_cerv IS NULL AND fk_inv_even_even IS NOT NULL AND fk_inv_even_pres IS NOT NULL AND fk_inv_even_cerv IS NOT NULL)
    )
);

-- PUNTO CANJEO

CREATE TABLE PUNT_CLIE (
    cod_punt_clie serial PRIMARY KEY,
    cant_puntos_acum numeric(10, 2), 
    cant_puntos_canj numeric(10, 2),
    fecha_transaccion date NOT NULL,
    canjeado boolean NOT NULL, 
    fk_clie varchar(20) NOT NULL,
    fk_punt_canj serial,
    fk_tasa serial NOT NULL,
    fk_vent serial NOT NULL, 
    FOREIGN KEY (fk_clie) REFERENCES Cliente (RIF_clie),
    FOREIGN KEY (fk_punt_canj) REFERENCES Punto_Canjeo (cod_punt_canj), 
    FOREIGN KEY (fk_tasa) REFERENCES Tasa (cod_tasa),
    FOREIGN KEY (fk_vent) REFERENCES Venta (cod_vent)
);