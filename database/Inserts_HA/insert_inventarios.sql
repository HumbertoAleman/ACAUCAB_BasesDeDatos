CREATE OR REPLACE PROCEDURE populate_events_inventories ()
    AS $$
DECLARE
    x integer;
    c_v CERV_PRES%ROWTYPE;
BEGIN
    FOR x IN (SELECT cod_even FROM Evento)
        LOOP
            FOR c_v IN (SELECT * FROM CERV_PRES)
                LOOP
                    INSERT INTO Inventario_Evento (fk_cerv_pres_1, fk_cerv_pres_2, fk_even, cant_pres, precio_actual_pres)
                        VALUES (c_v.fk_cerv, c_v.fk_pres, x, 100, 9.99);
                END LOOP;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

CALL populate_events_inventories()
