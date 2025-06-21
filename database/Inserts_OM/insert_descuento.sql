CREATE OR REPLACE PROCEDURE give_random_descuentos ()
    AS $$
DECLARE
    c_v record;
    d record;
BEGIN
    FOR c_v IN (
        SELECT
            *
        FROM
            CERV_PRES
        ORDER BY
            RANDOM()
        LIMIT 100)
    LOOP
        SELECT
            *
        FROM
            Descuento
        ORDER BY
            RANDOM()
        LIMIT 1 INTO d;
        INSERT INTO DESC_CERV (fk_desc, fk_cerv_pres_1, fk_cerv_pres_2, porcentaje_desc)
            VALUES (d.cod_desc, c_v.fk_cerv, c_v.fk_pres, ROUND(RANDOM() * 70) + 10);
    END LOOP;
END
$$
LANGUAGE plpgsql;

INSERT INTO DESCUENTO (descripcion_desc, fecha_ini_desc, fecha_fin_desc)
    VALUES ('Descuento de Navidad', '2022-12-01', '2023-01-01'),
    ('Descuento DiarioUnaCerveza', '2023-01-01', '2023-01-21'),
    ('Descuento DiarioUnaCerveza', '2023-01-21', '2023-02-10'),
    ('Descuento DiarioUnaCerveza', '2023-02-10', '2023-03-02'),
    ('Descuento DiarioUnaCerveza', '2023-03-02', '2023-03-22'),
    ('Descuento DiarioUnaCerveza', '2023-03-22', '2023-04-11'),
    ('Descuento DiarioUnaCerveza', '2023-04-11', '2023-05-01'),
    ('Descuento DiarioUnaCerveza', '2023-05-01', '2023-05-21'),
    ('Descuento DiarioUnaCerveza', '2023-05-21', '2023-06-10'),
    ('Descuento DiarioUnaCerveza', '2023-06-10', '2023-06-30');

CALL give_random_descuentos ();
