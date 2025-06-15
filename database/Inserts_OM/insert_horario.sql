CREATE OR REPLACE PROCEDURE add_horario (hora_ini time, hora_fin time, dia varchar(20))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Horario (hora_ini_hora, hora_fin_hora, dia_hora)
    VALUES (hora_ini, hora_fin, dia);
END;
$$

CALL add_horario('08:00', '16:00', 'Lunes');
CALL add_horario('09:00', '17:00', 'Martes');
CALL add_horario('10:00', '18:00', 'Miércoles');
CALL add_horario('07:30', '15:30', 'Jueves');
CALL add_horario('12:00', '20:00', 'Viernes');
CALL add_horario('08:00', '14:00', 'Sábado');
CALL add_horario('09:00', '13:00', 'Domingo');
CALL add_horario('14:00', '22:00', 'Lunes');
CALL add_horario('16:00', '00:00', 'Viernes');
CALL add_horario('18:00', '02:00', 'Sábado');