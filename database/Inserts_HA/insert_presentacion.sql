CREATE OR REPLACE PROCEDURE pres_to_cerv_all ()
    AS $$
DECLARE
    x integer;
    y integer;
    rif text;
BEGIN
    FOR x IN (
        SELECT
            cod_cerv
        FROM
            Cerveza)
        LOOP
            FOR y IN (
                SELECT
                    cod_pres
                FROM
                    Presentacion)
                LOOP
                    SELECT
                        rif_miem INTO rif
                    FROM
                        Miembro
                    ORDER BY
                        RANDOM()
                    LIMIT 1;
                    INSERT INTO CERV_PRES (fk_cerv, fk_pres, fk_miem, precio_pres_cerv)
                        VALUES (x, y, rif, 9.99);
                END LOOP;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Botella Estandar', 330),
    ('Botella Extra-Grande', 1000),
    ('Botella Grande', 500),
    ('Botella Pequeña', 250),
    ('Lata Estandar', 330),
    ('Lata Extra-Grande', 1000),
    ('Lata Grande', 500),
    ('Lata Pequeña', 250),
    ('Pinta Americana', 473),
    ('Pinta Inglesa', 568);

CALL pres_to_cerv_all ();
