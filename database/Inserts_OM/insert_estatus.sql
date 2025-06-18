CREATE OR REPLACE PROCEDURE add_estatus (nombre varchar(20), descripcion text)
    AS $$
BEGIN
    INSERT INTO Estatus (nombre_esta, descripcion_esta)
        VALUES (nombre, descripcion);
END
$$
LANGUAGE plpgsql;

-- Estatus de Compras
CALL add_estatus ('Por aprobar', 'El jefe del departamento de compras aún no ha aceptado la solicitud de reposición');

CALL add_estatus ('Por pagar', 'El jefe del departamento de compras aun no ha realizado el pago de compra a proveedor');

CALL add_estatus ('Cancelado', 'El jefe de del departamento de compras ha cancelado la orden de reposición');

CALL add_estatus ('Compra Pagada', 'El jefe de del departamento de compras ha cancelado la orden de reposición');

-- Estatus de Ventas
CALL add_estatus ('Pagado', 'La entrega u presupuesto ha sido pagada');

CALL add_estatus ('En Camino', 'La entrega esta en camino a su destino');

CALL add_estatus ('Entregado', 'La venta ha concluido');

-- Estatus de Eventos
CALL add_estatus ('Pendiente', 'El evento ha sido formalizado pero aún no ha iniciado');

CALL add_estatus ('En curso', 'El evento esta ocurriendo en estos instantes');

CALL add_estatus ('Cancelado', 'El evento ha sido cancelado');

CALL add_estatus ('Finalizado', 'El evento ha finalizado');
