-- Obtener Banco cualquiera
CREATE OR REPLACE PROCEDURE get_banco_random (out id_banco)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_banc INTO id_banco FROM Banco ORDER BY RANDOM() LIMIT 1;
END;
$$

-- Obtener Banco por nombre
CREATE OR REPLACE PROCEDURE get_banco (out id_banco, nombre varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_banc INTO id_banco FROM Banco WHERE nombre_banc = nombre;
END;
$$

-- -----------------------------------------------------

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
    INSERT INTO Tarjeta (fk_meto_pago, numero_tarj, fecha_venci_tarj, cvv_tarj, nombre_titu_tarj, credito)
    VALUES (fk_metodo, numero, fecha_venci, cvv, nombre_titu, credito);
END;
$$

-- Agregar Punto_Canjeo
CREATE OR REPLACE PROCEDURE add_punto_canjeo ()
LANGUAGE plpgsql
AS $$
DECLARE
    fk_metodo integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Punto_Canjeo (fk_meto_pago)
    VALUES (fk_metodo);
END;
$$

-- Agregar Cheque
-- Con banco random
CREATE OR REPLACE PROCEDURE add_cheque (numero integer, numero_cuenta integer)
LANGUAGE plpgsql
AS $$
DECLARE
    fk_metodo integer;
    fk_banco integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    CALL get_banco_random (fk_banco);
    INSERT INTO Cheque (fk_meto_pago, numero_cheque, numero_cuenta_cheque, fk_banc)
    VALUES (fk_metodo, numero, numero_cuenta, fk_banco);
END;
$$

-- Banco específico
CREATE OR REPLACE PROCEDURE add_cheque (numero integer, numero_cuenta integer, nombre_banco varchar(40))
LANGUAGE plpgsql
AS $$
DECLARE
    fk_metodo integer;
    fk_banco integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    CALL get_banco (fk_banco, nombre_banco);
    INSERT INTO Cheque (fk_meto_pago, numero_cheque, numero_cuenta_cheque, fk_banc)
    VALUES (fk_metodo, numero, numero_cuenta, fk_banco);
END;
$$

-- Agregar Efectivo
CREATE OR REPLACE PROCEDURE add_efectivo (denominacion char)
LANGUAGE plpgsql
AS $$
DECLARE
    fk_metodo integer;
BEGIN
    CALL add_metodo_pago (fk_metodo);
    INSERT INTO Efectivo (fk_meto_pago, denominacion_efec)
    VALUES (fk_metodo, denominacion);
END;
$$