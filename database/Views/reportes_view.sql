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

CREATE OR REPLACE VIEW ventas_totales_view AS
    SELECT fecha_vent "Fecha de Venta", CAST(Venta.online AS int) "Tipo de Tienda", COUNT (*) "Cantidad por Tienda", SUM (total_vent) "Total de Ventas"
    FROM Venta
    GROUP BY Venta.online, fecha_vent
    ORDER BY fecha_vent;

CREATE OR REPLACE VIEW obtener_ventas_view AS
    SELECT fecha_vent "Fecha de Venta", SUM (total_vent) "Total de Ventas"
    FROM Venta
    GROUP BY fecha_vent
    ORDER BY fecha_vent;

-- Procedimientos

CREATE OR REPLACE FUNCTION periodo_ventas_totales(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Tienda" varchar, "Total Ventas" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
      CASE WHEN v.online THEN 'Online' ELSE t.nombre_tien END AS "Tienda",
      SUM(v.total_vent) AS "Total Ventas"
    FROM Venta v
    LEFT JOIN Tienda t ON v.fk_tien = t.cod_tien
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY "Tienda";
END;
$$;

CREATE OR REPLACE FUNCTION crecimiento_ventas(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Periodo" text, "Diferencia" numeric, "Conclusión" text)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT (fecha_inicio::text || ' a ' || fecha_fin::text) AS "Periodo",
           SUM("Total de Ventas") AS "Diferencia",
           CASE WHEN SUM("Total de Ventas") > 0 THEN 'Crecimiento' ELSE 'Decrecimiento' END AS "Conclusión"
    FROM obtener_ventas_view
    WHERE "Fecha de Venta" BETWEEN fecha_inicio AND fecha_fin;
END;
$$;

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

-- =============================
-- INDICADORES Y REPORTES FALTANTES
-- =============================

-- 1. Ticket Promedio (VMP)
CREATE OR REPLACE VIEW ticket_promedio_view AS
SELECT fecha_vent "Fecha de Venta", 
    COALESCE(SUM(total_vent) / NULLIF(COUNT(*),0),0) AS "Ticket Promedio"
FROM Venta
GROUP BY fecha_vent;

-- 2. Volumen de Unidades Vendidas
CREATE OR REPLACE VIEW volumen_unidades_vendidas_view AS
SELECT v.fecha_vent "Fecha de Venta", SUM(dv.cant_deta_vent) AS "Total Unidades Vendidas"
FROM Detalle_Venta dv
JOIN Venta v ON dv.fk_vent = v.cod_vent
GROUP BY v.fecha_vent;

-- 3. Clientes Nuevos vs. Recurrentes
CREATE OR REPLACE VIEW clientes_nuevos_recurrentes_view AS
SELECT c.rif_clie, 
        MIN(v.fecha_vent) AS "Primera Compra", 
        COUNT(v.cod_vent) AS "Total Compras",
        CASE WHEN COUNT(v.cod_vent) = 1 THEN 'Nuevo' ELSE 'Recurrente' END AS "Tipo Cliente"
FROM Cliente c
JOIN Venta v ON c.rif_clie = v.fk_clie
GROUP BY c.rif_clie;

-- 4. Tasa de Retención de Clientes
CREATE OR REPLACE VIEW tasa_retencion_clientes_view AS
SELECT 
  COUNT(DISTINCT CASE WHEN sub."Total Compras" > 1 THEN sub.rif_clie END) * 100.0 / NULLIF(COUNT(DISTINCT sub.rif_clie),0) AS "Tasa Retencion (%)"
FROM (
    SELECT c.rif_clie, COUNT(v.cod_vent) AS "Total Compras"
    FROM Cliente c
    JOIN Venta v ON c.rif_clie = v.fk_clie
    GROUP BY c.rif_clie
) sub;

-- 5. Rotación de Inventario (simple)
CREATE OR REPLACE VIEW rotacion_inventario_view AS
SELECT 
    SUM(dv.cant_deta_vent) / NULLIF(AVG(it.cant_pres),0) AS "Rotacion Inventario"
FROM Detalle_Venta dv
JOIN Inventario_Tienda it ON dv.fk_inve_tien_1 = it.fk_cerv_pres_1 AND dv.fk_inve_tien_2 = it.fk_cerv_pres_2;

-- 6. Tasa de Ruptura de Stock
CREATE OR REPLACE VIEW tasa_ruptura_stock_view AS
SELECT COUNT(*) AS "Rupturas de Stock"
FROM Inventario_Tienda
WHERE cant_pres = 0;

-- -- 7. Ventas por Empleado FALTA MODIFICAR A NIVEL DE DDL PARA AGREGAR EL NUMERO DE EMPLEADO
-- CREATE OR REPLACE VIEW ventas_por_empleado_view AS
-- SELECT v.fk_empl AS "Empleado", COUNT(*) AS "Ventas Realizadas", SUM(v.total_vent) AS "Total Ventas"
-- FROM Venta v
-- GROUP BY v.fk_empl;

-- 8. Productos con Mejor Rendimiento
CREATE OR REPLACE VIEW productos_mejor_rendimiento_view AS
SELECT dv.fk_inve_tien_1 AS "Producto 1", dv.fk_inve_tien_2 AS "Producto 2", SUM(dv.cant_deta_vent) AS "Total Vendido"
FROM Detalle_Venta dv
GROUP BY dv.fk_inve_tien_1, dv.fk_inve_tien_2
ORDER BY "Total Vendido" DESC
LIMIT 10;

-- 9. Reporte de Inventario Actual
CREATE OR REPLACE VIEW inventario_actual_view AS
SELECT * FROM Inventario_Tienda;

-- FUNCIONES PARA DASHBOARD INTERACTIVO (NO MODIFICAR VISTAS EXISTENTES)

-- Ticket Promedio (por periodo)
CREATE OR REPLACE FUNCTION ticket_promedio_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Periodo" varchar, "Ticket Promedio" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT TO_CHAR(fecha_vent, 'YYYY-MM-DD')::varchar as "Periodo", AVG(total_vent) as "Ticket Promedio"
    FROM Venta
    WHERE fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY TO_CHAR(fecha_vent, 'YYYY-MM-DD');
END;
$$;

-- Volumen de Unidades Vendidas (por periodo)
CREATE OR REPLACE FUNCTION volumen_unidades_vendidas_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Periodo" varchar, "Unidades Vendidas" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT TO_CHAR(v.fecha_vent, 'YYYY-MM-DD')::varchar as "Periodo", SUM(dv.cant_deta_vent) as "Unidades Vendidas"
    FROM Venta v
    JOIN Detalle_Venta dv ON v.cod_vent = dv.fk_vent
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY TO_CHAR(v.fecha_vent, 'YYYY-MM-DD');
END;
$$;

-- Ventas por Estilo de Cerveza (por periodo)
CREATE OR REPLACE FUNCTION ventas_por_estilo_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Estilo" varchar, "Unidades Vendidas" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT tc.nombre_tipo_cerv::varchar as "Estilo", SUM(dv.cant_deta_vent) as "Unidades Vendidas"
    FROM Venta v
    JOIN Detalle_Venta dv ON v.cod_vent = dv.fk_vent
    JOIN Inventario_Tienda it ON dv.fk_inve_tien_1 = it.fk_cerv_pres_1 AND dv.fk_inve_tien_2 = it.fk_cerv_pres_2
    JOIN Cerveza c ON it.fk_cerv_pres_1 = c.cod_cerv
    JOIN Tipo_Cerveza tc ON c.fk_tipo_cerv = tc.cod_tipo_cerv
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY tc.nombre_tipo_cerv;
END;
$$;

-- Clientes Nuevos vs Recurrentes (por periodo)
CREATE OR REPLACE FUNCTION clientes_nuevos_vs_recurrentes(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Tipo Cliente" varchar, "Cantidad" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT tipo_cliente::varchar as "Tipo Cliente", COUNT(*) as "Cantidad"
    FROM (
        SELECT CASE WHEN COUNT(v.cod_vent) = 1 THEN 'Nuevo' ELSE 'Recurrente' END as tipo_cliente, v.fk_clie
        FROM Venta v
        WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
        GROUP BY v.fk_clie
    ) sub
    GROUP BY tipo_cliente;
END;
$$;

-- Tasa de Retención de Clientes (por periodo)
CREATE OR REPLACE FUNCTION tasa_retencion_clientes(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Tasa Retención" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT (COUNT(DISTINCT v.fk_clie)::numeric / NULLIF((SELECT COUNT(*) FROM Cliente),0)) as "Tasa Retención"
    FROM Venta v
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin;
END;
$$;

-- Rotación de Inventario (por periodo)
CREATE OR REPLACE FUNCTION rotacion_inventario_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Periodo" varchar, "Rotación" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT TO_CHAR(v.fecha_vent, 'YYYY-MM-DD')::varchar as "Periodo", 
           SUM(dv.cant_deta_vent) / NULLIF(AVG(it.cant_pres),0) as "Rotación"
    FROM Venta v
    JOIN Detalle_Venta dv ON v.cod_vent = dv.fk_vent
    JOIN Inventario_Tienda it ON dv.fk_inve_tien_1 = it.fk_cerv_pres_1 AND dv.fk_inve_tien_2 = it.fk_cerv_pres_2
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY TO_CHAR(v.fecha_vent, 'YYYY-MM-DD');
END;
$$;

-- Tasa de Ruptura de Stock (por periodo)
CREATE OR REPLACE FUNCTION tasa_ruptura_stock_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Periodo" varchar, "Ruptura Stock" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT TO_CHAR(v.fecha_vent, 'YYYY-MM-DD')::varchar as "Periodo", 
           SUM(CASE WHEN it.cant_pres = 0 THEN 1 ELSE 0 END)::numeric as "Ruptura Stock"
    FROM Venta v
    JOIN Detalle_Venta dv ON v.cod_vent = dv.fk_vent
    JOIN Inventario_Tienda it ON dv.fk_inve_tien_1 = it.fk_cerv_pres_1 AND dv.fk_inve_tien_2 = it.fk_cerv_pres_2
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY TO_CHAR(v.fecha_vent, 'YYYY-MM-DD');
END;
$$;

-- Ventas por Empleado (por periodo)
CREATE OR REPLACE FUNCTION ventas_por_empleado_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Empleado" varchar, "Cantidad Ventas" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT (e.primer_nom_empl || ' ' || e.primer_ape_empl)::varchar as "Empleado", COUNT(v.cod_vent) as "Cantidad Ventas"
    FROM Venta v
    JOIN Empleado e ON v.fk_empl = e.cod_empl
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY e.primer_nom_empl, e.primer_ape_empl;
END;
$$;

-- Gráfico de Tendencia de Ventas (por periodo)
CREATE OR REPLACE FUNCTION tendencia_ventas_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Periodo" varchar, "Total Ventas" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT TO_CHAR(fecha_vent, 'YYYY-MM-DD')::varchar as "Periodo", SUM(total_vent) as "Total Ventas"
    FROM Venta
    WHERE fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY TO_CHAR(fecha_vent, 'YYYY-MM-DD');
END;
$$;

-- Gráfico de Ventas por Canal (por periodo)
CREATE OR REPLACE FUNCTION ventas_por_canal_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Canal" varchar, "Total Ventas" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT (CASE WHEN online THEN 'Online' ELSE 'Física' END)::varchar as "Canal", SUM(total_vent) as "Total Ventas"
    FROM Venta
    WHERE fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY online;
END;
$$;

-- Tabla de Productos con Mejor Rendimiento (por periodo)
CREATE OR REPLACE FUNCTION productos_mejor_rendimiento_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Producto" varchar, "Unidades Vendidas" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT c.nombre_cerv::varchar as "Producto", SUM(dv.cant_deta_vent) as "Unidades Vendidas"
    FROM Venta v
    JOIN Detalle_Venta dv ON v.cod_vent = dv.fk_vent
    JOIN Inventario_Tienda it ON dv.fk_inve_tien_1 = it.fk_cerv_pres_1 AND dv.fk_inve_tien_2 = it.fk_cerv_pres_2
    JOIN Cerveza c ON it.fk_cerv_pres_1 = c.cod_cerv
    WHERE v.fecha_vent BETWEEN fecha_inicio AND fecha_fin
    GROUP BY c.nombre_cerv
    ORDER BY "Unidades Vendidas" DESC
    LIMIT 10;
END;
$$;

-- Reporte de Inventario Actual
CREATE OR REPLACE FUNCTION inventario_actual_periodo(fecha_inicio date, fecha_fin date)
RETURNS TABLE ("Producto" varchar, "Stock Actual" bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT c.nombre_cerv::varchar as "Producto", SUM(it.cant_pres) as "Stock Actual"
    FROM Inventario_Tienda it
    JOIN Cerveza c ON it.fk_cerv_pres_1 = c.cod_cerv
    WHERE it.fecha_ult_act BETWEEN fecha_inicio AND fecha_fin
    GROUP BY c.nombre_cerv;
END;
$$;

-- Vista para factura de venta de productos (física/online)
CREATE OR REPLACE VIEW factura_venta_productos_view AS
SELECT 
    v.cod_vent AS id_venta,
    v.fecha_vent AS fecha,
    v.iva_vent AS iva,
    v.base_imponible_vent AS base_imponible,
    v.total_vent AS total,
    v.online AS venta_online,
    v.fk_tien AS id_tienda,
    t.nombre_tien AS nombre_tienda,
    t.direccion_tien AS direccion_tienda,
    cl.rif_clie AS rif_cliente,
    cl.tipo_clie AS tipo_cliente,
    cl.primer_nom_natu AS nombre_cliente,
    cl.primer_ape_natu AS apellido_cliente,
    cl.razon_social_juri AS razon_social,
    cl.direccion_fiscal_clie AS direccion_fiscal,
    cr.prefijo_corr || '@' || cr.dominio_corr AS correo_cliente,
    dv.cant_deta_vent AS cantidad,
    dv.precio_unitario_vent AS precio_unitario,
    (dv.cant_deta_vent * dv.precio_unitario_vent) AS subtotal,
    c.nombre_cerv AS producto,
    p.nombre_pres AS presentacion
FROM Venta v
JOIN Detalle_Venta dv ON dv.fk_vent = v.cod_vent
JOIN CERV_PRES cp ON dv.fk_inve_tien_1 = cp.fk_cerv AND dv.fk_inve_tien_2 = cp.fk_pres
JOIN Cerveza c ON cp.fk_cerv = c.cod_cerv
JOIN Presentacion p ON cp.fk_pres = p.cod_pres
LEFT JOIN Cliente cl ON v.fk_clie = cl.rif_clie
LEFT JOIN Correo cr ON cl.rif_clie = cr.fk_clie
LEFT JOIN Tienda t ON v.fk_tien = t.cod_tien;

-- Vista para factura de venta de entradas de eventos
CREATE OR REPLACE VIEW factura_venta_entradas_view AS
SELECT 
    v.cod_vent AS id_venta,
    v.fecha_vent AS fecha,
    v.iva_vent AS iva,
    v.base_imponible_vent AS base_imponible,
    v.total_vent AS total,
    v.online AS venta_online,
    v.fk_even AS id_evento,
    e.nombre_even AS nombre_evento,
    e.direccion_even AS direccion_evento,
    cl.rif_clie AS rif_cliente,
    cl.tipo_clie AS tipo_cliente,
    cl.primer_nom_natu AS nombre_cliente,
    cl.primer_ape_natu AS apellido_cliente,
    cl.razon_social_juri AS razon_social,
    cl.direccion_fiscal_clie AS direccion_fiscal,
    cr.prefijo_corr || '@' || cr.dominio_corr AS correo_cliente,
    de.cant_deta_entr AS cantidad,
    de.precio_unitario_entr AS precio_unitario,
    (de.cant_deta_entr * de.precio_unitario_entr) AS subtotal
FROM Venta v
JOIN Detalle_Entrada de ON de.fk_vent = v.cod_vent
JOIN Evento e ON v.fk_even = e.cod_even
LEFT JOIN Cliente cl ON v.fk_clie = cl.rif_clie
LEFT JOIN Correo cr ON cl.rif_clie = cr.fk_clie;

-- Fin vistas de factura