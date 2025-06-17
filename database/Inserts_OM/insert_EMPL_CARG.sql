-- Buscar Empleado
CREATE OR REPLACE PROCEDURE get_empleado (out codempl integer, p_nombre varchar(40), p_apellido varchar(40), ci integer)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_empl INTO codempl FROM Empleado 
    WHERE ci_empl = ci AND primer_nom_empl = p_nombre AND primer_ape_empl = p_apellido;
END;
$$

-- Buscar Cargo
CREATE OR REPLACE PROCEDURE get_cargo (out codcargo integer, nombre varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_carg INTO cod_cargo FROM Cargo WHERE nombre_carg = nombre;
END;
$$

-- Buscar Tienda 1
CREATE OR REPLACE PROCEDURE get_tienda_1(out id_tienda)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_tien INTO id_tienda FROM Tienda ORDER BY cod_tien LIMIT 1;
END;
$$

-- Buscar Departamento
CREATE OR REPLACE PROCEDURE get_departamento (out depa_1, out depa_2, nombre varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    CALL get_tienda_1(depa_2);
    SELECT cod_depa INTO depa_1 FROM Departamento WHERE fk_tien = depa_2 AND nombre_depa = nombre;
END;

-- ---------------------------------------------------------------

CREATE OR REPLACE PROCEDURE add_empl_carg (p_nombre varchar(40), p_apellido varchar(40), ci integer, nombre_carg varchar(40), ini date, fin date, montoTotal integer, nombre_derp varchar(40))
LANGUAGE plpgsql
AS $$
DECLARE
    id_empl integer;
    id_carg integer;
    fk_depa1 integer;
    fk_depa2 integer;
BEGIN
    CALL get_empleado (id_empl, p_nombre, p_apellido, ci);
    CALL get_cargo (id_carg, nombre_carg);
    CALL get_departamento (fk_depa1, fk_depa2, nombre_derp);
    INSERT INTO EMPL_CARG (fk_empl, fk_carg, fecha_ini, fecha_fin, cantidad_total_salario, fk_depa_1, fk_depa_2)
    VALUES (id_empl, id_carg, ini, fin, montoTotal, fk_depa1, fk_depa2);
END;
$$