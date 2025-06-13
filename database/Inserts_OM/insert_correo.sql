CREATE OR REPLACE PROCEDURE add_correo_random (prefijo varchar(40), dominio varchar(40), tipo integer)
LANGUAGE plpgsql
AS $$
DECLARE
    rif varchar (20);
    cod integer;
BEGIN
    CASE tipo
    WHEN 1 THEN
    BEGIN
        SELECT rif_clie INTO rif FROM Cliente ORDER BY RANDOM() LIMIT 1;
        INSERT INTO Correo (prefijo_corr, dominio_corr, fk_clie)
        VALUES (prefijo, dominio, rif);
    END;
    WHEN 2 THEN
    BEGIN
        SELECT cod_empl INTO cod FROM Empleado ORDER BY RANDOM() LIMIT 1;
        INSERT INTO Correo (prefijo_corr, dominio_corr, fk_empl)
        VALUES (prefijo, dominio, cod);
    END;
    WHEN 3 THEN
    BEGIN
        SELECT cod_pers INTO cod FROM Contacto ORDER BY RANDOM() LIMIT 1;
        INSERT INTO Correo (prefijo_corr, dominio_corr, fk_pers)
        VALUES (prefijo, dominio, cod);
    END;
    WHEN 4 THEN
    BEGIN
        SELECT rif_miem INTO rif FROM Miembro ORDER BY RANDOM() LIMIT 1;
        INSERT INTO Correo (prefijo_corr, dominio_corr, fk_miem)
        VALUES (prefijo, dominio, rif);
    END;
END;
$$

-- DE SER NECESARIO, SI BIEN ES RANDOM PODEMOS HACER UNA VALIDACIÓN PARA QUE SOLO ESCOJA A LOS QUE YA TIENEN UN NUM DE TLF

CALL add_correo_random('juan.perez', '@gmail.com', 1);
CALL add_correo_random('maria.garcia', '@hotmail.com', 2);
CALL add_correo_random('carlos.fernandez', '@yahoo.com', 3);
CALL add_correo_random('ana.lopez', '@outlook.com', 4);
CALL add_correo_random('luis.martinez', '@protonmail.com', 1);
CALL add_correo_random('sofia.gomez', '@icloud.com', 2);
CALL add_correo_random('pedro.sanchez', '@zoho.com', 3);
CALL add_correo_random('laura.ruiz', '@mail.com', 4);
CALL add_correo_random('jorge.diaz', '@gmx.com', 1);
CALL add_correo_random('valentina.torres', '@yandex.com', 2);