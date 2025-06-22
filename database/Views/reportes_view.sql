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

CREATE OR REPLACE VIEW proporcion_tarjetas_view AS
    SELECT v.fecha_vent, t.nombre_titu_tarj, t.credito
    FROM Venta v, Pago p, Metodo_Pago mp, Tarjeta t
    WHERE v.cod_vent = p.fk_vent
        AND p.fk_meto_pago = mp.cod_meto_pago
        AND mp.cod_meto_pago = t.fk_meto_pago;

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