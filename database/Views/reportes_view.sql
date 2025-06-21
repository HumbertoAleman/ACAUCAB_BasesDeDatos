CREATE OR REPLACE VIEW tipo_cliente_view AS
    SELECT tipo_clie 'Tipo de Cliente', fecha_ingr_clie 'Fecha de ingreso'
    FROM Cliente
    Order By fecha_ingr_clie ASC;

CREATE OR REPLACE VIEW horas_trabajo_view AS
    SELECT e.cod_empl 'Numero Empleado', e.ci_empl 'Cedula'
    FROM Asistencia a, EMPL_CARG ec, Empleado e
    WHERE a.fk_empl_carg_1 = ec.fk_empl AND a.fk_empl_carg_2 = ec.fk_carg AND a.fk_empl_carg_3 = ec.cod_empl_carg
        AND ec.fk_empl = e.cod_empl;