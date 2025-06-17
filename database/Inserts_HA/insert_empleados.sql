CREATE OR REPLACE PROCEDURE add_empleado (ci integer, p_nom text, s_nom text, p_ape text, s_ape text, salario numeric(8, 2))
LANGUAGE plpgsql
AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO Empleado (ci_empl, primer_nom_empl, segundo_nom_empl, primer_ape_empl, segundo_ape_empl, salario_base_empl)
        VALUES (ci, p_nom, s_nom, p_ape, s_ape, salario)
    RETURNING
        cod_empl INTO x;
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_empl)
        VALUES ('admin', p_nom || ' ' || s_nom, 300, x);
END;
$$;

DELETE FROM Usuario
WHERE fk_rol = 300;

DELETE FROM Rol
WHERE nombre_rol = 'Empleado';

DELETE FROM Empleado;

INSERT INTO Rol
    VALUES (300, 'Empleado', 'Empleado regular de ACAUCAB');

CALL add_empleado(31279920, 'Serita Whittington', 'Jewel Christiansen', 'Herrick', 'Blevins', 73.02);

CALL add_empleado(48422996, 'Thora Beck', 'Candra Blackburn', 'Ferrer', 'Pina', 46.97);

CALL add_empleado(2428796, 'Barney Ruth', 'Merlin Zaragoza', 'Atchison', 'Hooker', 18.39);

CALL add_empleado(26806759, 'Stacey Allan', 'Eura Addison', 'Seeley', 'Thomsen', 85.59);

CALL add_empleado(4221028, 'Kati Felton', 'Serafina Sommer-Rey', 'Valencia', 'Guillory', 53.06);

CALL add_empleado(1418738, 'Loni Fain', 'Hershel Runyon', 'Stubblefield', 'Ahmad-Alley', 20.58);

CALL add_empleado(518945, 'Loree Walston', 'Alpha Kong', 'Sparks', 'Sell', 62.83);

CALL add_empleado(46565698, 'Vashti Mathias', 'Conchita Wentz', 'Sadler', 'Carpenter', 67.6);

CALL add_empleado(42233317, 'Bula Duff', 'Norbert Solomon', 'Amaral', 'Wooley', 55.88);

CALL add_empleado(40959596, 'Jewel Walston', 'Elene Downey', 'Bray', 'Penn', 18.01);
