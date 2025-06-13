CREATE OR REPLACE PROCEDURE add_descuento (descripcion text, fecha_ini date, fecha_fin date)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Descuento (descripcion_desc, fecha_ini_desc, fecha_fin_desc)
    VALUES (descripcion, fecha_ini, fecha_fin);
END;
$$

CALL add_descuento ('Descuento de Navidad', '2022-12-01', '2023-01-01');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-01-01', '2023-01-21');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-01-21', '2023-02-10');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-02-10', '2023-03-02');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-03-02', '2023-03-22');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-03-22', '2023-04-11');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-04-11', '2023-05-01');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-05-01', '2023-05-21');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-05-21', '2023-06-10');
CALL add_descuento ('Descuento DiarioUnaCerveza', '2023-06-10', '2023-06-30');