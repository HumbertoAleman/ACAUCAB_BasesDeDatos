-- Crear fila Metodo_Pago
CREATE OR REPLACE PROCEDURE add_metodo_pago (out id_metodo)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Metodo_Pago DEFAULT VALUES RETURNING cod_metodo_pago INTO id_metodo;
END;
$$

-- Agregar Tarjeta
CREATE OR REPLACE PROCEDURE add_tarjeta (numero integer, fecha_venci date, cvv integer, nombre_titu varchar(40), credito boolean)
LANGUAGE plpgsql
AS $$
DECLARE
    fk_metodo integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Tarjeta (fk_metodo_pago, numero_tarj, fecha_venci_tarj, cvv_tarj, nombre_titu_tarj, credito)
    VALUES (numero, fecha_venci, cvv, nombre_titu, credito);
END;
$$