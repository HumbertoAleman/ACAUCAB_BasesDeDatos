-- [[ SETUP DATABASE USERS ]] --
CREATE OR REPLACE FUNCTION auto_asign_rol_to_user ()
    RETURNS TRIGGER
    AS $$
DECLARE
    rol_codigo int;
    rol_nombre text;
    usename text;
    groname text;
BEGIN
    SELECT
        cod_rol,
        nombre_rol INTO rol_codigo,
        rol_nombre
    FROM
        Rol
    WHERE
        cod_rol = NEW.fk_rol;
    usename = rol_codigo || '_' || rol_nombre;
    groname = NEW.cod_usua || '_' || NEW.username_usua;
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', groname, NEW.contra_usua);
    EXECUTE format('GRANT %I TO %I', usename, groname);
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auto_asign_rol_to_user_tri
    AFTER INSERT ON Usuario
    FOR EACH ROW
    EXECUTE FUNCTION auto_asign_rol_to_user ();

CREATE OR REPLACE FUNCTION auto_change_rol_on_user_change ()
    RETURNS TRIGGER
    AS $$
DECLARE
    rol_codigo int;
    rol_nombre text;
    old_rol_codigo int;
    old_rol_nombre text;
    usename text;
    groname text;
    old_usename text;
BEGIN
    SELECT
        cod_rol,
        nombre_rol INTO rol_codigo,
        rol_nombre
    FROM
        Rol
    WHERE
        cod_rol = NEW.fk_rol;
    SELECT
        cod_rol,
        nombre_rol INTO old_rol_codigo,
        old_rol_nombre
    FROM
        Rol
    WHERE
        cod_rol = OLD.fk_rol;
    usename = rol_codigo || '_' || rol_nombre;
    old_usename = old_rol_codigo || '_' || old_rol_nombre;
    groname = NEW.cod_usua || '_' || NEW.username_usua;
    EXECUTE format('REVOKE %I FROM %I', old_usename, groname);
    EXECUTE format('GRANT %I TO %I', usename, groname);
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auto_change_rol_on_user_change_tri
    AFTER UPDATE ON Usuario
    FOR EACH ROW
    EXECUTE FUNCTION auto_change_rol_on_user_change ();

CREATE OR REPLACE FUNCTION auto_create_group ()
    RETURNS TRIGGER
    AS $$
BEGIN
    EXECUTE format('CREATE ROLE %I', NEW.cod_rol || '_' || NEW.nombre_rol);
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auto_create_group_tri
    AFTER INSERT ON Rol
    FOR EACH ROW
    EXECUTE FUNCTION auto_create_group ();

CREATE OR REPLACE FUNCTION grant_privilege_on_priv_rol_add ()
    RETURNS TRIGGER
    AS $$
DECLARE
    rol record;
    priv record;
    permission text;
    table_name text;
    group_name text;
BEGIN
    SELECT
        *
    FROM
        Rol
    WHERE
        NEW.fk_rol = cod_rol INTO rol;
    SELECT
        *
    FROM
        Privilegio
    WHERE
        NEW.fk_priv = cod_priv INTO priv;
    group_name = rol.cod_rol || '_' || rol.nombre_rol;
    SELECT
        substring(priv.nombre_priv FROM 1 FOR position('_' IN priv.nombre_priv) - 1),
        substring(priv.nombre_priv FROM position('_' IN priv.nombre_priv) + 1) INTO permission,
        table_name;
    IF permission = 'insert' THEN
        EXECUTE format('GRANT INSERT ON TABLE %I TO %I', table_name, group_name);
    ELSIF permission = 'select' THEN
        EXECUTE format('GRANT SELECT ON TABLE %I TO %I', table_name, group_name);
    ELSIF permission = 'update' THEN
        EXECUTE format('GRANT UPDATE ON TABLE %I TO %I', table_name, group_name);
    ELSIF permission = 'delete' THEN
        EXECUTE format('GRANT DELETE ON TABLE %I TO %I', table_name, group_name);
    ELSE
        RAISE NOTICE 'Unknown permission: %', permission;
    END IF;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER grant_privilege_on_priv_rol_add_tri
    AFTER INSERT ON PRIV_ROL
    FOR EACH ROW
    EXECUTE FUNCTION grant_privilege_on_priv_rol_add ();

CREATE OR REPLACE FUNCTION revoke_privilege_on_rol_delete ()
    RETURNS TRIGGER
    AS $$
DECLARE
    rol record;
    priv record;
    permission text;
    table_name text;
    group_name text;
BEGIN
    SELECT
        *
    FROM
        Rol
    WHERE
        OLD.fk_rol = cod_rol INTO rol;
    SELECT
        *
    FROM
        Privilegio
    WHERE
        OLD.fk_priv = cod_priv INTO priv;
    group_name = rol.cod_rol || '_' || rol.nombre_rol;
    SELECT
        substring(priv.nombre_priv FROM 1 FOR position('_' IN priv.nombre_priv) - 1),
        substring(priv.nombre_priv FROM position('_' IN priv.nombre_priv) + 1) INTO permission,
        table_name;
    IF permission = 'insert' THEN
        EXECUTE format('REVOKE INSERT ON TABLE %I FROM %I', table_name, group_name);
    ELSIF permission = 'select' THEN
        EXECUTE format('REVOKE SELECT ON TABLE %I FROM %I', table_name, group_name);
    ELSIF permission = 'update' THEN
        EXECUTE format('REVOKE UPDATE ON TABLE %I FROM %I', table_name, group_name);
    ELSIF permission = 'delete' THEN
        EXECUTE format('REVOKE DELETE ON TABLE %I FROM %I', table_name, group_name);
    ELSE
        RAISE NOTICE 'Unknown permission: %', permission;
    END IF;
    RETURN OLD;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER revoke_privilege_on_rol_delete_tri
    AFTER DELETE ON PRIV_ROL
    FOR EACH ROW
    EXECUTE FUNCTION revoke_privilege_on_rol_delete ();

--[[[ FUNCTION BEGIN ]]]--
CREATE OR REPLACE FUNCTION create_or_insert_tasa (curr_date date)
    RETURNS integer
    AS $$
DECLARE
    v_cod_tasa int;
BEGIN
    -- Check if a record exists with today's date in fecha_ini_tasa
    SELECT
        cod_tasa
    FROM
        Tasa
    WHERE
        fecha_fin_tasa IS NULL
    LIMIT 1 INTO v_cod_tasa;
    -- If a record is found, return the cod_tasa
    IF v_cod_tasa IS NULL THEN
        -- Insert a new record with today's date and numeric values increased by 100
        INSERT INTO Tasa (tasa_dolar_bcv, tasa_punto, fecha_ini_tasa, fecha_fin_tasa)
            VALUES (100, 10, curr_date, curr_date)
        RETURNING
            cod_tasa INTO v_cod_tasa;
    END IF;
    -- Return the cod_tasa
    RETURN v_cod_tasa;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_estatus (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_esta
    FROM
        Estatus
    WHERE
        nombre_esta LIKE $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tipo_even (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tipo_even
    FROM
        Tipo_Evento
    WHERE
        nombre_tipo_even LIKE $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_banco_random ()
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_banc
    FROM
        Banco
    ORDER BY
        RANDOM()
    LIMIT 1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_banco (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_banc
    FROM
        Banco
    WHERE
        nombre_banc = nombre INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cerv (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_cerv
    FROM
        Cerveza
    WHERE
        nombre_cerv = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tipo_cerv (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tipo_cerv
    FROM
        Tipo_Cerveza
    WHERE
        nombre_tipo_cerv = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_rece_by_type (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        fk_rece
    FROM
        Tipo_Cerveza
    WHERE
        nombre_tipo_cerv = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cara (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_cara
    FROM
        Caracteristica
    WHERE
        nombre_cara = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_ingr (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_ingr
    FROM
        Ingrediente
    WHERE
        nombre_ingr = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

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

-- Get parroquia from name
CREATE OR REPLACE FUNCTION get_parroquia (nom_parroquia varchar(40))
    RETURNS integer
    AS $$
DECLARE
    id_parroquia integer;
BEGIN
    SELECT
        cod_luga
    FROM
        Lugar
    WHERE
        nombre_luga = nom_parroquia
        AND tipo_luga = 'Parroquia'
    LIMIT 1 INTO id_parroquia;
    RETURN id_parroquia;
END
$$
LANGUAGE plpgsql;

-- Get parroquia, from a specific state
CREATE OR REPLACE FUNCTION get_parroquia_from_estado (nom_parroquia varchar(40), nom_estado varchar(40))
    RETURNS integer
    AS $$
DECLARE
    id_parroquia integer;
BEGIN
    SELECT
        l1.cod_luga
    FROM
        Lugar l1,
        Lugar l2,
        Lugar l3
    WHERE
        l1.fk_luga = l2.cod_luga
        AND l2.fk_luga = l3.cod_luga
        AND l3.nombre_luga = nom_estado
        AND l1.tipo_luga = 'Parroquia'
        AND l1.nombre_luga = nom_parroquia
    LIMIT 1 INTO id_parroquia;
    RETURN id_parroquia;
END
$$
LANGUAGE plpgsql;

-- Get parroquia at random
CREATE OR REPLACE FUNCTION get_parroquia_random ()
    RETURNS integer
    AS $$
DECLARE
    id_parroquia integer;
BEGIN
    SELECT
        cod_luga
    FROM
        Lugar
    WHERE
        tipo_luga = 'Parroquia'
    ORDER BY
        RANDOM()
    LIMIT 1 INTO id_parroquia;
    RETURN id_parroquia;
END
$$
LANGUAGE plpgsql;

-- Get first tienda
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

-- Buscar Departamento In Tienda 1
CREATE OR REPLACE FUNCTION get_departamento_1 (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_depa
    FROM
        Departamento
    WHERE
        fk_tien = get_tienda_1 ()
        AND nombre_depa = nombre INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Get tienda from parroquia, estado
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

-- Obtener un estatus específico según el nombre
CREATE OR REPLACE FUNCTION get_esta_even (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_esta
    FROM
        Estatus
    WHERE
        nombre_esta LIKE $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE CERV_PRES ]]--
CREATE OR REPLACE PROCEDURE pres_to_cerv_all ()
    AS $$
DECLARE
    x integer;
    y integer;
    rif text;
BEGIN
    FOR x IN (
        SELECT
            cod_cerv
        FROM
            Cerveza)
        LOOP
            FOR y IN (
                SELECT
                    cod_pres
                FROM
                    Presentacion)
                LOOP
                    SELECT
                        rif_miem INTO rif
                    FROM
                        Miembro
                    ORDER BY
                        RANDOM()
                    LIMIT 1;
                    INSERT INTO CERV_PRES (fk_cerv, fk_pres, fk_miem, precio_pres_cerv)
                        VALUES (x, y, rif, 9.99);
                END LOOP;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_juridico ()
    RETURNS varchar (
        20
)
    AS $$
DECLARE
    res varchar(20);
BEGIN
    SELECT
        rif_clie
    FROM
        cliente
    WHERE
        tipo_clie = 'Juridico' INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cheque_random ()
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        fk_meto_pago
    FROM
        cheque INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_estatus_by_name (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    result integer;
BEGIN
    SELECT
        cod_esta INTO result
    FROM
        Estatus
    WHERE
        nombre_esta = nombre;
    RETURN result;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_precio_from_inventario (integer, integer, integer, integer)
    RETURNS numeric
    AS $$
DECLARE
    res numeric;
BEGIN
    SELECT
        precio_actual_pres
    FROM
        Inventario_Tienda
    WHERE
        fk_cerv_pres_1 = $1
        AND fk_cerv_pres_2 = $2
        AND fk_tien = $3
        AND fk_luga_tien = $4 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_most_recent_punt_clie_punt (clie varchar(20))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cant_puntos_acum
    FROM
        PUNT_CLIE AS p_c
    WHERE
        fk_clie = clie
    ORDER BY
        p_c.cod_punt_clie DESC
    LIMIT 1 INTO res;
    RETURN COALESCE(res, 0);
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tasa_conversion (curr_date date)
    RETURNS integer
    AS $$
DECLARE
    tasa numeric;
BEGIN
    SELECT
        tasa_punto
    FROM
        Tasa
    WHERE
        fecha_ini_tasa = curr_date
    LIMIT 1 INTO tasa;
    RETURN tasa;
END
$$
LANGUAGE plpgsql;



--[[[ FUNCTION END ]]]---

-- [[ PROCEDURE Lugar, INDEPENDENT ]]--
CREATE OR REPLACE PROCEDURE insert_estados(varchar(40)[]) AS $$
DECLARE
    x varchar(40);
BEGIN
    FOREACH x IN ARRAY $1
    LOOP
	    INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Estado', NULL);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_municipios(varchar(40)[], text) AS $$
DECLARE
    found_id integer = (SELECT cod_luga FROM Lugar WHERE nombre_luga = $2 AND tipo_luga = 'Estado' LIMIT 1);
    x varchar(40);
BEGIN
    FOREACH x IN ARRAY $1
    LOOP
	    INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Municipio', found_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_parroquias(varchar(40)[], text, text) AS $$
DECLARE
    found_id integer = (SELECT l1.cod_luga FROM Lugar l1, Lugar l2 WHERE l1.nombre_luga = $2 AND l1.tipo_luga = 'Municipio' AND l1.fk_luga = l2.cod_luga AND l2.tipo_luga = 'Estado' AND l2.nombre_luga = $3 LIMIT 1);
    x varchar(40);
BEGIN
    FOREACH x IN ARRAY $1
    LOOP
	    INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Parroquia', found_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--[[ PROCEDURE TIENDA,
-- DEPENDENT get_parroquia() ]]--
CREATE OR REPLACE PROCEDURE add_tienda (nombre varchar(40), fecha date, direccion text, nom_parroquia varchar(40), nom_estado varchar(40))
    AS $$
BEGIN
    INSERT INTO Tienda (nombre_tien, fecha_apertura_tien, direccion_tien, fk_luga)
        VALUES (nombre, fecha, direccion, get_parroquia (nom_parroquia));
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_departamento (nombre varchar(40), parroquia varchar(40), estado varchar(40), tienda varchar(40))
    AS $$
BEGIN
    INSERT INTO Departamento (fk_tien, nombre_depa)
        VALUES (get_tienda (parroquia, estado, tienda), nombre);
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_departamento_tienda_1 (nombre varchar(40))
    AS $$
BEGIN
    INSERT INTO Departamento (fk_tien, nombre_depa)
        VALUES (get_tienda_1 (), nombre);
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE EMPLEADO, INDEPENDENT ]]--

CREATE OR REPLACE PROCEDURE add_empleado (ci integer, p_nom text, s_nom text, p_ape text, s_ape text, salario numeric(8, 2))
LANGUAGE plpgsql
AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO Empleado (ci_empl, primer_nom_empl, segundo_nom_empl, primer_ape_empl, segundo_ape_empl, salario_base_empl)
        VALUES (ci, p_nom, s_nom, p_ape, s_ape, salario)
    RETURNING
        cod_empl INTO x;
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_empl)
        VALUES ('admin', p_nom || ' ' || p_ape, 300, x);
END;
$$;

-- [[ PROCEDURE EMPL_CARG
-- DEPENDENT get_tienda_1, get_departamento_1 ]]--

CREATE OR REPLACE PROCEDURE add_empl_carg_to_tien_1 (ci integer, nombre_carg varchar(40), ini date, fin date, montoTotal integer, nombre_derp varchar(40))
    AS $$
DECLARE
    fk_depa1 integer;
BEGIN
    INSERT INTO EMPL_CARG (fk_empl, fk_carg, fecha_ini, fecha_fin, cantidad_total_salario, fk_depa_1, fk_depa_2)
        VALUES (get_empleado (ci), get_cargo (nombre_carg), ini, fin, montoTotal, get_departamento_1 (nombre_derp), get_tienda_1 ());
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE EMPL_BENE ]]--
CREATE OR REPLACE PROCEDURE give_benefits ()
    AS $$
DECLARE
    bene integer;
    e_c record;
BEGIN
    FOR e_c IN (
        SELECT
            *
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO EMPL_BENE (fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3, fk_bene, monto_bene)
                VALUES (e_c.fk_empl, e_c.fk_carg, e_c.cod_empl_carg, (
                        SELECT
                            cod_bene
                        FROM
                            Beneficio
                        ORDER BY
                            RANDOM()
                        LIMIT 1),
                    100);
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE VACACION ]]--
CREATE OR REPLACE PROCEDURE create_vacaciones ()
    AS $$
DECLARE
    e_c record;
BEGIN
    FOR e_c IN (
        SELECT
            *
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO Vacacion (fecha_ini_vaca, fecha_fin_vaca, pagada, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                VALUES ('2024-12-12', '2025-01-01', FALSE, e_c.fk_empl, e_c.fk_carg, e_c.cod_empl_carg);
        END LOOP;
END
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE, ASISTENCIA ]]--
CREATE OR REPLACE PROCEDURE generate_asistencia_entries ()
    AS $$
DECLARE
    emp record;
    start_date date := '2024-10-11';
    business_day date;
    start_hour interval;
    end_hour interval;
BEGIN
    FOR emp IN SELECT DISTINCT
        *
    FROM
        EMPL_CARG LOOP
            FOR i IN 0..9 LOOP
                business_day := start_date + i;
                IF RANDOM() >= 0.05 THEN
                    start_hour := INTERVAL '9 hours' + (RANDOM() * INTERVAL '30 minutes');
                    end_hour := INTERVAL '17 hours' + (RANDOM() * INTERVAL '30 minutes');
                    INSERT INTO Asistencia (fecha_hora_ini_asis, fecha_hora_fin_asis, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                        VALUES (business_day + start_hour, business_day + end_hour, emp.fk_empl, emp.fk_carg, emp.cod_empl_carg);
                END IF;
            END LOOP;
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE EMPL_HORA ]]--
CREATE OR REPLACE PROCEDURE insert_empl_hora ()
    AS $$
DECLARE
    rec_horario RECORD;
    rec_empl_carg RECORD;
BEGIN
    FOR rec_horario IN
    SELECT
        *
    FROM
        Horario
    LIMIT 7 LOOP
        FOR rec_empl_carg IN
        SELECT
            *
        FROM
            EMPL_CARG LOOP
                INSERT INTO EMPL_HORA (fk_hora, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                    VALUES (rec_horario.cod_hora, rec_empl_carg.fk_empl, rec_empl_carg.fk_carg, rec_empl_carg.cod_empl_carg);
            END LOOP;
    END LOOP;
END
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE TELEFONO ]]--
CREATE OR REPLACE PROCEDURE add_tlf (cod_area integer, numero integer, cliente varchar(20), contacto integer, miembro varchar(20))
    AS $$
BEGIN
    INSERT INTO Telefono (cod_area_tele, num_tele, fk_clie, fk_pers, fk_miem)
        VALUES (cod_area, numero, cliente, contacto, miembro);
END
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE CORREO ]]--
CREATE OR REPLACE PROCEDURE add_correo (prefijo varchar(40), dominio varchar(40), cliente varchar(20), contacto integer, miembro varchar(20), empleado integer)
    AS $$
BEGIN
    INSERT INTO Correo (prefijo_corr, dominio_corr, fk_clie, fk_empl, fk_pers, fk_miem)
        VALUES (prefijo, dominio, cliente, empleado, contacto, miembro);
END
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE CLIENTE ]]--
-- Natural
CREATE OR REPLACE PROCEDURE add_cliente_natural (rif varchar(20), fiscal text, fisica text, parroquia_fiscal varchar(40), estado_fiscal varchar(40), parroquia_fisica varchar(40), estado_fisica varchar(40), p_nom varchar(40), s_nom varchar(40), p_ape varchar(40), s_ape varchar(40), ci integer, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, primer_nom_natu, segundo_nom_natu, primer_ape_natu, segundo_ape_natu, ci_natu)
        VALUES (rif, fiscal, fisica, get_parroquia_from_estado (parroquia_fiscal, estado_fiscal), get_parroquia_from_estado (parroquia_fisica, estado_fisica), 'Natural', p_nom, s_nom, p_ape, s_ape, ci)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', p_nom || ' ' || p_ape, 200, id_clie);
END
$$
LANGUAGE plpgsql;

-- RANDOM DATA
CREATE OR REPLACE PROCEDURE add_cliente_natural_random (rif varchar(20), fiscal text, fisica text, p_nom varchar(40), s_nom varchar(40), p_ape varchar(40), s_ape varchar(40), ci integer, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, primer_nom_natu, segundo_nom_natu, primer_ape_natu, segundo_ape_natu, ci_natu)
        VALUES (rif, fiscal, fisica, get_parroquia_random (), get_parroquia_random (), 'Natural', p_nom, s_nom, p_ape, s_ape, ci)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', p_nom || ' ' || p_ape, 200, id_clie);
END
$$
LANGUAGE plpgsql;

-- Juridico
CREATE OR REPLACE PROCEDURE add_cliente_juridico (rif varchar(20), fiscal text, fisica text, parroquia_fiscal varchar(40), estado_fiscal varchar(40), parroquia_fisica varchar(40), estado_fisica varchar(40), razon varchar(40), denom varchar(40), capital numeric(8, 2), pag text, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, razon_social_juri, denom_comercial_juri, capital_juri, pag_web_juri)
        VALUES (rif, fiscal, fisica, get_parroquia_from_estado (parroquia_fiscal, estado_fiscal), get_parroquia_from_estado (parroquia_fisica, estado_fisica), 'Juridico', razon, denom, capital, pag)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', razon, 201, id_clie);
END
$$
LANGUAGE plpgsql;

-- RANDOM DATA
CREATE OR REPLACE PROCEDURE add_cliente_juridico_random (rif varchar(20), fiscal text, fisica text, razon varchar(40), denom varchar(40), capital numeric(8, 2), pag text, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, razon_social_juri, denom_comercial_juri, capital_juri, pag_web_juri)
        VALUES (rif, fiscal, fisica, get_parroquia_random (), get_parroquia_random (), 'Juridico', razon, denom, capital, pag)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', razon, 201, id_clie);
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE MIEMBRO ]]--
CREATE OR REPLACE PROCEDURE add_miembro (rif text, razon_social text, denom_comercial text, direccion_fiscal text, pag_web text, luga_1 integer, luga_2 integer)
AS $$
DECLARE
    x varchar(20);
BEGIN
    INSERT INTO Miembro (rif_miem, razon_social_miem, denom_comercial_miem, direccion_fiscal_miem, pag_web_miem, fk_luga_1, fk_luga_2)
        VALUES (rif, razon_social, denom_comercial, direccion_fiscal, pag_web, luga_1, luga_2);
END;
$$
LANGUAGE plpgsql;

-- RANDOM DATA
CREATE OR REPLACE PROCEDURE add_miembro_random (rif text, razon_social text, denom_comercial text, direccion_fiscal text, pag_web text)
    AS $$
DECLARE
    x varchar(20);
BEGIN
    CALL add_miembro (rif, razon_social, denom_comercial, direccion_fiscal, pag_web, get_parroquia_random (), get_parroquia_random ());
END;
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE CONTACTO ]]--
CREATE OR REPLACE PROCEDURE insert_contacto_random (text, text, text, text)
    AS $$
DECLARE
    x text;
BEGIN
    SELECT
        rif_miem INTO x
    FROM
        Miembro
    ORDER BY
        RANDOM()
    LIMIT 1;
    INSERT INTO Contacto (primer_nom_pers, segundo_nom_pers, primer_ape_pers, segundo_ape_pers, fk_miem)
        VALUES ($1, $2, $3, $4, x);
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE PRIVILEGIO ]]--
CREATE OR REPLACE PROCEDURE privileges ()
    AS $$
DECLARE
    x text;
    y text;
    perms varchar(10)[] = ARRAY['insert', 'select', 'update', 'delete'];
BEGIN
    FOR x IN (
        SELECT
            relname
        FROM
            pg_stat_user_tables)
        LOOP
            FOREACH y IN ARRAY perms LOOP
                INSERT INTO Privilegio (nombre_priv, descripcion_priv)
                    VALUES (y || '_' || x, 'Privilegio para ' || y || ' la tabla ' || x);
            END LOOP;
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE PRIV_ROL ]]--
CREATE OR REPLACE PROCEDURE admin_privileges ()
    AS $$
DECLARE
    x integer;
BEGIN
    FOR x IN (
        SELECT
            cod_priv
        FROM
            Privilegio)
        LOOP
            INSERT INTO PRIV_ROL (fk_rol, fk_priv)
                VALUES (500, x);
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE TIPO_CERVEZA ]]--
CREATE OR REPLACE PROCEDURE insert_tipo_cerveza (text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO Receta (nombre_rece)
        VALUES ('Receta para cervezas de tipo ' || $1)
    RETURNING
        cod_rece INTO x;
    INSERT INTO Tipo_Cerveza (nombre_tipo_cerv, fk_rece, fk_tipo_cerv)
        VALUES ($1, x, get_tipo_cerv ($2));
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE TIPO_CARA ]]--
CREATE OR REPLACE PROCEDURE relate_cara (text, text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO TIPO_CARA (fk_tipo_cerv, fk_cara, valor_cara)
        VALUES (get_tipo_cerv ($1), get_cara ($2), $3);
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE CERV_CARA ]]--
CREATE OR REPLACE PROCEDURE relate_cara_cerv (text, text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO CERV_CARA (fk_cerv, fk_cara, valor_cara)
        VALUES (get_cerv ($1), get_cara ($2), $3);
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE RECE_INGR ]]--
CREATE OR REPLACE PROCEDURE relate_ingr (text, text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO RECE_INGR (fk_rece, fk_ingr, cant_ingr)
        VALUES (get_rece_by_type ($1), get_ingr ($2), $3);
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE INSTRUCCION ]]--
CREATE OR REPLACE PROCEDURE add_inst (text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO Instruccion (nombre_inst, fk_rece)
        VALUES ($2, get_rece_by_type ($1));
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE DESC_CERV ]]--
CREATE OR REPLACE PROCEDURE give_random_descuentos ()
    AS $$
DECLARE
    c_v record;
    d record;
BEGIN
    FOR c_v IN (
        SELECT
            *
        FROM
            CERV_PRES
        ORDER BY
            RANDOM()
        LIMIT 100)
    LOOP
        SELECT
            *
        FROM
            Descuento
        ORDER BY
            RANDOM()
        LIMIT 1 INTO d;
        INSERT INTO DESC_CERV (fk_desc, fk_cerv_pres_1, fk_cerv_pres_2, porcentaje_desc)
            VALUES (d.cod_desc, c_v.fk_cerv, c_v.fk_pres, ROUND(RANDOM() * 70) + 10);
    END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE METODO_PAGO, TARJETA, PUNTO_CANJEO, CHEQUE, EFECTIVO ]]--
-- Crear fila Metodo_Pago
CREATE OR REPLACE PROCEDURE add_metodo_pago (out id_metodo integer)
    AS $$
BEGIN
    INSERT INTO Metodo_Pago DEFAULT
        VALUES
        RETURNING
            cod_meto_pago INTO id_metodo;
END
$$
LANGUAGE plpgsql;

-- Agregar Tarjeta
CREATE OR REPLACE PROCEDURE add_tarjeta (numero numeric(21, 0), fecha_venci date, cvv integer, nombre_titu varchar(40), credito boolean)
    AS $$
DECLARE
    fk_metodo integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Tarjeta (fk_meto_pago, numero_tarj, fecha_venci_tarj, cvv_tarj, nombre_titu_tarj, credito)
        VALUES (fk_metodo, numero, fecha_venci, cvv, nombre_titu, credito);
END
$$
LANGUAGE plpgsql;

-- Agregar Punto_Canjeo
CREATE OR REPLACE PROCEDURE add_punto_canjeo ()
    AS $$
DECLARE
    fk_metodo integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Punto_Canjeo (fk_meto_pago)
        VALUES (fk_metodo);
END
$$
LANGUAGE plpgsql;

