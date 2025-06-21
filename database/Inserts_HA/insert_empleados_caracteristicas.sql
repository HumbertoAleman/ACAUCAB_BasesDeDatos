CREATE OR REPLACE PROCEDURE create_and_give_benefits ()
    AS $$
DECLARE
    bene integer;
    e_c record;
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
            *
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO EMPL_BENE (fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3, fk_bene, monto_bene)
                VALUES (e_c.fk_empl, e_c.fk_carg, e_c.cod_empl_carg, (
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
    e_c record;
BEGIN
    FOR e_c IN (
        SELECT
            *
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO Vacacion (fecha_ini_vaca, fecha_fin_vaca, pagada, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                VALUES ('2024-12-12', '2025-01-01', FALSE, e_c.fk_empl, e_c.fk_carg, e_c.cod_empl_carg);
        END LOOP;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE generate_asistencia_entries ()
    AS $$
DECLARE
    emp record;
    start_date date := '2024-10-11';
    business_day date;
    start_hour interval;
    end_hour interval;
BEGIN
    FOR emp IN SELECT DISTINCT
        *
    FROM
        EMPL_CARG LOOP
            FOR i IN 0..9 LOOP
                business_day := start_date + i;
                IF RANDOM() >= 0.05 THEN
                    start_hour := INTERVAL '9 hours' + (RANDOM() * INTERVAL '30 minutes');
                    end_hour := INTERVAL '17 hours' + (RANDOM() * INTERVAL '30 minutes');
                    INSERT INTO Asistencia (fecha_hora_ini_asis, fecha_hora_fin_asis, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                        VALUES (business_day + start_hour, business_day + end_hour, emp.fk_empl, emp.fk_carg, emp.cod_empl_carg);
                END IF;
            END LOOP;
        END LOOP;
END
$$
LANGUAGE plpgsql;

CALL create_and_give_benefits ();

CALL create_vacaciones ();

CALL generate_asistencia_entries ();
