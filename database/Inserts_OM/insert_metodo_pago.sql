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
CREATE OR REPLACE PROCEDURE add_tarjeta (numero numeric (21,0), fecha_venci date, cvv integer, nombre_titu varchar(40), credito boolean)
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
CREATE OR REPLACE PROCEDURE add_cheque_random (numero numeric (21,0), numero_cuenta numeric(21,0))
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

-- Banco específico (Store procedure)
CREATE OR REPLACE PROCEDURE add_cheque (numero numeric (21,0), numero_cuenta numeric(21,0), nombre_banco varchar(40))
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

CALL add_tarjeta(4123456789012345, '2027-05-31', 123, 'Juan Perez', true);
CALL add_tarjeta(4169876543210987, '2026-11-15', 456, 'Maria Gomez', false);
CALL add_tarjeta(4241234567890123, '2028-03-20', 789, 'Carlos Ruiz', true);
CALL add_tarjeta(4262345678901234, '2025-07-10', 321, 'Ana Torres', false);
CALL add_tarjeta(4125678901234567, '2029-01-01', 654, 'Luis Fernandez', true);
CALL add_tarjeta(4143456789012345, '2026-09-12', 987, 'Sofia Martinez', false);
CALL add_tarjeta(4164567890123456, '2027-12-25', 159, 'Pedro Alvarez', true);
CALL add_tarjeta(4245678901234567, '2028-06-18', 753, 'Lucia Romero', false);
CALL add_tarjeta(4266789012345678, '2025-04-05', 852, 'Miguel Herrera', true);
CALL add_tarjeta(4147890123456789, '2029-08-22', 951, 'Valentina Rivas', false);