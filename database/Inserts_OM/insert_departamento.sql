-- Buscar Tienda 1
CREATE OR REPLACE PROCEDURE get_tienda_1(out id_tienda)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_tien INTO id_tienda FROM Tienda ORDER BY cod_tien LIMIT 1;
END;
$$

-- Buscar Tienda específica
CREATE OR REPLACE PROCEDURE get_tienda (out id_tienda, parroquia varchar(40), estado varchar(40), tienda varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT t.cod_tien INTO id_tienda FROM Tienda t, Lugar l1, Lugar l2, Lugar l3
    WHERE t.fk_luga = l1.cod_luga AND l1.fk_luga = l2.cod_luga AND l2.fk_luga = l3.cod_luga AND t.nombre_tien = tienda AND l1.nombre_luga = parroquia AND l3.nombre_luga = estado;
END;
$$


-- ------------------------------------------------------

-- Agregar Departamento con Tienda 1
CREATE OR REPLACE PROCEDURE add_departamento_tienda1(nombre varchar(40))
LANGUAGE plpgsql
AS $$
DECLARE
    id_tienda integer;
BEGIN
    CALL get_tienda_1 (id_tienda);
    INSERT INTO Departamento (fk_tien, nombre_depa)
    VALUES (id_tienda, nombre);
END;
$$

-- Agregar Departamento con Tienda Específica
CREATE OR REPLACE PROCEDURE add_departamento(nombre varchar(40), parroquia varchar(40), estado varchar(40), tienda varchar(40))
LANGUAGE plpgsql
AS $$
DECLARE
    id_tienda integer;
BEGIN
    CALL get_tienda (id_tienda, parroquia, estado, tienda);
    INSERT INTO Departamento (fk_tien, nombre_depa)
    VALUES (id_tienda, nombre);
END;
$$

CALL add_departamento_tienda1('Compras');
CALL add_departamento_tienda1('Ventas');
CALL add_departamento_tienda1('Despacho');
CALL add_departamento_tienda1('Entrega');
CALL add_departamento_tienda1('Marketing');
CALL add_departamento_tienda1('Recursos Humanos');
CALL add_departamento_tienda1('Finanzas');
CALL add_departamento_tienda1('Seguridad');
CALL add_departamento_tienda1('Limpieza');
CALL add_departamento_tienda1('Mantenimiento');