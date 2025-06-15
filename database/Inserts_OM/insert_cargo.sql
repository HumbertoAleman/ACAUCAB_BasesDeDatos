CREATE OR REPLACE PROCEDURE add_cargo(nombre varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Cargo (nombre_carg)
    VALUES (nombre);
END;
$$

CALL add_cargo('Administrador');
CALL add_cargo('Gerente');
CALL add_cargo('Analista');
CALL add_cargo('Jefe');
CALL add_cargo('Especialista de Marketing');
CALL add_cargo('Contador');
CALL add_cargo('Coordinador de Eventos');
CALL add_cargo('Gestor de Inventario');
CALL add_cargo('Especialista de Reportes');
CALL add_cargo('Empleado');
CALL add_cargo('Vigilante');