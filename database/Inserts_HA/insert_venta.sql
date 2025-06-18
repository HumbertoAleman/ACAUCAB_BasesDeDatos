CREATE OR REPLACE FUNCTION get_estatus (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    result integer;
BEGIN
    SELECT
        cod_esta INTO result
    FROM
        Estatus
    WHERE
        nombre_esta = nombre;
    RETURN result;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_punc_canj_historial_on_new_venta ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF NOT NEW.online THEN
        INSERT INTO PUNT_CLIE (fk_clie, fk_tasa, fk_vent, cant_puntos_acum, cant_puntos_canj, fecha_transaccion)
            VALUES (NEW.fk_clie, create_or_insert_tasa (NEW.fecha_vent), NEW.cod_vent, get_most_recent_punt_clie_punt (NEW.fk_clie), 0, NEW.fecha_vent);
    END IF;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_new_estatus_for_venta ()
    RETURNS TRIGGER
    AS $$
BEGIN
    INSERT INTO ESTA_VENT (fk_esta, fk_vent, fecha_ini, fecha_fin)
        VALUES (get_estatus ('Pagado'), NEW.cod_vent, NEW.fecha_vent, NULL);
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_most_recent_punt_clie_punt (clie varchar(20))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cant_puntos_acum
    FROM
        PUNT_CLIE AS p_c
    WHERE
        fk_clie = clie
    ORDER BY
        p_c.cod_punt_clie DESC
    LIMIT 1 INTO res;
    RETURN COALESCE(res, 0);
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tasa_conversion (curr_date date)
    RETURNS integer
    AS $$
DECLARE
    tasa numeric;
BEGIN
    SELECT
        tasa_punto
    FROM
        Tasa
    WHERE
        fecha_ini_tasa = curr_date
    LIMIT 1 INTO tasa;
    RETURN tasa;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_or_insert_tasa (curr_date date)
    RETURNS integer
    AS $$
DECLARE
    v_cod_tasa int;
BEGIN
    -- Check if a record exists with today's date in fecha_ini_tasa
    SELECT
        cod_tasa
    FROM
        Tasa
    WHERE
        fecha_ini_tasa = curr_date
    LIMIT 1 INTO v_cod_tasa;
    -- If a record is found, return the cod_tasa
    IF v_cod_tasa IS NULL THEN
        -- Insert a new record with today's date and numeric values increased by 100
        INSERT INTO Tasa (tasa_dolar_bcv, tasa_punto, fecha_ini_tasa, fecha_fin_tasa)
            VALUES (100, 10, curr_date, curr_date)
        RETURNING
            cod_tasa INTO v_cod_tasa;
    END IF;
    -- Return the cod_tasa
    RETURN v_cod_tasa;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_venta_total ()
    RETURNS TRIGGER
    AS $$
BEGIN
    UPDATE
        Venta
    SET
        iva_vent = NEW.cant_deta_vent * NEW.precio_unitario_vent * 0.16,
        base_imponible_vent = NEW.cant_deta_vent * NEW.precio_unitario_vent
    WHERE
        cod_vent = NEW.fk_vent;
    UPDATE
        Venta
    SET
        total_vent = base_imponible_vent + iva_vent
    WHERE
        cod_vent = NEW.fk_vent;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_from_inventory ()
    RETURNS TRIGGER
    AS $$
DECLARE
    x integer;
BEGIN
    UPDATE
        Inventario_Tienda
    SET
        cant_pres = (cant_pres - NEW.cant_deta_vent)
    WHERE
        NEW.fk_inve_tien_1 = fk_cerv_pres_1
        AND NEW.fk_inve_tien_2 = fk_cerv_pres_2
        AND NEW.fk_inve_tien_3 = fk_tien
        AND NEW.fk_inve_tien_4 = fk_luga_tien;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_points_to_clie ()
    RETURNS TRIGGER
    AS $$
BEGIN
    UPDATE
        PUNT_CLIE
    SET
        cant_puntos_acum = cant_puntos_acum + NEW.cant_deta_vent,
        cant_puntos_canj = cant_puntos_canj + NEW.cant_deta_vent
    WHERE
        fk_vent = NEW.fk_vent;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION substract_points_to_clie ()
    RETURNS TRIGGER
    AS $$
DECLARE
    vent RECORD;
BEGIN
    -- If it's not Punto_Canjeo, bail
    IF NOT EXISTS (
        SELECT
            1
        FROM
            Punto_Canjeo
        WHERE
            fk_meto_pago = NEW.fk_meto_pago) THEN
    RETURN NEW;
END IF;
    -- If PUNT_CLIE doesn't exist for the current Venta, create one
    IF NOT EXISTS (
        SELECT
            1
        FROM
            PUNT_CLIE
        WHERE
            fk_vent = NEW.fk_vent) THEN
    SELECT
        *
    FROM
        Venta
    WHERE
        cod_vent = NEW.fk_vent INTO vent;
    INSERT INTO PUNT_CLIE (fk_clie, fk_tasa, fk_vent, cant_puntos_acum, cant_puntos_canj, fecha_transaccion)
        VALUES (vent.fk_clie, NEW.fk_tasa, NEW.fk_vent, get_most_recent_punt_clie_punt (vent.fk_clie), 0, NEW.fecha_pago);
END IF;
    -- Finally, update the thing to have the correct data
    UPDATE
        PUNT_CLIE
    SET
        cant_puntos_acum = cant_puntos_acum - (NEW.monto_pago / get_tasa_conversion (NEW.fecha_pago)),
        cant_puntos_canj = cant_puntos_canj - (NEW.monto_pago / get_tasa_conversion (NEW.fecha_pago))
    WHERE
        fk_vent = NEW.fk_vent;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER create_punc_canj_on_venta_creation
    AFTER INSERT ON Venta
    FOR EACH ROW
    EXECUTE FUNCTION create_punc_canj_historial_on_new_venta ();

CREATE OR REPLACE TRIGGER after_insert_detalle_venta
    AFTER INSERT ON Detalle_Venta
    FOR EACH ROW
    EXECUTE FUNCTION increment_venta_total ();

CREATE OR REPLACE TRIGGER remove_from_inventory_after_detalle
    AFTER INSERT ON Detalle_Venta
    FOR EACH ROW
    EXECUTE FUNCTION remove_from_inventory ();

CREATE OR REPLACE TRIGGER add_points_on_venta
    AFTER INSERT ON Detalle_Venta
    FOR EACH ROW
    EXECUTE FUNCTION add_points_to_clie ();

CREATE OR REPLACE TRIGGER substract_points_on_venta
    AFTER INSERT ON Pago
    FOR EACH ROW
    EXECUTE FUNCTION substract_points_to_clie ();

CREATE OR REPLACE TRIGGER set_estatus_for_new_venta
    AFTER INSERT ON Venta
    FOR EACH ROW
    EXECUTE FUNCTION create_new_estatus_for_venta ();

CREATE OR REPLACE FUNCTION get_precio_from_inventario (integer, integer, integer, integer)
    RETURNS numeric
    AS $$
DECLARE
    res numeric;
BEGIN
    SELECT
        precio_actual_pres
    FROM
        Inventario_Tienda
    WHERE
        fk_cerv_pres_1 = $1
        AND fk_cerv_pres_2 = $2
        AND fk_tien = $3
        AND fk_luga_tien = $4 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Crear un trigger cuando se cree la venta, en el trigger se revisa si es online u offline,
-- solo se crea PUNT_CLIE cuando la venta es offline
-- Crear otro trigger cuando se cree un pago utilizando el metodo de pago Punto_Canjeo,
-- si PUNT_CLIE
CREATE OR REPLACE PROCEDURE venta_en_tienda (
-- Parameters Venta
p_fecha_vent date, -- Date of Venta
p_online boolean, -- If was online
-- Parameters Who & Where
p_fk_clie varchar(20), -- Who bought this
p_fk_tien integer, -- fk_tien
-- Parameters for Metodo_Pago
m_p_fk_meto_pago integer[], -- Array fk_meto_pago
m_p_monto_pago numeric(8, 2)[], -- Array montos
-- Parameters for Detalle_Venta
d_v_cant_deta_vent integer[], -- Array of quantities sold
d_v_fk_inve_tien_1 integer[], -- Array fk_cerv
d_v_fk_inve_tien_2 integer[], -- Array fk_pres
d_v_fk_inve_tien_4 integer[] -- fk_luga_tien
)
    AS $$
DECLARE
    total_acum integer;
    v_cod_tasa integer;
    v_cod_vent integer;
    precio_unitario numeric;
    -- Hold generated cod_vent
    i integer;
    -- Loop index
BEGIN
    ----
    -- Create Venta record
    -- * This shoots set_estatus_for_new_venta that creates ESTA_VENT, in "Pagado" since we assume that it's already paid for
    ----
    INSERT INTO Venta (fecha_vent, base_imponible_vent, iva_vent, total_vent, online, fk_clie, fk_tien)
        VALUES (p_fecha_vent, 0, 0, 0, p_online, p_fk_clie, p_fk_tien)
    RETURNING
        cod_vent INTO v_cod_vent;
    ----
    -- Loop through the item details and insert each item into Detalle_Venta
    -- * This shoots after_insert_detalle_venta that updates Venta with the price of the item * quantity
    -- * This shoots remove_from_inventory_after_detalle that updates
    --     Inventario_Tienda removing the amount bought
    -- * This shoots add_points_on_venta, in which if the Venta is offline, it adds points to the Client
    ----
    FOR i IN 1..array_length(d_v_cant_deta_vent, 1)
    LOOP
        total_acum := total_acum + d_v_cant_deta_vent[i];
        precio_unitario := get_precio_from_inventario (d_v_fk_inve_tien_1[i], d_v_fk_inve_tien_2[i], p_fk_tien, d_v_fk_inve_tien_4[i]);
        INSERT INTO Detalle_Venta (cant_deta_vent, precio_unitario_vent, fk_vent, fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_3, fk_inve_tien_4)
            VALUES (d_v_cant_deta_vent[i], precio_unitario, v_cod_vent, d_v_fk_inve_tien_1[i], d_v_fk_inve_tien_2[i], p_fk_tien, d_v_fk_inve_tien_4[i]);
    END LOOP;
    ----
    -- Loop through the payment arrays and insert each payment
    -- * This shoots substract_points_on_venta where if Pago is Punto_Canjeo
    --     it discounts the apropriate points from the Client
    ----
    FOR i IN 1..array_length(m_p_fk_meto_pago, 1)
    LOOP
        INSERT INTO Pago (fk_vent, fk_meto_pago, monto_pago, fecha_pago, fk_tasa)
            VALUES (v_cod_vent, m_p_fk_meto_pago[i], m_p_monto_pago[i], p_fecha_vent, create_or_insert_tasa (p_fecha_vent));
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE realizar_ventas_aleatorias ()
    AS $$
DECLARE
    v_fecha_vent date;
    v_base_imponible_vent numeric(8, 2);
    v_iva_vent numeric(8, 2);
    v_online boolean;
    v_fk_clie varchar(20);
    v_fk_tien integer := 1;
    -- Always set tienda to 1
    v_m_p_fk_meto_pago integer[];
    v_m_p_monto_pago numeric(8, 2)[];
    v_d_v_cant_deta_vent integer[];
    v_d_v_fk_inve_tien_1 integer[];
    v_d_v_fk_inve_tien_2 integer[];
    v_d_v_fk_inve_tien_4 integer[];
    entry RECORD;
BEGIN
    FOR i IN 1..10 LOOP
        v_fecha_vent := CURRENT_DATE - (RANDOM() * 30)::int;
        v_base_imponible_vent := ROUND(RANDOM() * 1000);
        v_online := (RANDOM() < 0.25);
        SELECT
            rif_clie INTO v_fk_clie
        FROM
            cliente
        ORDER BY
            RANDOM()
        LIMIT 1;
        SELECT
            cod_meto_pago INTO entry
        FROM
            Metodo_Pago
        ORDER BY
            RANDOM()
        LIMIT 1;
        v_m_p_fk_meto_pago := '{}';
        v_m_p_fk_meto_pago := array_append(v_m_p_fk_meto_pago, entry.cod_meto_pago);
        SELECT
            precio_actual_pres,
            fk_cerv_pres_1,
            fk_cerv_pres_2,
            fk_luga_tien INTO entry
        FROM
            Inventario_Tienda
        WHERE
            fk_tien = 1
        ORDER BY
            RANDOM()
        LIMIT 1;
        v_d_v_fk_inve_tien_1 := '{}';
        v_d_v_fk_inve_tien_2 := '{}';
        v_d_v_fk_inve_tien_4 := '{}';
        v_d_v_fk_inve_tien_1 := array_append(v_d_v_fk_inve_tien_1, entry.fk_cerv_pres_1);
        v_d_v_fk_inve_tien_2 := array_append(v_d_v_fk_inve_tien_2, entry.fk_cerv_pres_2);
        v_d_v_fk_inve_tien_4 := array_append(v_d_v_fk_inve_tien_4, entry.fk_luga_tien);
        v_d_v_cant_deta_vent := ARRAY[RANDOM() * 10::int + 1]::int[];
        v_m_p_monto_pago := ARRAY[v_d_v_cant_deta_vent[1] * get_precio_from_inventario (entry.fk_cerv_pres_1, entry.fk_cerv_pres_2, v_fk_tien, entry.fk_luga_tien)]::int[];
        -- Call the venta_en_tienda procedure with the random values
        CALL venta_en_tienda (v_fecha_vent, v_online, v_fk_clie, v_fk_tien, v_m_p_fk_meto_pago, v_m_p_monto_pago, v_d_v_cant_deta_vent, v_d_v_fk_inve_tien_1, v_d_v_fk_inve_tien_2, v_d_v_fk_inve_tien_4);
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_juridico ()
    RETURNS varchar (
        20
)
        AS $$
DECLARE
    res varchar(20);
BEGIN
    SELECT
        rif_clie
    FROM
        cliente
    WHERE
        tipo_clie = 'Juridico' INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cheque_random ()
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        fk_meto_pago
    FROM
        cheque INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_orden_compra_10_productos ()
    AS $$
DECLARE
    x integer;
    i integer;
    res record;
    cant_item int[];
    precio_total numeric = 0;
    fk_inve_tien_1 int[];
    fk_inve_tien_2 int[];
    fk_inve_tien_4 int[];
BEGIN
    FOR i IN 1..10 LOOP
        -- Set Initial Values
        cant_item := '{}';
        precio_total := 0;
        fk_inve_tien_1 := '{}';
        fk_inve_tien_2 := '{}';
        fk_inve_tien_4 := '{}';
        FOR x IN 1..10 LOOP
            SELECT
                fk_cerv_pres_1,
                fk_cerv_pres_2,
                precio_actual_pres,
                fk_luga_tien INTO res
            FROM
                Inventario_Tienda
            WHERE
                fk_tien = 1 AND
				fk_cerv_pres_1 <> ALL(fk_inve_tien_1)
            ORDER BY
                RANDOM();
            cant_item := array_append(cant_item, ROUND(RANDOM() * 200) + 200);
            precio_total := precio_total + (cant_item[x] * res.precio_actual_pres);
            fk_inve_tien_1 := array_append(fk_inve_tien_1, res.fk_cerv_pres_1);
            fk_inve_tien_2 := array_append(fk_inve_tien_2, res.fk_cerv_pres_2);
            fk_inve_tien_4 := array_append(fk_inve_tien_4, res.fk_luga_tien);
        END LOOP;
        precio_total := precio_total * 1.16;
        ----
        -- Make them TODAY
        -- Make them ONLINE
        -- Make them from JURIDICO
        -- Make them from SHOP 1
        -- Make them 1 PAYMENT, CHEQUE
        -- Make them 1 PAYMENT, CALCULATED HERE
        -- Arrays of Bought Items, Qty, Beer, Size, ShopPlace
        CALL venta_en_tienda (CURRENT_DATE, TRUE, get_random_juridico (), 1, ARRAY[get_cheque_random ()], ARRAY[precio_total], cant_item, fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_4);
        ----
    END LOOP;
END
$$
LANGUAGE plpgsql;

CALL create_orden_compra_10_productos ();

CALL realizar_ventas_aleatorias ();
