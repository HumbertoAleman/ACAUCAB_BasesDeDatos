CREATE TABLE Ingrediente (
    cod_ingr serial,
    nombre_ingr varchar(50) NOT NULL,
    PRIMARY KEY (cod_ingr)
);

CREATE TABLE Receta (
    cod_rece serial,
    nombre_rece varchar(50) NOT NULL,
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

CREATE TABLE Instruccion (
    cod_inst serial,
    nombre_inst varchar(50) NOT NULL,
    fk_rece serial NOT NULL,
    PRIMARY KEY (cod_inst),
    FOREIGN KEY (fk_rece) REFERENCES Receta (cod_rece)
);

CREATE TABLE Cerveza (
    cod_cerv serial,
    nombre_cerv varchar(50) NOT NULL,
    fk_tipo_cerv serial NOT NULL,
    PRIMARY KEY (cod_cerv),
    FOREIGN KEY (fk_tipo_cerv) REFERENCES Tipo_Cerveza (cod_tipo_cerv),
);

CREATE TABLE Presentacion (
    cod_pres serial,
    nombre_pres varchar(50) NOT NULL,
    capacidad_pres numeric(5) NOT NULL,
    PRIMARY KEY (cod_pres)
);

CREATE TABLE Caracteristica (
    cod_cara serial,
    nombre_cara varchar(50) NOT NULL,
    PRIMARY KEY (cod_cara)
);

CREATE TABLE Descuento (
    cod_desc serial,
    descripcion_desc text NOT NULL,
    fecha_ini_desc date NOT NULL,
    fecha_fin_desc date NOT NULL,
    PRIMARY KEY (cod_desc)
);

CREATE TABLE Miembro (
    rif_miem varchar(20),
    razon_social_miem varchar(50) NOT NULL,
    denom_comercial_miem varchar(50) NOT NULL,
    direccion_fiscal_miem varchar(50) NOT NULL,
    direccion_fisica_miem varchar(50) NOT NULL,
    pag_web_miem text,
    fk_luga_1 serial NOT NULL,
    fk_luga_2 serial NOT NULL,
    PRIMARY KEY (rif_miem),
    FOREIGN KEY (fk_luga_1) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_luga_2) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Lugar (
    cod_luga serial,
    nombre_luga text NOT NULL,
    tipo_luga varchar(15) NOT NULL CHECK (tipo_luga IN ('Pais', 'Estado', 'Ciudad', 'Parroquia')),
    fk_luga serial,
    PRIMARY KEY (cod_luga),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Natural (
    RIF_clie varchar(20),
    direccion_fiscal_clie varchar(50) NOT NULL,
    direccion_fisica_clie varchar(50) NOT NULL,
    primer_nom_natu varchar(20) NOT NULL,
    segundo_nom_natu varchar(20),
    primer_ape_natu varchar(20) NOT NULL,
    segundo_ape_natu varchar(20),
    CI_natu varchar(20) NOT NULL,
    fk_luga_1 serial NOT NULL,
    fk_luga_2 serial NOT NULL,
    PRIMARY KEY (RIF_clie),
    FOREIGN KEY (fk_luga_1) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_luga_2) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Juridico (
    RIF_clie varchar(20),
    direccion_fiscal_clie varchar(50) NOT NULL,
    direccion_fisica_clie varchar(50) NOT NULL,
    razon_social_juri varchar(50) NOT NULL,
    denom_comercial_juri varchar(50) NOT NULL,
    capital_juri numeric(9, 2) NOT NULL,
    pag_web_juri text,
    fk_luga_1 serial NOT NULL,
    fk_luga_2 serial NOT NULL,
    PRIMARY KEY (RIF_clie),
    FOREIGN KEY (fk_luga_1) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_luga_2) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Contacto (
    cod_pers serial,
    primer_nom_pers varchar(20) NOT NULL,
    segundo_nom_pers varchar(20),
    primer_ape_pers varchar(20) NOT NULL,
    segundo_ape_pers varchar(20),
    fk_miem varchar(20),
    PRIMARY KEY (cod_pers),
    FOREIGN KEY (fk_miem) REFERENCES Miembro (RIF_miem)
);

CREATE TABLE Tipo_Evento (
    cod_tipo_even serial,
    nombre_tipo_even varchar(50) NOT NULL,
    PRIMARY KEY (cod_tipo_even)
);

CREATE TABLE Evento (
    cod_even serial,
    nombre_even varchar(50) NOT NULL,
    fecha_hora_ini_even date NOT NULL,
    fecha_hora_fin_even date NOT NULL,
    direccion_even varchar(50) NOT NULL,
    capacidad_even numeric(5) NOT NULL,
    descripcion_even text,
    precio_entrada_even numeric(10, 2),
    cant_entradas_even numeric(5) NOT NULL,
    fk_luga serial NOT NULL,
    fk_tipo_even serial NOT NULL,
    PRIMARY KEY (cod_even),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga),
    FOREIGN KEY (fk_tipo_even) REFERENCES Tipo_Evento (cod_tipo_even)
);

CREATE TABLE Juez (
    cod_juez serial,
    primer_nom_juez varchar(20) NOT NULL,
    segundo_nom_juez varchar(20),
    primer_ape_juez varchar(20) NOT NULL,
    segundo_ape_juez varchar(20),
    CI_juez varchar(20) NOT NULL,
    PRIMARY KEY (cod_juez),
);

CREATE TABLE Tasa (
    cod_tasa serial,
    tasa_dolar_bcv numeric(10, 2) NOT NULL,
    tasa_punto numeric(10, 2) NOT NULL,
    fecha_ini_tasa date NOT NULL,
    fecha_fin_tasa date NOT NULL,
    PRIMARY KEY (cod_tasa)
);

CREATE TABLE Banco (
    cod_banc serial,
    nombre_banc varchar(50) NOT NULL,
    PRIMARY KEY (cod_banco)
);

CREATE TABLE Tarjeta (
    cod_meto_pago serial,
    numero_tarj numeric(16) NOT NULL,
    fecha_venci_tarj date NOT NULL,
    cvv_tarj numeric(3) NOT NULL,
    nombre_titu_tarj varchar(50) NOT NULL,
    credito boolean NOT NULL check in ('T','F'),
    PRIMARY KEY (cod_meto_pago)
);

CREATE TABLE Punto_Canjeo (
    cod_meto_pago serial,
    PRIMARY KEY (cod_meto_pago)
);

CREATE TABLE Cheque (
    cod_meto_pago serial,
    numero_cheq numeric(20) NOT NULL,
    numero_cuenta_cheq numeric(20) NOT NULL,
    fk_banc serial NOT NULL,
    PRIMARY KEY (cod_meto_pago)
    FOREIGN KEY (fk_banc) REFERENCES Banco (cod_banc)
);

CREATE TABLE Efectivo (
    cod_meto_pago serial,
    denominacion_efect numeric(10, 2) NOT NULL,
    PRIMARY KEY (cod_meto_pago)
);

CREATE TABLE Empleado (
    cod_empl serial,
    CI_empl varchar(20) NOT NULL,
    primer_nom_empl varchar(20) NOT NULL,
    segundo_nom_empl varchar(20),
    primer_ape_empl varchar(20) NOT NULL,
    segundo_ape_empl varchar(20),
    salario_base_empl numeric(10, 2) NOT NULL,
    PRIMARY KEY (cod_empl)
);

CREATE TABLE Cargo (
    cod_carg serial,
    nombre_carg varchar(50) NOT NULL,
    PRIMARY KEY (cod_carg)
);

CREATE TABLE Vacacion (
    cod_vac serial,
    fecha_ini_vac date NOT NULL,
    fecha_fin_vac date NOT NULL,
    pagada boolean NOT NULL check in ('T','F'),
    fk_empl serial NOT NULL,
    PRIMARY KEY (cod_vac),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl)
    --TERMINAR
);

