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
    SELECT t.credito "Es de Crédito", COUNT (t.credito)
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