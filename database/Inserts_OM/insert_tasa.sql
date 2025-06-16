CREATE OR REPLACE PROCEDURE add_tasa (tasa_bcv numeric (8,2), tasa_punto numeric (8,2), fecha_ini date, fecha_fin date)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Tasa (tasa_dolar_bcv, tasa_punto, fecha_ini_tasa, fecha_fin_tasa)
    VALUES (tasa_bcv, tasa_punto, fecha_ini, fecha_fin);
END;
$$

CALL add_tasa(36.50, 1.00, '2024-01-01', '2024-01-02');
CALL add_tasa(36.75, 1.00, '2024-01-02', '2024-01-03');
CALL add_tasa(37.00, 1.00, '2024-01-03', '2024-01-04');
CALL add_tasa(37.25, 1.00, '2024-01-04', '2024-01-05');
CALL add_tasa(37.50, 1.00, '2024-01-05', '2024-01-06');
CALL add_tasa(37.80, 1.00, '2024-01-06', '2024-01-07');
CALL add_tasa(38.00, 1.00, '2024-01-07', '2024-01-08');
CALL add_tasa(38.20, 1.00, '2024-01-08', '2024-01-09');
CALL add_tasa(38.50, 1.00, '2024-01-09', '2024-01-10');
CALL add_tasa(38.75, 1.00, '2024-01-10', '2024-01-11');