CREATE OR REPLACE add_tlf (cod_area integer, numero integer, cliente varchar(20), contacto integer, miembro varchar(20))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Telefono (cod_area-tele, num_tele, fk_clie, fk_pers, fk_miem)
    VALUES (cod_area, numero, cliente, contacto, miembro);
END
$$

CALL add_tlf(0412, 9876543, NULL, SELECT cod_pers FROM Contacto ORDER BY RANDOM() LIMIT 1, NULL);
CALL add_tlf(0414, 1234567, SELECT rif_clie FROM Cliente ORDER BY RANDOM() LIMIT 1, NULL, NULL);
CALL add_tlf(0424, 7654321, NULL, NULL, SELECT rif_miem FROM Miembro ORDER BY RANDOM() LIMIT 1);
CALL add_tlf(0416, 2345678, NULL, SELECT cod_pers FROM Contacto ORDER BY RANDOM() LIMIT 1, NULL);
CALL add_tlf(0426, 8765432, SELECT rif_clie FROM Cliente ORDER BY RANDOM() LIMIT 1, NULL, NULL);
CALL add_tlf(0412, 3456789, NULL, NULL, SELECT rif_miem FROM Miembro ORDER BY RANDOM() LIMIT 1);
CALL add_tlf(0414, 4567890, SELECT rif_clie FROM Cliente ORDER BY RANDOM() LIMIT 1, NULL, NULL);
CALL add_tlf(0424, 5678901, NULL, SELECT cod_pers FROM Contacto ORDER BY RANDOM() LIMIT 1, NULL);
CALL add_tlf(0416, 6789012, NULL, NULL, SELECT rif_miem FROM Miembro ORDER BY RANDOM() LIMIT 1);
CALL add_tlf(0426, 7890123, SELECT rif_clie FROM Cliente ORDER BY RANDOM() LIMIT 1, NULL, NULL);