CREATE OR REPLACE PROCEDURE insert_contacto_random (text, text, text, text)
    AS $$
DECLARE
    x text;
BEGIN
    SELECT
        rif_miem INTO x
    FROM
        Miembro
    ORDER BY
        RANDOM()
    LIMIT 1;
    INSERT INTO Contacto (primer_nom_pers, segundo_nom_pers, primer_ape_pers, segundo_ape_pers, fk_miem)
        VALUES ($1, $2, $3, $4, x);
END;
$$
LANGUAGE plpgsql;

--AGREGAR FUNCIÓN QUE GENERE UN REGISTRO DE UN TELÉFONO AL INSERTAR UN NUEVO REGISTRO EN LA TABLA

CALL insert_contacto_random ('Salmon', 'Ruby', 'Flowerden', 'Aizkovitch');

CALL insert_contacto_random ('Elvina', 'Harlen', 'Crack', 'Hurlestone');

CALL insert_contacto_random ('Hinze', 'Minetta', 'Antonelli', 'Winfrey');

CALL insert_contacto_random ('Sibbie', 'Ettore', 'Cogan', 'Philson');

CALL insert_contacto_random ('Gene', 'Alexandra', 'Snedden', 'Blankman');

CALL insert_contacto_random ('Annmaria', 'Berti', 'Greggs', 'Fawdrie');

CALL insert_contacto_random ('Gertrude', 'Nan', 'Loutheane', 'Drezzer');

CALL insert_contacto_random ('Casey', 'Aldus', 'Semerad', 'Kench');

CALL insert_contacto_random ('Alina', 'Ezra', 'Canham', 'Cole');

CALL insert_contacto_random ('Oralie', 'Jaimie', 'Longstreeth', 'Eldered');
