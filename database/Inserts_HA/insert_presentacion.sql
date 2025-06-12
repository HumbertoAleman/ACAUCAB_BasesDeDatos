-- 1. Loops through every beer in the database
-- 2. Loops through every presentation available
-- 3. Selects a random member
-- 4. Assigns all of the presentations to that member
CREATE OR REPLACE PROCEDURE pres_to_cerv_all ()
LANGUAGE plpgsql
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
                    SELECT rif_miem INTO rif FROM Miembro ORDER BY RANDOM() LIMIT 1;
                    INSERT INTO CERV_PRES (fk_cerv, fk_pres, fk_miem, precio_pres_cerv)
                        VALUES (x, y, rif, 9.99);
                END LOOP;
        END LOOP;
END
$$;

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Botella Estandar', 330);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Botella Extra-Grande', 1000);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Botella Grande', 500);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Botella Pequeña', 250);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Lata Estandar', 330);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Lata Extra-Grande', 1000);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Lata Grande', 500);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Lata Pequeña', 250);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Pinta Americana', 473);

INSERT INTO Presentacion (nombre_pres, capacidad_pres)
    VALUES ('Pinta Inglesa', 568);

CALL pres_to_cerv_all();
