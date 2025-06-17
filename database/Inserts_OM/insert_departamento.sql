-- Buscar Tienda random
CREATE OR REPLACE PROCEDURE get_tienda_random(out id_tienda)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_tien INTO id_tienda FROM Tienda ORDER BY RANDOM() LIMIT 1;
END;
$$

-- Buscar Tienda específica
CREATE OR REPLACE PROCEDURE get_tienda (out id_tienda, parroquia varchar(40), estado varchar(40), tienda varchar(40))
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT t.cod_tien INTO id_tienda FROM Tienda t, Lugar l1, Lugar l2, Lugar l3
    WHERE t.fk_luga = l1.cod_luga AND l1.fk_luga = l2.cod_luga AND l2.fk_luga = l3.cod_luga AND t.nombre_tien = tienda AND l1.nombre_luga = parroquia AND l3.nombre_luga = estado;
END;
$$

