CREATE OR REPLACE PROCEDURE privileges ()
LANGUAGE plpgsql
AS $$
DECLARE
    x text;
    y text;
	perms varchar(10)[] = ARRAY ['create', 'read', 'update', 'delete'];
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

DELETE FROM Privilegio;

CALL privileges ();

SELECT
    *
FROM
    Privilegio;
