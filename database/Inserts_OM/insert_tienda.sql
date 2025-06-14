-- Obtener una parroquia en especifico
CREATE OR REPLACE PROCEDURE get_parroquia (out id_parroquia INT, in nom_parroquia varchar(40), in nom_estado varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT l1.cod_luga INTO id_parroquia FROM Lugar l1, Lugar l2, Lugar l3 WHERE  l1.fk_luga = l2.cod_luga AND l2.fk_luga = l3.cod_luga AND l3.nombre_luga = nom_estado AND l1.tipo_luga = 'Parroquia' AND l1.nombre_luga = nom_parroquia;
END;
$$

-- ------------------------------------------------------------------------

-- Agregar Tienda (Store Procedure)
CREATE OR REPLACE PROCEDURE add_tienda(nombre varchar(40), fecha date, direccion text, nom_parroquia varchar(40), nom_estado varchar(40))
LANGUAGE plpgsql;
AS $$
DECLARE
    id_parroquia integer;
BEGIN
    CALL get_parroquia(id_parroquia, nom_parroquia, nom_estado);
    INSERT INTO Tienda (nombre_tien, fecha_apertura_tien, direccion_tien, fk_luga)
    VALUES (nombre, fecha, direccion, id_parroquia);
END;
$$

CALL add_tienda('ACAUCAB-La Pastora', '2018-01-15', 'Calle Real de La Pastora, Caracas 1010', 'La Pastora', 'Distrito Capital');
CALL add_tienda('ACAUCAB-Choroni', '2019-02-20', 'Avenida Principal de Choroni, Choroni 2109', 'Choroni', 'Aragua');
CALL add_tienda('ACAUCAB-Santa Rosa', '2020-03-10', 'Calle Santa Rosa, Barquisimeto 3001', 'Santa Rosa', 'Lara');
CALL add_tienda('ACAUCAB-El Valle', '2021-04-05', 'Avenida Intercomunal El Valle, Caracas 1090', 'El Valle', 'Distrito Capital');
CALL add_tienda('ACAUCAB-Catia La Mar', '2022-05-12', 'Avenida La Armada, Catia La Mar 1162', 'Catia La Mar', 'La Guaira');
CALL add_tienda('ACAUCAB-San Juan', '2023-06-18', 'Calle San Juan, Caracas 1020', 'San Juan', 'Distrito Capital');
CALL add_tienda('ACAUCAB-Macuto', '2024-07-22', 'Avenida La Playa, Macuto 1164', 'Macuto', 'La Guaira');
CALL add_tienda('ACAUCAB-Santa Barbara', '2025-08-30', 'Calle Bolivar, Santa Barbara de Barinas 5216', 'Santa Barbara', 'Barinas');
CALL add_tienda('ACAUCAB-La Vega', '2026-09-14', 'Calle La Vega, Caracas 1021', 'La Vega', 'Distrito Capital');
CALL add_tienda('ACAUCAB-El Junko', '2027-10-03', 'Carretera El Junko, El Junko 1204', 'El Junko', 'La Guaira');