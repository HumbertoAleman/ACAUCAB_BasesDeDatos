CREATE OR REPLACE FUNCTION tri_create_esta_comp_pendiente ()
    RETURNS TRIGGER
    AS $$
DECLARE
    compra_pagada integer;
BEGIN
    SELECT
        cod_esta
    FROM
        Estatus
    WHERE
        nombre_esta = 'Por aprobar'
    LIMIT 1 INTO compra_pagada;
    INSERT INTO ESTA_COMP (fk_esta, fk_comp, fecha_ini)
        VALUES (compra_pagada, NEW.cod_comp, CURRENT_DATE);
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_compra_insert_create_esta_comp_pendiente
    AFTER INSERT ON Compra
    FOR EACH ROW
    EXECUTE FUNCTION tri_create_esta_comp_pendiente ();

CREATE OR REPLACE FUNCTION tri_increment_compra_total ()
    RETURNS TRIGGER
    AS $$
BEGIN
    UPDATE
        Compra
    SET
        base_imponible_comp = base_imponible_comp + (NEW.cant_deta_comp * NEW.precio_unitario_comp),
        iva_comp = iva_comp + (NEW.cant_deta_comp * NEW.precio_unitario_comp) * 0.16,
        total_comp = total_comp + (NEW.cant_deta_comp * NEW.precio_unitario_comp) * 1.16
    WHERE
        cod_comp = NEW.fk_comp;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_detalle_compra_insert_increment_compra_total
    AFTER INSERT ON Detalle_Compra
    FOR EACH ROW
    EXECUTE FUNCTION tri_increment_compra_total ();

CREATE OR REPLACE FUNCTION tri_add_inventario_tienda ()
    RETURNS TRIGGER
    AS $$
DECLARE
    comp record;
    luga_tien record;
    cerv_pres record;
    deta_comp record;
BEGIN
    IF NEW.fk_esta <> (
        SELECT
            cod_esta
        FROM
            Estatus
        WHERE
            nombre_esta = 'Compra Pagada'
        LIMIT 1) THEN
        RETURN NEW;
    END IF;
    SELECT
        *
    FROM
        Compra
    WHERE
        cod_comp = NEW.fk_comp INTO comp;
    SELECT
        *
    FROM
        Lugar_Tienda
    WHERE
        tipo_luga_tien = 'Almacen'
    ORDER BY
        cod_luga_tien ASC
    LIMIT 1 INTO luga_tien;
    -- Loop for each detalle copra in compra
    FOR deta_comp IN (
        SELECT
            *
        FROM
            Detalle_Compra AS dc
        WHERE
            dc.fk_comp = comp.cod_comp)
        LOOP
            -- If inventario_tienda does not exist for cerveza_presentacion
            IF NOT EXISTS (
                SELECT
                    *
                FROM
                    Inventario_Tienda AS i_t
                    JOIN Lugar_Tienda AS lt ON lt.tipo_luga_tien = 'Almacen'
                        AND i_t.fk_luga_tien = lt.cod_luga_tien
                WHERE
                    fk_tien = 1
                    AND fk_cerv_pres_1 = d_t.fk_cerv_pres_1
                    AND fk_cerv_pres_2 = d_t.fk_cerv_pres_2) THEN
            cerv_pres := (
                SELECT
                    *
                FROM
                    CERV_PRES
                WHERE
                    fk_cerv = d_v.fk_cerv_pres_1
                    AND fk_pres = d_v.fk_cerv_pres_2
                    AND fk_miem = comp.fk_miem);
            INSERT INTO Inventario_Tienda (fk_cerv_pres_1, fk_cerv_pres_2, fk_tien, fk_luga_tien, cant_pres, precio_actual_pres)
                VALUES (d_t.fk_cerv_pres_1, d_t.fk_cerv_pres_2, comp.fk_tien, luga_tien.cod_luga_tien, 0, cerv_pres.precio_cerv_pres);
        END IF;
    -- After checking if doesnt exist (and inserting if doesnt, put here)
    UPDATE
        Inventario_Tienda
    SET
        cant_pres = cant_pres + d_v.cant_deta_comp
    WHERE
        fk_cerv_pres_1 = d_v.fk_cerv_pres_1
        AND fk_cerv_pres_2 = d_v.fk_cerv_pres_2
        AND fk_comp = comp.cod_comp;
END LOOP;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_esta_compra_insert_add_inventario_tienda
    AFTER INSERT ON ESTA_COMP
    FOR EACH ROW
    EXECUTE FUNCTION tri_add_inventario_tienda ();

CREATE OR REPLACE PROCEDURE crear_compra ( -- Crear compra
tien_dest int, -- Tienda Destino
miem_prov text, -- Miembro Proveedor
cant_comp int[], -- Cantidad comprada
prec_cerv numeric[], -- Precio por el que la cerveza fue comprada
cerv_arr int[], -- Cervezas a comprar
pres_arr int[] -- Presentaciones a comprar
)
    AS $$
DECLARE
    x int;
    comp int;
BEGIN
    INSERT INTO Compra (fecha_comp, iva_comp, base_imponible_comp, total_comp, fk_tien, fk_miem)
        VALUES (CURRENT_DATE, 0, 0, 0, tien_dest, miem_prov)
    RETURNING
        cod_comp INTO comp;
    FOR x IN 1..array_length(cerv_arr, 1)
    LOOP
        INSERT INTO Detalle_Compra (cant_deta_comp, precio_unitario_comp, fk_cerv_pres_1, fk_cerv_pres_2, fk_comp)
            VALUES (cant_comp[x], prec_cerv[x], cerv_arr[x], pres_arr[x], comp);
    END LOOP;
END
$$
LANGUAGE plpgsql;

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[1], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[2], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[3], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[4], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[5], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[6], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[7], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[8], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[9], ARRAY[1]);

CALL crear_compra (1, 'J358172469', ARRAY[10000], ARRAY[4.99], ARRAY[10], ARRAY[1]);
