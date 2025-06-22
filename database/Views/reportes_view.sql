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
    SELECT c.cod_cerv, c.nombre_cerv, cp.fk_cerv, cp.fk_pres, dc.fk_cerv_pres_1 "Cerveza DC", dc.fk_cerv_pres_2 "Presentacion DC",
        it.fk_cerv_pres_1 "Cerveza Inventario", it.fk_cerv_pres_2 "Presentación Inventario", dv.fk_inve_tien_1 "Cerveza DV", dv.fk_inve_tien_2 "Presentacion DV"
    FROM Detalle_Compra dc, Detalle_Venta dv, CERV_PRES cp, Cerveza c, Inventario_Tienda it
    WHERE c.cod_cerv = cp.fk_cerv AND cp.fk_cerv = dc.fk_cerv_pres_1 AND cp.fk_pres = dc.fk_cerv_pres_2
        AND cp.fk_cerv = it.fk_cerv_pres_1 AND cp.fk_pres = it.fk_cerv_pres_2 AND it.fk_cerv_pres_1 = dv.fk_inve_tien_1
        AND it.fk_cerv_pres_2 = dv.fk_inve_tien_2;