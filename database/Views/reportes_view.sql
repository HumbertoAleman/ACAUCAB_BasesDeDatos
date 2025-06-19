CREATE OR REPLACE VIEW tipo_cliente_view AS
    SELECT tipo_clie, fecha_ingr_clie
    FROM Cliente
    GROUP BY fecha_ingr_clie, tipo_clie;