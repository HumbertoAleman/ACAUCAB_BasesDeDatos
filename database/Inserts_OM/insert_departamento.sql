-- Buscar Tienda 1
CREATE OR REPLACE FUNCTION get_tienda_1 ()
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tien
    FROM
        Tienda
    ORDER BY
        cod_tien
    LIMIT 1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Buscar Tienda específica
CREATE OR REPLACE FUNCTION get_tienda (parroquia varchar(40), estado varchar(40), tienda varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        t.cod_tien
    FROM
        Tienda t,
        Lugar l1,
        Lugar l2,
        Lugar l3
    WHERE
        t.fk_luga = l1.cod_luga
        AND l1.fk_luga = l2.cod_luga
        AND l2.fk_luga = l3.cod_luga
        AND t.nombre_tien = tienda
        AND l1.nombre_luga = parroquia
        AND l3.nombre_luga = estado;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- ------------------------------------------------------
-- Agregar Departamento con Tienda 1
CREATE OR REPLACE PROCEDURE add_departamento_tienda_1 (nombre varchar(40))
    AS $$
BEGIN
    INSERT INTO Departamento (fk_tien, nombre_depa)
        VALUES (get_tienda_1 (), nombre);
END
$$
LANGUAGE plpgsql;

-- Agregar Departamento con Tienda Específica
CREATE OR REPLACE PROCEDURE add_departamento (nombre varchar(40), parroquia varchar(40), estado varchar(40), tienda varchar(40))
    AS $$
BEGIN
    INSERT INTO Departamento (fk_tien, nombre_depa)
        VALUES (get_tienda (parroquia, estado, tienda), nombre);
END
$$
LANGUAGE plpgsql;

CALL add_departamento_tienda_1 ('Compras');

CALL add_departamento_tienda_1 ('Ventas');

CALL add_departamento_tienda_1 ('Despacho');

CALL add_departamento_tienda_1 ('Entrega');

CALL add_departamento_tienda_1 ('Marketing');

CALL add_departamento_tienda_1 ('Recursos Humanos');

CALL add_departamento_tienda_1 ('Finanzas');

CALL add_departamento_tienda_1 ('Seguridad');

CALL add_departamento_tienda_1 ('Limpieza');

CALL add_departamento_tienda_1 ('Mantenimiento');
