CREATE OR REPLACE PROCEDURE populate_events_inventories ()
    AS $$
DECLARE
    x integer;
    c_v CERV_PRES%ROWTYPE;
BEGIN
    FOR x IN (
        SELECT
            cod_even
        FROM
            Evento)
        LOOP
            FOR c_v IN (
                SELECT
                    *
                FROM
                    CERV_PRES)
                LOOP
                    INSERT INTO Inventario_Evento (fk_cerv_pres_1, fk_cerv_pres_2, fk_even, cant_pres, precio_actual_pres)
                        VALUES (c_v.fk_cerv, c_v.fk_pres, x, 100, 9.99);
                END LOOP;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE populate_tiendas_inventories ()
    AS $$
DECLARE
    x integer;
    c_v CERV_PRES%ROWTYPE;
    l_t integer;
BEGIN
    FOR c_v IN (
        SELECT
            *
        FROM
            CERV_PRES
        ORDER BY
            RANDOM()
        LIMIT 5)
    LOOP
        FOR l_t IN (
            SELECT
                cod_luga_tien
            FROM
                Lugar_Tienda)
            LOOP
                INSERT INTO Inventario_Tienda (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien, cant_pres, precio_actual_pres, fk_luga_tien)
                    VALUES (c_v.fk_cerv, c_v.fk_pres, 1, 100, 9.99, l_t);
            END LOOP;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

DELETE FROM Inventario_Evento;

DELETE FROM Inventario_Tienda;

CALL populate_events_inventories ();

CALL populate_tiendas_inventories ();
