CREATE OR REPLACE PROCEDURE privileges ()
LANGUAGE plpgsql
AS $$
DECLARE
    x text;
    y text;
    perms varchar(10)[] = ARRAY['create', 'read', 'update', 'delete'];
BEGIN
    FOR x IN (
        SELECT
            relname
        FROM
            pg_stat_user_tables)
        LOOP
            FOREACH y IN ARRAY perms LOOP
                INSERT INTO Privilegio (nombre_priv, descripcion_priv)
                    VALUES (x || '_' || y, 'Privilegio para ' || y || ' la tabla ' || x);
            END LOOP;
        END LOOP;
END
$$;

CREATE OR REPLACE PROCEDURE admin_privileges ()
    AS $$
DECLARE
    x integer;
BEGIN
    FOR x IN (
        SELECT
            cod_priv
        FROM
            Privilegio)
        LOOP
            INSERT INTO PRIV_ROL (fk_rol, fk_priv)
                VALUES (500, x);
        END LOOP;
END
$$
LANGUAGE plpgsql;

DELETE FROM Privilegio;

CALL privileges ();
CALL admin_privileges ();
