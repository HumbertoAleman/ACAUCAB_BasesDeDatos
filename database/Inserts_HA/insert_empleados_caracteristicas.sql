CREATE OR REPLACE PROCEDURE create_and_give_benefits ()
    AS $$
DECLARE
    bene integer;
    e_c EMPL_CARG%ROWTYPE;
BEGIN
    INSERT INTO Beneficio (nombre_bene, cantidad_bene)
        VALUES ('Salario Competitivo', 50000),
        ('Seguro de Salud', 2000),
        ('Vacaciones Pagadas', 3000),
        ('Bonificaciones Anuales', 5000),
        ('Capacitación y Desarrollo', 1500),
        ('Horario Flexible', 0),
        ('Trabajo Remoto', 0),
        ('Plan de Jubilación', 3000),
        ('Días de Enfermedad Pagados', 2000),
        ('Beneficios de Bienestar', 1000);
    FOR e_c IN (
        SELECT
            fk_empl,
            fk_carg
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO EMPL_BENE (fk_empl_carg_1, fk_empl_carg_2, fk_bene, monto_bene)
                VALUES (e_c.fk_empl, e_c.fk_carg, (
                        SELECT
                            cod_bene
                        FROM
                            Beneficio
                        ORDER BY
                            RANDOM()
                        LIMIT 1),
                    100);
        END LOOP;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_vacaciones ()
    AS $$
DECLARE
    e_c EMPL_CARG%ROWTYPE;
BEGIN
    FOR e_c IN (
        SELECT
            fk_empl,
            fk_carg
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO Vacacion (fecha_ini_vaca, fecha_fin_vaca, pagada, fk_empl_carg_1, fk_empl_carg_2)
                VALUES ('2024-12-12', '2025-01-01', FALSE, e_c.fk_empl, e_c.fk_carg);
        END LOOP;
END
$$
LANGUAGE plpgsql;

-- Call the procedure to generate the entries
CALL give_benefits ();

CALL create_vacaciones ();

