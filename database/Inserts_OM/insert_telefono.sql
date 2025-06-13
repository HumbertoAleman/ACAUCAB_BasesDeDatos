CREATE OR REPLACE PROCEDURE add_tlf (cod_area integer, numero integer, cliente varchar(20), contacto integer, miembro varchar(20))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Telefono (cod_area-tele, num_tele, fk_clie, fk_pers, fk_miem)
    VALUES (cod_area, numero, cliente, contacto, miembro);
END;
$$

-- Obtener Cliente
CREATE OR REPLACE FUNCTION obtener_cliente ()
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN SELECT rif_clie FROM Cliente ORDER BY RANDOM() LIMIT 1;
END;
$$

-- Obtener Miembro
CREATE OR REPLACE FUNCTION obtener_miembro ()
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN SELECT rif_miem FROM Miembro ORDER BY RANDOM() LIMIT 1;
END
$$

-- Obtener Persona de Contacto
CREATE OR REPLACE FUNCTION obtener_contacto ()
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN SELECT cod_pers FROM Contacto ORDER BY RANDOM() LIMIT 1;
END;
$$

DO $$
DECLARE
    clie varchar(20);
    pers integer;
    miem varchar(20);
BEGIN
    clie := obtener_cliente();
    pers := obtener_contacto();
    miem := obtener_miembro();
    CALL add_tlf(0412, 9876543, NULL, pers, NULL);
    CALL add_tlf(0414, 1234567, clie, NULL, NULL);
    CALL add_tlf(0424, 7654321, NULL, NULL, miem);
    clie := obtener_cliente();
    pers := obtener_contacto();
    miem := obtener_miembro();
    CALL add_tlf(0416, 2345678, NULL, pers , NULL);
    CALL add_tlf(0426, 8765432, clie, NULL, NULL);
    CALL add_tlf(0412, 3456789, NULL, NULL, miem);
    clie := obtener_cliente();
    pers := obtener_contacto();
    miem := obtener_miembro();
    CALL add_tlf(0414, 4567890, clie, NULL, NULL);
    CALL add_tlf(0424, 5678901, NULL, pers, NULL);
    CALL add_tlf(0416, 6789012, NULL, NULL, miem);
    clie := obtener_cliente();
    CALL add_tlf(0426, 7890123, clie, NULL, NULL);
END;
$$;