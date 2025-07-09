DROP VIEW IF EXISTS tipo_cliente_view CASCADE;

DROP VIEW IF EXISTS horas_trabajo_view CASCADE;

DROP VIEW IF EXISTS productos_generan_repo_view CASCADE;

DROP VIEW IF EXISTS rentabilidad_tipo_view CASCADE;

DROP VIEW IF EXISTS rentabilidad_tipo_total_view CASCADE;

DROP VIEW IF EXISTS proporcion_tarjetas_view CASCADE;

DROP FUNCTION IF EXISTS periodo_tipo_cliente CASCADE;

DROP FUNCTION IF EXISTS consolidar_horas CASCADE;

-- DROP Telefonos, Correos
DROP TABLE IF EXISTS Telefono CASCADE;

DROP TABLE IF EXISTS Correo CASCADE;

-- DROP Caracteristicas de la cerveza
DROP TABLE IF EXISTS RECE_INGR CASCADE;

DROP TABLE IF EXISTS CERV_CARA CASCADE;

DROP TABLE IF EXISTS TIPO_CARA CASCADE;

DROP TABLE IF EXISTS Caracteristica CASCADE;

DROP TABLE IF EXISTS Ingrediente CASCADE;

DROP TABLE IF EXISTS Instruccion CASCADE;

-- DROP Usuarios
DROP TABLE IF EXISTS Usuario CASCADE;

DROP TABLE IF EXISTS PRIV_ROL CASCADE;

DROP TABLE IF EXISTS Rol CASCADE;

DROP TABLE IF EXISTS Privilegio CASCADE;

-- Drop Empleados
DROP TABLE IF EXISTS Asistencia CASCADE;

DROP TABLE IF EXISTS Vacacion CASCADE;

DROP TABLE IF EXISTS EMPL_BENE CASCADE;

DROP TABLE IF EXISTS Beneficio CASCADE;

DROP TABLE IF EXISTS EMPL_HORA CASCADE;

DROP TABLE IF EXISTS Horario CASCADE;

DROP TABLE IF EXISTS EMPL_CARG CASCADE;

DROP TABLE IF EXISTS Cargo CASCADE;

DROP TABLE IF EXISTS Departamento CASCADE;

DROP TABLE IF EXISTS Empleado CASCADE;

-- DROP Estado
DROP TABLE IF EXISTS ESTA_EVEN CASCADE;

DROP TABLE IF EXISTS ESTA_COMP CASCADE;

DROP TABLE IF EXISTS ESTA_VENT CASCADE;

DROP TABLE IF EXISTS Estatus CASCADE;

-- DROP Ventas
DROP TABLE IF EXISTS PUNT_CLIE CASCADE;

DROP TABLE IF EXISTS Pago CASCADE;

DROP TABLE IF EXISTS Detalle_Venta CASCADE;

DROP TABLE IF EXISTS Venta CASCADE;

DROP TABLE IF EXISTS Tasa CASCADE;

DROP TABLE IF EXISTS Cuota CASCADE;

-- DROP Compras
DROP TABLE IF EXISTS Detalle_Compra CASCADE;

DROP TABLE IF EXISTS Compra CASCADE;

-- DROP Inventarios - Tiendas - Eventos
DROP TABLE IF EXISTS Inventario_Tienda CASCADE;

DROP TABLE IF EXISTS Inventario_Evento CASCADE;

DROP TABLE IF EXISTS Tienda CASCADE;

DROP TABLE IF EXISTS Lugar_Tienda CASCADE;

DROP TABLE IF EXISTS Registro_Evento CASCADE;

DROP TABLE IF EXISTS Evento CASCADE;

DROP TABLE IF EXISTS Tipo_Evento CASCADE;

DROP TABLE IF EXISTS Juez CASCADE;

-- DROP Cervezas
DROP TABLE IF EXISTS DESC_CERV CASCADE;

DROP TABLE IF EXISTS Descuento CASCADE;

DROP TABLE IF EXISTS CERV_PRES CASCADE;

DROP TABLE IF EXISTS Presentacion CASCADE;

DROP TABLE IF EXISTS Cerveza CASCADE;

DROP TABLE IF EXISTS Tipo_Cerveza CASCADE;

DROP TABLE IF EXISTS Receta CASCADE;

-- DROP Metodos de Pago
DROP TABLE IF EXISTS Efectivo CASCADE;

DROP TABLE IF EXISTS Punto_Canjeo CASCADE;

DROP TABLE IF EXISTS Tarjeta CASCADE;

DROP TABLE IF EXISTS Cheque CASCADE;

DROP TABLE IF EXISTS Banco CASCADE;

DROP TABLE IF EXISTS Metodo_Pago CASCADE;

-- Drop Clientes
DROP TABLE IF EXISTS Cliente CASCADE;

-- Drop Miembros
DROP TABLE IF EXISTS Contacto CASCADE;

DROP TABLE IF EXISTS Miembro CASCADE;

-- DROP Lugar
DROP TABLE IF EXISTS Lugar CASCADE;

-- Drop Detalle_Entrada
DROP TABLE IF EXISTS Detalle_Entrada CASCADE;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
    SELECT
        usename
    FROM
        pg_user
    WHERE
        usename <> 'postgres' LOOP
            EXECUTE 'DROP USER ' || quote_ident(r.usename) || ';';
        END LOOP;
END
$$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
    SELECT
        rolname
    FROM
        pg_roles
    WHERE
        rolname NOT IN ('postgres', 'pg_create_subscription', 'pg_maintain', 'pg_use_reserved_connections', 'pg_checkpoint', 'pg_read_server_files', 'pg_write_server_files', 'pg_write_server_files', 'pg_database_owner', 'pg_read_all_settings', 'pg_stat_scan_tables', 'pg_read_all_data', 'pg_write_all_data', 'pg_execute_server_program', 'pg_monitor', 'pg_signal_backend', 'pg_read_all_stats', 'pg_write_all_stats')
        LOOP
            EXECUTE 'REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ' || quote_ident(r.rolname);
            EXECUTE 'DROP ROLE ' || quote_ident(r.rolname);
        END LOOP;
END
$$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE p.prokind = 'p'
        AND n.nspname = 'public'
    LOOP
        EXECUTE format(
            'DROP PROCEDURE IF EXISTS "%I"."%I"(%s);',
            r.nspname, r.proname, r.args
        );
    END LOOP;
END
$$;