CREATE TABLE Beneficio (
    cod_bene serial,
    nombre_bene varchar(50) NOT NULL,
    cant_bene numeric(10, 2) NOT NULL,
    PRIMARY KEY (cod_bene)
);

CREATE TABLE Asistencia (
    cod_asis serial,
    fecha_hora_ent_asis date NOT NULL,
    fecha_hora_sal_asis date NOT NULL,
    fk_empl serial NOT NULL,
    PRIMARY KEY (cod_asis),
    FOREIGN KEY (fk_empl) REFERENCES Empleado (cod_empl)
    --TERMINAR
);

CREATE TABLE Rol (
    cod_rol serial,
    nombre_rol varchar(50) NOT NULL,
    descripcion_rol text NOT NULL,
    PRIMARY KEY (cod_rol)
);

CREATE TABLE Privilegio (
    cod_priv serial,
    nombre_priv varchar(50) NOT NULL,
    descripcion_priv text NOT NULL,
    PRIMARY KEY (cod_priv)
);

CREATE TABLE Horario (
    cod_hora serial,
    hora_ini_hora time NOT NULL,
    hora_fin_hora time NOT NULL,
    dia_hora varchar(10) NOT NULL CHECK (dia_hora IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')),
    PRIMARY KEY (cod_hora)
);

CREATE TABLE Tienda (
    cod_tien serial,
    nombre_tien varchar(50) NOT NULL,
    fecha_apertura_tien date NOT NULL,
    direccion_tien varchar(50) NOT NULL,
    fk_luga serial NOT NULL,
    PRIMARY KEY (cod_tien),
    FOREIGN KEY (fk_luga) REFERENCES Lugar (cod_luga)
);

CREATE TABLE Departamento (
    cod_depa serial,
    nombre_depa varchar(50) NOT NULL,
    PRIMARY KEY (cod_depa)
    --TERMINAR
);