-- Agregar Cheque
-- Con banco random
CREATE OR REPLACE PROCEDURE add_cheque_random (numero numeric(21, 0), numero_cuenta numeric(21, 0))
    AS $$
DECLARE
    fk_metodo integer;
    fk_banco integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Cheque (fk_meto_pago, numero_cheque, numero_cuenta_cheque, fk_banc)
        VALUES (fk_metodo, numero, numero_cuenta, get_banco_random());
END
$$
LANGUAGE plpgsql;

-- Banco específico (Store procedure)
CREATE OR REPLACE PROCEDURE add_cheque (numero numeric(21, 0), numero_cuenta numeric(21, 0), nombre_banco varchar(40))
    AS $$
DECLARE
    fk_metodo integer;
    fk_banco integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Cheque (fk_meto_pago, numero_cheque, numero_cuenta_cheque, fk_banc)
        VALUES (fk_metodo, numero, numero_cuenta, get_banco(nombre_banco));
END
$$
LANGUAGE plpgsql;

-- Agregar Efectivo
CREATE OR REPLACE PROCEDURE add_efectivo (denominacion varchar(10))
    AS $$
DECLARE
    fk_metodo integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Efectivo (fk_meto_pago, denominacion_efec)
        VALUES (fk_metodo, denominacion);
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE REGISTRO_EVENTO ]]--
CREATE OR REPLACE PROCEDURE register_juez_for_event ()
    AS $$
DECLARE
    x int;
    ev record;
BEGIN
    SELECT
        *
    FROM
        Evento
    ORDER BY
        cod_even ASC
    LIMIT 1 INTO ev;
    FOR x IN (
        SELECT
            cod_juez
        FROM
            Juez)
        LOOP
            INSERT INTO Registro_Evento (fk_even, fk_juez, fecha_hora_regi_even)
                VALUES (ev.cod_even, x, ev.fecha_hora_ini_even);
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE INVENTARIO_EVENTO ]]--
CREATE OR REPLACE PROCEDURE populate_events_inventories ()
    AS $$
DECLARE
    x integer;
    c_v CERV_PRES%ROWTYPE;
BEGIN
    FOR x IN (
        SELECT
            cod_even
        FROM
            Evento)
        LOOP
            FOR c_v IN (
                SELECT
                    *
                FROM
                    CERV_PRES)
                LOOP
                    INSERT INTO Inventario_Evento (fk_cerv_pres_1, fk_cerv_pres_2, fk_even, cant_pres, precio_actual_pres)
                        VALUES (c_v.fk_cerv, c_v.fk_pres, x, 500, 9.99);
                END LOOP;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE INVENTARIO_TIENDA ]]--
CREATE OR REPLACE PROCEDURE populate_tiendas_inventories ()
    AS $$
DECLARE
    x integer;
    c_v CERV_PRES%ROWTYPE;
    l_t integer;
BEGIN
    FOR c_v IN (
        SELECT
            *
        FROM
            CERV_PRES)
        LOOP
            FOR l_t IN (
                SELECT
                    cod_luga_tien
                FROM
                    Lugar_Tienda
                ORDER BY
                    RANDOM()
                LIMIT 5)
            LOOP
                INSERT INTO Inventario_Tienda (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien, cant_pres, precio_actual_pres, fk_luga_tien)
                    VALUES (c_v.fk_cerv, c_v.fk_pres, 1, 100000, 9.99, l_t);
            END LOOP;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

--[[ PROCEDURE VENTA ]]--
CREATE OR REPLACE PROCEDURE venta_en_tienda (
-- Parameters Venta
p_fecha_vent date, -- Date of Venta
p_online boolean, -- If was online
-- Parameters Who & Where
p_fk_clie varchar(20), -- Who bought this
p_fk_tien integer, -- fk_tien
-- Parameters for Metodo_Pago
metodos_pago integer[], -- Array fk_meto_pago
m_p_monto_pago numeric(8, 2)[], -- Array montos
-- Parameters for Detalle_Venta
d_v_cant_deta_vent integer[], -- Array of quantities sold
d_v_fk_inve_tien_1 integer[], -- Array fk_cerv
d_v_fk_inve_tien_2 integer[], -- Array fk_pres
d_v_fk_inve_tien_4 integer[] -- fk_luga_tien
)
    AS $$
DECLARE
    total_acum integer;
    v_cod_tasa integer;
    v_cod_vent integer; -- Hold generated cod_vent
    precio_unitario numeric;
    i integer; -- Loop index
BEGIN
    ----
    -- Create Venta record
    -- * This shoots set_estatus_for_new_venta that creates ESTA_VENT, in "Pagado" since we assume that it's already paid for
    ----
    INSERT INTO Venta (fecha_vent, base_imponible_vent, iva_vent, total_vent, online, fk_clie, fk_tien)
        VALUES (p_fecha_vent, 0, 0, 0, p_online, p_fk_clie, p_fk_tien)
    RETURNING
        cod_vent INTO v_cod_vent;
    ----
    -- Loop through the item details and insert each item into Detalle_Venta
    -- * This shoots after_insert_detalle_venta that updates Venta with the price of the item * quantity
    -- * This shoots remove_from_inventory_after_detalle that updates
    --     Inventario_Tienda removing the amount bought
    -- * This shoots add_points_on_venta, in which if the Venta is offline, it adds points to the Client
    ----
    FOR i IN 1..array_length(d_v_cant_deta_vent, 1)
    LOOP
        total_acum := total_acum + d_v_cant_deta_vent[i];
        precio_unitario := get_precio_from_inventario (d_v_fk_inve_tien_1[i], d_v_fk_inve_tien_2[i], p_fk_tien, d_v_fk_inve_tien_4[i]);
        INSERT INTO Detalle_Venta (cant_deta_vent, precio_unitario_vent, fk_vent, fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_3, fk_inve_tien_4)
            VALUES (d_v_cant_deta_vent[i], precio_unitario, v_cod_vent, d_v_fk_inve_tien_1[i], d_v_fk_inve_tien_2[i], p_fk_tien, d_v_fk_inve_tien_4[i]);
    END LOOP;
    ----
    -- Loop through the payment arrays and insert each payment
    -- * This shoots substract_points_on_venta where if Pago is Punto_Canjeo
    --     it discounts the apropriate points from the Client
    ----
    FOR i IN 1..array_length(metodos_pago, 1)
    LOOP
		INSERT INTO Pago (fk_vent, fk_meto_pago, monto_pago, fecha_pago, fk_tasa)
            VALUES (v_cod_vent, metodos_pago[i], m_p_monto_pago[i], p_fecha_vent, create_or_insert_tasa (p_fecha_vent));
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE generate_random_ventas ()
    AS $$
DECLARE
    v_fecha_vent date;
    v_base_imponible_vent numeric(8, 2);
    v_iva_vent numeric(8, 2);
    v_online boolean;
    v_fk_clie varchar(20);
    v_fk_tien integer := 1;
    -- Always set tienda to 1
    v_m_p_fk_meto_pago integer[];
    v_m_p_monto_pago numeric(8, 2)[];
    v_d_v_cant_deta_vent integer[];
    v_d_v_fk_inve_tien_1 integer[];
    v_d_v_fk_inve_tien_2 integer[];
    v_d_v_fk_inve_tien_4 integer[];
    entry RECORD;
BEGIN
    FOR i IN 1..10 LOOP
        v_fecha_vent := CURRENT_DATE - (RANDOM() * 30)::int;
        v_base_imponible_vent := ROUND(RANDOM() * 1000);
        v_online := (RANDOM() < 0);
        SELECT
            rif_clie INTO v_fk_clie
        FROM
            cliente
        ORDER BY
            RANDOM()
        LIMIT 1;
        SELECT
            cod_meto_pago INTO entry
        FROM
            Metodo_Pago
        ORDER BY
            RANDOM()
        LIMIT 1;
        v_m_p_fk_meto_pago := '{}';
        v_m_p_fk_meto_pago := array_append(v_m_p_fk_meto_pago, entry.cod_meto_pago);
        SELECT
            precio_actual_pres,
            fk_cerv_pres_1,
            fk_cerv_pres_2,
            fk_luga_tien INTO entry
        FROM
            Inventario_Tienda
        WHERE
            fk_tien = 1
        ORDER BY
            RANDOM()
        LIMIT 1;
        v_d_v_fk_inve_tien_1 := '{}';
        v_d_v_fk_inve_tien_2 := '{}';
        v_d_v_fk_inve_tien_4 := '{}';
        v_d_v_fk_inve_tien_1 := array_append(v_d_v_fk_inve_tien_1, entry.fk_cerv_pres_1);
        v_d_v_fk_inve_tien_2 := array_append(v_d_v_fk_inve_tien_2, entry.fk_cerv_pres_2);
        v_d_v_fk_inve_tien_4 := array_append(v_d_v_fk_inve_tien_4, entry.fk_luga_tien);
        v_d_v_cant_deta_vent := ARRAY[RANDOM() * 10::int + 1]::int[];
        v_m_p_monto_pago := ARRAY[v_d_v_cant_deta_vent[1] * get_precio_from_inventario (entry.fk_cerv_pres_1, entry.fk_cerv_pres_2, v_fk_tien, entry.fk_luga_tien)]::int[];
        -- Call the venta_en_tienda procedure with the random values
        CALL venta_en_tienda (v_fecha_vent, v_online, v_fk_clie, v_fk_tien, v_m_p_fk_meto_pago, v_m_p_monto_pago, v_d_v_cant_deta_vent, v_d_v_fk_inve_tien_1, v_d_v_fk_inve_tien_2, v_d_v_fk_inve_tien_4);
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_orden_compra_10_productos ()
    AS $$
DECLARE
    x integer;
    i integer;
    res record;
    cant_item int[];
    precio_total numeric = 0;
    fk_inve_tien_1 int[];
    fk_inve_tien_2 int[];
    fk_inve_tien_4 int[];
BEGIN
    FOR i IN 1..10 LOOP
        -- Set Initial Values
        cant_item := '{}';
        precio_total := 0;
        fk_inve_tien_1 := '{}';
        fk_inve_tien_2 := '{}';
        fk_inve_tien_4 := '{}';
        FOR x IN 1..10 LOOP
            SELECT
                fk_cerv_pres_1,
                fk_cerv_pres_2,
                precio_actual_pres,
                fk_luga_tien INTO res
            FROM
                Inventario_Tienda
            WHERE
                fk_tien = 1
                AND fk_cerv_pres_1 <> ALL (fk_inve_tien_1)
            ORDER BY
                RANDOM();
            cant_item := array_append(cant_item, ROUND(RANDOM() * 200) + 200);
            precio_total := precio_total + (cant_item[x] * res.precio_actual_pres);
            fk_inve_tien_1 := array_append(fk_inve_tien_1, res.fk_cerv_pres_1);
            fk_inve_tien_2 := array_append(fk_inve_tien_2, res.fk_cerv_pres_2);
            fk_inve_tien_4 := array_append(fk_inve_tien_4, res.fk_luga_tien);
        END LOOP;
        precio_total := precio_total * 1.16;
        ----
        -- Make them TODAY
        -- Make them ONLINE
        -- Make them from JURIDICO
        -- Make them from SHOP 1
        -- Make them 1 PAYMENT, CHEQUE
        -- Make them 1 PAYMENT, CALCULATED HERE
        -- Arrays of Bought Items, Qty, Beer, Size, ShopPlace
        CALL venta_en_tienda (CURRENT_DATE, TRUE, get_random_juridico (), 1, ARRAY[get_cheque_random ()], ARRAY[precio_total], cant_item, fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_4);
        ----
    END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE COMPRA ]]--
CREATE OR REPLACE PROCEDURE crear_compra ( -- Crear compra
tien_dest int, -- Tienda Destino
miem_prov text, -- Miembro Proveedor
cant_comp int[], -- Cantidad comprada
prec_cerv numeric[], -- Precio por el que la cerveza fue comprada
cerv_arr int[], -- Cervezas a comprar
pres_arr int[] -- Presentaciones a comprar
)
    AS $$
DECLARE
    x int;
    comp int;
BEGIN
    INSERT INTO Compra (fecha_comp, iva_comp, base_imponible_comp, total_comp, fk_tien, fk_miem)
        VALUES (CURRENT_DATE, 0, 0, 0, tien_dest, miem_prov)
    RETURNING
        cod_comp INTO comp;
    FOR x IN 1..array_length(cerv_arr, 1)
    LOOP
        INSERT INTO Detalle_Compra (cant_deta_comp, precio_unitario_comp, fk_cerv_pres_1, fk_cerv_pres_2, fk_comp)
            VALUES (cant_comp[x], prec_cerv[x], cerv_arr[x], pres_arr[x], comp);
    END LOOP;
END
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE EVENTO, DEPENDENT on get_parroquia_from_estado(), get_tipo_even()]]
CREATE OR REPLACE PROCEDURE insertar_evento (nombres varchar(40)[], fechas_hora_ini timestamp [], fechas_hora_fin timestamp [], direcciones text [], capacidades integer [], descripciones text [], precios_entradas numeric (8,2) [], cantidades_entradas integer [], tipos_de_eventos varchar(60) [], parroquias varchar(40) [], estados varchar(40)[])
LANGUAGE plpgsql
AS $$
DECLARE
    estado varchar (40);
    i integer := 1;
    j integer;
BEGIN
    FOREACH estado IN ARRAY estados
    LOOP
        FOR j IN 1..5
        LOOP
            INSERT INTO Evento (nombre_even, fecha_hora_ini_even, fecha_hora_fin_even, direccion_even, capacidad_even, descripcion_even, precio_entrada_even, cant_entradas_evento, fk_tipo_even, fk_luga)
            VALUES (nombres[i], fechas_hora_ini[i], fechas_hora_fin[i], direcciones[i], capacidades[i], descripciones[i], precios_entradas[i], cantidades_entradas[i], get_tipo_even (tipos_de_eventos[i]), get_parroquia_from_estado (parroquias[i],estado));
            i := i + 1;
        END LOOP;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE insert_10venta_entrada ()
LANGUAGE plpgsql
AS $$
DECLARE
    fk_even integer;
    monto numeric(32,2);
    iva numeric(32,2);
    total numeric (32,2);
BEGIN
    FOR i IN 1..10
    LOOP
        fk_even := (SELECT cod_even FROM evento ORDER BY RANDOM() LIMIT 1);
        monto := (SELECT precio_entrada_even FROM Evento WHERE cod_even = fk_even);
        iva := monto*0.16;
        total := monto+iva;
        INSERT INTO Venta (fecha_vent, iva_vent, base_imponible_vent, total_vent, fk_clie, fk_miem, fk_even, fk_tien, fk_cuot, fk_empl) VALUES (CURRENT_DATE, iva, monto, total, get_random_juridico(), null, fk_even, null, null, null);
    END LOOP;
END;
$$;

CALL insert_10venta_entrada();

CREATE OR REPLACE PROCEDURE insert_10detalle_entrada ()
LANGUAGE plpgsql
AS $$
DECLARE
    venta_entrada integer[];
    evento_encontrado integer;
    precio_entrada numeric(32,2);
	v integer;
BEGIN
    SELECT array_agg(cod_vent) INTO venta_entrada FROM Venta WHERE fk_even IS NOT null LIMIT 10;
    FOREACH v IN ARRAY venta_entrada
    LOOP
        evento_encontrado := (SELECT fk_even FROM Venta WHERE cod_vent = v);
        precio_entrada := (SELECT precio_entrada_even FROM Evento WHERE cod_even = evento_encontrado); 
        INSERT INTO Detalle_Entrada (cant_deta_entr, precio_unitario_entr, fk_vent, fk_even)
        VALUES (1, precio_entrada, v, evento_encontrado);
    END LOOP;
END;
$$;

CALL insert_10detalle_entrada();

--[[[ TRIGGER BEGIN ]]]--

-- Trigger to run before inserting on tasa, marks fecha_fin_tasa from latest one to the fecha_ini_tasa from NEW one
CREATE OR REPLACE FUNCTION mark_fecha_fin_tasa_from_latest_tasa()
	RETURNS TRIGGER
	AS $$
BEGIN
	UPDATE Tasa
	SET fecha_fin_tasa = NEW.fecha_ini_tasa
	WHERE fecha_fin_tasa IS NULL;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER before_insert_tasa
	BEFORE INSERT ON Tasa
	FOR EACH ROW
	EXECUTE FUNCTION mark_fecha_fin_tasa_from_latest_tasa();

-- Trigger to run after inserting on event, marks it as 'Pendiente'
CREATE OR REPLACE FUNCTION insert_into_esta_even ()
    RETURNS TRIGGER
    AS $$
BEGIN
    INSERT INTO ESTA_EVEN (fk_esta, fk_even, fecha_ini)
        VALUES (get_estatus ('Pendiente'), NEW.cod_even, NOW());
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_insert_evento
    AFTER INSERT ON Evento
    FOR EACH ROW
    EXECUTE FUNCTION insert_into_esta_even ();

-- Trigger to run after insert on Venta, to create PUNT_CLIE if NOT online
CREATE OR REPLACE FUNCTION create_punc_canj_historial_on_new_venta ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF NOT NEW.online THEN
        INSERT INTO PUNT_CLIE (fk_clie, fk_tasa, fk_vent, cant_puntos_acum, cant_puntos_canj, fecha_transaccion)
            VALUES (NEW.fk_clie, create_or_insert_tasa (NEW.fecha_vent), NEW.cod_vent, get_most_recent_punt_clie_punt (NEW.fk_clie), 0, NEW.fecha_vent);
    END IF;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER create_punc_canj_on_venta_creation
    AFTER INSERT ON Venta
    FOR EACH ROW
    EXECUTE FUNCTION create_punc_canj_historial_on_new_venta ();

-- Trigger to run after insert on Venta, to create status as 'Pagado'
CREATE OR REPLACE FUNCTION create_new_estatus_for_venta ()
    RETURNS TRIGGER
    AS $$
BEGIN
	IF NEW.online THEN
		RETURN NEW;
	END IF;
    INSERT INTO ESTA_VENT (fk_esta, fk_vent, fecha_ini, fecha_fin)
        VALUES (get_estatus_by_name ('Pagado'), NEW.cod_vent, NEW.fecha_vent, NULL);
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER set_estatus_for_new_venta
    AFTER INSERT ON Venta
    FOR EACH ROW
    EXECUTE FUNCTION create_new_estatus_for_venta ();

-- Trigger to run after insert on Detalle_Venta, to update total on Venta
CREATE OR REPLACE FUNCTION increment_venta_total ()
    RETURNS TRIGGER
    AS $$
BEGIN
    UPDATE
        Venta
    SET
        iva_vent = iva_vent + NEW.cant_deta_vent * NEW.precio_unitario_vent * 0.16,
        base_imponible_vent = base_imponible_vent + NEW.cant_deta_vent * NEW.precio_unitario_vent
    WHERE
        cod_vent = NEW.fk_vent;
    UPDATE
        Venta
    SET
        total_vent = base_imponible_vent + iva_vent
    WHERE
        cod_vent = NEW.fk_vent;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_insert_detalle_venta
    AFTER INSERT ON Detalle_Venta
    FOR EACH ROW
    EXECUTE FUNCTION increment_venta_total ();

-- Trigger to run after insert on Detalle_Venta, to discount items from inventory
CREATE OR REPLACE FUNCTION remove_from_inventory ()
    RETURNS TRIGGER
    AS $$
BEGIN
    UPDATE
        Inventario_Tienda
    SET
        cant_pres = (cant_pres - NEW.cant_deta_vent)
    WHERE
        NEW.fk_inve_tien_1 = fk_cerv_pres_1
        AND NEW.fk_inve_tien_2 = fk_cerv_pres_2
        AND NEW.fk_inve_tien_3 = fk_tien
        AND NEW.fk_inve_tien_4 = fk_luga_tien;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER remove_from_inventory_after_detalle
    AFTER INSERT ON Detalle_Venta
    FOR EACH ROW
    EXECUTE FUNCTION remove_from_inventory ();

-- Trigger to run after insert on Detalle_Venta, sum points per product bought
CREATE OR REPLACE FUNCTION add_points_to_clie ()
    RETURNS TRIGGER
    AS $$
DECLARE
	v record;
BEGIN
	SELECT * FROM Venta WHERE cod_vent = NEW.fk_vent INTO v;
	-- If venta is online, user does not win points
	IF v.online THEN
		RETURN NEW;
	END IF;

    UPDATE
        PUNT_CLIE
    SET
        cant_puntos_acum = cant_puntos_acum + NEW.cant_deta_vent,
        cant_puntos_canj = cant_puntos_canj + NEW.cant_deta_vent
    WHERE
        fk_vent = NEW.fk_vent;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER add_points_on_venta
    AFTER INSERT ON Detalle_Venta
    FOR EACH ROW
    EXECUTE FUNCTION add_points_to_clie ();

-- Trigger to run after insert on Pago, substract points when points were used, and create PUNT_CLIE if necessary
CREATE OR REPLACE FUNCTION substract_points_to_clie ()
    RETURNS TRIGGER
    AS $$
DECLARE
    vent RECORD;
BEGIN
    -- If it's not Punto_Canjeo, bail
    IF NOT EXISTS (
        SELECT
            1
        FROM
            Punto_Canjeo
        WHERE
            fk_meto_pago = NEW.fk_meto_pago) THEN
    RETURN NEW;
END IF;
    -- If PUNT_CLIE doesn't exist for the current Venta, create one
    IF NOT EXISTS (
        SELECT
            1
        FROM
            PUNT_CLIE
        WHERE
            fk_vent = NEW.fk_vent) THEN
    SELECT
        *
    FROM
        Venta
    WHERE
        cod_vent = NEW.fk_vent INTO vent;
    INSERT INTO PUNT_CLIE (fk_clie, fk_tasa, fk_vent, cant_puntos_acum, cant_puntos_canj, fecha_transaccion)
        VALUES (vent.fk_clie, NEW.fk_tasa, NEW.fk_vent, get_most_recent_punt_clie_punt (vent.fk_clie), 0, NEW.fecha_pago);
END IF;
    -- Finally, update the thing to have the correct data
    UPDATE
        PUNT_CLIE
    SET
        cant_puntos_acum = cant_puntos_acum - (NEW.monto_pago / get_tasa_conversion (NEW.fecha_pago)),
        cant_puntos_canj = cant_puntos_canj - (NEW.monto_pago / get_tasa_conversion (NEW.fecha_pago))
    WHERE
        fk_vent = NEW.fk_vent;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER substract_points_on_venta
    AFTER INSERT ON Pago
    FOR EACH ROW
    EXECUTE FUNCTION substract_points_to_clie ();

-- Trigger to run after insert on Compra to set estatus as 'Por Aprobar'
CREATE OR REPLACE FUNCTION tri_create_esta_comp_pendiente ()
    RETURNS TRIGGER
    AS $$
DECLARE
    compra_pagada integer;
BEGIN
    SELECT
        cod_esta
    FROM
        Estatus
    WHERE
        nombre_esta = 'Por aprobar'
    LIMIT 1 INTO compra_pagada;
    INSERT INTO ESTA_COMP (fk_esta, fk_comp, fecha_ini)
        VALUES (compra_pagada, NEW.cod_comp, CURRENT_DATE);
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_compra_insert_create_esta_comp_pendiente
    AFTER INSERT ON Compra
    FOR EACH ROW
    EXECUTE FUNCTION tri_create_esta_comp_pendiente ();

-- Trigger to run after insert on Detalle_Compra,
CREATE OR REPLACE FUNCTION tri_increment_compra_total ()
    RETURNS TRIGGER
    AS $$
BEGIN
    UPDATE
        Compra
    SET
        base_imponible_comp = base_imponible_comp + (NEW.cant_deta_comp * NEW.precio_unitario_comp),
        iva_comp = iva_comp + (NEW.cant_deta_comp * NEW.precio_unitario_comp) * 0.16,
        total_comp = total_comp + (NEW.cant_deta_comp * NEW.precio_unitario_comp) * 1.16
    WHERE
        cod_comp = NEW.fk_comp;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_detalle_compra_insert_increment_compra_total
    AFTER INSERT ON Detalle_Compra
    FOR EACH ROW
    EXECUTE FUNCTION tri_increment_compra_total ();

-- Trigger to run after insert on ESTA_COMP, add units to inventario correspondiente (probably algun almacen) when estatus = 'Compra Pagada'
CREATE OR REPLACE FUNCTION tri_add_inventario_tienda ()
    RETURNS TRIGGER
    AS $$
DECLARE
    comp record;
    luga_tien record;
    cerv_pres record;
    deta_comp record;
BEGIN
    IF NEW.fk_esta <> (
        SELECT
            cod_esta
        FROM
            Estatus
        WHERE
            nombre_esta = 'Compra Pagada'
        LIMIT 1) THEN
        RETURN NEW;
    END IF;
    SELECT
        *
    FROM
        Compra
    WHERE
        cod_comp = NEW.fk_comp INTO comp;
    SELECT
        *
    FROM
        Lugar_Tienda
    WHERE
        tipo_luga_tien = 'Almacen'
    ORDER BY
        cod_luga_tien ASC
    LIMIT 1 INTO luga_tien;
    -- Loop for each detalle copra in compra
    FOR deta_comp IN (
        SELECT
            *
        FROM
            Detalle_Compra AS dc
        WHERE
            dc.fk_comp = comp.cod_comp)
        LOOP
            -- If inventario_tienda does not exist for cerveza_presentacion
            IF NOT EXISTS (
                SELECT
                    *
                FROM
                    Inventario_Tienda AS i_t
                    JOIN Lugar_Tienda AS lt ON lt.tipo_luga_tien = 'Almacen'
                        AND i_t.fk_luga_tien = lt.cod_luga_tien
                WHERE
                    fk_tien = 1
                    AND fk_cerv_pres_1 = i_t.fk_cerv_pres_1
                    AND fk_cerv_pres_2 = i_t.fk_cerv_pres_2) THEN
            cerv_pres := (
                SELECT
                    *
                FROM
                    CERV_PRES
                WHERE
                    fk_cerv = deta_comp.fk_cerv_pres_1
                    AND fk_pres = deta_comp.fk_cerv_pres_2
                    AND fk_miem = comp.fk_miem);
            INSERT INTO Inventario_Tienda (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien, fk_luga_tien, cant_pres, precio_actual_pres)
                VALUES (deta_comp.fk_cerv_pres_1, deta_comp.fk_cerv_pres_2, comp.fk_tien, luga_tien.cod_luga_tien, 0, cerv_pres.precio_cerv_pres);
        END IF;
    -- After checking if doesnt exist (and inserting if doesnt, put here)
    UPDATE
        Inventario_Tienda
    SET
        cant_pres = cant_pres + deta_comp.cant_deta_comp
    WHERE
        fk_cerv_pres_1 = deta_comp.fk_cerv_pres_1
        AND fk_cerv_pres_2 = deta_comp.fk_cerv_pres_2
        AND fk_tien = 1
		AND cant_pres < 100; -- HACK: Arreglar esto en algun momento
END LOOP;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_esta_compra_insert_add_inventario_tienda
    AFTER INSERT ON ESTA_COMP
    FOR EACH ROW
    EXECUTE FUNCTION tri_add_inventario_tienda ();

CREATE OR REPLACE FUNCTION on_low_stock_create_orden_compra()
	RETURNS TRIGGER
	AS $$
DECLARE
	cerv integer;
	pres integer;
	miem text;
BEGIN
	IF NEW.cant_pres > 100 THEN
		RETURN NEW;
	END IF;

	SELECT fk_miem
	FROM CERV_PRES
	WHERE fk_cerv = NEW.fk_cerv_pres_1 AND fk_pres = NEW.fk_cerv_pres_2
	INTO miem;

	CALL crear_compra ( -- Crear compra
		1, -- Tienda Destino
		miem, -- Miembro Proveedor
		ARRAY [10000], -- Cantidad comprada
		ARRAY [4.99], -- Precio por el que la cerveza fue comprada
		ARRAY [NEW.fk_cerv_pres_1], -- Cervezas a comprar
		ARRAY [NEW.fk_cerv_pres_2] -- Presentaciones a comprar
	);

	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_low_stock_create_compra
	AFTER UPDATE ON Inventario_Tienda
	FOR EACH ROW
	EXECUTE FUNCTION on_low_stock_create_orden_compra();

