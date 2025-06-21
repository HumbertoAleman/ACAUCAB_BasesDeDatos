CREATE OR REPLACE PROCEDURE insert_empl_hora ()
    AS $$
DECLARE
    rec_horario RECORD;
    rec_empl_carg RECORD;
BEGIN
    FOR rec_horario IN
    SELECT
        *
    FROM
        Horario
    LIMIT 7 LOOP
        FOR rec_empl_carg IN
        SELECT
            *
        FROM
            EMPL_CARG LOOP
                INSERT INTO EMPL_HORA (fk_hora, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                    VALUES (rec_horario.cod_hora, rec_empl_carg.fk_empl, rec_empl_carg.fk_carg, rec_empl_carg.cod_empl_carg);
            END LOOP;
    END LOOP;
END
$$
LANGUAGE plpgsql;

INSERT INTO Horario (hora_ini_hora, hora_fin_hora, dia_hora)
    VALUES ('08:00', '16:00', 'Lunes'),
    ('09:00', '17:00', 'Martes'),
    ('10:00', '18:00', 'Miercoles'),
    ('07:30', '15:30', 'Jueves'),
    ('12:00', '20:00', 'Viernes'),
    ('08:00', '14:00', 'Sabado'),
    ('09:00', '13:00', 'Domingo'),
    ('14:00', '22:00', 'Lunes'),
    ('16:00', '00:00', 'Viernes'),
    ('18:00', '02:00', 'Sabado'),

CALL insert_empl_hora ();
