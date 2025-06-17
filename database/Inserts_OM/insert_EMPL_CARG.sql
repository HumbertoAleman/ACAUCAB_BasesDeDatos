-- Buscar Empleado
CREATE OR REPLACE FUNCTION get_empleado (ci integer)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_empl
    FROM
        Empleado
    WHERE
        ci_empl = ci INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Buscar Cargo
CREATE OR REPLACE FUNCTION get_cargo (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_carg
    FROM
        Cargo
    WHERE
        nombre_carg = nombre INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Buscar Departamento
CREATE OR REPLACE PROCEDURE get_departamento (out depa_1 integer, nombre varchar(40))
    AS $$
BEGIN
    SELECT
        cod_depa INTO depa_1
    FROM
        Departamento
    WHERE
        fk_tien = 1
        AND nombre_depa = nombre;
END
$$
LANGUAGE plpgsql;

-- ---------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_empl_carg (ci integer, nombre_carg varchar(40), ini date, fin date, montoTotal integer, nombre_derp varchar(40))
    AS $$
DECLARE
    fk_depa1 integer;
BEGIN
    CALL get_departamento (fk_depa1, nombre_derp);
    INSERT INTO EMPL_CARG (fk_empl, fk_carg, fecha_ini, fecha_fin, cantidad_total_salario, fk_depa_1, fk_depa_2)
        VALUES (get_empleado (ci), get_cargo (nombre_carg), ini, fin, montoTotal, fk_depa1, 1);
END
$$
LANGUAGE plpgsql;

CALL add_empl_carg (40959596, 'Empleado', '2024-10-10', NULL, 25000, 'Compras');

CALL add_empl_carg (48422996, 'Empleado', '2024-10-10', NULL, 25000, 'Ventas');

CALL add_empl_carg (2428796, 'Empleado', '2024-10-10', NULL, 25000, 'Despacho');

CALL add_empl_carg (26806759, 'Empleado', '2024-10-10', NULL, 25000, 'Entrega');

CALL add_empl_carg (4221028, 'Empleado', '2024-10-10', NULL, 25000, 'Marketing');

CALL add_empl_carg (1418738, 'Empleado', '2024-10-10', NULL, 25000, 'Recursos Humanos');

CALL add_empl_carg (518945, 'Empleado', '2024-10-10', NULL, 25000, 'Finanzas');

CALL add_empl_carg (46565698, 'Empleado', '2024-10-10', NULL, 25000, 'Seguridad');

CALL add_empl_carg (42233317, 'Empleado', '2024-10-10', NULL, 25000, 'Limpieza');

CALL add_empl_carg (40959596, 'Empleado', '2024-10-10', NULL, 25000, 'Mantenimiento');