--[[[ TRIGGER END ]]]--

--[[[ INSERT BEGIN ]]]--

--[[ INSERT JUEZ, INDEPENDENT ]]--
INSERT INTO Juez (primar_nom_juez, segundo_nom_juez, primar_ape_juez, segundo_ape_juez, ci_juez)
    VALUES ('Dot', 'Bay', 'Linton', 'Dossit', '0785098'),
    ('Patton', 'Grayce', 'Bartlosz', 'Roston', '7272681'),
    ('Quincy', 'Renee', 'Krzysztofiak', 'Pietz', '8088538'),
    ('Janeva', 'Tera', 'Belz', 'Amis', '5472356'),
    ('Valle', 'Valle', 'Trevarthen', 'Jadczak', '6944297'),
    ('Ephrem', 'Sybilla', 'O''Cannovane', 'Indgs', '4532104'),
    ('Albertina', 'Ermentrude', 'Linnell', 'Fraczek', '3006741'),
    ('Georgine', 'Haskel', 'Reeks', 'Regi', '9667987'),
    ('Nora', 'Gayla', 'Ensten', 'Jeandeau', '0912550'),
    ('Marwin', 'Llywellyn', 'Fairney', 'Brain', '0908301');

--[[ INSERT ROL, INDEPENDENT ]]--
INSERT INTO Rol
    VALUES (100, 'Miembro', 'Proveedor de Cervezas'),
    (200, 'Cliente Natural', 'Persona Natural, compra cervezas'),
    (201, 'Cliente Juridico', 'Persona Juridica, puede comprar cervezas, usualmente en gran cantidad'),
    (300, 'Empleado Regular', 'Empleado del mas bajo nivel'),
    (301, 'Empleado Ventas en Linea', 'Empleado encargado de manejar las ventas en linea'),
    (302, 'Empleado Despacho', 'Empleado encargado de manejar y gestionar inventario y pasillo'),
    (303, 'Empleado Entrega', 'Empleado encargado de la logistica de entrega de cervezas'),
    (304, 'Empleado Compras', 'Empleado encargado de la logistica de compras y ordenes de reposicion'),
    (400, 'Empleado Administrador', 'Empleado encargado de administrar otros empleados'),
    (500, 'Administrador', 'Empleado encargado de administrar todo el sistema');

--[[ INSERT TASA, INDEPENDENT ]]--
INSERT INTO Tasa (tasa_dolar_bcv, tasa_punto, fecha_ini_tasa, fecha_fin_tasa)
    VALUES (36.50, 1.00, '2024-01-01', NULL),
    (36.75, 1.00, '2024-01-02', NULL),
    (37.00, 1.00, '2024-01-03', NULL),
    (37.25, 1.00, '2024-01-04', NULL),
    (37.50, 1.00, '2024-01-05', NULL),
    (37.80, 1.00, '2024-01-06', NULL),
    (38.00, 1.00, '2024-01-07', NULL),
    (38.20, 1.00, '2024-01-08', NULL),
    (38.50, 1.00, '2024-01-09', NULL),
    (38.75, 1.00, '2024-01-10', NULL);

--[[ INSERT CARGO, INDEPENDENT ]]--
INSERT INTO Cargo (nombre_carg)
    VALUES ('Administrador'),
    ('Gerente'),
    ('Analista'),
    ('Jefe'),
    ('Especialista de Marketing'),
    ('Contador'),
    ('Coordinador de Eventos'),
    ('Gestor de Inventario'),
    ('Especialista de Reportes'),
    ('Empleado'),
    ('Vigilante');

--[[ INSERT BANCO, INDEPENDENT ]]--
INSERT INTO Banco (nombre_banc)
    VALUES ('Banco de Venezuela'),
    ('Bancamiga'),
    ('Banesco'),
    ('Banco Mercantil'),
    ('Banco Nacional de Crédito (BNC)'),
    ('Banco del Tesoro'),
    ('Banco Exterior'),
    ('Banco Provincial'),
    ('Banco Caroní'),
    ('Banco Sofitasa'),
    ('Banca Amiga'),
    ('Banco Agrícola de Venezuela'),
    ('Banco Bicentenario'),
    ('Banco del Caribe');

-- [[ INSERT CUOTA, INDEPENDENT ]]--
INSERT INTO Cuota (nombre_plan_cuot, precio_cuot)
    VALUES ('Monthly Plan January 2024', 50.00),
    ('Monthly Plan February 2024', 50.00),
    ('Monthly Plan March 2024', 50.00),
    ('Monthly Plan April 2024', 50.00),
    ('Monthly Plan May 2024', 50.00),
    ('Monthly Plan June 2024', 50.00),
    ('Monthly Plan July 2024', 50.00),
    ('Monthly Plan August 2024', 50.00),
    ('Monthly Plan September 2024', 50.00),
    ('Monthly Plan October 2024', 50.00);

-- [[ INSERT TIPO_EVENTO, INDEPENDENT ]]--
INSERT INTO Tipo_Evento (nombre_tipo_even)
    VALUES ('Cata de cervezas'),
    ('Recorrido por cerveceria'),
    ('Festival de Cervezas'),
    ('Cena de Maridaje'),
    ('Taller de Elaboracion de Cerveza'),
    ('Fiesta de Lanzamiento de Cervezas de Temporada'),
    ('Noche de Musica en Vivo'),
    ('Noche de Trivia'),
    ('Evento de Cerveza y Arte'),
    ('Evento de Networking Para Cerveceros');

-- [[ INSERT LUGAR_TIENDA, INDEPENDENT ]]--
INSERT INTO Lugar_Tienda (nombre_luga_tien, tipo_luga_tien, fk_luga_tien)
    VALUES ('Almacen Principal', 'Almacen', NULL),
    ('Pasillo 1', 'Pasillo', 1),
    ('Pasillo 2', 'Pasillo', 1),
    ('Anaquel A1', 'Anaquel', 2),
    ('Anaquel A2', 'Anaquel', 2),
    ('Pasillo 3', 'Pasillo', 1),
    ('Anaquel B1', 'Anaquel', 3),
    ('Almacen Secundario', 'Almacen', NULL),
    ('Pasillo 4', 'Pasillo', 8),
    ('Anaquel C1', 'Anaquel', 9);

-- [[ INSERT HORARIO, INDEPENDENT ]]--
INSERT INTO Horario (hora_ini_hora, hora_fin_hora, dia_hora)
    VALUES ('08:00', '16:00', 'Lunes'),
    ('09:00', '17:00', 'Martes'),
    ('10:00', '18:00', 'Miercoles'),
    ('07:30', '15:30', 'Jueves'),
    ('12:00', '20:00', 'Viernes'),
    ('08:00', '14:00', 'Sabado'),
    ('09:00', '13:00', 'Domingo'),
    ('14:00', '22:00', 'Lunes'),
    ('16:00', '00:00', 'Viernes'),
    ('18:00', '02:00', 'Sabado');

-- [[ INSERT BENEFICIO, INDEPENDENT ]]--
INSERT INTO Beneficio (nombre_bene, cantidad_bene)
	VALUES ('Salario Competitivo', 50000),
	('Seguro de Salud', 2000),
	('Vacaciones Pagadas', 3000),
	('Bonificaciones Anuales', 5000),
	('Capacitación y Desarrollo', 1500),
	('Horario Flexible', 0),
	('Trabajo Remoto', 0),
	('Plan de Jubilación', 3000),
	('Días de Enfermedad Pagados', 2000),
	('Beneficios de Bienestar', 1000);

-- [[ INSERT ESTATUS, INDEPENDENT ]]--
INSERT INTO Estatus (nombre_esta, descripcion_esta)
    VALUES
        -- Estatus de Compras
        ('Por aprobar', 'El jefe del departamento de compras aún no ha aceptado la solicitud de reposición'),
        ('Por pagar', 'El jefe del departamento de compras aun no ha realizado el pago de compra a proveedor'),
        ('Cancelado', 'El jefe de del departamento de compras ha cancelado la orden de reposición'),
        ('Compra Pagada', 'El jefe de del departamento de compras ha cancelado la orden de reposición'),
        -- Estatus de Ventas
        ('Pagado', 'La entrega u presupuesto ha sido pagada'),
        ('En Camino', 'La entrega esta en camino a su destino'),
        ('Entregado', 'La venta ha concluido'),
        -- Estatus de Eventos
        ('Pendiente', 'El evento ha sido formalizado pero aún no ha iniciado'),
        ('En curso', 'El evento esta ocurriendo en estos instantes'),
        ('Cancelado', 'El evento ha sido cancelado'),
        ('Finalizado', 'El evento ha finalizado');

--[[ INSERT PRESENTACION, INDEPENDENT ]]--
INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Botella Estandar', 330),
    ('Botella Extra-Grande', 1000),
    ('Botella Grande', 500),
    ('Botella Pequeña', 250),
    ('Lata Estandar', 330),
    ('Lata Extra-Grande', 1000),
    ('Lata Grande', 500),
    ('Lata Pequeña', 250),
    ('Pinta Americana', 473),
    ('Pinta Inglesa', 568);

--[[ INSERT DESCUENTO, INDEPENDENT ]]--
INSERT INTO DESCUENTO (descripcion_desc, fecha_ini_desc, fecha_fin_desc)
    VALUES ('Descuento de Navidad', '2022-12-01', '2023-01-01'),
    ('Descuento DiarioUnaCerveza', '2023-01-01', '2023-01-21'),
    ('Descuento DiarioUnaCerveza', '2023-01-21', '2023-02-10'),
    ('Descuento DiarioUnaCerveza', '2023-02-10', '2023-03-02'),
    ('Descuento DiarioUnaCerveza', '2023-03-02', '2023-03-22'),
    ('Descuento DiarioUnaCerveza', '2023-03-22', '2023-04-11'),
    ('Descuento DiarioUnaCerveza', '2023-04-11', '2023-05-01'),
    ('Descuento DiarioUnaCerveza', '2023-05-01', '2023-05-21'),
    ('Descuento DiarioUnaCerveza', '2023-05-21', '2023-06-10'),
    ('Descuento DiarioUnaCerveza', '2023-06-10', '2023-06-30');

--[[ INSERT ESTADOS,
-- DEPENDENT on PROCEDURE ESTADOS ]]--
CALL insert_estados(ARRAY ['Amazonas', 'Anzoategui', 'Apure', 'Aragua', 'Barinas', 'Bolivar', 'Carabobo', 'Cojedes', 'Delta Amacuro', 'Distrito Capital', 'Falcon', 'Guarico', 'La Guaira', 'Lara', 'Merida', 'Miranda', 'Monagas', 'Nueva Esparta', 'Portuguesa', 'Sucre', 'Tachira', 'Trujillo', 'Yaracuy', 'Zulia']);

-- Amazonas
CALL insert_municipios(ARRAY['Altures', 'Alto Orinoco', 'Atabapo', 'Autana', 'Manapiare', 'Maroa', 'Rio Negro'], 'Amazonas');
CALL insert_parroquias(ARRAY['Fernando Giron Tovar', 'Luis Alberto Gomez', 'Parhueña', 'Platanillal'], 'Altures', 'Amazonas');
CALL insert_parroquias(ARRAY['La Esmeralda', 'Marawaka', 'Mavaca', 'Sierra Parima'], 'Alto Orinoco', 'Amazonas');
CALL insert_parroquias(ARRAY['San Fernando de Atabapo', 'Laja Lisa', 'Santa Barbara', 'Guarinuma'], 'Atabapo', 'Amazonas');
CALL insert_parroquias(ARRAY['Isla Raton', 'San Pedro del Orinoco', 'Pendare', 'Manduapo', 'Samariapo'], 'Autana', 'Amazonas');
CALL insert_parroquias(ARRAY['San Juan de Manapiare', 'Camani', 'Capure', 'Manueta'], 'Manapiare', 'Amazonas');
CALL insert_parroquias(ARRAY['Maroa', 'Comunidad', 'Victorino'], 'Maroa', 'Amazonas');
CALL insert_parroquias(ARRAY['San Carlos de Rio Negro', 'Solano', 'Curimacare', 'Santa Lucia'], 'Rio Negro', 'Amazonas');

-- Anzoategui
CALL insert_municipios(ARRAY['Anaco', 'Aragua', 'Diego Bautista Urbaneja', 'Fernando de Peñalver', 'Francisco del Carmen Carvajal', 'Francisco de Miranda', 'Guanta', 'Independencia', 'Jose Gregorio Monagas', 'Juan Antonio Sotillo', 'Juan Manuel Cajigal', 'Libertad', 'Manuel Ezequiel Bruzual', 'Pedro Maria Freites', 'Piritu', 'Guanipa', 'San Juan de Capistrano', 'Santa Ana', 'Simon Bolivar', 'Simon Rodriguez', 'Sir Arthur McGregor'], 'Anzoategui');
CALL insert_parroquias(ARRAY['Anaco', 'San Joaquin'], 'Anaco', 'Anzoategui');
CALL insert_parroquias(ARRAY['Cachipo', 'Aragua de Barcelona'], 'Aragua', 'Anzoategui');
CALL insert_parroquias(ARRAY['Lecheria', 'El Morro'], 'Diego Bautista Urbaneja', 'Anzoategui');
CALL insert_parroquias(ARRAY['San Miguel', 'Sucre'], 'Fernando de Peñalver', 'Anzoategui');
CALL insert_parroquias(ARRAY['Valle de Guanape', 'Santa Barbara'], 'Francisco del Carmen Carvajal', 'Anzoategui');
CALL insert_parroquias(ARRAY['Atapirire', 'Boca del Pao', 'El Pao', 'Pariaguan'], 'Francisco de Miranda', 'Anzoategui');
CALL insert_parroquias(ARRAY['Guanta', 'Chorreron'], 'Guanta', 'Anzoategui');
CALL insert_parroquias(ARRAY['Mamo', 'Soledad'], 'Independencia', 'Anzoategui');
CALL insert_parroquias(ARRAY['Mapire', 'Piar', 'Santa Clara', 'San Diego de Cabrutica', 'Uverito', 'Zuata'], 'Jose Gregorio Monagas', 'Anzoategui');
CALL insert_parroquias(ARRAY['Puerto La Cruz', 'Pozuelos'], 'Juan Antonio Sotillo', 'Anzoategui');
CALL insert_parroquias(ARRAY['Onoto', 'San Pablo'], 'Juan Manuel Cajigal', 'Anzoategui');
CALL insert_parroquias(ARRAY['San Mateo', 'El Carito', 'Santa Ines', 'La Romereña'], 'Libertad', 'Anzoategui');
CALL insert_parroquias(ARRAY['Clarines', 'Guanape', 'Sabana de Uchire'], 'Manuel Ezequiel Bruzual', 'Anzoategui');
CALL insert_parroquias(ARRAY['Cantaura', 'Libertador', 'Santa Rosa', 'Urica'], 'Pedro Maria Freites', 'Anzoategui');
CALL insert_parroquias(ARRAY['Piritu', 'San Francisco'], 'Piritu', 'Anzoategui');
CALL insert_parroquias(ARRAY['San Jose de Guanipa'], 'Guanipa', 'Anzoategui');
CALL insert_parroquias(ARRAY['Boca de Uchire', 'Boca de Chavez'], 'San Juan de Capistrano', 'Anzoategui');
CALL insert_parroquias(ARRAY['Pueblo Nuevo', 'Santa Ana'], 'Santa Ana', 'Anzoategui');
CALL insert_parroquias(ARRAY['Bergantin', 'El Pilar', 'Naricual', 'San Cristobal'], 'Simon Bolivar', 'Anzoategui');
CALL insert_parroquias(ARRAY['Edmundo Barrios', 'Miguel Otero Silva'], 'Simon Rodriguez', 'Anzoategui');
CALL insert_parroquias(ARRAY['El Chaparro', 'Tomas Alfaro', 'Calatrava'], 'Sir Arthur McGregor', 'Anzoategui');

-- Apure
CALL insert_municipios(ARRAY['Achaguas', 'Biruaca', 'Muñoz', 'Paez', 'Pedro Camejo', 'Romulo Gallegos', 'San Fernando'], 'Apure');
CALL insert_parroquias(ARRAY['Achaguas', 'Apurito', 'El Yagual', 'Guachara', 'Mucuritas', 'Queseras del Medio'], 'Achaguas', 'Apure');
CALL insert_parroquias(ARRAY['Biruaca'], 'Biruaca', 'Apure');
CALL insert_parroquias(ARRAY['Bruzual', 'Santa Barbara'], 'Muñoz', 'Apure');
CALL insert_parroquias(ARRAY['Guasdualito', 'Aramendi', 'El Amparo', 'San Camilo', 'Urdaneta', 'Canagua', 'Dominga Ortiz de Paez', 'Santa Rosalia'], 'Paez', 'Apure');
CALL insert_parroquias(ARRAY['San Juan de Payara', 'Codazzi', 'Cunaviche'], 'Pedro Camejo', 'Apure');
CALL insert_parroquias(ARRAY['Elorza', 'La Trinidad de Orichuna'], 'Romulo Gallegos', 'Apure');
CALL insert_parroquias(ARRAY['El Recreo', 'Peñalver', 'San Fernando de Apure', 'San Rafael de Atamaica'], 'San Fernando', 'Apure');

-- Aragua
CALL insert_municipios(ARRAY['Girardot', 'Bolivar', 'Mario Briceño Iragorry', 'Santos Michelena', 'Sucre', 'Santiago Mariño', 'Jose angel Lamas', 'Francisco Linares Alcantara', 'San Casimiro', 'Urdaneta', 'Jose Felix Ribas', 'Jose Rafael Revenga', 'Ocumare de la Costa de Oro', 'Tovar', 'Camatagua', 'Zamora', 'San Sebastian', 'Libertador'], 'Aragua');
CALL insert_parroquias(ARRAY['Bolivar San Mateo'], 'Bolivar', 'Aragua');
CALL insert_parroquias(ARRAY['Camatagua', 'Carmen de Cura'], 'Camatagua', 'Aragua');
CALL insert_parroquias(ARRAY['Santa Rita', 'Francisco de Miranda', 'Moseñor Feliciano Gonzalez Paraparal'], 'Francisco Linares Alcantara', 'Aragua');
CALL insert_parroquias(ARRAY['Pedro Jose Ovalles', 'Joaquin Crespo', 'Jose Casanova Godoy', 'Madre Maria de San Jose', 'Andres Eloy Blanco', 'Los Tacarigua', 'Las Delicias', 'Choroni'], 'Girardot', 'Aragua');
CALL insert_parroquias(ARRAY['Santa Cruz'], 'Jose angel Lamas', 'Aragua');
CALL insert_parroquias(ARRAY['Jose Felix Ribas', 'Castor Nieves Rios', 'Las Guacamayas', 'Pao de Zarate', 'Zuata'], 'Jose Felix Ribas', 'Aragua');
CALL insert_parroquias(ARRAY['Jose Rafael Revenga'], 'Jose Rafael Revenga', 'Aragua');
CALL insert_parroquias(ARRAY['Palo Negro', 'San Martin de Porres'], 'Libertador', 'Aragua');
CALL insert_parroquias(ARRAY['El Limon', 'Caña de Azucar'], 'Mario Briceño Iragorry', 'Aragua');
CALL insert_parroquias(ARRAY['Ocumare de la Costa'], 'Ocumare de la Costa de Oro', 'Aragua');
CALL insert_parroquias(ARRAY['San Casimiro', 'Güiripa', 'Ollas de Caramacate', 'Valle Morin'], 'San Casimiro', 'Aragua');
CALL insert_parroquias(ARRAY['San Sebastian'], 'San Sebastian', 'Aragua');
CALL insert_parroquias(ARRAY['Turmero', 'Arevalo Aponte', 'Chuao', 'Saman de Güere', 'Alfredo Pacheco Miranda'], 'Santiago Mariño', 'Aragua');
CALL insert_parroquias(ARRAY['Santos Michelena', 'Tiara'], 'Santos Michelena', 'Aragua');
CALL insert_parroquias(ARRAY['Cagua', 'Bella Vista'], 'Sucre', 'Aragua');
CALL insert_parroquias(ARRAY['Tovar'], 'Tovar', 'Aragua');
CALL insert_parroquias(ARRAY['Urdaneta', 'Las Peñitas', 'San Francisco de Cara', 'Taguay'], 'Urdaneta', 'Aragua');
CALL insert_parroquias(ARRAY['Zamora', 'Magdaleno', 'San Francisco de Asis', 'Valles de Tucutunemo', 'Augusto Mijares'], 'Zamora', 'Aragua');

-- Barinas
CALL insert_municipios(ARRAY['Alberto Arvelo Torrealba', 'Andres Eloy Blanco', 'Antonio Jose de Sucre', 'Arismendi', 'Barinas', 'Bolivar', 'Cruz Paredes', 'Ezequiel Zamora', 'Obispos', 'Pedraza', 'Sosa', 'Rojas'], 'Barinas');
CALL insert_parroquias(ARRAY['Arismendi', 'Guadarrama', 'La Union', 'San Antonio'], 'Arismendi', 'Barinas');
CALL insert_parroquias(ARRAY['Barinas', 'Alfredo Arvelo Larriva', 'San Silvestre', 'Santa Ines', 'Santa Lucia', 'Torunos', 'El Carmen', 'Romulo Betancourt', 'Corazon de Jesus', 'Ramon Ignacio Mendez', 'Alto Barinas', 'Manuel Palacio Fajardo', 'Juan Antonio Rodriguez Dominguez', 'Dominga Ortiz de Paez'], 'Barinas', 'Barinas');
CALL insert_parroquias(ARRAY['El Canton', 'Santa Cruz de Guacas', 'Puerto Vivas'], 'Andres Eloy Blanco', 'Barinas');
CALL insert_parroquias(ARRAY['Barinitas', 'Altamira de Caceres', 'Calderas'], 'Bolivar', 'Barinas');
CALL insert_parroquias(ARRAY['Masparrito', 'El Socorro', 'Barrancas'], 'Cruz Paredes', 'Barinas');
CALL insert_parroquias(ARRAY['Obispos', 'El Real', 'La Luz', 'Los Guasimitos'], 'Obispos', 'Barinas');
CALL insert_parroquias(ARRAY['Ciudad Bolivia', 'Ignacio Briceño', 'Jose Felix Ribas', 'Paez'], 'Pedraza', 'Barinas');
CALL insert_parroquias(ARRAY['Libertad', 'Dolores', 'Santa Rosa', 'Simon Rodriguez', 'Palacio Fajardo'], 'Rojas', 'Barinas');
CALL insert_parroquias(ARRAY['Ciudad de Nutrias', 'El Regalo', 'Puerto Nutrias', 'Santa Catalina', 'Simon Bolivar'], 'Sosa', 'Barinas');
CALL insert_parroquias(ARRAY['Ticoporo', 'Nicolas Pulido', 'Andres Bello'], 'Antonio Jose de Sucre', 'Barinas');
CALL insert_parroquias(ARRAY['Sabaneta', 'Juan Antonio Rodriguez Dominguez'], 'Alberto Arvelo Torrealba', 'Barinas');
CALL insert_parroquias(ARRAY['Santa Barbara', 'Pedro Briceño Mendez', 'Ramon Ignacio Mendez', 'Jose Ignacio del Pumar'], 'Ezequiel Zamora', 'Barinas');

-- Bolivar
CALL insert_municipios(ARRAY['Caroni', 'Cedeño', 'El Callao', 'Gran Sabana', 'Heres', 'Padre Pedro Chien', 'Piar', 'Angostura', 'Roscio', 'Sifontes', 'Sucre'], 'Bolivar');
CALL insert_parroquias(ARRAY['Cachamay', 'Chirica', 'Dalla Costa', 'Once de Abril', 'Simon Bolivar', 'Unare', 'Universidad', 'Vista al Sol', 'Pozo Verde', 'Yocoima', '5 de Julio'], 'Caroni', 'Bolivar');
CALL insert_parroquias(ARRAY['Cedeño', 'Altagracia', 'Ascension Farreras', 'Guaniamo', 'La Urbana', 'Pijiguaos'], 'Cedeño', 'Bolivar');
CALL insert_parroquias(ARRAY['El Callao'], 'El Callao', 'Bolivar');
CALL insert_parroquias(ARRAY['Gran Sabana', 'Ikabaru'], 'Gran Sabana', 'Bolivar');
CALL insert_parroquias(ARRAY['Catedral', 'Zea', 'Orinoco', 'Jose Antonio Paez', 'Marhuanta', 'Agua Salada', 'Vista Hermosa', 'La Sabanita', 'Panapana'], 'Heres', 'Bolivar');
CALL insert_parroquias(ARRAY['Padre Pedro Chien'], 'Padre Pedro Chien', 'Bolivar');
CALL insert_parroquias(ARRAY['Andres Eloy Blanco', 'Pedro Cova', 'Upata'], 'Piar', 'Bolivar');
CALL insert_parroquias(ARRAY['Raul Leoni', 'Barceloneta', 'Santa Barbara', 'San Francisco'], 'Angostura', 'Bolivar');
CALL insert_parroquias(ARRAY['Roscio', 'Salom'], 'Roscio', 'Bolivar');
CALL insert_parroquias(ARRAY['Tumeremo', 'Dalla Costa', 'San Isidro'], 'Sifontes', 'Bolivar');
CALL insert_parroquias(ARRAY['Sucre', 'Aripao', 'Guarataro', 'Las Majadas', 'Moitaco'], 'Sucre', 'Bolivar');

-- Carabobo
CALL insert_municipios(ARRAY['Bejuma','Carlos Arvelo','Diego Ibarra','Guacara','Juan Jose Mora','Libertador','Los Guayos','Miranda','Montalban','Naguanagua','Puerto Cabello','San Diego','San Joaquin','Valencia'],'Carabobo');
CALL insert_parroquias(ARRAY['Canoabo', 'Simon Bolivar'], 'Bejuma', 'Carabobo');
CALL insert_parroquias(ARRAY['Güigüe', 'Belen', 'Tacarigua'], 'Carlos Arvelo', 'Carabobo');
CALL insert_parroquias(ARRAY['Mariara', 'Aguas Calientes'], 'Diego Ibarra', 'Carabobo');
CALL insert_parroquias(ARRAY['Ciudad Alianza', 'Guacara', 'Yagua'], 'Guacara', 'Carabobo');
CALL insert_parroquias(ARRAY['Moron', 'Urama'], 'Juan Jose Mora', 'Carabobo');
CALL insert_parroquias(ARRAY['Tocuyito Valencia', 'Independencia Campo Carabobo'], 'Libertador', 'Carabobo');
CALL insert_parroquias(ARRAY['Los Guayos Valencia'], 'Los Guayos', 'Carabobo');
CALL insert_parroquias(ARRAY['Miranda'], 'Miranda', 'Carabobo');
CALL insert_parroquias(ARRAY['Montalban'], 'Montalban', 'Carabobo');
CALL insert_parroquias(ARRAY['Urbana Naguanagua Valencia'], 'Naguanagua', 'Carabobo');
CALL insert_parroquias(ARRAY['Bartolome Salom', 'Democracia', 'Fraternidad', 'Goaigoaza', 'Juan Jose Flores', 'Union', 'Borburata', 'Patanemo'], 'Puerto Cabello', 'Carabobo');
CALL insert_parroquias(ARRAY['San Diego Valencia'], 'San Diego', 'Carabobo');
CALL insert_parroquias(ARRAY['San Joaquin'], 'San Joaquin', 'Carabobo');
CALL insert_parroquias(ARRAY['Urbana Candelaria', 'Urbana Catedral', 'Urbana El Socorro', 'Urbana Miguel Peña', 'Urbana Rafael Urdaneta', 'Urbana San Blas', 'Urbana San Jose', 'Urbana Santa Rosa', 'Rural Negro Primero'], 'Valencia', 'Carabobo');

