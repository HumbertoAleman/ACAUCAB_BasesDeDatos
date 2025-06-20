INSERT INTO Estatus (nombre_esta, descripcion_esta)
    VALUES
        -- Estatus de Compras
        ('Por aprobar', 'El jefe del departamento de compras aún no ha aceptado la solicitud de reposición'),
        ('Por pagar', 'El jefe del departamento de compras aun no ha realizado el pago de compra a proveedor'),
        ('Cancelado', 'El jefe de del departamento de compras ha cancelado la orden de reposición'),
        ('Compra Pagada', 'El jefe de del departamento de compras ha cancelado la orden de reposición'),
        -- Estatus de Ventas
        ('Pagado', 'La entrega u presupuesto ha sido pagada'),
        ('En Camino', 'La entrega esta en camino a su destino'),
        ('Entregado', 'La venta ha concluido'),
        -- Estatus de Eventos
        ('Pendiente', 'El evento ha sido formalizado pero aún no ha iniciado'),
        ('En curso', 'El evento esta ocurriendo en estos instantes'),
        ('Cancelado', 'El evento ha sido cancelado'),
        ('Finalizado', 'El evento ha finalizado');
