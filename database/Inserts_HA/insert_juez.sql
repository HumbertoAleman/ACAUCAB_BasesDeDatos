CREATE OR REPLACE PROCEDURE register_juez_for_event ()
    AS $$
DECLARE
    x int;
    ev record;
BEGIN
    SELECT
        *
    FROM
        Evento
    ORDER BY
        cod_even ASC
    LIMIT 1 INTO ev;
    FOR x IN (
        SELECT
            cod_juez
        FROM
            Juez)
        LOOP
            INSERT INTO Registro_Evento (fk_even, fk_juez, fecha_hora_regi_even)
                VALUES (ev.cod_even, x, ev.fecha_hora_ini_even);
        END LOOP;
END
$$
LANGUAGE plpgsql;

-- Generated Using https://mockaroo.com/
INSERT INTO Juez (primar_nom_juez, segundo_nom_juez, primar_ape_juez, segundo_ape_juez, ci_juez)
    VALUES ('Dot', 'Bay', 'Linton', 'Dossit', '0785098'),
    ('Patton', 'Grayce', 'Bartlosz', 'Roston', '7272681'),
    ('Quincy', 'Renee', 'Krzysztofiak', 'Pietz', '8088538'),
    ('Janeva', 'Tera', 'Belz', 'Amis', '5472356'),
    ('Valle', 'Valle', 'Trevarthen', 'Jadczak', '6944297'),
    ('Ephrem', 'Sybilla', 'O''Cannovane', 'Indgs', '4532104'),
    ('Albertina', 'Ermentrude', 'Linnell', 'Fraczek', '3006741'),
    ('Georgine', 'Haskel', 'Reeks', 'Regi', '9667987'),
    ('Nora', 'Gayla', 'Ensten', 'Jeandeau', '0912550'),
    ('Marwin', 'Llywellyn', 'Fairney', 'Brain', '0908301');

CALL register_juez_for_event ();
