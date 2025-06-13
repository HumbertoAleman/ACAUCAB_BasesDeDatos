CREATE OR REPLACE PROCEDURE add_estatus (nombre varchar(20), descripcion text)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Estatus (nombre_esta, descripcion_esta)
    VALUES (nombre, descripcion);
END;
$$

CALL add_estatus ('Por aprobar', 'El jefe del departamento de compras aún no ha aceptado la solicitud de reposición');
CALL add_estatus ('Por pagar', NULL);
CALL add_estatus ('Cancelado', 'El jefe de del departamento de compras ha cancelado la orden de reposición');
CALL add_estatus ('Pagado', NULL);
CALL add_estatus ('Procesando', NULL);
CALL add_estatus ('Listo para entregar', NULL);
CALL add_estatus ('Entregado', NULL);
CALL add_estatus ('Pendiente', 'El evento ha sido formalizado pero aún no ha iniciado');
CALL add_estatus ('En curso', 'El evento esta ocurriendo en estos instantes');
CALL add_estatus ('Cancelado', 'El evento ha sido cancelado');
CALL add_estatus ('Finalizado', 'El evento ha finalizado');