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

CREATE OR REPLACE FUNCTION periodo_ventas_totales (year int, month int, trimonth int, modalidad text)
RETURNS TABLE ("Tipo" int, "Cantidad Ventas" bigint, "Total Ventas" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    IF modalidad = 'mensual' THEN
        RETURN QUERY
        SELECT CAST("Tipo de Tienda" AS int) "Tipo de Tienda", COUNT (*) "Cantidad por Tienda", SUM ("Total de Ventas") "Total de Ventas"
        FROM ventas_totales_view
        WHERE EXTRACT(MONTH FROM "Fecha de Venta") = month
            AND EXTRACT(YEAR FROM "Fecha de Venta") = year
        GROUP BY  "Tipo de Tienda";

    ELSIF modalidad = 'trimestral' THEN
        RETURN QUERY
        SELECT CAST("Tipo de Tienda" AS int) "Tipo de Tienda", COUNT (*) "Cantidad por Tienda", SUM ("Total de Ventas") "Total de Ventas"
        FROM ventas_totales_view
        WHERE EXTRACT(QUARTER FROM "Fecha de Venta") = trimonth
            AND EXTRACT(YEAR FROM "Fecha de Venta") = year
        GROUP BY  "Tipo de Tienda";

    ELSIF modalidad = 'anual' THEN
        RETURN QUERY
        SELECT CAST("Tipo de Tienda" AS int) "Tipo de Tienda", COUNT (*) "Cantidad por Tienda", SUM ("Total de Ventas") "Total de Ventas"
        FROM ventas_totales_view
        WHERE EXTRACT(YEAR FROM "Fecha de Venta") = year
        GROUP BY  "Tipo de Tienda";

    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION crecimiento_ventas (ini varchar(10), fin varchar(10), modalidad text)
RETURNS TABLE ("Rango de Fechas" text, "Diferencia" numeric, "Conclusión" text)
LANGUAGE plpgsql
AS $$
BEGIN
    IF modalidad = 'semanal' THEN
        RETURN QUERY
        SELECT (CAST(DATE_TRUNC('week', CAST(ini AS date)) AS date) || ' vs ' || CAST ( DATE_TRUNC('week', CAST(fin AS date)) AS date)) AS "Rango de Fechas", ov2."Total OV2" - ov1."Total OV1" AS "Diferencia", CASE WHEN ov2."Total OV2" - ov1."Total OV1" > 0 THEN 'Crecimiento' ELSE 'Decrecimiento' END AS "Conclusión"
        FROM (SELECT SUM("Total de Ventas") AS "Total OV1" FROM obtener_ventas_view WHERE DATE_TRUNC('week', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('week', CAST(ini AS date))) AS ov1, 
            (SELECT SUM("Total de Ventas")  AS "Total OV2" FROM obtener_ventas_view WHERE DATE_TRUNC('week', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('week', CAST(fin AS date))) AS ov2;
    ELSIF modalidad = 'mensual' THEN
        RETURN QUERY
        SELECT (CAST(DATE_TRUNC('month', CAST(ini AS date)) AS date) || ' vs ' || CAST ( DATE_TRUNC('month', CAST(fin AS date)) AS date)) AS "Rango de Fechas", ov2."Total OV2" - ov1."Total OV1" AS "Diferencia", CASE WHEN ov2."Total OV2" - ov1."Total OV1" > 0 THEN 'Crecimiento' ELSE 'Decrecimiento' END AS "Conclusión"
        FROM (SELECT SUM("Total de Ventas") AS "Total OV1" FROM obtener_ventas_view WHERE DATE_TRUNC('month', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('month', CAST(ini AS date))) AS ov1, 
            (SELECT SUM("Total de Ventas")  AS "Total OV2" FROM obtener_ventas_view WHERE DATE_TRUNC('month', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('month', CAST(fin AS date))) AS ov2;
    ELSIF modalidad = 'trimestral' THEN
        RETURN QUERY
        SELECT (CAST(DATE_TRUNC('quarter', CAST(ini AS date)) AS date) || ' vs ' || CAST ( DATE_TRUNC('quarter', CAST(fin AS date)) AS date)) AS "Rango de Fechas", ov2."Total OV2" - ov1."Total OV1" AS "Diferencia", CASE WHEN ov2."Total OV2" - ov1."Total OV1" > 0 THEN 'Crecimiento' ELSE 'Decrecimiento' END AS "Conclusión"
        FROM (SELECT SUM("Total de Ventas") AS "Total OV1" FROM obtener_ventas_view WHERE DATE_TRUNC('quarter', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('quarter', CAST(ini AS date))) AS ov1, 
            (SELECT SUM("Total de Ventas")  AS "Total OV2" FROM obtener_ventas_view WHERE DATE_TRUNC('quarter', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('quarter', CAST(fin AS date))) AS ov2;
    ELSIF modalidad = 'anual' THEN
        RETURN QUERY
        SELECT (CAST(DATE_TRUNC('year', CAST(ini AS date)) AS date) || ' vs ' || CAST ( DATE_TRUNC('year', CAST(fin AS date)) AS date)) AS "Rango de Fechas", ov2."Total OV2" - ov1."Total OV1" AS "Diferencia", CASE WHEN ov2."Total OV2" - ov1."Total OV1" > 0 THEN 'Crecimiento' ELSE 'Decrecimiento' END AS "Conclusión"
        FROM (SELECT SUM("Total de Ventas") AS "Total OV1" FROM obtener_ventas_view WHERE DATE_TRUNC('year', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('year', CAST(ini AS date))) AS ov1, 
            (SELECT SUM("Total de Ventas")  AS "Total OV2" FROM obtener_ventas_view WHERE DATE_TRUNC('year', CAST("Fecha de Venta" AS date)) = DATE_TRUNC('year', CAST(fin AS date))) AS ov2;
    END IF;
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