-- Cojedes
CALL insert_municipios(ARRAY['Anzoategui','Pao de San Juan Bautista','Tinaquillo','Girardot','Lima Blanco','Ricaurte','Romulo Gallegos','Ezequiel Zamora','Tinaco'],'Cojedes');
CALL insert_parroquias(ARRAY['Cojedes', 'Juan de Mata Suarez'], 'Anzoategui', 'Cojedes');
CALL insert_parroquias(ARRAY['El Pao'], 'Pao de San Juan Bautista', 'Cojedes');
CALL insert_parroquias(ARRAY['Tinaquillo'], 'Tinaquillo', 'Cojedes');
CALL insert_parroquias(ARRAY['El Baul', 'Sucre'], 'Girardot', 'Cojedes');
CALL insert_parroquias(ARRAY['La Aguadita', 'Macapo'], 'Lima Blanco', 'Cojedes');
CALL insert_parroquias(ARRAY['El Amparo', 'Libertad de Cojedes'], 'Ricaurte', 'Cojedes');
CALL insert_parroquias(ARRAY['Romulo Gallegos (Las Vegas)'], 'Romulo Gallegos', 'Cojedes');
CALL insert_parroquias(ARRAY['San Carlos de Austria', 'Juan angel Bravo', 'Manuel Manrique'], 'Ezequiel Zamora', 'Cojedes');
CALL insert_parroquias(ARRAY['General en Jefe Jos Laurencio Silva'], 'Tinaco', 'Cojedes');

-- Delta Amacuro
CALL insert_municipios(ARRAY['Antonio Diaz','Casacoima','Pedernales','Tucupita'],'Delta Amacuro');
CALL insert_parroquias(ARRAY['Curiapo','Almirante Luis Brion','Francisco Aniceto Lugo','Manuel Renaud','Padre Barral','Santos de Abelgas'],'Antonio Diaz','Delta Amacuro');
CALL insert_parroquias(ARRAY['Imataca','Juan Bautista Arismendi','Manuel Piar','Romulo Gallegos'],'Casacoima','Delta Amacuro');
CALL insert_parroquias(ARRAY['Pedernales','Luis Beltran Prieto Figueroa'],'Pedernales','Delta Amacuro');
CALL insert_parroquias(ARRAY['San Jose','Jose Vidal Marcano','Leonardo Ruiz Pineda','Mariscal Antonio Jose de Sucre','Monseñor Argimiro Garcia','Virgen del Valle','San Rafael','Juan Millan'],'Tucupita','Delta Amacuro');

-- Distrito Federal
CALL insert_municipios(ARRAY['Libertador'],'Distrito Capital');
CALL insert_parroquias(ARRAY['23 de Enero','Altagracia','Antimano','Caricuao','Catedral','Coche','El Junquito','El Paraiso','El Recreo','El Valle','La Candelaria','La Pastora','La Vega','Macarao','San Agustin','San Bernardino','San Jose','San Juan','San Pedro','Santa Rosalia','Santa Teresa','Sucre'],'Libertador','Distrito Capital');

-- Falcon
CALL insert_municipios(ARRAY['Acosta','Bolivar','Buchivacoa','Cacique Manaure','Carirubana','Colina','Dabajuro','Democracia','Falcon','Federacion','Jacura','Los Taques','Mauroa','Miranda','Monseñor Iturriza','Palmasola','Petit','Piritu','San Francisco','Jose Laurencio Silva','Sucre','Tocopero','Union','Urumaco','Zamora'],'Falcon');
CALL insert_parroquias(ARRAY['Capadare', 'La Pastora', 'Libertador', 'San Juan de los Cayos'], 'Acosta', 'Falcon');
CALL insert_parroquias(ARRAY['Aracua', 'La Peña', 'San Luis'], 'Bolivar', 'Falcon');
CALL insert_parroquias(ARRAY['Bariro', 'Borojo', 'Capatarida', 'Guajiro', 'Seque', 'Valle de Eroa', 'Zazarida'], 'Buchivacoa', 'Falcon');
CALL insert_parroquias(ARRAY['Cacique Manaure (Yaracal)'], 'Cacique Manaure', 'Falcon');
CALL insert_parroquias(ARRAY['Norte', 'Carirubana', 'Santa Ana', 'Urbana Punta Cardon'], 'Carirubana', 'Falcon');
CALL insert_parroquias(ARRAY['La Vela de Coro', 'Acurigua', 'Guaibacoa', 'Las Calderas', 'Mataruca'], 'Colina', 'Falcon');
CALL insert_parroquias(ARRAY['Dabajuro'], 'Dabajuro', 'Falcon');
CALL insert_parroquias(ARRAY['Agua Clara', 'Avaria', 'Pedregal', 'Piedra Grande', 'Purureche'], 'Democracia', 'Falcon');
CALL insert_parroquias(ARRAY['Adaure', 'Adicora', 'Baraived', 'Buena Vista', 'Jadacaquiva', 'El Vinculo', 'El Hato', 'Moruy', 'Pueblo Nuevo'], 'Falcon', 'Falcon');
CALL insert_parroquias(ARRAY['Agua Larga', 'Churuguara', 'El Pauji', 'Independencia', 'Maparari'], 'Federacion', 'Falcon');
CALL insert_parroquias(ARRAY['Agua Linda', 'Araurima', 'Jacura'], 'Jacura', 'Falcon');
CALL insert_parroquias(ARRAY['Tucacas', 'Boca de Aroa'], 'Jose Laurencio Silva', 'Falcon');
CALL insert_parroquias(ARRAY['Los Taques', 'Judibana'], 'Los Taques', 'Falcon');
CALL insert_parroquias(ARRAY['Mene de Mauroa', 'San Felix', 'Casigua'], 'Mauroa', 'Falcon');
CALL insert_parroquias(ARRAY['Guzman Guillermo', 'Mitare', 'Rio Seco', 'Sabaneta', 'San Antonio', 'San Gabriel', 'Santa Ana'], 'Miranda', 'Falcon');
CALL insert_parroquias(ARRAY['Boca del Tocuyo', 'Chichiriviche', 'Tocuyo de la Costa'], 'Monseñor Iturriza', 'Falcon');
CALL insert_parroquias(ARRAY['Palmasola'], 'Palmasola', 'Falcon');
CALL insert_parroquias(ARRAY['Cabure', 'Colina', 'Curimagua'], 'Petit', 'Falcon');
CALL insert_parroquias(ARRAY['San Jose de la Costa', 'Piritu'], 'Piritu', 'Falcon');
CALL insert_parroquias(ARRAY['Capital San Francisco Mirimire'], 'San Francisco', 'Falcon');
CALL insert_parroquias(ARRAY['Sucre', 'Pecaya'], 'Sucre', 'Falcon');
CALL insert_parroquias(ARRAY['Tocopero'], 'Tocopero', 'Falcon');
CALL insert_parroquias(ARRAY['El Charal', 'Las Vegas del Tuy', 'Santa Cruz de Bucaral'], 'Union', 'Falcon');
CALL insert_parroquias(ARRAY['Bruzual', 'Urumaco'], 'Urumaco', 'Falcon');
CALL insert_parroquias(ARRAY['Puerto Cumarebo', 'La Cienaga', 'La Soledad', 'Pueblo Cumarebo', 'Zazarida'], 'Zamora', 'Falcon');

-- Guarico
CALL insert_municipios(ARRAY['Leonardo Infante','Julian Mellado','Francisco de Miranda','Monagas','Ribas','Roscio','Camaguan','San Jose de Guaribe','Las Mercedes','El Socorro','Ortiz','Santa Maria de Ipire','Chaguaramas','San Jeronimo de Guayabal', 'Juan Jose Rondon', 'Jose Felix Ribas', 'Jose Tadeo Monagas','Juan German Roscio','Pedro Zaraza'],'Guarico');
CALL insert_parroquias(ARRAY['Camaguan', 'Puerto Miranda', 'Uverito'], 'Camaguan', 'Guarico');
CALL insert_parroquias(ARRAY['Chaguaramas'], 'Chaguaramas', 'Guarico');
CALL insert_parroquias(ARRAY['El Socorro'], 'El Socorro', 'Guarico');
CALL insert_parroquias(ARRAY['El Calvario', 'El Rastro', 'Guardatinajas', 'Capital Urbana Calabozo'], 'Francisco de Miranda', 'Guarico');
CALL insert_parroquias(ARRAY['Tucupido', 'San Rafael de Laya'], 'Jose Felix Ribas', 'Guarico');
CALL insert_parroquias(ARRAY['Altagracia de Orituco', 'San Rafael de Orituco', 'San Francisco Javier de Lezama', 'Paso Real de Macaira', 'Carlos Soublette', 'San Francisco de Macaira', 'Libertad de Orituco'], 'Jose Tadeo Monagas', 'Guarico');
CALL insert_parroquias(ARRAY['Cantagallo', 'San Juan de los Morros', 'Parapara'], 'Juan German Roscio', 'Guarico');
CALL insert_parroquias(ARRAY['El Sombrero', 'Sosa'], 'Julian Mellado', 'Guarico');
CALL insert_parroquias(ARRAY['Las Mercedes', 'Cabruta', 'Santa Rita de Manapire'], 'Juan Jose Rondon', 'Guarico');
CALL insert_parroquias(ARRAY['Valle de la Pascua', 'Espino'], 'Leonardo Infante', 'Guarico');
CALL insert_parroquias(ARRAY['San Jose de Tiznados', 'San Francisco de Tiznados', 'San Lorenzo de Tiznados', 'Ortiz'], 'Ortiz', 'Guarico');
CALL insert_parroquias(ARRAY['San Jose de Unare', 'Zaraza'], 'Pedro Zaraza', 'Guarico');
CALL insert_parroquias(ARRAY['Guayabal', 'Cazorla'], 'San Jeronimo de Guayabal', 'Guarico');
CALL insert_parroquias(ARRAY['San Jose de Guaribe'], 'San Jose de Guaribe', 'Guarico');
CALL insert_parroquias(ARRAY['Santa Maria de Ipire', 'Altamira'], 'Santa Maria de Ipire', 'Guarico');

-- La Guaira
CALL insert_municipios(ARRAY['Vargas'], 'La Guaira');
CALL insert_parroquias(ARRAY['Caraballeda','Carayaca','Carlos Soublette','Caruao','Catia La Mar','El Junko','La Guaira','Macuto','Maiquetia','Naiguata','Urimare'],'Vargas','La Guaira');

-- Lara
CALL insert_municipios(ARRAY['Iribarren','Jimenez','Crespo','Andres Eloy Blanco','Urdaneta','Torres','Palavecino','Moran','Simon Planas'],'Lara');
CALL insert_parroquias(ARRAY['Quebrada Honda de Guache', 'Pio Tamayo', 'Yacambu'], 'Andres Eloy Blanco', 'Lara');
CALL insert_parroquias(ARRAY['Freitez', 'Jose Maria Blanco'], 'Crespo', 'Lara');
CALL insert_parroquias(ARRAY['Anzoategui', 'Bolivar', 'Guarico', 'Hilario Luna y Luna', 'Humocaro Bajo', 'Humocaro Alto', 'La Candelaria', 'Moran'], 'Moran', 'Lara');
CALL insert_parroquias(ARRAY['Cabudare', 'Jose Gregorio Bastidas', 'Agua Viva'], 'Palavecino', 'Lara');
CALL insert_parroquias(ARRAY['Buria', 'Gustavo Vega', 'Sarare'], 'Simon Planas', 'Lara');
CALL insert_parroquias(ARRAY['Altagracia', 'Antonio Diaz', 'Camacaro', 'Castañeda', 'Cecilio Zubillaga', 'Chiquinquira', 'El Blanco', 'Espinoza de los Monteros', 'Heriberto Arrollo', 'Lara', 'Las Mercedes', 'Manuel Morillo', 'Montaña Verde', 'Montes de Oca', 'Reyes de Vargas', 'Torres', 'Trinidad Samuel'], 'Torres', 'Lara');
CALL insert_parroquias(ARRAY['Xaguas', 'Siquisique', 'San Miguel', 'Moroturo'], 'Urdaneta', 'Lara');
CALL insert_parroquias(ARRAY['Aguedo Felipe Alvarado', 'Buena Vista', 'Catedral', 'Concepcion', 'El Cuji', 'Juares', 'Guerrera Ana Soto', 'Santa Rosa', 'Tamaca', 'Union'], 'Iribarren', 'Lara');
CALL insert_parroquias(ARRAY['Juan Bautista Rodriguez', 'Cuara', 'Diego de Lozada', 'Paraiso de San Jose', 'San Miguel', 'Tintorero', 'Jose Bernardo Dorante', 'Coronel Mariano Peraza'], 'Jimenez', 'Lara');

-- Merida
CALL insert_municipios(ARRAY['Antonio Pinto Salinas','Aricagua','Arzobispo Chacon','Campo Elias','Caracciolo Parra Olmedo','Cardenal Quintero','Chacanta','El Mucuy','Guaraque','Julio Cesar Salas','Justo Briceño','Libertador','Luis Cristobal Moncada','Rivas Davila','Rangel','Santos Marquina','Tovar','Tulio Febres Cordero','Alberto Adriani','Andres Bello','Miranda','Zea','Sucre','Pueblo Llano','Obispo Ramos de Lora','Padre Noguera'],'Merida');
CALL insert_parroquias(ARRAY['Presidente Betancourt','Presidente Paez','Presidente Romulo Gallegos','Gabriel Picon Gonzalez','Hector Amable Mora','Jose Nucete Sardi','Pulido Mendez'],'Alberto Adriani','Merida');
CALL insert_parroquias(ARRAY['Santa Cruz de Mora','Mesa Bolivar','Mesa de Las Palmas'],'Antonio Pinto Salinas','Merida');
CALL insert_parroquias(ARRAY['La Azulita'],'Andres Bello','Merida');
CALL insert_parroquias(ARRAY['Aricagua','San Antonio'],'Aricagua','Merida');
CALL insert_parroquias(ARRAY['Canagua','Capuri','Chacanta','El Molino','Guaimaral','Mucutuy','Mucuchachi'],'Arzobispo Chacon','Merida');
CALL insert_parroquias(ARRAY['Fernandez Peña','Matriz','Montalban','Acequias','Jaji','La Mesa','San Jose del Sur'],'Campo Elias','Merida');
CALL insert_parroquias(ARRAY['Tucani','Florencio Ramirez'],'Caracciolo Parra Olmedo','Merida');
CALL insert_parroquias(ARRAY['Santo Domingo','Las Piedras'],'Cardenal Quintero','Merida');
CALL insert_parroquias(ARRAY['Guaraque','Mesa Quintero','Rio Negro'],'Guaraque','Merida');
CALL insert_parroquias(ARRAY['Arapuey','Palmira'],'Julio Cesar Salas','Merida');
CALL insert_parroquias(ARRAY['San Cristobal de Torondoy','Torondoy'],'Justo Briceño','Merida');
CALL insert_parroquias(ARRAY['Antonio Spinetti Dini','Arias','Caracciolo Parra Perez','Domingo Peña', 'Gonzalo Picon Febres','Jacinto Plaza','Juan Rodriguez Suarez','Lasso de la Vega','Mariano Picon Salas','Milla','Osuna Rodriguez','Sagrario','El Morro','Los Nevados'],'Libertador','Merida');
CALL insert_parroquias(ARRAY['Andres Eloy Blanco','La Venta','Piñango','Timotes'],'Miranda','Merida');
CALL insert_parroquias(ARRAY['Eloy Paredes','San Rafael de Alcazar','Santa Elena de Arenales'],'Obispo Ramos de Lora','Merida');
CALL insert_parroquias(ARRAY['Santa Maria de Caparo'],'Padre Noguera','Merida');
CALL insert_parroquias(ARRAY['Pueblo Llano'],'Pueblo Llano','Merida');
CALL insert_parroquias(ARRAY['Cacute','La Toma','Mucuchies','Mucuruba','San Rafael'],'Rangel','Merida');
CALL insert_parroquias(ARRAY['Geronimo Maldonado','Bailadores'],'Rivas Davila','Merida');
CALL insert_parroquias(ARRAY['Tabay'],'Santos Marquina','Merida');
CALL insert_parroquias(ARRAY['Chiguara','Estanques','Lagunillas','La Trampa','Pueblo Nuevo del Sur','San Juan'],'Sucre','Merida');
CALL insert_parroquias(ARRAY['El Amparo','El Llano','San Francisco','Tovar'],'Tovar','Merida');
CALL insert_parroquias(ARRAY['Independencia','Maria de la Concepcion Palacios Blanco','Nueva Bolivia','Santa Apolonia'],'Tulio Febres Cordero','Merida');
CALL insert_parroquias(ARRAY['Caño El Tigre','Zea'],'Zea','Merida');

-- Miranda
CALL insert_municipios(ARRAY['Acevedo','Andres Bello','Baruta','Brion','Buroz','Carrizal','Chacao','Cristobal Rojas','El Hatillo','Guaicaipuro','Independencia','Lander','Los Salias','Paez','Paz Castillo','Pedro Gual','Plaza','Simon Bolivar','Sucre','Urdaneta','Zamora'],'Miranda');
CALL insert_parroquias(ARRAY['Aragüita','Arevalo Gonzalez','Capaya','Caucagua','Panaquire','Ribas','El Cafe','Marizapa','Yaguapa'],'Acevedo','Miranda');
CALL insert_parroquias(ARRAY['Cumbo','San Jose de Barlovento'],'Andres Bello','Miranda');
CALL insert_parroquias(ARRAY['El Cafetal','Las Minas','Nuestra Señora del Rosario'],'Baruta','Miranda');
CALL insert_parroquias(ARRAY['Higuerote','Curiepe','Tacarigua de Brion','Chirimena','Birongo'],'Brion','Miranda');
CALL insert_parroquias(ARRAY['Mamporal'],'Buroz','Miranda');
CALL insert_parroquias(ARRAY['Carrizal'],'Carrizal','Miranda');
CALL insert_parroquias(ARRAY['Chacao'],'Chacao','Miranda');
CALL insert_parroquias(ARRAY['Charallave','Las Brisas'],'Cristobal Rojas','Miranda');
CALL insert_parroquias(ARRAY['Santa Rosalia de Palermo de El Hatillo'],'El Hatillo','Miranda');
CALL insert_parroquias(ARRAY['Altagracia de la Montaña','Cecilio Acosta','Los Teques','El Jarillo','San Pedro','Tacata','Paracotos'],'Guaicaipuro','Miranda');
CALL insert_parroquias(ARRAY['el Cartanal','Santa Teresa del Tuy'],'Independencia','Miranda');
CALL insert_parroquias(ARRAY['La Democracia','Ocumare del Tuy','Santa Barbara','La Mata','La Cabrera'],'Lander','Miranda');
CALL insert_parroquias(ARRAY['San Antonio de los Altos'],'Los Salias','Miranda');
CALL insert_parroquias(ARRAY['Rio Chico','El Guapo','Tacarigua de la Laguna','Paparo','San Fernando del Guapo'],'Paez','Miranda');
CALL insert_parroquias(ARRAY['Santa Lucia del Tuy','Santa Rita','Siquire','Soapire'],'Paz Castillo','Miranda');
CALL insert_parroquias(ARRAY['Cupira','Machurucuto','Guarabe'],'Pedro Gual','Miranda');
CALL insert_parroquias(ARRAY['Guarenas'],'Plaza','Miranda');
CALL insert_parroquias(ARRAY['San Antonio de Yare','San Francisco de Yare'],'Simon Bolivar','Miranda');
CALL insert_parroquias(ARRAY['Cua','Nueva Cua'],'Urdaneta','Miranda');
CALL insert_parroquias(ARRAY['Leoncio Martinez','Caucagüita','Filas de Mariche','La Dolorita','Petare'],'Sucre','Miranda');
CALL insert_parroquias(ARRAY['Guatire','Araira'],'Zamora','Miranda');

-- Monagas
CALL insert_municipios(ARRAY['Acosta','Aguasay','Bolivar','Caripe','Cedeño','Ezequiel Zamora','Libertador','Maturin','Piar','Punceres','Santa Barbara','Sotillo','Uracoa'],'Monagas');
CALL insert_parroquias(ARRAY['San Antonio de Maturin','San Francisco de Maturin'],'Acosta','Monagas');
CALL insert_parroquias(ARRAY['Aguasay'],'Aguasay','Monagas');
CALL insert_parroquias(ARRAY['Caripito'],'Bolivar','Monagas');
CALL insert_parroquias(ARRAY['El Guacharo','La Guanota','Sabana de Piedra','San Agustin','Teresen','Caripe'],'Caripe','Monagas');
CALL insert_parroquias(ARRAY['Areo','Capital Cedeño','San Felix de Cantalicio','Viento Fresco'],'Cedeño','Monagas');
CALL insert_parroquias(ARRAY['El Tejero','Punta de Mata'],'Ezequiel Zamora','Monagas');
CALL insert_parroquias(ARRAY['Chaguaramas','Las Alhuacas','Tabasca','Temblador'],'Libertador','Monagas');
CALL insert_parroquias(ARRAY['Alto de los Godos','Boqueron','Las Cocuizas','La Cruz','San Simon','El Corozo','El Furrial','Jusepin','La Pica','San Vicente'],'Maturin','Monagas');
CALL insert_parroquias(ARRAY['Aparicio','Aragua de Maturin','Chaguaramal','El Pinto','Guanaguana','La Toscana','Taguaya'],'Piar','Monagas');
CALL insert_parroquias(ARRAY['Cachipo','Quiriquire'],'Punceres','Monagas');
CALL insert_parroquias(ARRAY['Santa Barbara','Moron'],'Santa Barbara','Monagas');
CALL insert_parroquias(ARRAY['Barrancas','Los Barrancos de Fajardo'],'Sotillo','Monagas');
CALL insert_parroquias(ARRAY['Uracoa'],'Uracoa','Monagas');

-- Nueva Esparta
CALL insert_municipios(ARRAY['Antolin del Campo','Arismendi','Diaz','Garcia','Gomez','Maneiro','Marcano','Mariño','Macanao','Tubores','Villalba'],'Nueva Esparta');
CALL insert_parroquias(ARRAY['Antolin del Campo'],'Antolin del Campo','Nueva Esparta');
CALL insert_parroquias(ARRAY['Arismendi'],'Arismendi','Nueva Esparta');
CALL insert_parroquias(ARRAY['San Juan Bautista','Zabala'],'Diaz','Nueva Esparta');
CALL insert_parroquias(ARRAY['Garcia','Francisco Fajardo'],'Garcia','Nueva Esparta');
CALL insert_parroquias(ARRAY['Bolivar','Guevara','Matasiete','Santa Ana','Sucre'],'Gomez','Nueva Esparta');
CALL insert_parroquias(ARRAY['Aguirre','Maneiro'],'Maneiro','Nueva Esparta');
CALL insert_parroquias(ARRAY['Adrian','Juan Griego'],'Marcano','Nueva Esparta');
CALL insert_parroquias(ARRAY['Mariño'],'Mariño','Nueva Esparta');
CALL insert_parroquias(ARRAY['San Francisco de Macanao','Boca de Rio'],'Macanao','Nueva Esparta');
CALL insert_parroquias(ARRAY['Tubores','Los Barales'],'Tubores','Nueva Esparta');
CALL insert_parroquias(ARRAY['Vicente Fuentes','Villalba'],'Villalba','Nueva Esparta');

-- Portuguesa
CALL insert_municipios(ARRAY['Araure','Esteller','Guanare','Guanarito','Ospino','Paez','Sucre','Turen','Monseñor Jose V. de Unda','Agua Blanca','Papelon','San Genaro de Boconoito','San Rafael de Onoto','Santa Rosalia'],'Portuguesa');
CALL insert_parroquias(ARRAY['Araure','Rio Acarigua'],'Araure','Portuguesa');
CALL insert_parroquias(ARRAY['Agua Blanca'],'Agua Blanca','Portuguesa');
CALL insert_parroquias(ARRAY['Piritu','Uveral'],'Esteller','Portuguesa');
CALL insert_parroquias(ARRAY['Cordova','Guanare','San Jose de la Montaña','San Juan de Guanaguanare','Virgen de Coromoto'],'Guanare','Portuguesa');
CALL insert_parroquias(ARRAY['Guanarito','Trinidad de la Capilla','Divina Pastora'],'Guanarito','Portuguesa');
CALL insert_parroquias(ARRAY['Chabasquen','Peña Blanca'],'Monseñor Jose V. de Unda','Portuguesa');
CALL insert_parroquias(ARRAY['Aparicion','La Estacion','Ospino'],'Ospino','Portuguesa');
CALL insert_parroquias(ARRAY['Acarigua','Payara','Pimpinela','Ramon Peraza'],'Paez','Portuguesa');
CALL insert_parroquias(ARRAY['Caño Delgadito','Papelon'],'Papelon','Portuguesa');
CALL insert_parroquias(ARRAY['Antolin Tovar Aquino','Boconoito'],'San Genaro de Boconoito','Portuguesa');
CALL insert_parroquias(ARRAY['Santa Fe','San Rafael de Onoto','Thelmo Morles'],'San Rafael de Onoto','Portuguesa');
CALL insert_parroquias(ARRAY['Florida','El Playon'],'Santa Rosalia','Portuguesa');
CALL insert_parroquias(ARRAY['Biscucuy','Concepcion','San Rafael de Palo Alzado.','San Jose de Saguaz','Uvencio Antonio Velasquez.','Villa Rosa.'],'Sucre','Portuguesa');
CALL insert_parroquias(ARRAY['Villa Bruzual','Canelones','Santa Cruz','San Isidro Labrador la colonia'],'Turen','Portuguesa');

-- Sucre
CALL insert_municipios(ARRAY['Andres Eloy Blanco','Andres Mata','Arismendi','Benitez','Bermudez','Bolivar','Cajigal','Cruz Salmeron Acosta','Libertador','Mariño','Mejia','Montes','Ribero','Sucre','Valdez'],'Sucre');
CALL insert_parroquias(ARRAY['Mariño','Romulo Gallegos'],'Andres Eloy Blanco','Sucre');
CALL insert_parroquias(ARRAY['San Jose de Areocuar','Tavera Acosta'],'Andres Mata','Sucre');
CALL insert_parroquias(ARRAY['Rio Caribe','Antonio Jose de Sucre','El Morro de Puerto Santo','Puerto Santo','San Juan de las Galdonas'],'Arismendi','Sucre');
CALL insert_parroquias(ARRAY['El Pilar','El Rincon','General Francisco Antonio Vazquez','Guaraunos','Tunapuicito','Union'],'Benitez','Sucre');
CALL insert_parroquias(ARRAY['Santa Catalina','Santa Rosa','Santa Teresa','Bolivar','Maracapana'],'Bermudez','Sucre');
CALL insert_parroquias(ARRAY['Marigüitar'],'Bolivar','Sucre');
CALL insert_parroquias(ARRAY['Libertad','El Paujil','Yaguaraparo'],'Cajigal','Sucre');
CALL insert_parroquias(ARRAY['Araya','Chacopata','Manicuare'],'Cruz Salmeron Acosta','Sucre');
CALL insert_parroquias(ARRAY['Tunapuy','Campo Elias'],'Libertador','Sucre');
CALL insert_parroquias(ARRAY['Irapa','Campo Claro','Marabal','San Antonio de Irapa','Soro'],'Mariño','Sucre');
CALL insert_parroquias(ARRAY['San Antonio del Golfo'],'Mejia','Sucre');
CALL insert_parroquias(ARRAY['Cumanacoa','Arenas','Aricagua','Cocollar','San Fernando','San Lorenzo'],'Montes','Sucre');
CALL insert_parroquias(ARRAY['Cariaco','Catuaro','Rendon','Santa Cruz','Santa Maria'],'Ribero','Sucre');
CALL insert_parroquias(ARRAY['Altagracia Cumana','Santa Ines Cumana','Valentin Valiente Cumana','Ayacucho Cumana','San Juan','Raul Leoni','Gran Mariscal'],'Sucre','Sucre');
CALL insert_parroquias(ARRAY['Cristobal Colon','Bideau','Punta de Piedras','Güiria'],'Valdez','Sucre');

