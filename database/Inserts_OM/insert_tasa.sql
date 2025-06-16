CREATE OR REPLACE PROCEDURE add_tasa (tasa_bcv numeric (8,2), tasa_punto numeric (8,2), fecha_ini date, fecha_fin date)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Tasa (tasa_dolar_bcv, tasa_punto, fecha_ini_tasa, fecha_fin_tasa)
    VALUES (tasa_bcv, tasa_punto, fecha_ini, fecha_fin);
END;
$$