-- Tachira
CALL insert_municipios(ARRAY['Andres Bello','Antonio Romulo Acosta','Ayacucho','Bolivar','Cardenas','Cordoba','Fernandez Feo','Francisco de Miranda','Garcia de Hevia','Guasimos','Independencia','Jauregui','Jose Maria Vargas','Junin','Libertad','Libertador','Lobatera','Michelena','Panamericano','Pedro Maria Ureña','Rafael Urdaneta','Samuel Dario Maldonado','San Cristobal','San Judas Tadeo','Seboruco','Simon Rodriguez','Tariba','Torbes','Uribante'],'Tachira');
CALL insert_parroquias(ARRAY['Cordero'],'Andres Bello','Tachira');
CALL insert_parroquias(ARRAY['Virgen del Carmen'],'Antonio Romulo Acosta','Tachira');
CALL insert_parroquias(ARRAY['Rivas Berti','San Juan de Colon','San Pedro del Rio'],'Ayacucho','Tachira');
CALL insert_parroquias(ARRAY['Isaias Medina Angarita','Juan Vicente Gomez','Palotal','San Antonio del Tachira'],'Bolivar','Tachira');
CALL insert_parroquias(ARRAY['Amenodoro Rangel Lamus','La Florida','Tariba'],'Cardenas','Tachira');
CALL insert_parroquias(ARRAY['Santa Ana del Tachira'],'Cordoba','Tachira');
CALL insert_parroquias(ARRAY['Alberto Adriani','San Rafael del Piñal','Santo Domingo'],'Fernandez Feo','Tachira');
CALL insert_parroquias(ARRAY['San Jose de Bolivar'],'Francisco de Miranda','Tachira');
CALL insert_parroquias(ARRAY['Boca de Grita','Jose Antonio Paez','La Fria'],'Garcia de Hevia','Tachira');
CALL insert_parroquias(ARRAY['Palmira'],'Guasimos','Tachira');
CALL insert_parroquias(ARRAY['Capacho Nuevo','Juan German Roscio','Roman Cardenas'],'Independencia','Tachira');
CALL insert_parroquias(ARRAY['Emilio Constantino Guerrero','La Grita','Monseñor Miguel Antonio Salas'],'Jauregui','Tachira');
CALL insert_parroquias(ARRAY['El Cobre'],'Jose Maria Vargas','Tachira');
CALL insert_parroquias(ARRAY['Bramon','La Petrolea','Quinimari','Rubio'],'Junin','Tachira');
CALL insert_parroquias(ARRAY['Capacho Viejo','Cipriano Castro','Manuel Felipe Rugeles'],'Libertad','Tachira');
CALL insert_parroquias(ARRAY['Abejales','Doradas','Emeterio Ochoa','San Joaquin de Navay'],'Libertador','Tachira');
CALL insert_parroquias(ARRAY['Lobatera','Constitucion'],'Lobatera','Tachira');
CALL insert_parroquias(ARRAY['Michelena'],'Michelena','Tachira');
CALL insert_parroquias(ARRAY['San Pablo','La Palmita'],'Panamericano','Tachira');
CALL insert_parroquias(ARRAY['Ureña','Nueva Arcadia'],'Pedro Maria Ureña','Tachira');
CALL insert_parroquias(ARRAY['Delicias'],'Rafael Urdaneta','Tachira');
CALL insert_parroquias(ARRAY['Bocono','Hernandez','La Tendida'],'Samuel Dario Maldonado','Tachira');
CALL insert_parroquias(ARRAY['Francisco Romero Lobo','La Concordia','Pedro Maria Morantes','San Juan Bautista','San Sebastian'],'San Cristobal','Tachira');
CALL insert_parroquias(ARRAY['San Judas Tadeo'],'San Judas Tadeo','Tachira');
CALL insert_parroquias(ARRAY['Seboruco'],'Seboruco','Tachira');
CALL insert_parroquias(ARRAY['San Simon'],'Simon Rodriguez','Tachira');
CALL insert_parroquias(ARRAY['Eleazar Lopez Contreras','Capital Sucre','San Pablo'],'Sucre','Tachira');
CALL insert_parroquias(ARRAY['San Josecito'],'Torbes','Tachira');
CALL insert_parroquias(ARRAY['Cardenas','Juan Pablo Peñaloza','Potosi','Pregonero'],'Uribante','Tachira');

-- Trujillo
CALL insert_municipios(ARRAY['Andres Bello','Bocono','Bolivar','Candelaria','Carache','Escuque','Jose Felipe Marquez Cañizales','Juan Vicente Campo Elias','La Ceiba','Miranda','Monte Carmelo','Motatan','Pampan','Pampanito','Rafael Rangel','San Rafael de Carvajal','Sucre','Trujillo','Urdaneta','Valera'],'Trujillo');
CALL insert_parroquias(ARRAY['Santa Isabel','Araguaney','El Jaguito','La Esperanza'],'Andres Bello','Trujillo');
CALL insert_parroquias(ARRAY['Bocono','Ayacucho','Burbusay','El Carmen','General Ribas','Guaramacal','Monseñor Jauregui','Mosquey','Rafael Rangel','San Jose','San Miguel','Vega de Guaramacal'],'Bocono','Trujillo');
CALL insert_parroquias(ARRAY['Sabana Grande','Cheregüe','Granados'],'Bolivar','Trujillo');
CALL insert_parroquias(ARRAY['Chejende','Arnoldo Gabaldon','Bolivia','Carrillo','Cegarra','Manuel Salvador Ulloa','San Jose'],'Candelaria','Trujillo');
CALL insert_parroquias(ARRAY['Carache','Cuicas','La Concepcion','Panamericana','Santa Cruz'],'Carache','Trujillo');
CALL insert_parroquias(ARRAY['Escuque','La Union','Sabana Libre','Santa Rita'],'Escuque','Trujillo');
CALL insert_parroquias(ARRAY['El Socorro','Antonio Jose de Sucre','Los Caprichos'],'Jose Felipe Marquez Cañizales','Trujillo');
CALL insert_parroquias(ARRAY['Campo Elias','Arnoldo Gabaldon'],'Juan Vicente Campo Elias','Trujillo');
CALL insert_parroquias(ARRAY['Santa Apolonia','El Progreso','La Ceiba','Tres de Febrero'],'La Ceiba','Trujillo');
CALL insert_parroquias(ARRAY['El Dividive','Agua Caliente','Agua Santa','El Cenizo','Valerita'],'Miranda','Trujillo');
CALL insert_parroquias(ARRAY['Monte Carmelo','Buena Vista','Santa Maria del Horcon'],'Monte Carmelo','Trujillo');
CALL insert_parroquias(ARRAY['Motatan','El Baño','Jalisco'],'Motatan','Trujillo');
CALL insert_parroquias(ARRAY['Pampan','Flor de Patria','La Paz','Santa Ana'],'Pampan','Trujillo');
CALL insert_parroquias(ARRAY['Pampanito','La Concepcion','Pampanito II'],'Pampanito','Trujillo');
CALL insert_parroquias(ARRAY['Betijoque','Jose Gregorio Hernandez','La Pueblita','Los Cedros'],'Rafael Rangel','Trujillo');
CALL insert_parroquias(ARRAY['Carvajal','Antonio Nicolas Briceño','Campo Alegre','Jose Leonardo Suarez'],'San Rafael de Carvajal','Trujillo');
CALL insert_parroquias(ARRAY['Sabana de Mendoza','El Paraiso','Junin','Valmore Rodriguez'],'Sucre','Trujillo');
CALL insert_parroquias(ARRAY['Matriz','Andres Linares','Chiquinquira','Cristobal Mendoza','Cruz Carrillo','Monseñor Carrillo','Tres Esquinas'],'Trujillo','Trujillo');
CALL insert_parroquias(ARRAY['La Quebrada','Cabimbu','Jajo','La Mesa','Santiago','Tuñame'],'Urdaneta','Trujillo');
CALL insert_parroquias(ARRAY['Mercedes Diaz','Juan Ignacio Montilla','La Beatriz','La Puerta','Mendoza del Valle de Momboy','San Luis'],'Valera','Trujillo');

-- Yaracuy
CALL insert_municipios(ARRAY['Aristides Bastidas','Bolivar','Bruzual','Cocorote','Independencia','Jose Antonio Paez','La Trinidad','Manuel Monge','Nirgua','Peña','San Felipe','Sucre','Urachiche','Veroes'],'Yaracuy');
CALL insert_parroquias(ARRAY['Aristides Bastidas'],'Aristides Bastidas','Yaracuy');
CALL insert_parroquias(ARRAY['Bolivar'],'Bolivar','Yaracuy');
CALL insert_parroquias(ARRAY['Chivacoa','Campo Elias'],'Bruzual','Yaracuy');
CALL insert_parroquias(ARRAY['Cocorote'],'Cocorote','Yaracuy');
CALL insert_parroquias(ARRAY['Independencia'],'Independencia','Yaracuy');
CALL insert_parroquias(ARRAY['Jose Antonio Paez'],'Jose Antonio Paez','Yaracuy');
CALL insert_parroquias(ARRAY['La Trinidad'],'La Trinidad','Yaracuy');
CALL insert_parroquias(ARRAY['Manuel Monge'],'Manuel Monge','Yaracuy');
CALL insert_parroquias(ARRAY['Salom','Temerla','Nirgua','Cogollos'],'Nirgua','Yaracuy');
CALL insert_parroquias(ARRAY['San Andres','Yaritagua'],'Peña','Yaracuy');
CALL insert_parroquias(ARRAY['San Javier','Albarico','San Felipe'],'San Felipe','Yaracuy');
CALL insert_parroquias(ARRAY['Sucre'],'Sucre','Yaracuy');
CALL insert_parroquias(ARRAY['Urachiche'],'Urachiche','Yaracuy');
CALL insert_parroquias(ARRAY['El Guayabo','Farriar'],'Veroes','Yaracuy');

-- Zulia
CALL insert_municipios(ARRAY['Almirante Padilla','Baralt','Cabimas','Catatumbo','Colon','Francisco Javier Pulgar','Guajira','Jesus Enrique Lossada','Jesus Maria Semprun','La Cañada de Urdaneta','Lagunillas','Machiques de Perija','Mara','Maracaibo','Miranda','Rosario de Perija','San Francisco','Santa Rita','Simon Bolivar','Sucre','Valmore Rodriguez'],'Zulia');
CALL insert_parroquias(ARRAY['Isla de Toas','Monagas'],'Almirante Padilla','Zulia');
CALL insert_parroquias(ARRAY['San Timoteo','General Urdaneta','Libertador','Marcelino Briceño','Pueblo Nuevo','Manuel Guanipa Matos'],'Baralt','Zulia');
CALL insert_parroquias(ARRAY['Ambrosio','Aristides Calvani','Carmen Herrera','German Rios Linares','Jorge Hernandez','La Rosa','Punta Gorda','Romulo Betancourt','San Benito'],'Cabimas','Zulia');
CALL insert_parroquias(ARRAY['Encontrados','Udon Perez'],'Catatumbo','Zulia');
CALL insert_parroquias(ARRAY['San Carlos del Zulia','Moralito','Santa Barbara','Santa Cruz del Zulia','Urribarri'],'Colon','Zulia');
CALL insert_parroquias(ARRAY['Simon Rodriguez','Agustin Codazzi','Carlos Quevedo','Francisco Javier Pulgar'],'Francisco Javier Pulgar','Zulia');
CALL insert_parroquias(ARRAY['Sinamaica','Alta Guajira','Elias Sanchez Rubio','Guajira'],'Guajira','Zulia');
CALL insert_parroquias(ARRAY['La Concepcion','San Jose','Mariano Parra Leon','Jose Ramon Yepez'],'Jesus Enrique Lossada','Zulia');
CALL insert_parroquias(ARRAY['Jesus Maria Semprun','Bari'],'Jesus Maria Semprun','Zulia');
CALL insert_parroquias(ARRAY['Concepcion','Andres Bello','Chiquinquira','El Carmelo','Potreritos'],'La Cañada de Urdaneta','Zulia');
CALL insert_parroquias(ARRAY['Alonso de Ojeda','Libertad','Eleazar Lopez Contreras','Campo Lara','Venezuela','El Danto'],'Lagunillas','Zulia');
CALL insert_parroquias(ARRAY['Libertad','Bartolome de las Casas','Rio Negro','San Jose de Perija'],'Machiques de Perija','Zulia');
CALL insert_parroquias(ARRAY['San Rafael','La Sierrita','Las Parcelas','Luis De Vicente','Monseñor Marcos Sergio Godoy','Ricaurte','Tamare'],'Mara','Zulia');
CALL insert_parroquias(ARRAY['Antonio Borjas Romero','Bolivar','Cacique Mara','Carracciolo Parra Perez','Cecilio Acosta','Chinquinquira','Coquivacoa','Cristo de Aranza','Francisco Eugenio Bustamante','Idelfonzo Vasquez','Juana de avila','Luis Hurtado Higuera','Manuel Dagnino','Olegario Villalobos','Raul Leoni','San Isidro','Santa Lucia','Venancio Pulgar'],'Maracaibo','Zulia');
CALL insert_parroquias(ARRAY['Altagracia','Ana Maria Campos','Faria','San Antonio','San Jose'],'Miranda','Zulia');
CALL insert_parroquias(ARRAY['El Rosario','Donaldo Garcia','Sixto Zambrano'],'Rosario de Perija','Zulia');
CALL insert_parroquias(ARRAY['San Francisco','El Bajo','Domitila Flores','Francisco Ochoa','Los Cortijos','Marcial Hernandez','Jose Domingo Rus'],'San Francisco','Zulia');
CALL insert_parroquias(ARRAY['Santa Rita','El Mene','Jose Cenobio Urribarri','Pedro Lucas Urribarri'],'Santa Rita','Zulia');
CALL insert_parroquias(ARRAY['Manuel Manrique','Rafael Maria Baralt','Rafael Urdaneta'],'Simon Bolivar','Zulia');
CALL insert_parroquias(ARRAY['Bobures','El Batey','Gibraltar','Heras','Monseñor Arturo alvarez','Romulo Gallegos'],'Sucre','Zulia');
CALL insert_parroquias(ARRAY['Rafael Urdaneta','La Victoria','Raul Cuenca'],'Valmore Rodriguez','Zulia');

-- [[ INSERT TIENDA,
-- DEPENDENT add_tienda, Lugar ]]--
CALL add_tienda ('ACAUCAB-La Pastora', '2018-01-15', 'Calle Real de La Pastora, Caracas 1010', 'La Pastora', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-Choroni', '2019-02-20', 'Avenida Principal de Choroni, Choroni 2109', 'Choroni', 'Aragua');

CALL add_tienda ('ACAUCAB-Santa Rosa', '2020-03-10', 'Calle Santa Rosa, Barquisimeto 3001', 'Santa Rosa', 'Lara');

CALL add_tienda ('ACAUCAB-El Valle', '2021-04-05', 'Avenida Intercomunal El Valle, Caracas 1090', 'El Valle', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-Catia La Mar', '2022-05-12', 'Avenida La Armada, Catia La Mar 1162', 'Catia La Mar', 'La Guaira');

CALL add_tienda ('ACAUCAB-San Juan', '2023-06-18', 'Calle San Juan, Caracas 1020', 'San Juan', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-Macuto', '2024-07-22', 'Avenida La Playa, Macuto 1164', 'Macuto', 'La Guaira');

CALL add_tienda ('ACAUCAB-Santa Barbara', '2025-08-30', 'Calle Bolivar, Santa Barbara de Barinas 5216', 'Santa Barbara', 'Barinas');

CALL add_tienda ('ACAUCAB-La Vega', '2026-09-14', 'Calle La Vega, Caracas 1021', 'La Vega', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-El Junko', '2027-10-03', 'Carretera El Junko, El Junko 1204', 'El Junko', 'La Guaira');

-- [[ INSERT DEPARTAMENTO
-- DEPENDENT tienda, add_departamento_1 ]]--
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

-- [[ INSERT EMPLEADO
-- DEPENDENT add_empleado ]]--
CALL add_empleado (31279920, 'Serita', 'Jewel', 'Herrick', 'Blevins', 73.02);

CALL add_empleado (48422996, 'Thora', 'Candra', 'Ferrer', 'Pina', 46.97);

CALL add_empleado (2428796, 'Barney', 'Merlin', 'Atchison', 'Hooker', 18.39);

CALL add_empleado (26806759, 'Stacey', 'Eura', 'Seeley', 'Thomsen', 85.59);

CALL add_empleado (4221028, 'Kati', 'Serafina', 'Valencia', 'Guillory', 53.06);

CALL add_empleado (1418738, 'Loni', 'Hershel', 'Stubblefield', 'Ahmad-Alley', 20.58);

CALL add_empleado (518945, 'Loree', 'Alpha', 'Sparks', 'Sell', 62.83);

CALL add_empleado (46565698, 'Vashti', 'Conchita', 'Sadler', 'Carpenter', 67.6);

CALL add_empleado (42233317, 'Bula', 'Norbert', 'Amaral', 'Wooley', 55.88);

CALL add_empleado (40959596, 'Jewel', 'Elene', 'Bray', 'Penn', 18.01);

-- [[ INSERT EMPL_CARG ]]--

CALL add_empl_carg_to_tien_1 (40959596, 'Empleado', '2024-10-10', NULL, 25000, 'Compras');

CALL add_empl_carg_to_tien_1 (48422996, 'Empleado', '2024-10-10', NULL, 25000, 'Ventas');

CALL add_empl_carg_to_tien_1 (2428796, 'Empleado', '2024-10-10', NULL, 25000, 'Despacho');

CALL add_empl_carg_to_tien_1 (26806759, 'Empleado', '2024-10-10', NULL, 25000, 'Entrega');

CALL add_empl_carg_to_tien_1 (4221028, 'Empleado', '2024-10-10', NULL, 25000, 'Marketing');

CALL add_empl_carg_to_tien_1 (1418738, 'Empleado', '2024-10-10', NULL, 25000, 'Recursos Humanos');

CALL add_empl_carg_to_tien_1 (518945, 'Empleado', '2024-10-10', NULL, 25000, 'Finanzas');

CALL add_empl_carg_to_tien_1 (46565698, 'Empleado', '2024-10-10', NULL, 25000, 'Seguridad');

CALL add_empl_carg_to_tien_1 (42233317, 'Empleado', '2024-10-10', NULL, 25000, 'Limpieza');

CALL add_empl_carg_to_tien_1 (40959596, 'Empleado', '2024-10-10', NULL, 25000, 'Mantenimiento');

--[[ INSERT EMPL_BENE, VACACION, ASISTENCIA, EMPL_HORA ]]--
CALL give_benefits ();

CALL create_vacaciones ();

CALL generate_asistencia_entries ();

CALL insert_empl_hora ();

--[[ INSERT CLIENTE ]]--
CALL add_cliente_natural_random ('J402357691', '22 Briar Crest Way', '823 Fair Oaks Parkway', 'Cam', 'Aharon', 'Biddlestone', 'Ellings', 50828613, 0412, 1234567, 'cam.aharone@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J314865203', '26961 Prairieview Lane', '82 Arrowood Crossing', 'Christiano', 'Janenna', 'Galego', 'Carayol', 73611427, 0414, 2345678, 'christiano.janenna@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J487265390', '9 Raven Avenue', '686 Bobwhite Point', 'Nancey', 'Rosabel', 'Hurt', 'Southerill', 97572920, 0416, 3456789, 'nancey.rosabel@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J325410879', '7569 Prairie Rose Point', '4784 Mandrake Circle', 'Brandon', 'Margareta', 'Girk', 'Latliff', 57086318, 0424, 4567890, 'brandon.margareta@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J419872635', '66 Lotheville Avenue', '5776 Birchwood Plaza', 'Pollyanna', 'Rowena', 'Shawyers', 'Osment', 48709114, 0426, 5678901, 'pollyanna.rowena@ejemplo.com', 'yahoo.com');

CALL add_cliente_natural_random ('J392645108', '337 Dakota Road', '85836 Johnson Alley', 'Ashlee', 'Alidia', 'Androli', 'Da Costa', 74670125, 0412, 6789012, 'ashlee.alidia@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J450328179', '64 Mayfield Trail', '71 Havey Trail', 'Dalila', 'Engracia', 'Vaissiere', 'Cudd', 33678051, 0414, 7890123, 'dalila.engracia@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J312478569', '26489 Lunder Center', '85655 Harbort Junction', 'Charissa', 'Nick', 'Sowman', 'Ransfield', 8410079, 0416, 8901234, 'charissa.nick@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J431209786', '0 Maple Point', '0608 Oneill Park', 'Cherie', 'Abey', 'Vlach', 'Korpolak', 12775958, 0424, 9012345, 'cherie.abey@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J324589106', '62 Schlimgen Junction', '0 Moland Hill', 'Ted', 'Axel', 'Brocklesby', 'Aggas', 6184964, 0426, 1122334, 'ted.axel@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J467381205', '16 Pearson Hill', '66755 Hoepker Terrace', 'Rupert', 'Pegeen', 'McSharry', 'Rodder', 2326653, 0412, 2233445, 'rupert.pegeen@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J405716892', '43369 Northridge Court', '8314 Lakeland Pass', 'Hanna', 'Fin', 'Blaxton', 'Pele', 2603386, 0414, 3344556, 'hanna.fin@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J318472569', '36696 Aberg Trail', '6 Calypso Circle', 'Kalie', 'Broderic', 'Gloyens', 'Delacour', 67259492, 0416, 4455667, 'kalie.broderic@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J429105738', '0271 Granby Road', '539 Colorado Avenue', 'Raven', 'Jaimie', 'Pettigree', 'Venning', 26022647, 0424, 5566778, 'raven.jaimie@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J375486219', '6114 Laurel Terrace', '2979 Coleman Way', 'Lynett', 'Marsh', 'Bednall', 'Govan', 72583336, 0426, 6677889, 'lynett.marsh@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J480327561', '15 Clove Alley', '0264 Cardinal Point', 'Aarika', 'Matias', 'Cubbit', 'Rivard', 19835736, 0412, 7788990, 'aarika.matias@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J329175086', '369 Rowland Crossing', '6825 Duke Point', 'Leontine', 'Meridith', 'Poag', 'Nelius', 29679721, 0414, 8899001, 'leontine.meridith@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J412638075', '4695 Eagle Crest Street', '4 Northfield Hill', 'Tedra', 'Ben', 'MacMillan', 'Pavyer', 91952089, 0416, 9900112, 'tedra.ben@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J354708962', '16930 Pearson Parkway', '76613 Merry Parkway', 'Cecelia', 'Theobald', 'Clemoes', 'Chasle', 4507000, 0424, 1011123, 'cecelia.theobald@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J498261375', '016 Debs Alley', '17767 Pearson Court', 'Roderic', 'Geri', 'Veal', 'Bradfield', 15685628, 0426, 1213141, 'roderic.geri@ejemplo.com', 'gmail.com');

-- Agregar Clientes Jurídicos
CALL add_cliente_juridico_random ('J402571893', '70 Oriole Point', '3 Bashford Drive', 'West, Hodkiewicz and Cronin', 'Hudson Inc', 40888.36, 'https://hudsoninc.com', 0412, 2345678, 'contacto@hudsoninc.com', 'hudsoninc.com');

CALL add_cliente_juridico_random ('J310958472', '8 Jenifer Point', '17642 Clove Pass', 'Emmerich-Botsford', 'Fritsch-Morissette', 22701.15, 'https://fritsch-morissette.com', 0414, 3456789, 'info@fritsch-morissette.com', 'fritsch-morissette.com');

CALL add_cliente_juridico_random ('J437025819', '5075 Spaight Point', '12 Glendale Court', 'Lind, Bashirian and Ratke', 'Reinger and Sons', 49454.82, 'https://reingerandsons.com', 0416, 4567890, 'contacto@reingerandsons.com', 'reingerandsons.com');

CALL add_cliente_juridico_random ('J324510987', '9 Bellgrove Drive', '4 Fieldstone Trail', 'Baumbach, Hackett and Murray', 'Heidenreich Group', 34814.19, 'https://heidenreichgroup.com', 0424, 5678901, 'info@heidenreichgroup.com', 'heidenreichgroup.com');

CALL add_cliente_juridico_random ('J479368251', '55968 Sloan Pass', '9724 Hovde Avenue', 'Wilkinson-Lang', 'Herzog-Schuppe', 10656.13, 'https://herzog-schuppe.com', 0426, 6789012, 'contacto@herzog-schuppe.com', 'herzog-schuppe.com');

CALL add_cliente_juridico_random ('J395720618', '823 Buhler Street', '579 Hollow Ridge Hill', 'Koepp and Sons', 'Reilly, Koss and Rogahn', 22512.14, 'https://reillykossandrogahn.com', 0412, 7890123, 'info@reillykossandrogahn.com', 'reillykossandrogahn.com');

CALL add_cliente_juridico_random ('J480216739', '0453 Bobwhite Plaza', '156 Surrey Terrace', 'Conroy-McLaughlin', 'Toy and Sons', 14469.88, 'https://toyandsons.com', 0414, 8901234, 'contacto@toyandsons.com', 'toyandsons.com');

CALL add_cliente_juridico_random ('J321759048', '257 Doe Crossing Park', '9 Arapahoe Hill', 'Anderson Group', 'Franecki, Kuhlman and Orn', 15964.06, 'https://franeckikuhlmanandorn.com', 0416, 9012345, 'info@franeckikuhlmanandorn.com', 'franeckikuhlmanandorn.com');

CALL add_cliente_juridico_random ('J412695038', '46 John Wall Drive', '9061 Longview Plaza', 'Braun-Koepp', 'Turcotte Group', 47698.22, 'https://turcottegroup.com', 0424, 1122334, 'contacto@turcottegroup.com', 'turcottegroup.com');

CALL add_cliente_juridico_random ('J375284609', '3429 Veith Crossing', '83704 La Follette Road', 'O''Hara LLC', 'Davis-Bogisich', 50133.53, 'https://davis-bogisich.com', 0426, 2233445, 'info@davis-bogisich.com', 'davis-bogisich.com');

CALL add_cliente_juridico_random ('J495083217', '44 Veith Street', '68419 Maywood Drive', 'Boehm, Jacobs and Wintheiser', 'Spinka, Cartwright and White', 31396.24, 'https://spinkacartwrightandwhite.com', 0412, 3344556, 'contacto@spinkacartwrightandwhite.com', 'spinkacartwrightandwhite.com');

CALL add_cliente_juridico_random ('J402867531', '8987 Gale Road', '0 Scofield Park', 'Goldner-Harvey', 'Aufderhar-Hahn', 53157.93, 'https://aufderhar-hahn.com', 0414, 4455667, 'info@aufderhar-hahn.com', 'aufderhar-hahn.com');

CALL add_cliente_juridico_random ('J319247685', '4695 Eastlawn Hill', '181 High Crossing Circle', 'Schiller Group', 'Grant, Hermann and Bergstrom', 15622.08, 'https://granthermannandbergstrom.com', 0416, 5566778, 'contacto@granthermannandbergstrom.com', 'granthermannandbergstrom.com');

CALL add_cliente_juridico_random ('J438501296', '134 Arizona Terrace', '5 Waubesa Point', 'Armstrong, Johnson and Aufderhar', 'Schumm, Kemmer and Boehm', 43092.48, 'https://schummkemmerandboehm.com', 0424, 6677889, 'info@schummkemmerandboehm.com', 'schummkemmerandboehm.com');

CALL add_cliente_juridico_random ('J325861074', '121 Pennsylvania Way', '03002 High Crossing Circle', 'Dickinson, Harvey and Reynolds', 'Casper-Reichert', 56565.97, 'https://casper-reichert.com', 0426, 7788990, 'contacto@casper-reichert.com', 'casper-reichert.com');

CALL add_cliente_juridico_random ('J479302518', '9 Mccormick Plaza', '058 Carey Pass', 'Wolff, Bailey and Hermann', 'Balistreri Group', 36211.36, 'https://balistrerigroup.com', 0412, 8899001, 'info@balistrerigroup.com', 'balistrerigroup.com');

CALL add_cliente_juridico_random ('J398571462', '1118 Butterfield Drive', '3106 Fisk Crossing', 'O''Reilly-Hartmann', 'Lynch Inc', 20195.17, 'https://lynchinc.com', 0414, 9900112, 'contacto@lynchinc.com', 'lynchinc.com');

CALL add_cliente_juridico_random ('J412786053', '777 Sloan Street', '911 Briar Crest Parkway', 'Doyle Group', 'Shanahan, Stanton and Lemke', 55376.91, 'https://shanahanstantonandlemke.com', 0416, 1011123, 'info@shanahanstantonandlemke.com', 'shanahanstantonandlemke.com');

CALL add_cliente_juridico_random ('J350917246', '352 Pierstorff Alley', '6 Kinsman Terrace', 'Schmidt Inc', 'Wunsch LLC', 23240.90, 'https://wunschllc.com', 0424, 1213141, 'contacto@wunschllc.com', 'wunschllc.com');

CALL add_cliente_juridico_random ('J487520139', '95 Mccormick Junction', '599 Welch Park', 'Stanton Group', 'Graham, Corkery and Greenfelder', 58473.49, 'https://grahamcorkeryandgreenfelder.com', 0426, 1314151, 'info@grahamcorkeryandgreenfelder.com', 'grahamcorkeryandgreenfelder.com');

--[[ INSERT MIEMBRO ]]--
-- NOTE: Esta es importante porque aqui es donde insertaremos la mayoria de cervezas
CALL add_miembro ('J000413126', 'Compañía Anónima Cervecería Polar', 'Polar', 'Avenida José Antonio Páez, Edificio Polar, El Paraíso, Caracas, Venezuela', 'https://empresaspolar.com', get_parroquia_from_estado('El Recreo', 'Distrito Capital'), get_parroquia_from_estado('El Recreo', 'Distrito Capital'));

CALL add_miembro_random ('J482367195', 'Blacks International ', 'Interior Mutual S.A', '6287 Holmcroft, Simi Valley, Rhode Island, 54650', 'https://crowd.nationwide/ver.php');

CALL add_miembro_random ('J314982657', 'Gulf Corp', 'Stewart ', '8208 Melland Avenue, Fort Worth, Indiana, 05019', 'https://www.innocent.com/vienna.html');

CALL add_miembro_random ('J471086329', 'Closes International Company', 'Invest Stores Corp', '2639 Mill, Richmond County, New York, 45183', 'http://simpson.com/positive');

CALL add_miembro_random ('J329475018', 'Recording Corporation', 'Transferred ', '2612 Maynestone Road, Leominster, Louisiana, 82578', 'https://bargain.com/involve.php');

CALL add_miembro_random ('J405318762', 'Animation Stores SIA', 'Liver B.V', '1885 Sherbrooke Street, Spokane, Ohio, 23210', 'https://www.despite.com/japanese.aspx');

CALL add_miembro_random ('J387521094', 'Brooks ', 'Largely Holdings Company', '9875 Light Circle, Brighton, Montana, 87266', 'https://www.historical.com/mumbai.aspx');

CALL add_miembro_random ('J412693075', 'Professional Company', 'Equilibrium International SIA', '7220 Tedder, Miramar, Indiana, 73039', 'https://xerox.com/portuguese.aspx#genuine');

CALL add_miembro_random ('J324860917', 'Clear Energy Corporation', 'Sara LLC', '6027 Radclyffe Circle, Kenosha, Iowa, 91275', 'https://lexington.com/peter.php#ones');

CALL add_miembro_random ('J479652130', 'Commander Industries A.G', 'Shaft Stores Corporation', '0635 Pelham Circle, Henderson, Delaware, 25851', 'https://www.employees.com/angry.php');

CALL add_miembro_random ('J358172469', 'Pete Mutual GmbH', 'Pearl International Corporation', '3457 Cardus Avenue, Sacramento, Nebraska, 54606', 'https://www.money.com/antonio');

CALL add_miembro_random ('J490327516', 'Tail Stores SIA', 'International Software Inc', '6904 Talkin Circle, Overland Park, Alaska, 44352', 'http://www.occupational.com/vernon');

CALL add_miembro_random ('J312489075', 'Agreements SIA', 'Repository Holdings ', '9571 Caldecott, Detroit, Kansas, 48806', 'http://nebraska.com/responded.aspx');

CALL add_miembro_random ('J437051298', 'Fog Industries GmbH', 'Designing Mutual S.A', '9500 Coke, Pittsburgh, Tennessee, 46878', 'https://globe.com/atlanta.aspx');

CALL add_miembro_random ('J329748105', 'Sold Industries S.A', 'Associates Industries ', '3553 Stonepail Road, Tempe, Alabama, 53812', 'https://automobile.com/circus.html');

CALL add_miembro_random ('J468230975', 'Itunes International ', 'Earlier LLC', '5637 Beech Street, Newburgh, Georgia, 52735', 'http://www.isolation.manchester.museum/revelation');

CALL add_miembro_random ('J402871639', 'Syndication Mutual S.A', 'Solar Holdings Corp', '0717 Wincombe Avenue, Ogden, Nebraska, 31435', 'https://www.myrtle.freebox-os.com/suspect.php');

CALL add_miembro_random ('J310975842', 'Gpl Stores LLC', 'Caution Holdings GmbH', '1009 Thirlwater Road, Anaheim, Rhode Island, 34589', 'https://instant.com/currencies.aspx');

CALL add_miembro_random ('J438201756', 'Kernel Energy ', 'Peru B.V', '5593 Hollinhurst Lane, Tulsa, Rhode Island, 72951', 'http://conducting.com/mess.php');

CALL add_miembro_random ('J325497068', 'Upc Industries SIA', 'Ending International S.A', '9767 Raydon Avenue, Provo, Florida, 56944', 'https://www.navigator.bømlo.no/lucy');

CALL add_miembro_random ('J471039258', 'Coordinate Industries Company', 'Emotions International ', '9059 Reddisher Circle, Grand Prairie, Maine, 73188', 'http://condos.com/rock.aspx');

--[[ INSERT CONTACTO ]]--
CALL insert_contacto_random ('Salmon', 'Ruby', 'Flowerden', 'Aizkovitch');

CALL insert_contacto_random ('Elvina', 'Harlen', 'Crack', 'Hurlestone');

CALL insert_contacto_random ('Hinze', 'Minetta', 'Antonelli', 'Winfrey');

CALL insert_contacto_random ('Sibbie', 'Ettore', 'Cogan', 'Philson');

CALL insert_contacto_random ('Gene', 'Alexandra', 'Snedden', 'Blankman');

CALL insert_contacto_random ('Annmaria', 'Berti', 'Greggs', 'Fawdrie');

CALL insert_contacto_random ('Gertrude', 'Nan', 'Loutheane', 'Drezzer');

CALL insert_contacto_random ('Casey', 'Aldus', 'Semerad', 'Kench');

CALL insert_contacto_random ('Alina', 'Ezra', 'Canham', 'Cole');

CALL insert_contacto_random ('Oralie', 'Jaimie', 'Longstreeth', 'Eldered');

--[[ INSERT INTO PRIVILEGIO, PRIV_ROL ]]--
CALL privileges ();

CALL admin_privileges ();

--[[ INSERT TIPO_CERVEZA ]]--
CALL insert_tipo_cerveza ('Lager', NULL);

CALL insert_tipo_cerveza ('Ale', NULL);

CALL insert_tipo_cerveza ('De Trigo', 'Ale');

CALL insert_tipo_cerveza ('Bock', 'Lager');

CALL insert_tipo_cerveza ('Eisbock', 'Bock');

CALL insert_tipo_cerveza ('Pale Ale', 'Ale');

CALL insert_tipo_cerveza ('Indian Pale Ale', 'Pale Ale');

CALL insert_tipo_cerveza ('English Bitter', 'Pale Ale');

CALL insert_tipo_cerveza ('Dark Ale', 'Ale');

CALL insert_tipo_cerveza ('Stout', 'Dark Ale');

CALL insert_tipo_cerveza ('Guiness Irlandesa', 'Stout');

CALL insert_tipo_cerveza ('Porter', 'Dark Ale');

CALL insert_tipo_cerveza ('Belga', 'Ale');

CALL insert_tipo_cerveza ('Abadia', 'Belga');

CALL insert_tipo_cerveza ('Trapense', 'Belga');

CALL insert_tipo_cerveza ('Ambar', 'Belga');

CALL insert_tipo_cerveza ('Flamenca', 'Belga');

CALL insert_tipo_cerveza ('Pilsener', 'Ale');

CALL insert_tipo_cerveza ('American Amber Ale', 'Ale');

CALL insert_tipo_cerveza ('American Pale Ale', 'American Amber Ale');

CALL insert_tipo_cerveza ('American IPA', 'Indian Pale Ale');

CALL insert_tipo_cerveza ('Belgian Dubbel', 'Belga');

CALL insert_tipo_cerveza ('Belgian Golden Strong Ale', 'Belga');

CALL insert_tipo_cerveza ('Belgian Specialty Ale', 'Belga');

CALL insert_tipo_cerveza ('Orval', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Chouffe', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Blond Trappist', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Table Beer', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Artisanal Blond', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Artisanal Amber', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Artisanal Brown', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Belgian Barleywine', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Trappist Quadrupel', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Belgian Spiced Christmass Beer', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Belgian IPA', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Strong Dark Saison', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Flanders Red', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Flanders Brown', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Blonde Ale', 'Ale');

CALL insert_tipo_cerveza ('Bohemian Pilsener', 'Pilsener');

CALL insert_tipo_cerveza ('Dry Stout', 'Stout');

CALL insert_tipo_cerveza ('Düsseldorf Altbier', 'Stout');

CALL insert_tipo_cerveza ('English Pale Ale', 'Pale Ale');

CALL insert_tipo_cerveza ('Extra-Strong Bitter', 'Pale Ale');

CALL insert_tipo_cerveza ('Fruit Lambic', 'Ale');

CALL insert_tipo_cerveza ('Imperial IPA', 'Indian Pale Ale');

CALL insert_tipo_cerveza ('Imperial Stout', 'Stout');

CALL insert_tipo_cerveza ('Munich Helles', 'Lager');

CALL insert_tipo_cerveza ('Oktoberfest-Marzen', 'Lager');

CALL insert_tipo_cerveza ('Red Ale', 'Ale');

CALL insert_tipo_cerveza ('Irish Red Ale', 'Red Ale');

CALL insert_tipo_cerveza ('Schwarzbier', 'Lager');

CALL insert_tipo_cerveza ('Sweet Stout', 'Stout');

CALL insert_tipo_cerveza ('Weizen-Weissbier', 'De Trigo');

CALL insert_tipo_cerveza ('Witbier', 'De Trigo');

CALL insert_tipo_cerveza ('Milk Stout', 'Stout');

CALL insert_tipo_cerveza ('Coffee Stout', 'Stout');

CALL insert_tipo_cerveza ('Chocolate Stout', 'Stout');

CALL insert_tipo_cerveza ('Red IPA', 'Indian Pale Ale');

--[[ INSERT INGREDIENTE, INDEPENDENT ]]--
INSERT INTO Ingrediente (nombre_ingr)
    VALUES ('Levadura'),
    ('Levadura Saccharomyces Carlsbergenesis'),
    ('Levadura Saccharomyces Uvarum'),
    ('Levadura Saccharomyces Cerevisiae'),
    ('Levadura Lager'),
    ('Levadura Ale'),
    ('Levadura Belga'),
    ('Ester'),
    ('Fenol'),
    ('Lupulo'),
    ('Lupulo Americano'),
    ('Lupulo Columbus'),
    ('Lupulo Cascade'),
    ('Styrian Goldings'),
    ('Malta'),
    ('Malta Ambar'),
    ('Malta de Trigo'),
    ('Malta Clara'),
    ('Malta Tostada'),
    ('Malta Caramelizada'),
    ('Malta Cristal'),
    ('Malta Pale Ale'),
    ('Malta Best Malz Pale Ale'),
    ('Malta Best Malz Aromatic'),
    ('Malta Best Malz Caramel Light'),
    ('Malta Pils Belga'),
    ('Sugar Candy'),
    ('Miel'),
    ('Chocolate'),
    ('Leche'),
    ('Cafe'),
    ('Diacetilo'),
    ('Agua'),
    ('CaraVienna'),
    ('CaraMunich');

--[[ INSERT CARACTERISTICA, INDEPENDENT ]]--
INSERT INTO Caracteristica (nombre_cara)
    VALUES ('Color'),
    ('Graduacion'),
    ('Temperatura de Fermentado'),
    ('Tiempo de Fermentado'),
    ('Turbidez'),
    ('Color de Espuma'),
    ('Retencion de Espuma'),
    ('Sabor'),
    ('Regusto'),
    ('Textura'),
    ('Cuerpo'),
    ('Carbonatacion'),
    ('Acabado'),
    ('Densidad Inicial'),
    ('Densidad Final'),
    ('IBUs'),
    ('Amargor (IBUs)'),
    ('Aroma');

--[[ INSERT TIPO_CARA, RECE_INGR ]]--
-- Lager
CALL relate_ingr ('Lager', 'Malta Clara', 'Alto Porcentaje');

CALL relate_ingr ('Lager', 'Malta Tostada', 'Poco o Nada');

CALL relate_ingr ('Lager', 'Malta Caramelizada', 'Poco o Nada');

CALL relate_ingr ('Lager', 'Malta de Trigo', 'Poco o Nada');

CALL relate_ingr ('Lager', 'Levadura Lager', 'Sin Especificar');

CALL relate_ingr ('Lager', 'Lupulo', 'Poco');

CALL relate_cara ('Lager', 'Temperatura de Fermentado', 'Menor a 10 Grados Celcius');

CALL relate_cara ('Lager', 'Tiempo de Fermentado', '1 a 3 Meses');

CALL relate_cara ('Lager', 'Color', 'Claro');

CALL relate_cara ('Lager', 'Graduacion', '3.5% ~ 5%');

-- Ale
CALL relate_ingr ('Ale', 'Malta', 'Sin Especificar');

CALL relate_ingr ('Ale', 'Levadura Ale', 'Sin Especificar');

CALL relate_ingr ('Ale', 'Lupulo', 'Bastante');

CALL relate_cara ('Ale', 'Temperatura de Fermentado', '~19 Grados Celcius');

CALL relate_cara ('Ale', 'Tiempo de Fermentado', '5 a 7 Dias');

CALL relate_cara ('Ale', 'Graduacion', 'Elevado');

-- De Trigo
CALL relate_ingr ('De Trigo', 'Levadura Ale', 'Sin Especificar');

CALL relate_ingr ('De Trigo', 'Malta de Trigo', 'Muy Algo Porcentaje');

CALL relate_cara ('De Trigo', 'Color', 'Claro');

CALL relate_cara ('De Trigo', 'Graduacion', 'Baja');

-- Bock
CALL relate_ingr ('Bock', 'Lupulo', 'Poco');

CALL relate_ingr ('Bock', 'Levadura Lager', 'Sin Especificar');

CALL relate_ingr ('Bock', 'Malta Tostada', 'Alta Cantidad');

CALL relate_cara ('Bock', 'Color', 'Muy Oscuro');

CALL relate_cara ('Bock', 'Color de Espuma', 'Blanco');

CALL relate_cara ('Bock', 'Graduacion', '7%');

-- NOTE: Potencialmente agregar para poner multiples de la misma caracteristica, como sabor
CALL relate_cara ('Bock', 'Sabor', 'A malta, Algo de Dulzor');

-- Pale Ale
CALL relate_ingr ('Pale Ale', 'Malta Tostada', 'Bajo Porcentaje');

CALL relate_ingr ('Pale Ale', 'Lupulo', 'Mucho');

CALL relate_cara ('Pale Ale', 'Color', 'Claro');

CALL relate_cara ('Pale Ale', 'Sabor', 'Mucho');

CALL relate_cara ('Pale Ale', 'Amargor (IBUs)', 'Bastante');

-- Indian Pale Ale
CALL relate_ingr ('Indian Pale Ale', 'Lupulo', 'Mucho');

CALL relate_cara ('Indian Pale Ale', 'Graduacion', 'Alta');

-- Dark Ale
CALL relate_cara ('Dark Ale', 'Color', 'Muy Oscuro');

-- Stout
CALL relate_ingr ('Stout', 'Malta Tostada', 'Grande Porcentaje');

CALL relate_ingr ('Stout', 'Malta Caramelizada', 'Grande Porcentaje');

CALL relate_cara ('Stout', 'Color', 'Muy Oscuro');

-- NOTE: Lo mismo que la nota de arriba
CALL relate_cara ('Stout', 'Textura', 'Espesa y Cremosa');

CALL relate_cara ('Stout', 'Aroma', 'A malta');

CALL relate_cara ('Stout', 'Regusto', 'Dulce');

-- Imperial Stout
CALL relate_cara ('Stout', 'Graduacion', 'Muy Alta');

-- Chocolate, Coffee, Milk Stout (Se nos dice que las 3 tienen leche)
CALL relate_ingr ('Chocolate Stout', 'Chocolate', 'Sin Especificar');

CALL relate_ingr ('Chocolate Stout', 'Leche', 'Sin Especificar');

CALL relate_cara ('Chocolate Stout', 'Sabor', 'Dulce');

CALL relate_ingr ('Coffee Stout', 'Cafe', 'Sin Especificar');

CALL relate_ingr ('Coffee Stout', 'Leche', 'Sin Especificar');

CALL relate_cara ('Coffee Stout', 'Sabor', 'Dulce');

CALL relate_ingr ('Milk Stout', 'Leche', 'Sin Especificar');

CALL relate_cara ('Milk Stout', 'Sabor', 'Dulce');

-- Porter
CALL relate_ingr ('Porter', 'Lupulo', 'Buena Cantidad');

CALL relate_cara ('Porter', 'Color', 'Medio-Oscuro');

-- Belgas
CALL relate_ingr ('Belga', 'Lupulo', 'Buena Cantidad');

CALL relate_ingr ('Belga', 'Malta Ambar', 'Sin Especificar');

CALL relate_ingr ('Belga', 'Malta Cristal', 'Sin Especificar');

CALL relate_cara ('Belga', 'Color', 'Palidas ~ Oscuras, Tonos Rojizos o Rubias');

CALL relate_cara ('Belga', 'Sabor', 'Intenso, Fondo Dulce');

-- Abadía, la Trapense, la Ámbar o la Flamenca
CALL relate_cara ('Abadia', 'Graduacion', '6% ~ 7%');

CALL relate_cara ('Trapense', 'Graduacion', '6% ~ 7%');

CALL relate_cara ('Ambar', 'Graduacion', '6% ~ 7%');

CALL relate_cara ('Flamenca', 'Graduacion', '6% ~ 7%');

-- Pilsener
CALL relate_cara ('Pilsener', 'Sabor', 'Ligero pero Intenso');

CALL relate_cara ('Pilsener', 'Graduacion', 'Medio');

-- American Amber Ale
CALL relate_ingr ('American Amber Ale', 'Malta Best Malz Pale Ale', '5kg');

CALL relate_ingr ('American Amber Ale', 'Malta Best Malz Aromatic', '0.5kg');

CALL relate_ingr ('American Amber Ale', 'Malta Best Malz Caramel Light', '0.4kg');

CALL relate_ingr ('American Amber Ale', 'Lupulo Columbus', '17gr');

CALL relate_ingr ('American Amber Ale', 'Lupulo Cascade', '37gr');

-- NOTE: Deberiamos de verdad agregarle una unique ID a TIPO_CARA para poder agregar
-- muchos valores a la caracteristica
CALL relate_cara ('American Amber Ale', 'Aroma', 'Cítrico, Floral, Resinoso, Herbal...');

CALL relate_cara ('American Amber Ale', 'Sabor', 'Dulzura Inicial, seguida de Caramelo');

CALL relate_cara ('American Amber Ale', 'Color', 'Entre Ambar y Marron Cobrizo (10 - 17)');

CALL relate_cara ('American Amber Ale', 'Color de Espuma', 'Blanca');

CALL relate_cara ('American Amber Ale', 'Retencion de Espuma', 'Buena');

CALL relate_cara ('American Amber Ale', 'Amargor (IBUs)', '25 - 40');

CALL relate_cara ('American Amber Ale', 'Cuerpo', 'Medio ~ Alto');

CALL relate_cara ('American Amber Ale', 'Carbonatacion', 'Media ~ Alta');

CALL relate_cara ('American Amber Ale', 'Acabado', 'Suave, Sin Astringencia');

CALL relate_cara ('American Amber Ale', 'Densidad Inicial', '1.045 – 1.060');

CALL relate_cara ('American Amber Ale', 'Densidad Final', '1.010 – 1.015');

CALL relate_cara ('American Amber Ale', 'Graduacion', '4.5% ~ 6.2%');

-- American IPA
CALL relate_cara ('American IPA', 'Aroma', 'A Lupulo, Floral, hasta Citrico o resinoso');

CALL relate_cara ('American IPA', 'Sabor', 'A Lupulo, Floral, hasta Citrico o resinoso');

-- NOTE: SAbor a malta medio bajo y puede tener maltosidad dulce
CALL relate_cara ('American IPA', 'Amargor (IBUs)', '40 ~ 60');

CALL relate_cara ('American IPA', 'Graduacion', '5 ~ 7.5 grados');

-- American Pale Ale
-- NOTE: Aqui tambien
CALL relate_ingr ('American Pale Ale', 'Ester', 'De Nulo a Moderado');

CALL relate_cara ('American Pale Ale', 'Aroma', 'A Lupulo, Moderado o Fuerte, Citrico, A Malta, bajo o moderado');

CALL relate_cara ('American Pale Ale', 'Color', 'De Palido a Ambar');

CALL relate_cara ('American Pale Ale', 'Color de Espuma', 'De Blanca a Blancuza');

CALL relate_cara ('American Pale Ale', 'Retencion de Espuma', 'Buena');

CALL relate_cara ('American Pale Ale', 'Sabor', 'A Lupulo Moderado, A Malta Moderado, A Caramelo: Ausente');

CALL relate_cara ('American Pale Ale', 'Amargor (IBUs)', 'De Moderado a Alto');

CALL relate_cara ('American Pale Ale', 'Acabado', 'Moderadamente Seco, Suave, Sin Astringencias');

CALL relate_cara ('American Pale Ale', 'Cuerpo', 'Medio-Liviano');

CALL relate_cara ('American Pale Ale', 'Carbonatacion', 'Moderada a Alta');

-- Belgian Dubbel
CALL relate_ingr ('Belgian Dubbel', 'Styrian Goldings', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Levadura Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Agua', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Malta Pils Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Malta Pale Ale', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'CaraVienna', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'CaraMunich', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Ester', 'Moderados');

CALL relate_ingr ('Belgian Dubbel', 'Fenol', 'Sin Especificar');

CALL relate_cara ('Belgian Dubbel', 'Aroma', 'Dulzor, Notas de Chocolate, Caramelo, Tostado');

CALL relate_cara ('Belgian Dubbel', 'Color', 'Ambar Oscuro a Cobre');

CALL relate_cara ('Belgian Dubbel', 'Color de Espuma', 'Blancuzca');

CALL relate_cara ('Belgian Dubbel', 'Retencion de Espuma', 'Cremosa, Persiste');

CALL relate_cara ('Belgian Dubbel', 'Sabor', 'Dulzor de Malta, A Pasas, Frutas Secas');

CALL relate_cara ('Belgian Dubbel', 'Amargor (IBUs)', 'Medio-Bajo');

CALL relate_cara ('Belgian Dubbel', 'Acabado', 'Moderadamente Seco');

CALL relate_cara ('Belgian Dubbel', 'Cuerpo', 'Medio-Pleno');

CALL relate_cara ('Belgian Dubbel', 'Carbonatacion', 'Media-Alta');

CALL relate_cara ('Belgian Dubbel', 'Graduacion', '6.5% ~ 7%');

-- Belgian Golden Strong Ale
CALL relate_ingr ('Belgian Golden Strong Ale', 'Levadura Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Golden Strong Ale', 'Styrian Goldings', 'Sin Especificar');

CALL relate_ingr ('Belgian Golden Strong Ale', 'Malta Pils Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Golden Strong Ale', 'Agua', 'Sin Especificar');

CALL relate_cara ('Belgian Golden Strong Ale', 'Color', 'Amarillo a dorado medio');

CALL relate_cara ('Belgian Golden Strong Ale', 'Turbidez', 'Buena claridad');

CALL relate_cara ('Belgian Golden Strong Ale', 'Color de Espuma', 'Blanca');

CALL relate_cara ('Belgian Golden Strong Ale', 'Retencion de Espuma', 'Densa, masiva, persistente');

CALL relate_cara ('Belgian Golden Strong Ale', 'Sabor', 'Combinación de sabores frutados (peras, naranjas, manzanas), especiados (pimienta) y alcohólicos, con un suave carácter a malta');

CALL relate_cara ('Belgian Golden Strong Ale', 'Regusto', 'Leve a moderadamente amargo');

CALL relate_cara ('Belgian Golden Strong Ale', 'Textura', 'Suave pero evidente tibieza por alcohol; jamás caliente o solventada');

CALL relate_cara ('Belgian Golden Strong Ale', 'Cuerpo', 'Liviano a medio');

CALL relate_cara ('Belgian Golden Strong Ale', 'Carbonatacion', 'Altamente carbonatada');

CALL relate_cara ('Belgian Golden Strong Ale', 'Acabado', 'Seco');

CALL relate_cara ('Belgian Golden Strong Ale', 'Amargor (IBUs)', 'Medio a alto');

CALL relate_cara ('Belgian Golden Strong Ale', 'Aroma', 'Complejo, con aroma a ésteres frutados, moderado a especias, y bajos a moderados aromas a alcohol y lúpulo');

-- Belgian Specialty Ale
CALL relate_ingr ('Belgian Specialty Ale', 'Levadura', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Ester', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Fenol', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Lupulo', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Malta', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Malta de Trigo', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Sugar Candy', 'Puede incluirse');

CALL relate_ingr ('Belgian Specialty Ale', 'Miel', 'Puede incluirse');

CALL relate_ingr ('Belgian Specialty Ale', 'Agua', 'Sin Especifica');

CALL relate_cara ('Belgian Specialty Ale', 'Color', 'Varía considerablemente de dorado pálido a muy oscuro');

CALL relate_cara ('Belgian Specialty Ale', 'Turbidez', 'Puede ser desde turbia hasta cristalina');

CALL relate_cara ('Belgian Specialty Ale', 'Retencion de Espuma', 'Generalmente buena');

CALL relate_cara ('Belgian Specialty Ale', 'Sabor', 'Se encuentran una gran variedad de sabores, con maltosidad de ligera a algo sabrosa y un sabor y amargor del lúpulo de bajo a alto');

CALL relate_cara ('Belgian Specialty Ale', 'Textura', 'Puede haber una sensación de "fruncimiento de boca" debido a la acidez');

CALL relate_cara ('Belgian Specialty Ale', 'Cuerpo', 'Algunas están bien atenuadas, por lo que tendrán un cuerpo más liviano, mientras que otras son espesas y densas');

CALL relate_cara ('Belgian Specialty Ale', 'Carbonatacion', 'Usualmente de moderada a alta');

CALL relate_cara ('Belgian Specialty Ale', 'Aroma', 'Variable, con distintas cantidades de ésteres frutados, fenoles especiados, aromas de levadura, y puede incluir aromas de adiciones de especias');

--[[ INSERT CERVEZA, CERV_CARA ]]--
-- Pilsen Fuente: https://birrapedia.com/polar-pilsen/f-56d6d147f70fb5ca0c7e71ed
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Polar Pilsen', get_tipo_cerv ('Pilsener'));

CALL relate_cara_cerv ('Polar Pilsen', 'Color', 'Dorado');

CALL relate_cara_cerv ('Polar Pilsen', 'Color de Espuma', 'Blanca');

CALL relate_cara_cerv ('Polar Pilsen', 'Aroma', 'Ligero a Malta y Maiz');

CALL relate_cara_cerv ('Polar Pilsen', 'Cuerpo', 'Ligero');

CALL relate_cara_cerv ('Polar Pilsen', 'Sabor', 'Algo dulce, a malta y maiz');

-- Solera Clasica: https://birrapedia.com/polar-pilsen/f-56d6d147f70fb5ca0c7e71ed
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera Clasica', get_tipo_cerv ('Munich Helles'));

CALL relate_cara_cerv ('Solera Clasica', 'Cuerpo', 'Pronunciado');

CALL relate_cara_cerv ('Solera Clasica', 'Graduacion', '6%');

CALL relate_cara_cerv ('Solera Clasica', 'Color', 'Amarillo');

-- Solera Light https://birrapedia.com/solera-light/f-598abdbd1603dad60e8d39c8
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera Light', get_tipo_cerv ('Lager'));

CALL relate_cara_cerv ('Solera Light', 'Carbonatacion', 'Bajo');

CALL relate_cara_cerv ('Solera Light', 'Graduacion', '4%');

CALL relate_cara_cerv ('Solera Light', 'Color', 'Amarillo');

-- Solera IPA https://birrapedia.com/solera-ipa/f-5aff60251603dacb688b4a00
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera IPA', get_tipo_cerv ('Indian Pale Ale'));

-- Solera Kriek https://birrapedia.com/solera-kriek/f-5d489aed1603dae30d8b4807
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera Kriek', get_tipo_cerv ('Fruit Lambic'));

CALL relate_cara_cerv ('Solera Kriek', 'Aroma', 'Frutal a cereza, persistente');

CALL relate_cara_cerv ('Solera Kriek', 'Sabor', 'Entre acido, amargo y dulcel');

CALL relate_cara_cerv ('Solera Kriek', 'Color', 'Rojo macerado');

CALL relate_cara_cerv ('Solera Kriek', 'Amargor (IBUs)', 'Ligero');

CALL relate_cara_cerv ('Solera Kriek', 'Cuerpo', 'Medio');

CALL relate_cara_cerv ('Solera Kriek', 'Graduacion', '4%');

-- Mito Brewhouse Momoy https://birrapedia.com/mito-brewhouse-momoy/f-577cc4dd1603dad47a4bb481
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Momoy', get_tipo_cerv ('Witbier'));

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Graduacion', '4.6%');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Sabor', 'Recuerda a canela o clavo');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Carbonatacion', 'Alta');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Aroma', 'Hierba o pino fresco');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Color', 'Palido');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Retencion de Espuma', 'Estable y Consistente');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Regusto', 'Bueno');

-- Mito Brewhouse Sayona https://birrapedia.com/mito-brewhouse-sayona/f-577cc62f1603dabe204bd0a6
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Sayona', get_tipo_cerv ('Red Ale'));

CALL relate_cara_cerv ('Mito Brewhouse Sayona', 'Aroma', 'Citrico y Floral');

CALL relate_cara_cerv ('Mito Brewhouse Sayona', 'Sabor', 'Amargo');

CALL relate_cara_cerv ('Mito Brewhouse Sayona', 'Color', 'Rojizo');

-- Mito Brewhouse Silbon https://birrapedia.com/mito-brewhouse-silbon/f-577cc74f1603da5d0c4bfb3f
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Silbon', get_tipo_cerv ('Dry Stout'));

CALL relate_cara_cerv ('Mito Brewhouse Silbon', 'Amargor (IBUs)', '15');

-- Mito Brewhouse Alcántara https://birrapedia.com/mito-brewhouse-alcantara/f-57e8dd271603da873690d05a
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Alcántara', get_tipo_cerv ('Imperial Stout'));

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Color', 'Oscuro Profundo');

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Aroma', 'Intenso');

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Graduacion', 'Alto');

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Sabor', 'Roble, Malta Dulce, de Caramelo, Tostado');

-- Mito Brewhouse Candilleja https://birrapedia.com/mito-brewhouse-candileja/f-57e8de101603da893690d053
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Candileja de Abadía', get_tipo_cerv ('Belgian Dubbel'));

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Cuerpo', 'Denso');

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Color', 'Ambar');

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Aroma', 'Intenso a Caramelo');

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Carbonatacion', 'Media a Alta');

-- Instrucciones
CALL add_inst ('American Amber Ale', 'Maceración de toda la malta durante 1 hora a 66 grados');

CALL add_inst ('American Amber Ale', 'Realizar el sparging a 76 grados');

CALL add_inst ('American Amber Ale', 'Ebullición de una hora, siguiendo los tiempos de adición del lúpulo indicados');

CALL add_inst ('American Amber Ale', 'Fermentar a 18-20 grados');

CALL add_inst ('American Amber Ale', 'Maduración en botella o en barril durante 4 semanas');

CALL add_inst ('Belgian Dubbel', 'Reúne los ingredientes necesarios, incluyendo maltas Pilsner, Munich, Caramelo, de trigo, lúpulos nobles como Saaz o Hallertau, levadura belga y agua de buena calidad.');

CALL add_inst ('Belgian Dubbel', 'Calienta el agua a aproximadamente 66-68 °C, añade las maltas molidas y mantén esta temperatura durante 60 minutos para la conversión de almidones en azúcares fermentables.');

CALL add_inst ('Belgian Dubbel', 'Separa el mosto después de la maceración y llévalo a ebullición durante 60 minutos, añadiendo lúpulo al inicio para amargor y en los últimos 15 minutos para aroma.');

CALL add_inst ('Belgian Dubbel', 'Enfría rápidamente el mosto a unos 20-22 °C, transfiérelo a un fermentador y añade la levadura, sellando el fermentador con un airlock.');

CALL add_inst ('Belgian Dubbel', 'Deja fermentar durante 1-2 semanas a temperatura controlada, embotella la cerveza con un poco de azúcar para carbonatación y deja madurar en botella durante al menos 2-4 semanas antes de disfrutar.');

-- NOTE: Venezolanas
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Destilo', get_tipo_cerv ('Ale'));

INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Dos Leones Latin American Pale Ale', get_tipo_cerv ('American IPA'));

INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Benitz Pale Ale', get_tipo_cerv ('Pale Ale'));

INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Cervecería Lago Ángel o Demonio', get_tipo_cerv ('Belgian Golden Strong Ale'));

INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Barricas Saison Belga', get_tipo_cerv ('Belgian Specialty Ale'));

INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Aldarra Mantuana', get_tipo_cerv ('Blonde Ale'));

-- Dos Leones Latin American Pale Ale
CALL relate_cara_cerv ('Dos Leones Latin American Pale Ale', 'Sabor', 'Tonos cítricos');

-- Benitz Pale Ale
CALL relate_cara_cerv ('Benitz Pale Ale', 'Sabor', 'Dulce de Maltas');

CALL relate_cara_cerv ('Benitz Pale Ale', 'Amargor (IBUs)', 'Suave');

CALL relate_cara_cerv ('Benitz Pale Ale', 'Acabado', 'Suave y fluido');

--Cervecería Lago Ángel o Demonio
CALL relate_cara_cerv ('Cervecería Lago Ángel o Demonio', 'Color', 'Dorado');

CALL relate_cara_cerv ('Cervecería Lago Ángel o Demonio', 'Color de Espuma', 'Blanca');

-- Aldarra Mantuana
CALL relate_cara_cerv ('Aldarra Mantuana', 'Color', 'Dorado');

CALL relate_cara_cerv ('Aldarra Mantuana', 'Sabor', 'Ligero');

CALL relate_cara_cerv ('Aldarra Mantuana', 'Cuerpo', 'Liviano, Sin Astringencias');

CALL relate_cara_cerv ('Aldarra Mantuana', 'Aroma', 'Recuerda a Frutas Tropicales');

CALL relate_cara_cerv ('Aldarra Mantuana', 'Carbonatacion', 'Media');

--[[ INSERT CERV_PRES ]]--
CALL pres_to_cerv_all ();

--[[ INSERT DESC_CERV ]]--
CALL give_random_descuentos ();

--[[ INSERT TARJETA ]]--
CALL add_tarjeta (4123456789012345, '2027-05-31', 123, 'Juan Perez', TRUE);

CALL add_tarjeta (4169876543210987, '2026-11-15', 456, 'Maria Gomez', FALSE);

CALL add_tarjeta (4241234567890123, '2028-03-20', 789, 'Carlos Ruiz', TRUE);

CALL add_tarjeta (4262345678901234, '2025-07-10', 321, 'Ana Torres', FALSE);

CALL add_tarjeta (4125678901234567, '2029-01-01', 654, 'Luis Fernandez', TRUE);

CALL add_tarjeta (4143456789012345, '2026-09-12', 987, 'Sofia Martinez', FALSE);

CALL add_tarjeta (4164567890123456, '2027-12-25', 159, 'Pedro Alvarez', TRUE);

CALL add_tarjeta (4245678901234567, '2028-06-18', 753, 'Lucia Romero', FALSE);

CALL add_tarjeta (4266789012345678, '2025-04-05', 852, 'Miguel Herrera', TRUE);

CALL add_tarjeta (4147890123456789, '2029-08-22', 951, 'Valentina Rivas', FALSE);

--[[ INSERT CHEQUE ]]--
CALL add_cheque_random (10001230000000000001, 20004560000000000001);

CALL add_cheque_random (10011240000000000002, 20014570000000000002);

CALL add_cheque_random (10021250000000000003, 20024580000000000003);

CALL add_cheque_random (10031260000000000004, 20034590000000000004);

CALL add_cheque_random (10041270000000000005, 20044600000000000005);

CALL add_cheque_random (10051280000000000006, 20054610000000000006);

CALL add_cheque_random (10061290000000000007, 20064620000000000007);

CALL add_cheque_random (10071300000000000008, 20074630000000000008);

CALL add_cheque_random (10081310000000000009, 20084640000000000009);

CALL add_cheque_random (10091320000000000010, 20094650000000000010);

--[[ INSERT EFECTIVO ]]--
CALL add_efectivo ('USD');

CALL add_efectivo ('EUR');

CALL add_efectivo ('GBP');

CALL add_efectivo ('JPY');

CALL add_efectivo ('CNY');

CALL add_efectivo ('KRW');

CALL add_efectivo ('INR');

CALL add_efectivo ('BRL');

CALL add_efectivo ('MXN');

CALL add_efectivo ('VES');

--[[ INSERT PUNCO_CANJEO ]]--
CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

CALL add_punto_canjeo ();

--[[ INSERT EVENTO ]]--
CALL insertar_evento(
-- Nombres de eventos
ARRAY[
'Cata de Cervezas Amazonas', 'Recorrido Cerveceria Amazonas', 'Festival de Cervezas Amazonas', 'Cena de Maridaje Amazonas', 'Taller de Elaboracion Amazonas',
'Cata de Cervezas Anzoategui', 'Recorrido Cerveceria Anzoategui', 'Festival de Cervezas Anzoategui', 'Cena de Maridaje Anzoategui', 'Taller de Elaboracion Anzoategui',
'Cata de Cervezas Apure', 'Recorrido Cerveceria Apure', 'Festival de Cervezas Apure', 'Cena de Maridaje Apure', 'Taller de Elaboracion Apure',
'Cata de Cervezas Aragua', 'Recorrido Cerveceria Aragua', 'Festival de Cervezas Aragua', 'Cena de Maridaje Aragua', 'Taller de Elaboracion Aragua',
'Cata de Cervezas Barinas', 'Recorrido Cerveceria Barinas', 'Festival de Cervezas Barinas', 'Cena de Maridaje Barinas', 'Taller de Elaboracion Barinas',
'Cata de Cervezas Bolivar', 'Recorrido Cerveceria Bolivar', 'Festival de Cervezas Bolivar', 'Cena de Maridaje Bolivar', 'Taller de Elaboracion Bolivar',
'Cata de Cervezas Carabobo', 'Recorrido Cerveceria Carabobo', 'Festival de Cervezas Carabobo', 'Cena de Maridaje Carabobo', 'Taller de Elaboracion Carabobo',
'Cata de Cervezas Cojedes', 'Recorrido Cerveceria Cojedes', 'Festival de Cervezas Cojedes', 'Cena de Maridaje Cojedes', 'Taller de Elaboracion Cojedes',
'Cata de Cervezas Delta Amacuro', 'Recorrido Cerveceria Delta Amacuro', 'Festival de Cervezas Delta Amacuro', 'Cena de Maridaje Delta Amacuro', 'Taller de Elaboracion Delta Amacuro',
'Cata de Cervezas Distrito Capital', 'Recorrido Cerveceria Distrito Capital', 'Festival de Cervezas Distrito Capital', 'Cena de Maridaje Distrito Capital', 'Taller de Elaboracion Distrito Capital',
'Cata de Cervezas Falcon', 'Recorrido Cerveceria Falcon', 'Festival de Cervezas Falcon', 'Cena de Maridaje Falcon', 'Taller de Elaboracion Falcon',
'Cata de Cervezas Guarico', 'Recorrido Cerveceria Guarico', 'Festival de Cervezas Guarico', 'Cena de Maridaje Guarico', 'Taller de Elaboracion Guarico',
'Cata de Cervezas La Guaira', 'Recorrido Cerveceria La Guaira', 'Festival de Cervezas La Guaira', 'Cena de Maridaje La Guaira', 'Taller de Elaboracion La Guaira',
'Cata de Cervezas Lara', 'Recorrido Cerveceria Lara', 'Festival de Cervezas Lara', 'Cena de Maridaje Lara', 'Taller de Elaboracion Lara',
'Cata de Cervezas Merida', 'Recorrido Cerveceria Merida', 'Festival de Cervezas Merida', 'Cena de Maridaje Merida', 'Taller de Elaboracion Merida',
'Cata de Cervezas Miranda', 'Recorrido Cerveceria Miranda', 'Festival de Cervezas Miranda', 'Cena de Maridaje Miranda', 'Taller de Elaboracion Miranda',
'Cata de Cervezas Monagas', 'Recorrido Cerveceria Monagas', 'Festival de Cervezas Monagas', 'Cena de Maridaje Monagas', 'Taller de Elaboracion Monagas',
'Cata de Cervezas Nueva Esparta', 'Recorrido Cerveceria Nueva Esparta', 'Festival de Cervezas Nueva Esparta', 'Cena de Maridaje Nueva Esparta', 'Taller de Elaboracion Nueva Esparta',
'Cata de Cervezas Portuguesa', 'Recorrido Cerveceria Portuguesa', 'Festival de Cervezas Portuguesa', 'Cena de Maridaje Portuguesa', 'Taller de Elaboracion Portuguesa',
'Cata de Cervezas Sucre', 'Recorrido Cerveceria Sucre', 'Festival de Cervezas Sucre', 'Cena de Maridaje Sucre', 'Taller de Elaboracion Sucre',
'Cata de Cervezas Tachira', 'Recorrido Cerveceria Tachira', 'Festival de Cervezas Tachira', 'Cena de Maridaje Tachira', 'Taller de Elaboracion Tachira',
'Cata de Cervezas Trujillo', 'Recorrido Cerveceria Trujillo', 'Festival de Cervezas Trujillo', 'Cena de Maridaje Trujillo', 'Taller de Elaboracion Trujillo',
'Cata de Cervezas Yaracuy', 'Recorrido Cerveceria Yaracuy', 'Festival de Cervezas Yaracuy', 'Cena de Maridaje Yaracuy', 'Taller de Elaboracion Yaracuy',
'Cata de Cervezas Zulia', 'Recorrido Cerveceria Zulia', 'Festival de Cervezas Zulia', 'Cena de Maridaje Zulia', 'Taller de Elaboracion Zulia'
] :: varchar(40)[],
ARRAY[
'2025-07-01 16:00:00','2025-07-01 17:00:00','2025-07-01 18:00:00','2025-07-01 19:00:00','2025-07-01 20:00:00',
'2025-07-02 16:00:00','2025-07-02 17:00:00','2025-07-02 18:00:00','2025-07-02 19:00:00','2025-07-02 20:00:00',
'2025-07-03 16:00:00','2025-07-03 17:00:00','2025-07-03 18:00:00','2025-07-03 19:00:00','2025-07-03 20:00:00',
'2025-07-04 16:00:00','2025-07-04 17:00:00','2025-07-04 18:00:00','2025-07-04 19:00:00','2025-07-04 20:00:00',
'2025-07-05 16:00:00','2025-07-05 17:00:00','2025-07-05 18:00:00','2025-07-05 19:00:00','2025-07-05 20:00:00',
'2025-07-06 16:00:00','2025-07-06 17:00:00','2025-07-06 18:00:00','2025-07-06 19:00:00','2025-07-06 20:00:00',
'2025-07-07 16:00:00','2025-07-07 17:00:00','2025-07-07 18:00:00','2025-07-07 19:00:00','2025-07-07 20:00:00',
'2025-07-08 16:00:00','2025-07-08 17:00:00','2025-07-08 18:00:00','2025-07-08 19:00:00','2025-07-08 20:00:00',
'2025-07-09 16:00:00','2025-07-09 17:00:00','2025-07-09 18:00:00','2025-07-09 19:00:00','2025-07-09 20:00:00',
'2025-07-10 16:00:00','2025-07-10 17:00:00','2025-07-10 18:00:00','2025-07-10 19:00:00','2025-07-10 20:00:00',
'2025-07-11 16:00:00','2025-07-11 17:00:00','2025-07-11 18:00:00','2025-07-11 19:00:00','2025-07-11 20:00:00',
'2025-07-12 16:00:00','2025-07-12 17:00:00','2025-07-12 18:00:00','2025-07-12 19:00:00','2025-07-12 20:00:00',
'2025-07-13 16:00:00','2025-07-13 17:00:00','2025-07-13 18:00:00','2025-07-13 19:00:00','2025-07-13 20:00:00',
'2025-07-14 16:00:00','2025-07-14 17:00:00','2025-07-14 18:00:00','2025-07-14 19:00:00','2025-07-14 20:00:00',
'2025-07-15 16:00:00','2025-07-15 17:00:00','2025-07-15 18:00:00','2025-07-15 19:00:00','2025-07-15 20:00:00',
'2025-07-16 16:00:00','2025-07-16 17:00:00','2025-07-16 18:00:00','2025-07-16 19:00:00','2025-07-16 20:00:00',
'2025-07-17 16:00:00','2025-07-17 17:00:00','2025-07-17 18:00:00','2025-07-17 19:00:00','2025-07-17 20:00:00',
'2025-07-18 16:00:00','2025-07-18 17:00:00','2025-07-18 18:00:00','2025-07-18 19:00:00','2025-07-18 20:00:00',
'2025-07-19 16:00:00','2025-07-19 17:00:00','2025-07-19 18:00:00','2025-07-19 19:00:00','2025-07-19 20:00:00',
'2025-07-20 16:00:00','2025-07-20 17:00:00','2025-07-20 18:00:00','2025-07-20 19:00:00','2025-07-20 20:00:00',
'2025-07-21 16:00:00','2025-07-21 17:00:00','2025-07-21 18:00:00','2025-07-21 19:00:00','2025-07-21 20:00:00',
'2025-07-22 16:00:00','2025-07-22 17:00:00','2025-07-22 18:00:00','2025-07-22 19:00:00','2025-07-22 20:00:00',
'2025-07-23 16:00:00','2025-07-23 17:00:00','2025-07-23 18:00:00','2025-07-23 19:00:00','2025-07-23 20:00:00',
'2025-07-24 16:00:00','2025-07-24 17:00:00','2025-07-24 18:00:00','2025-07-24 19:00:00','2025-07-24 20:00:00'
] :: timestamp[],
ARRAY[
'2025-07-01 20:00:00','2025-07-01 21:00:00','2025-07-01 22:00:00','2025-07-01 23:00:00','2025-07-01 23:30:00',
'2025-07-02 20:00:00','2025-07-02 21:00:00','2025-07-02 22:00:00','2025-07-02 23:00:00','2025-07-02 23:30:00',
'2025-07-03 20:00:00','2025-07-03 21:00:00','2025-07-03 22:00:00','2025-07-03 23:00:00','2025-07-03 23:30:00',
'2025-07-04 20:00:00','2025-07-04 21:00:00','2025-07-04 22:00:00','2025-07-04 23:00:00','2025-07-04 23:30:00',
'2025-07-05 20:00:00','2025-07-05 21:00:00','2025-07-05 22:00:00','2025-07-05 23:00:00','2025-07-05 23:30:00',
'2025-07-06 20:00:00','2025-07-06 21:00:00','2025-07-06 22:00:00','2025-07-06 23:00:00','2025-07-06 23:30:00',
'2025-07-07 20:00:00','2025-07-07 21:00:00','2025-07-07 22:00:00','2025-07-07 23:00:00','2025-07-07 23:30:00',
'2025-07-08 20:00:00','2025-07-08 21:00:00','2025-07-08 22:00:00','2025-07-08 23:00:00','2025-07-08 23:30:00',
'2025-07-09 20:00:00','2025-07-09 21:00:00','2025-07-09 22:00:00','2025-07-09 23:00:00','2025-07-09 23:30:00',
'2025-07-10 20:00:00','2025-07-10 21:00:00','2025-07-10 22:00:00','2025-07-10 23:00:00','2025-07-10 23:30:00',
'2025-07-11 20:00:00','2025-07-11 21:00:00','2025-07-11 22:00:00','2025-07-11 23:00:00','2025-07-11 23:30:00',
'2025-07-12 20:00:00','2025-07-12 21:00:00','2025-07-12 22:00:00','2025-07-12 23:00:00','2025-07-12 23:30:00',
'2025-07-13 20:00:00','2025-07-13 21:00:00','2025-07-13 22:00:00','2025-07-13 23:00:00','2025-07-13 23:30:00',
'2025-07-14 20:00:00','2025-07-14 21:00:00','2025-07-14 22:00:00','2025-07-14 23:00:00','2025-07-14 23:30:00',
'2025-07-15 20:00:00','2025-07-15 21:00:00','2025-07-15 22:00:00','2025-07-15 23:00:00','2025-07-15 23:30:00',
'2025-07-16 20:00:00','2025-07-16 21:00:00','2025-07-16 22:00:00','2025-07-16 23:00:00','2025-07-16 23:30:00',
'2025-07-17 20:00:00','2025-07-17 21:00:00','2025-07-17 22:00:00','2025-07-17 23:00:00','2025-07-17 23:30:00',
'2025-07-18 20:00:00','2025-07-18 21:00:00','2025-07-18 22:00:00','2025-07-18 23:00:00','2025-07-18 23:30:00',
'2025-07-19 20:00:00','2025-07-19 21:00:00','2025-07-19 22:00:00','2025-07-19 23:00:00','2025-07-19 23:30:00',
'2025-07-20 20:00:00','2025-07-20 21:00:00','2025-07-20 22:00:00','2025-07-20 23:00:00','2025-07-20 23:30:00',
'2025-07-21 20:00:00','2025-07-21 21:00:00','2025-07-21 22:00:00','2025-07-21 23:00:00','2025-07-21 23:30:00',
'2025-07-22 20:00:00','2025-07-22 21:00:00','2025-07-22 22:00:00','2025-07-22 23:00:00','2025-07-22 23:30:00',
'2025-07-23 20:00:00','2025-07-23 21:00:00','2025-07-23 22:00:00','2025-07-23 23:00:00','2025-07-23 23:30:00',
'2025-07-24 20:00:00','2025-07-24 21:00:00','2025-07-24 22:00:00','2025-07-24 23:00:00','2025-07-24 23:30:00'
] :: timestamp[],
ARRAY[
'Calle Fernando Giron Tovar, Puerto Ayacucho, Amazonas','Calle Luis Alberto Gomez, Puerto Ayacucho, Amazonas','Calle Parhueña, Puerto Ayacucho, Amazonas','Calle Platanillal, Puerto Ayacucho, Amazonas','Avenida La Esmeralda, Alto Orinoco, Amazonas',
'Calle Anaco, Anaco, Anzoategui','Avenida San Joaquin, Anaco, Anzoategui','Calle Cachipo, Aragua de Barcelona, Anzoategui','Avenida Lecheria, Lecheria, Anzoategui','Calle El Morro, Lecheria, Anzoategui',
'Calle Achaguas, Achaguas, Apure','Calle Apurito, Achaguas, Apure','Calle El Yagual, Achaguas, Apure','Calle Guachara, Achaguas, Apure','Calle Mucuritas, Achaguas, Apure',
'Calle Maracay, Maracay, Aragua','Avenida Las Delicias, Maracay, Aragua','Calle Cagua, Cagua, Aragua','Calle Turmero, Turmero, Aragua','Avenida Sucre, La Victoria, Aragua',
'Calle Barinas, Barinas, Barinas','Avenida Industrial, Barinas, Barinas','Calle Libertad, Barinas, Barinas','Calle Obispos, Obispos, Barinas','Calle Sabaneta, Sabaneta, Barinas',
'Calle Angostura, Ciudad Bolivar, Bolivar','Avenida Libertador, Ciudad Bolivar, Bolivar','Calle Upata, Upata, Bolivar','Calle Tumeremo, Tumeremo, Bolivar','Calle El Callao, El Callao, Bolivar',
'Calle Valencia, Valencia, Carabobo','Avenida Bolivar, Valencia, Carabobo','Calle Naguanagua, Naguanagua, Carabobo','Calle Guacara, Guacara, Carabobo','Avenida San Diego, San Diego, Carabobo',
'Calle Tinaquillo, Tinaquillo, Cojedes','Calle San Carlos, San Carlos, Cojedes','Calle Tinaco, Tinaco, Cojedes','Calle El Baul, El Baul, Cojedes','Calle Las Vegas, Las Vegas, Cojedes',
'Calle Tucupita, Tucupita, Delta Amacuro','Calle Pedernales, Pedernales, Delta Amacuro','Calle Curiapo, Curiapo, Delta Amacuro','Calle Capure, Capure, Delta Amacuro','Calle Araguaimujo, Araguaimujo, Delta Amacuro',
'Calle La Pastora, Caracas, Distrito Capital','Calle San Juan, Caracas, Distrito Capital','Calle El Valle, Caracas, Distrito Capital','Calle La Vega, Caracas, Distrito Capital','Calle Antimano, Caracas, Distrito Capital',
'Calle Coro, Coro, Falcon','Avenida Zamora, Coro, Falcon','Calle Punto Fijo, Punto Fijo, Falcon','Calle Chichiriviche, Chichiriviche, Falcon','Calle Tucacas, Tucacas, Falcon',
'Calle San Juan de los Morros, San Juan de los Morros, Guarico','Calle Calabozo, Calabozo, Guarico','Calle Zaraza, Zaraza, Guarico','Calle Valle de la Pascua, Valle de la Pascua, Guarico','Calle Altagracia de Orituco, Altagracia de Orituco, Guarico',
'Calle Macuto, Macuto, La Guaira','Avenida La Playa, Macuto, La Guaira','Calle Catia La Mar, Catia La Mar, La Guaira','Calle Maiquetia, Maiquetia, La Guaira','Calle Caraballeda, Caraballeda, La Guaira',
'Calle Barquisimeto, Barquisimeto, Lara','Avenida Lara, Barquisimeto, Lara','Calle Cabudare, Cabudare, Lara','Calle El Tocuyo, El Tocuyo, Lara','Calle Quibor, Quibor, Lara',
'Calle Merida, Merida, Merida','Avenida Los Andes, Merida, Merida','Calle Ejido, Ejido, Merida','Calle Tovar, Tovar, Merida','Calle Lagunillas, Lagunillas, Merida',
'Calle Los Teques, Los Teques, Miranda','Avenida Miranda, Los Teques, Miranda','Calle Guarenas, Guarenas, Miranda','Calle Guatire, Guatire, Miranda','Calle Charallave, Charallave, Miranda',
'Calle Maturin, Maturin, Monagas','Avenida Bolivar, Maturin, Monagas','Calle Punta de Mata, Punta de Mata, Monagas','Calle Caripito, Caripito, Monagas','Calle Temblador, Temblador, Monagas',
'Calle Porlamar, Porlamar, Nueva Esparta','Avenida 4 de Mayo, Porlamar, Nueva Esparta','Calle Pampatar, Pampatar, Nueva Esparta','Calle Juan Griego, Juan Griego, Nueva Esparta','Calle La Asuncion, La Asuncion, Nueva Esparta',
'Calle Guanare, Guanare, Portuguesa','Avenida Portuguesa, Guanare, Portuguesa','Calle Acarigua, Acarigua, Portuguesa','Calle Araure, Araure, Portuguesa','Calle Biscucuy, Biscucuy, Portuguesa',
'Calle Cumana, Cumana, Sucre','Avenida Sucre, Cumana, Sucre','Calle Carupano, Carupano, Sucre','Calle Rio Caribe, Rio Caribe, Sucre','Calle Guiria, Guiria, Sucre',
'Calle San Cristobal, San Cristobal, Tachira','Avenida Tachira, San Cristobal, Tachira','Calle Rubio, Rubio, Tachira','Calle La Grita, La Grita, Tachira','Calle Colon, Colon, Tachira',
'Calle Trujillo, Trujillo, Trujillo','Avenida Bolivar, Trujillo, Trujillo','Calle Boconó, Boconó, Trujillo','Calle Valera, Valera, Trujillo','Calle Carache, Carache, Trujillo',
'Calle San Felipe, San Felipe, Yaracuy','Avenida Yaracuy, San Felipe, Yaracuy','Calle Yaritagua, Yaritagua, Yaracuy','Calle Chivacoa, Chivacoa, Yaracuy','Calle Nirgua, Nirgua, Yaracuy',
'Calle Maracaibo, Maracaibo, Zulia','Avenida Bella Vista, Maracaibo, Zulia','Calle Cabimas, Cabimas, Zulia','Calle Ciudad Ojeda, Ciudad Ojeda, Zulia','Calle San Francisco, San Francisco, Zulia'
] :: text[],
ARRAY[
100,120,80,150,90,110,130,85,140,95,200,180,160,220,170,105,125,95,155,100,115,135,90,145,98,108,128,88,138,93,112,132,92,142,97,107,127,87,137,91,109,129,89,139,94,106,126,86,136,99,111,131,91,141,96,104,124,84,134,101,113,133,83,143,102,114,134,82,144,103,116,136,81,146,104,117,137,80,147,105,118,138,79,148,106,119,139,78,149,107,120,140,77,150,108,121,141,76,151,109,122,142,75,152,110,123,143,74,153,111,124,144,73,154,112,125,145,72,155,113,126,146,71,156,114,127,147,70,157,115,128,148,69,158,116,129,149,68,159,117,130,150,67,160,118,131,151,66,161,119,132,152,65,162,120,133,153,64,163,121,134,154,63,164,122,135,155,62,165,123,136,156,61,166,124,137,157,60,167,125,138,158,59,168,126,139,159,58,169,127,140,160
] :: integer[],
ARRAY[
'Cata guiada de cervezas artesanales de Amazonas','Recorrido por la cervecería local de Amazonas','Festival con las mejores cervezas de Amazonas','Cena de maridaje con cervezas y platos típicos de Amazonas','Taller práctico de elaboración de cerveza en Amazonas',
'Cata guiada de cervezas artesanales de Anzoategui','Recorrido por la cervecería local de Anzoategui','Festival con las mejores cervezas de Anzoategui','Cena de maridaje con cervezas y platos típicos de Anzoategui','Taller práctico de elaboración de cerveza en Anzoategui',
'Cata guiada de cervezas artesanales de Apure','Recorrido por la cervecería local de Apure','Festival con las mejores cervezas de Apure','Cena de maridaje con cervezas y platos típicos de Apure','Taller práctico de elaboración de cerveza en Apure',
'Cata guiada de cervezas artesanales de Aragua','Recorrido por la cervecería local de Aragua','Festival con las mejores cervezas de Aragua','Cena de maridaje con cervezas y platos típicos de Aragua','Taller práctico de elaboración de cerveza en Aragua',
'Cata guiada de cervezas artesanales de Barinas','Recorrido por la cervecería local de Barinas','Festival con las mejores cervezas de Barinas','Cena de maridaje con cervezas y platos típicos de Barinas','Taller práctico de elaboración de cerveza en Barinas',
'Cata guiada de cervezas artesanales de Bolivar','Recorrido por la cervecería local de Bolivar','Festival con las mejores cervezas de Bolivar','Cena de maridaje con cervezas y platos típicos de Bolivar','Taller práctico de elaboración de cerveza en Bolivar',
'Cata guiada de cervezas artesanales de Carabobo','Recorrido por la cervecería local de Carabobo','Festival con las mejores cervezas de Carabobo','Cena de maridaje con cervezas y platos típicos de Carabobo','Taller práctico de elaboración de cerveza en Carabobo',
'Cata guiada de cervezas artesanales de Cojedes','Recorrido por la cervecería local de Cojedes','Festival con las mejores cervezas de Cojedes','Cena de maridaje con cervezas y platos típicos de Cojedes','Taller práctico de elaboración de cerveza en Cojedes',
'Cata guiada de cervezas artesanales de Delta Amacuro','Recorrido por la cervecería local de Delta Amacuro','Festival con las mejores cervezas de Delta Amacuro','Cena de maridaje con cervezas y platos típicos de Delta Amacuro','Taller práctico de elaboración de cerveza en Delta Amacuro',
'Cata guiada de cervezas artesanales de Distrito Capital','Recorrido por la cervecería local de Distrito Capital','Festival con las mejores cervezas de Distrito Capital','Cena de maridaje con cervezas y platos típicos de Distrito Capital','Taller práctico de elaboración de cerveza en Distrito Capital',
'Cata guiada de cervezas artesanales de Falcon','Recorrido por la cervecería local de Falcon','Festival con las mejores cervezas de Falcon','Cena de maridaje con cervezas y platos típicos de Falcon','Taller práctico de elaboración de cerveza en Falcon',
'Cata guiada de cervezas artesanales de Guarico','Recorrido por la cervecería local de Guarico','Festival con las mejores cervezas de Guarico','Cena de maridaje con cervezas y platos típicos de Guarico','Taller práctico de elaboración de cerveza en Guarico',
'Cata guiada de cervezas artesanales de La Guaira','Recorrido por la cervecería local de La Guaira','Festival con las mejores cervezas de La Guaira','Cena de maridaje con cervezas y platos típicos de La Guaira','Taller práctico de elaboración de cerveza en La Guaira',
'Cata guiada de cervezas artesanales de Lara','Recorrido por la cervecería local de Lara','Festival con las mejores cervezas de Lara','Cena de maridaje con cervezas y platos típicos de Lara','Taller práctico de elaboración de cerveza en Lara',
'Cata guiada de cervezas artesanales de Merida','Recorrido por la cervecería local de Merida','Festival con las mejores cervezas de Merida','Cena de maridaje con cervezas y platos típicos de Merida','Taller práctico de elaboración de cerveza en Merida',
'Cata guiada de cervezas artesanales de Miranda','Recorrido por la cervecería local de Miranda','Festival con las mejores cervezas de Miranda','Cena de maridaje con cervezas y platos típicos de Miranda','Taller práctico de elaboración de cerveza en Miranda',
'Cata guiada de cervezas artesanales de Monagas','Recorrido por la cervecería local de Monagas','Festival con las mejores cervezas de Monagas','Cena de maridaje con cervezas y platos típicos de Monagas','Taller práctico de elaboración de cerveza en Monagas',
'Cata guiada de cervezas artesanales de Nueva Esparta','Recorrido por la cervecería local de Nueva Esparta','Festival con las mejores cervezas de Nueva Esparta','Cena de maridaje con cervezas y platos típicos de Nueva Esparta','Taller práctico de elaboración de cerveza en Nueva Esparta',
'Cata guiada de cervezas artesanales de Portuguesa','Recorrido por la cervecería local de Portuguesa','Festival con las mejores cervezas de Portuguesa','Cena de maridaje con cervezas y platos típicos de Portuguesa','Taller práctico de elaboración de cerveza en Portuguesa',
'Cata guiada de cervezas artesanales de Sucre','Recorrido por la cervecería local de Sucre','Festival con las mejores cervezas de Sucre','Cena de maridaje con cervezas y platos típicos de Sucre','Taller práctico de elaboración de cerveza en Sucre',
'Cata guiada de cervezas artesanales de Tachira','Recorrido por la cervecería local de Tachira','Festival con las mejores cervezas de Tachira','Cena de maridaje con cervezas y platos típicos de Tachira','Taller práctico de elaboración de cerveza en Tachira',
'Cata guiada de cervezas artesanales de Trujillo','Recorrido por la cervecería local de Trujillo','Festival con las mejores cervezas de Trujillo','Cena de maridaje con cervezas y platos típicos de Trujillo','Taller práctico de elaboración de cerveza en Trujillo',
'Cata guiada de cervezas artesanales de Yaracuy','Recorrido por la cervecería local de Yaracuy','Festival con las mejores cervezas de Yaracuy','Cena de maridaje con cervezas y platos típicos de Yaracuy','Taller práctico de elaboración de cerveza en Yaracuy',
'Cata guiada de cervezas artesanales de Zulia','Recorrido por la cervecería local de Zulia','Festival con las mejores cervezas de Zulia','Cena de maridaje con cervezas y platos típicos de Zulia','Taller práctico de elaboración de cerveza en Zulia'
] :: text[],
ARRAY[
15.00,20.00,25.00,30.00,18.00,16.00,21.00,26.00,31.00,19.00,35.00,40.00,45.00,50.00,38.00,17.00,22.00,27.00,32.00,20.00,18.50,23.00,28.00,33.00,21.00,19.50,24.00,29.00,34.00,22.00,20.50,25.00,30.00,35.00,23.00,21.50,26.00,31.00,36.00,24.00,22.50,27.00,32.00,37.00,25.00,23.50,28.00,33.00,38.00,26.00,24.50,29.00,34.00,39.00,27.00,25.50,30.00,35.00,40.00,28.00,26.50,31.00,36.00,41.00,29.00,27.50,32.00,37.00,42.00,30.00,28.50,33.00,38.00,43.00,31.00,29.50,34.00,39.00,44.00,32.00,30.50,35.00,40.00,45.00,33.00,31.50,36.00,41.00,46.00,34.00,32.50,37.00,42.00,47.00,35.00,33.50,38.00,43.00,48.00,36.00,34.50,39.00,44.00,49.00,37.00,35.50,40.00,45.00,50.00,38.00,36.50,41.00,46.00,51.00,39.00,37.50,42.00,47.00,52.00,40.00,38.50,43.00,48.00,53.00,41.00,39.50,44.00,49.00,54.00,42.00,40.50,45.00,50.00,55.00
] :: numeric (8,2) [],
ARRAY[
100,120,80,150,90,110,130,85,140,95,200,180,160,220,170,105,125,95,155,100,115,135,90,145,98,108,128,88,138,93,112,132,92,142,97,107,127,87,137,91,109,129,89,139,94,106,126,86,136,99,111,131,91,141,96,104,124,84,134,101,113,133,83,143,102,114,134,82,144,103,116,136,81,146,104,117,137,80,147,105,118,138,79,148,106,119,139,78,149,107,120,140,77,150,108,121,141,76,151,109,122,142,75,152,110,123,143,74,153,111,124,144,73,154,112,125,145,72,155,113,126,146,71,156,114,127,147,70,157,115,128,148,69,158,116,129,149,68,159,117,130,150,67,160,118,131,151,66,161,119,132,152,65,162,120,133,153,64,163,121,134,154,63,164,122,135,155,62,165,123,136,156,61,166,124,137,157,60,167,125,138,158,59,168,126,139,159,58,169,127,140,160
] :: integer[],
ARRAY[
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros'
] :: varchar(60)[],
ARRAY[
'Fernando Giron Tovar','Luis Alberto Gomez','Parhueña','Platanillal','La Esmeralda',
'Anaco','San Joaquin','Cachipo','Aragua de Barcelona','Lecheria',
'Achaguas','Apurito','El Yagual','Guachara','Mucuritas',
'Choroni','Las Delicias','Cagua','Turmero','Jose Felix Ribas',
'Barinas','Alfredo Arvelo Larriva','Libertad','Obispos','Sabaneta',
'Cachamay','Vista al Sol','Upata','Tumeremo','El Callao',
'Urbana San Blas','Simon Bolivar','Urbana Naguanagua Valencia','Guacara','San Diego Valencia',
'Cojedes','El Pao','Tinaquillo','Macapo','San Carlos de Austria',
'Curiapo','Imataca','Pedernales','San Jose','Curiapo',
'23 de Enero','Antimano','Catedral','El Valle','La Pastora',
'Capadare','Aracua','Bariro','Norte','La Vela de Coro',
'Camaguan','Chaguaramas','El Socorro','Tucupido','San Juan de los Morros',
'Caraballeda','Carayaca','Catia La Mar','Maiquetia','Macuto',
'Quebrada Honda de Guache','Freitez','Anzoategui','Cabudare','Buria',
'Presidente Betancourt','Santa Cruz de Mora','La Azulita','Aricagua','Fernandez Peña',
'Aragüita','Cumbo','El Cafetal','Higuerote','Mamporal',
'San Antonio de Maturin','Aguasay','Caripito','El Tejero','Alto de los Godos',
'Antolin del Campo','San Juan Bautista','Garcia','Bolivar','Aguirre',
'Araure','Agua Blanca','Piritu','Cordova','Guanarito',
'Mariño','San Jose de Areocuar','Rio Caribe','El Pilar','Santa Catalina',
'Cordero','Virgen del Carmen','San Juan de Colon','Isaias Medina Angarita','Amenodoro Rangel Lamus',
'Santa Isabel','Bocono','Sabana Grande','Chejende','Carache',
'Aristides Bastidas','Bolivar','Chivacoa','Cocorote','Independencia',
'Isla de Toas','San Timoteo','Ambrosio','Encontrados','San Carlos del Zulia'
] :: varchar(40)[],
ARRAY[
'Amazonas','Anzoategui','Apure','Aragua','Barinas','Bolivar','Carabobo','Cojedes','Delta Amacuro','Distrito Capital','Falcon','Guarico','La Guaira','Lara','Merida','Miranda','Monagas','Nueva Esparta','Portuguesa','Sucre','Tachira','Trujillo','Yaracuy','Zulia'
] :: varchar(40)[]
);

--[[ INSERT REGISTRO_EVENTO ]]--
CALL register_juez_for_event ();

--[[ INSERT INVENTARIO_EVENTO ]]--
CALL populate_events_inventories ();

--[[ INSERT INVENTARIO_TIENDA ]]--
CALL populate_tiendas_inventories ();

--[[ INSERT VENTA ]]--
CALL create_orden_compra_10_productos ();

CALL generate_random_ventas ();

--[[ INSERT COMPRA]]--
CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[1], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[2], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[3], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[4], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[5], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[6], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[7], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[8], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[9], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[10], ARRAY[1]);

--[[ INSERT ADMIN USER ]]--
INSERT INTO Empleado(cod_empl, ci_empl, primer_nom_empl, primer_ape_empl, salario_base_empl) VALUES (0, 123, 'admin', 'admin', 0.0);

INSERT INTO Usuario (username_usua, contra_usua, fk_rol, fk_empl) VALUES('admin', 'admin', 500, 0);

-- Views
CREATE OR REPLACE VIEW tipo_cliente_view AS
    SELECT tipo_clie "Tipo de Cliente", fecha_ingr_clie "Fecha de ingreso"
    FROM Cliente
    Order By fecha_ingr_clie ASC;

CREATE OR REPLACE VIEW horas_trabajo_view AS
    SELECT e.cod_empl "Numero Empleado", e.ci_empl "Cedula", a.fecha_hora_ini_asis "Entrada", a.fecha_hora_fin_asis "Salida"
    FROM Asistencia a, EMPL_CARG ec, Empleado e
    WHERE a.fk_empl_carg_1 = ec.fk_empl AND a.fk_empl_carg_2 = ec.fk_carg AND a.fk_empl_carg_3 = ec.cod_empl_carg
    AND ec.fk_empl = e.cod_empl;

CREATE OR REPLACE VIEW productos_generan_repo_view AS
    SELECT DISTINCT c.cod_cerv "Código de Cerveza", c.nombre_cerv "Nombre", p.cod_pres "Código de Presentación", p.nombre_pres "Nombre Presentación"
    FROM Detalle_Compra dc, Detalle_Venta dv, CERV_PRES cp, Cerveza c, Inventario_Tienda it, Presentacion p
    WHERE c.cod_cerv = cp.fk_cerv
        AND cp.fk_pres = p.cod_pres
        AND cp.fk_cerv = dc.fk_cerv_pres_1
        AND cp.fk_pres = dc.fk_cerv_pres_2
        AND cp.fk_cerv = it.fk_cerv_pres_1
        AND cp.fk_pres = it.fk_cerv_pres_2
        AND it.fk_cerv_pres_1 = dv.fk_inve_tien_1
        AND it.fk_cerv_pres_2 = dv.fk_inve_tien_2
        AND dv.fk_inve_tien_1 = dc.fk_cerv_pres_1
        AND dv.fk_inve_tien_2 = dc.fk_cerv_pres_2;

CREATE OR REPLACE VIEW rentabilidad_tipo_view AS
	SELECT tc.cod_tipo_cerv "Código Tipo", tc.nombre_tipo_cerv "Nombre Tipo de Cerveza",v.fecha_vent "Fecha de Venta", SUM(dv.precio_unitario_vent * dv.cant_deta_vent) "Ganancia total entre todas las Ventas"
    FROM Presentacion p, Detalle_Venta dv, Inventario_Tienda it, CERV_PRES cp, Cerveza c, Tipo_Cerveza tc, Venta v
    WHERE p.cod_pres = cp.fk_pres
        AND c.cod_cerv = cp.fk_cerv
        AND c.fk_tipo_cerv = tc.cod_tipo_cerv
        AND cp.fk_cerv = it.fk_cerv_pres_1
        AND cp.fk_pres = it.fk_cerv_pres_2
        AND it.fk_cerv_pres_1 = dv.fk_inve_tien_1
        AND it.fk_cerv_pres_2 = dv.fk_inve_tien_2
        AND dv.fk_vent = v.cod_vent
        AND v.online = true
	GROUP BY tc.cod_tipo_cerv, tc.nombre_tipo_cerv, v.fecha_vent;

CREATE OR REPLACE VIEW rentabilidad_tipo_total_view AS
	SELECT tc.cod_tipo_cerv "Código Tipo", tc.nombre_tipo_cerv "Nombre Tipo de Cerveza", SUM(dv.precio_unitario_vent * dv.cant_deta_vent) "Ganancia total entre todas las Ventas"
    FROM Presentacion p, Detalle_Venta dv, Inventario_Tienda it, CERV_PRES cp, Cerveza c, Tipo_Cerveza tc, Venta v
    WHERE p.cod_pres = cp.fk_pres
        AND c.cod_cerv = cp.fk_cerv
        AND c.fk_tipo_cerv = tc.cod_tipo_cerv
        AND cp.fk_cerv = it.fk_cerv_pres_1
        AND cp.fk_pres = it.fk_cerv_pres_2
        AND it.fk_cerv_pres_1 = dv.fk_inve_tien_1
        AND it.fk_cerv_pres_2 = dv.fk_inve_tien_2
        AND dv.fk_vent = v.cod_vent
        AND v.online = true
	GROUP BY tc.cod_tipo_cerv, tc.nombre_tipo_cerv;

CREATE OR REPLACE VIEW proporcion_tarjetas_view AS
    SELECT CAST(t.credito AS int) AS "Es de Crédito", COUNT (t.credito)
    FROM Venta v, Pago p, Metodo_Pago mp, Tarjeta t
    WHERE v.cod_vent = p.fk_vent
        AND p.fk_meto_pago = mp.cod_meto_pago
        AND mp.cod_meto_pago = t.fk_meto_pago
    GROUP BY t.credito;

CREATE OR REPLACE FUNCTION periodo_tipo_cliente (year integer, modalidad text)
RETURNS TABLE ("Tipo" varchar(40), "Periodo" integer, "Cantidad" bigint, "Año" integer)
LANGUAGE plpgsql
AS $$
BEGIN
    IF modalidad = 'mensual' THEN
        RETURN QUERY
            SELECT "Tipo de Cliente", EXTRACT(MONTH from "Fecha de ingreso"):: integer as "Mes", COUNT ("Tipo de Cliente"), EXTRACT(YEAR FROM "Fecha de ingreso"):: integer as "Año"
            FROM tipo_cliente_view
            WHERE EXTRACT(YEAR FROM "Fecha de ingreso") = year
            GROUP BY "Tipo de Cliente", EXTRACT(MONTH from "Fecha de ingreso"), EXTRACT(YEAR FROM "Fecha de ingreso")
			ORDER BY "Mes";
    ELSE
        RETURN QUERY
            SELECT "Tipo de Cliente", EXTRACT(QUARTER from "Fecha de ingreso"):: integer as "Trimestre", COUNT ("Tipo de Cliente"), EXTRACT(YEAR FROM "Fecha de ingreso"):: integer as "Año"
            FROM tipo_cliente_view
            WHERE EXTRACT(YEAR FROM "Fecha de ingreso") = year
            GROUP BY "Tipo de Cliente", EXTRACT(QUARTER from "Fecha de ingreso"), EXTRACT(YEAR FROM "Fecha de ingreso")
            ORDER BY "Trimestre";
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION consolidar_horas (year integer, month integer, trimonth integer, modalidad text)
RETURNS TABLE ("Numero de Empleado" integer, "Cedula Empleado" integer, "Horas trabajadas" numeric, "Periodo" date)
LANGUAGE plpgsql
AS $$
BEGIN
    IF modalidad = 'diario' AND month IS NOT NULL AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", EXTRACT(EPOCH FROM ("Salida" - "Entrada")) / 3600 AS horas_trabajadas, CAST("Entrada" AS date) AS "Fecha"
            FROM horas_trabajo_view
            WHERE CAST("Entrada" AS date) = CAST("Salida" AS date)
                AND EXTRACT(MONTH FROM "Entrada") = month
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado","Cedula", EXTRACT(EPOCH FROM ("Salida" - "Entrada")) / 3600, CAST("Entrada" AS date)
			ORDER BY "Fecha";
    ELSIF modalidad = 'diario' AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", EXTRACT(EPOCH FROM ("Salida" - "Entrada")) / 3600 AS horas_trabajadas, CAST("Entrada" AS date) AS "Fecha"
            FROM horas_trabajo_view
            WHERE CAST("Entrada" AS date) = CAST("Salida" AS date)
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado","Cedula", EXTRACT(EPOCH FROM ("Salida" - "Entrada")) / 3600, CAST("Entrada" AS date)
			ORDER BY "Fecha";
    ELSIF modalidad = 'diario' THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", EXTRACT(EPOCH FROM ("Salida" - "Entrada")) / 3600 AS horas_trabajadas, CAST("Entrada" AS date) AS "Fecha"
            FROM horas_trabajo_view
            WHERE CAST("Entrada" AS date) = CAST("Salida" AS date)
            GROUP BY "Numero Empleado","Cedula", EXTRACT(EPOCH FROM ("Salida" - "Entrada")) / 3600, CAST("Entrada" AS date)
			ORDER BY "Fecha";
    ELSIF modalidad = 'semanal' AND month IS NOT NULL AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('week', CAST("Entrada" AS date)) AS date) AS "Semana"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('week', CAST("Entrada" AS date)) = DATE_TRUNC('week', CAST("Salida" AS date))
                AND EXTRACT(MONTH FROM "Entrada") = month
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('week', CAST("Entrada" AS date)) AS date)
            ORDER BY "Semana";
    ELSIF modalidad = 'semanal' AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('week', CAST("Entrada" AS date)) AS date) AS "Semana"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('week', CAST("Entrada" AS date)) = DATE_TRUNC('week', CAST("Salida" AS date))
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('week', CAST("Entrada" AS date)) AS date)
            ORDER BY "Semana";
    ELSIF modalidad = 'semanal' THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('week', CAST("Entrada" AS date)) AS date) AS "Semana"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('week', CAST("Entrada" AS date)) = DATE_TRUNC('week', CAST("Salida" AS date))
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('week', CAST("Entrada" AS date)) AS date)
            ORDER BY "Semana";
    ELSIF modalidad = 'mensual' AND month IS NOT NULL AND YEAR IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('month', CAST("Entrada" AS date)) AS date) AS "Mes"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('month', CAST("Entrada" AS date)) = DATE_TRUNC('month', CAST("Salida" AS date))
                AND EXTRACT(MONTH FROM "Entrada") = month
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('month', CAST("Entrada" AS date)) AS date)
            ORDER BY "Mes";
    ELSIF modalidad = 'mensual' AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('month', CAST("Entrada" AS date)) AS date) AS "Mes"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('month', CAST("Entrada" AS date)) = DATE_TRUNC('month', CAST("Salida" AS date))
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('month', CAST("Entrada" AS date)) AS date)
            ORDER BY "Mes";
    ELSIF modalidad = 'mensual' THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('month', CAST("Entrada" AS date)) AS date) AS "Mes"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('month', CAST("Entrada" AS date)) = DATE_TRUNC('month', CAST("Salida" AS date))
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('month', CAST("Entrada" AS date)) AS date)
            ORDER BY "Mes";
    ELSIF modalidad = 'anual' AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('year', CAST("Entrada" AS date)) AS date) AS "Año"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('year', CAST("Entrada" AS date)) = DATE_TRUNC('year', CAST("Salida" AS date))
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('year', CAST("Entrada" AS date)) AS date)
            ORDER BY "Año";
    ELSIF modalidad = 'anual' THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('year', CAST("Entrada" AS date)) AS date) AS "Año"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('year', CAST("Entrada" AS date)) = DATE_TRUNC('year', CAST("Salida" AS date))
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('year', CAST("Entrada" AS date)) AS date)
            ORDER BY "Año";
    ELSIF modalidad = 'trimestral' AND trimonth IS NOT NULL AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('quarter', CAST("Entrada" AS date)) AS date) as "Trimestre"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('quarter', CAST("Entrada" AS date)) = DATE_TRUNC('quarter', CAST("Salida" AS date))
                AND EXTRACT(QUARTER FROM "Entrada") = trimonth
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('quarter', CAST("Entrada" AS date)) AS date)
            ORDER BY "Trimestre";
    ELSIF modalidad = 'trimestral' AND year IS NOT NULL THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('quarter', CAST("Entrada" AS date)) AS date) as "Trimestre"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('quarter', CAST("Entrada" AS date)) = DATE_TRUNC('quarter', CAST("Salida" AS date))
                AND EXTRACT(YEAR FROM "Entrada") = year
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('quarter', CAST("Entrada" AS date)) AS date)
            ORDER BY "Trimestre";
    ELSIF modalidad = 'trimestral' THEN
        RETURN QUERY
            SELECT "Numero Empleado", "Cedula", SUM(EXTRACT(EPOCH FROM ("Salida" - "Entrada"))) / 3600 AS horas_trabajadas, CAST(DATE_TRUNC('quarter', CAST("Entrada" AS date)) AS date) as "Trimestre"
            FROM horas_trabajo_view
            WHERE DATE_TRUNC('quarter', CAST("Entrada" AS date)) = DATE_TRUNC('quarter', CAST("Salida" AS date))
            GROUP BY "Numero Empleado", "Cedula", CAST(DATE_TRUNC('quarter', CAST("Entrada" AS date)) AS date)
            ORDER BY "Trimestre";
    END IF;
END;
$$;
