CREATE OR REPLACE FUNCTION get_esta_even (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_esta
    FROM
        Estatus
    WHERE
        nombre_esta LIKE $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tipo_even (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tipo_even
    FROM
        Tipo_Evento
    WHERE
        nombre_tipo_even LIKE $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_esta_even ()
    RETURNS TRIGGER
    AS $$
BEGIN
    INSERT INTO ESTA_EVEN (fk_esta, fk_even, fecha_ini)
        VALUES (get_esta_even ('Pendiente'), NEW.cod_even, NOW());
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_insert_evento
    AFTER INSERT ON Evento
    FOR EACH ROW
    EXECUTE FUNCTION insert_into_esta_even ();

CREATE OR REPLACE PROCEDURE insertar_evento (nombres varchar(40)[], fechas_hora_ini timestamp [], fechas_hora_fin timestamp [], direcciones text [], capacidades integer [], descripciones text [], precios_entradas numeric (8,2) [], cantidades_entradas integer [], tipos_de_eventos varchar(60) [], parroquias varchar(40) [], estados varchar(40)[])
LANGUAGE plpgsql
AS $$
DECLARE
    estado varchar (40);
    i integer := 1;
    j integer;
BEGIN
    FOREACH estado IN ARRAY estados
    LOOP
        FOR j IN 1..5
        LOOP
            INSERT INTO Evento (nombre_even, fecha_hora_ini_even, fecha_hora_fin_even, direccion_even, capacidad_even, descripcion_even, precio_entrada_even, cant_entradas_evento, fk_tipo_even, fk_luga)
            VALUES (nombres[i], fechas_hora_ini[i], fechas_hora_fin[i], direcciones[i], capacidades[i], descripciones[i], precios_entradas[i], cantidades_entradas[i], get_tipo_even (tipos_de_eventos[i]), get_parroquia_from_estado (parroquias[i],estado));
            i := i + 1;
        END LOOP;
    END LOOP;
END;
$$

CALL insertar_evento(
-- Nombres de eventos
ARRAY[
'Cata de Cervezas Amazonas', 'Recorrido Cerveceria Amazonas', 'Festival de Cervezas Amazonas', 'Cena de Maridaje Amazonas', 'Taller de Elaboracion Amazonas',
'Cata de Cervezas Anzoategui', 'Recorrido Cerveceria Anzoategui', 'Festival de Cervezas Anzoategui', 'Cena de Maridaje Anzoategui', 'Taller de Elaboracion Anzoategui',
'Cata de Cervezas Apure', 'Recorrido Cerveceria Apure', 'Festival de Cervezas Apure', 'Cena de Maridaje Apure', 'Taller de Elaboracion Apure',
'Cata de Cervezas Aragua', 'Recorrido Cerveceria Aragua', 'Festival de Cervezas Aragua', 'Cena de Maridaje Aragua', 'Taller de Elaboracion Aragua',
'Cata de Cervezas Barinas', 'Recorrido Cerveceria Barinas', 'Festival de Cervezas Barinas', 'Cena de Maridaje Barinas', 'Taller de Elaboracion Barinas',
'Cata de Cervezas Bolivar', 'Recorrido Cerveceria Bolivar', 'Festival de Cervezas Bolivar', 'Cena de Maridaje Bolivar', 'Taller de Elaboracion Bolivar',
'Cata de Cervezas Carabobo', 'Recorrido Cerveceria Carabobo', 'Festival de Cervezas Carabobo', 'Cena de Maridaje Carabobo', 'Taller de Elaboracion Carabobo',
'Cata de Cervezas Cojedes', 'Recorrido Cerveceria Cojedes', 'Festival de Cervezas Cojedes', 'Cena de Maridaje Cojedes', 'Taller de Elaboracion Cojedes',
'Cata de Cervezas Delta Amacuro', 'Recorrido Cerveceria Delta Amacuro', 'Festival de Cervezas Delta Amacuro', 'Cena de Maridaje Delta Amacuro', 'Taller de Elaboracion Delta Amacuro',
'Cata de Cervezas Distrito Capital', 'Recorrido Cerveceria Distrito Capital', 'Festival de Cervezas Distrito Capital', 'Cena de Maridaje Distrito Capital', 'Taller de Elaboracion Distrito Capital',
'Cata de Cervezas Falcon', 'Recorrido Cerveceria Falcon', 'Festival de Cervezas Falcon', 'Cena de Maridaje Falcon', 'Taller de Elaboracion Falcon',
'Cata de Cervezas Guarico', 'Recorrido Cerveceria Guarico', 'Festival de Cervezas Guarico', 'Cena de Maridaje Guarico', 'Taller de Elaboracion Guarico',
'Cata de Cervezas La Guaira', 'Recorrido Cerveceria La Guaira', 'Festival de Cervezas La Guaira', 'Cena de Maridaje La Guaira', 'Taller de Elaboracion La Guaira',
'Cata de Cervezas Lara', 'Recorrido Cerveceria Lara', 'Festival de Cervezas Lara', 'Cena de Maridaje Lara', 'Taller de Elaboracion Lara',
'Cata de Cervezas Merida', 'Recorrido Cerveceria Merida', 'Festival de Cervezas Merida', 'Cena de Maridaje Merida', 'Taller de Elaboracion Merida',
'Cata de Cervezas Miranda', 'Recorrido Cerveceria Miranda', 'Festival de Cervezas Miranda', 'Cena de Maridaje Miranda', 'Taller de Elaboracion Miranda',
'Cata de Cervezas Monagas', 'Recorrido Cerveceria Monagas', 'Festival de Cervezas Monagas', 'Cena de Maridaje Monagas', 'Taller de Elaboracion Monagas',
'Cata de Cervezas Nueva Esparta', 'Recorrido Cerveceria Nueva Esparta', 'Festival de Cervezas Nueva Esparta', 'Cena de Maridaje Nueva Esparta', 'Taller de Elaboracion Nueva Esparta',
'Cata de Cervezas Portuguesa', 'Recorrido Cerveceria Portuguesa', 'Festival de Cervezas Portuguesa', 'Cena de Maridaje Portuguesa', 'Taller de Elaboracion Portuguesa',
'Cata de Cervezas Sucre', 'Recorrido Cerveceria Sucre', 'Festival de Cervezas Sucre', 'Cena de Maridaje Sucre', 'Taller de Elaboracion Sucre',
'Cata de Cervezas Tachira', 'Recorrido Cerveceria Tachira', 'Festival de Cervezas Tachira', 'Cena de Maridaje Tachira', 'Taller de Elaboracion Tachira',
'Cata de Cervezas Trujillo', 'Recorrido Cerveceria Trujillo', 'Festival de Cervezas Trujillo', 'Cena de Maridaje Trujillo', 'Taller de Elaboracion Trujillo',
'Cata de Cervezas Yaracuy', 'Recorrido Cerveceria Yaracuy', 'Festival de Cervezas Yaracuy', 'Cena de Maridaje Yaracuy', 'Taller de Elaboracion Yaracuy',
'Cata de Cervezas Zulia', 'Recorrido Cerveceria Zulia', 'Festival de Cervezas Zulia', 'Cena de Maridaje Zulia', 'Taller de Elaboracion Zulia'
] :: varchar(40)[],

-- Fechas y horas de inicio
ARRAY[
'2025-07-01 16:00:00','2025-07-01 17:00:00','2025-07-01 18:00:00','2025-07-01 19:00:00','2025-07-01 20:00:00',
'2025-07-02 16:00:00','2025-07-02 17:00:00','2025-07-02 18:00:00','2025-07-02 19:00:00','2025-07-02 20:00:00',
'2025-07-03 16:00:00','2025-07-03 17:00:00','2025-07-03 18:00:00','2025-07-03 19:00:00','2025-07-03 20:00:00',
'2025-07-04 16:00:00','2025-07-04 17:00:00','2025-07-04 18:00:00','2025-07-04 19:00:00','2025-07-04 20:00:00',
'2025-07-05 16:00:00','2025-07-05 17:00:00','2025-07-05 18:00:00','2025-07-05 19:00:00','2025-07-05 20:00:00',
'2025-07-06 16:00:00','2025-07-06 17:00:00','2025-07-06 18:00:00','2025-07-06 19:00:00','2025-07-06 20:00:00',
'2025-07-07 16:00:00','2025-07-07 17:00:00','2025-07-07 18:00:00','2025-07-07 19:00:00','2025-07-07 20:00:00',
'2025-07-08 16:00:00','2025-07-08 17:00:00','2025-07-08 18:00:00','2025-07-08 19:00:00','2025-07-08 20:00:00',
'2025-07-09 16:00:00','2025-07-09 17:00:00','2025-07-09 18:00:00','2025-07-09 19:00:00','2025-07-09 20:00:00',
'2025-07-10 16:00:00','2025-07-10 17:00:00','2025-07-10 18:00:00','2025-07-10 19:00:00','2025-07-10 20:00:00',
'2025-07-11 16:00:00','2025-07-11 17:00:00','2025-07-11 18:00:00','2025-07-11 19:00:00','2025-07-11 20:00:00',
'2025-07-12 16:00:00','2025-07-12 17:00:00','2025-07-12 18:00:00','2025-07-12 19:00:00','2025-07-12 20:00:00',
'2025-07-13 16:00:00','2025-07-13 17:00:00','2025-07-13 18:00:00','2025-07-13 19:00:00','2025-07-13 20:00:00',
'2025-07-14 16:00:00','2025-07-14 17:00:00','2025-07-14 18:00:00','2025-07-14 19:00:00','2025-07-14 20:00:00',
'2025-07-15 16:00:00','2025-07-15 17:00:00','2025-07-15 18:00:00','2025-07-15 19:00:00','2025-07-15 20:00:00',
'2025-07-16 16:00:00','2025-07-16 17:00:00','2025-07-16 18:00:00','2025-07-16 19:00:00','2025-07-16 20:00:00',
'2025-07-17 16:00:00','2025-07-17 17:00:00','2025-07-17 18:00:00','2025-07-17 19:00:00','2025-07-17 20:00:00',
'2025-07-18 16:00:00','2025-07-18 17:00:00','2025-07-18 18:00:00','2025-07-18 19:00:00','2025-07-18 20:00:00',
'2025-07-19 16:00:00','2025-07-19 17:00:00','2025-07-19 18:00:00','2025-07-19 19:00:00','2025-07-19 20:00:00',
'2025-07-20 16:00:00','2025-07-20 17:00:00','2025-07-20 18:00:00','2025-07-20 19:00:00','2025-07-20 20:00:00',
'2025-07-21 16:00:00','2025-07-21 17:00:00','2025-07-21 18:00:00','2025-07-21 19:00:00','2025-07-21 20:00:00',
'2025-07-22 16:00:00','2025-07-22 17:00:00','2025-07-22 18:00:00','2025-07-22 19:00:00','2025-07-22 20:00:00',
'2025-07-23 16:00:00','2025-07-23 17:00:00','2025-07-23 18:00:00','2025-07-23 19:00:00','2025-07-23 20:00:00',
'2025-07-24 16:00:00','2025-07-24 17:00:00','2025-07-24 18:00:00','2025-07-24 19:00:00','2025-07-24 20:00:00'
] :: timestamp[],

-- Fechas y horas de fin
ARRAY[
'2025-07-01 20:00:00','2025-07-01 21:00:00','2025-07-01 22:00:00','2025-07-01 23:00:00','2025-07-01 23:30:00',
'2025-07-02 20:00:00','2025-07-02 21:00:00','2025-07-02 22:00:00','2025-07-02 23:00:00','2025-07-02 23:30:00',
'2025-07-03 20:00:00','2025-07-03 21:00:00','2025-07-03 22:00:00','2025-07-03 23:00:00','2025-07-03 23:30:00',
'2025-07-04 20:00:00','2025-07-04 21:00:00','2025-07-04 22:00:00','2025-07-04 23:00:00','2025-07-04 23:30:00',
'2025-07-05 20:00:00','2025-07-05 21:00:00','2025-07-05 22:00:00','2025-07-05 23:00:00','2025-07-05 23:30:00',
'2025-07-06 20:00:00','2025-07-06 21:00:00','2025-07-06 22:00:00','2025-07-06 23:00:00','2025-07-06 23:30:00',
'2025-07-07 20:00:00','2025-07-07 21:00:00','2025-07-07 22:00:00','2025-07-07 23:00:00','2025-07-07 23:30:00',
'2025-07-08 20:00:00','2025-07-08 21:00:00','2025-07-08 22:00:00','2025-07-08 23:00:00','2025-07-08 23:30:00',
'2025-07-09 20:00:00','2025-07-09 21:00:00','2025-07-09 22:00:00','2025-07-09 23:00:00','2025-07-09 23:30:00',
'2025-07-10 20:00:00','2025-07-10 21:00:00','2025-07-10 22:00:00','2025-07-10 23:00:00','2025-07-10 23:30:00',
'2025-07-11 20:00:00','2025-07-11 21:00:00','2025-07-11 22:00:00','2025-07-11 23:00:00','2025-07-11 23:30:00',
'2025-07-12 20:00:00','2025-07-12 21:00:00','2025-07-12 22:00:00','2025-07-12 23:00:00','2025-07-12 23:30:00',
'2025-07-13 20:00:00','2025-07-13 21:00:00','2025-07-13 22:00:00','2025-07-13 23:00:00','2025-07-13 23:30:00',
'2025-07-14 20:00:00','2025-07-14 21:00:00','2025-07-14 22:00:00','2025-07-14 23:00:00','2025-07-14 23:30:00',
'2025-07-15 20:00:00','2025-07-15 21:00:00','2025-07-15 22:00:00','2025-07-15 23:00:00','2025-07-15 23:30:00',
'2025-07-16 20:00:00','2025-07-16 21:00:00','2025-07-16 22:00:00','2025-07-16 23:00:00','2025-07-16 23:30:00',
'2025-07-17 20:00:00','2025-07-17 21:00:00','2025-07-17 22:00:00','2025-07-17 23:00:00','2025-07-17 23:30:00',
'2025-07-18 20:00:00','2025-07-18 21:00:00','2025-07-18 22:00:00','2025-07-18 23:00:00','2025-07-18 23:30:00',
'2025-07-19 20:00:00','2025-07-19 21:00:00','2025-07-19 22:00:00','2025-07-19 23:00:00','2025-07-19 23:30:00',
'2025-07-20 20:00:00','2025-07-20 21:00:00','2025-07-20 22:00:00','2025-07-20 23:00:00','2025-07-20 23:30:00',
'2025-07-21 20:00:00','2025-07-21 21:00:00','2025-07-21 22:00:00','2025-07-21 23:00:00','2025-07-21 23:30:00',
'2025-07-22 20:00:00','2025-07-22 21:00:00','2025-07-22 22:00:00','2025-07-22 23:00:00','2025-07-22 23:30:00',
'2025-07-23 20:00:00','2025-07-23 21:00:00','2025-07-23 22:00:00','2025-07-23 23:00:00','2025-07-23 23:30:00',
'2025-07-24 20:00:00','2025-07-24 21:00:00','2025-07-24 22:00:00','2025-07-24 23:00:00','2025-07-24 23:30:00'
] :: timestamp[],

-- Direcciones
ARRAY[
'Calle Fernando Giron Tovar, Puerto Ayacucho, Amazonas','Calle Luis Alberto Gomez, Puerto Ayacucho, Amazonas','Calle Parhueña, Puerto Ayacucho, Amazonas','Calle Platanillal, Puerto Ayacucho, Amazonas','Avenida La Esmeralda, Alto Orinoco, Amazonas',
'Calle Anaco, Anaco, Anzoategui','Avenida San Joaquin, Anaco, Anzoategui','Calle Cachipo, Aragua de Barcelona, Anzoategui','Avenida Lecheria, Lecheria, Anzoategui','Calle El Morro, Lecheria, Anzoategui',
'Calle Achaguas, Achaguas, Apure','Calle Apurito, Achaguas, Apure','Calle El Yagual, Achaguas, Apure','Calle Guachara, Achaguas, Apure','Calle Mucuritas, Achaguas, Apure',
'Calle Maracay, Maracay, Aragua','Avenida Las Delicias, Maracay, Aragua','Calle Cagua, Cagua, Aragua','Calle Turmero, Turmero, Aragua','Avenida Sucre, La Victoria, Aragua',
'Calle Barinas, Barinas, Barinas','Avenida Industrial, Barinas, Barinas','Calle Libertad, Barinas, Barinas','Calle Obispos, Obispos, Barinas','Calle Sabaneta, Sabaneta, Barinas',
'Calle Angostura, Ciudad Bolivar, Bolivar','Avenida Libertador, Ciudad Bolivar, Bolivar','Calle Upata, Upata, Bolivar','Calle Tumeremo, Tumeremo, Bolivar','Calle El Callao, El Callao, Bolivar',
'Calle Valencia, Valencia, Carabobo','Avenida Bolivar, Valencia, Carabobo','Calle Naguanagua, Naguanagua, Carabobo','Calle Guacara, Guacara, Carabobo','Avenida San Diego, San Diego, Carabobo',
'Calle Tinaquillo, Tinaquillo, Cojedes','Calle San Carlos, San Carlos, Cojedes','Calle Tinaco, Tinaco, Cojedes','Calle El Baul, El Baul, Cojedes','Calle Las Vegas, Las Vegas, Cojedes',
'Calle Tucupita, Tucupita, Delta Amacuro','Calle Pedernales, Pedernales, Delta Amacuro','Calle Curiapo, Curiapo, Delta Amacuro','Calle Capure, Capure, Delta Amacuro','Calle Araguaimujo, Araguaimujo, Delta Amacuro',
'Calle La Pastora, Caracas, Distrito Capital','Calle San Juan, Caracas, Distrito Capital','Calle El Valle, Caracas, Distrito Capital','Calle La Vega, Caracas, Distrito Capital','Calle Antimano, Caracas, Distrito Capital',
'Calle Coro, Coro, Falcon','Avenida Zamora, Coro, Falcon','Calle Punto Fijo, Punto Fijo, Falcon','Calle Chichiriviche, Chichiriviche, Falcon','Calle Tucacas, Tucacas, Falcon',
'Calle San Juan de los Morros, San Juan de los Morros, Guarico','Calle Calabozo, Calabozo, Guarico','Calle Zaraza, Zaraza, Guarico','Calle Valle de la Pascua, Valle de la Pascua, Guarico','Calle Altagracia de Orituco, Altagracia de Orituco, Guarico',
'Calle Macuto, Macuto, La Guaira','Avenida La Playa, Macuto, La Guaira','Calle Catia La Mar, Catia La Mar, La Guaira','Calle Maiquetia, Maiquetia, La Guaira','Calle Caraballeda, Caraballeda, La Guaira',
'Calle Barquisimeto, Barquisimeto, Lara','Avenida Lara, Barquisimeto, Lara','Calle Cabudare, Cabudare, Lara','Calle El Tocuyo, El Tocuyo, Lara','Calle Quibor, Quibor, Lara',
'Calle Merida, Merida, Merida','Avenida Los Andes, Merida, Merida','Calle Ejido, Ejido, Merida','Calle Tovar, Tovar, Merida','Calle Lagunillas, Lagunillas, Merida',
'Calle Los Teques, Los Teques, Miranda','Avenida Miranda, Los Teques, Miranda','Calle Guarenas, Guarenas, Miranda','Calle Guatire, Guatire, Miranda','Calle Charallave, Charallave, Miranda',
'Calle Maturin, Maturin, Monagas','Avenida Bolivar, Maturin, Monagas','Calle Punta de Mata, Punta de Mata, Monagas','Calle Caripito, Caripito, Monagas','Calle Temblador, Temblador, Monagas',
'Calle Porlamar, Porlamar, Nueva Esparta','Avenida 4 de Mayo, Porlamar, Nueva Esparta','Calle Pampatar, Pampatar, Nueva Esparta','Calle Juan Griego, Juan Griego, Nueva Esparta','Calle La Asuncion, La Asuncion, Nueva Esparta',
'Calle Guanare, Guanare, Portuguesa','Avenida Portuguesa, Guanare, Portuguesa','Calle Acarigua, Acarigua, Portuguesa','Calle Araure, Araure, Portuguesa','Calle Biscucuy, Biscucuy, Portuguesa',
'Calle Cumana, Cumana, Sucre','Avenida Sucre, Cumana, Sucre','Calle Carupano, Carupano, Sucre','Calle Rio Caribe, Rio Caribe, Sucre','Calle Guiria, Guiria, Sucre',
'Calle San Cristobal, San Cristobal, Tachira','Avenida Tachira, San Cristobal, Tachira','Calle Rubio, Rubio, Tachira','Calle La Grita, La Grita, Tachira','Calle Colon, Colon, Tachira',
'Calle Trujillo, Trujillo, Trujillo','Avenida Bolivar, Trujillo, Trujillo','Calle Boconó, Boconó, Trujillo','Calle Valera, Valera, Trujillo','Calle Carache, Carache, Trujillo',
'Calle San Felipe, San Felipe, Yaracuy','Avenida Yaracuy, San Felipe, Yaracuy','Calle Yaritagua, Yaritagua, Yaracuy','Calle Chivacoa, Chivacoa, Yaracuy','Calle Nirgua, Nirgua, Yaracuy',
'Calle Maracaibo, Maracaibo, Zulia','Avenida Bella Vista, Maracaibo, Zulia','Calle Cabimas, Cabimas, Zulia','Calle Ciudad Ojeda, Ciudad Ojeda, Zulia','Calle San Francisco, San Francisco, Zulia'
] :: text[],

-- Capacidades
ARRAY[
100,120,80,150,90,110,130,85,140,95,200,180,160,220,170,105,125,95,155,100,115,135,90,145,98,108,128,88,138,93,112,132,92,142,97,107,127,87,137,91,109,129,89,139,94,106,126,86,136,99,111,131,91,141,96,104,124,84,134,101,113,133,83,143,102,114,134,82,144,103,116,136,81,146,104,117,137,80,147,105,118,138,79,148,106,119,139,78,149,107,120,140,77,150,108,121,141,76,151,109,122,142,75,152,110,123,143,74,153,111,124,144,73,154,112,125,145,72,155,113,126,146,71,156,114,127,147,70,157,115,128,148,69,158,116,129,149,68,159,117,130,150,67,160,118,131,151,66,161,119,132,152,65,162,120,133,153,64,163,121,134,154,63,164,122,135,155,62,165,123,136,156,61,166,124,137,157,60,167,125,138,158,59,168,126,139,159,58,169,127,140,160
] :: integer[],

-- Descripciones
ARRAY[
'Cata guiada de cervezas artesanales de Amazonas','Recorrido por la cervecería local de Amazonas','Festival con las mejores cervezas de Amazonas','Cena de maridaje con cervezas y platos típicos de Amazonas','Taller práctico de elaboración de cerveza en Amazonas',
'Cata guiada de cervezas artesanales de Anzoategui','Recorrido por la cervecería local de Anzoategui','Festival con las mejores cervezas de Anzoategui','Cena de maridaje con cervezas y platos típicos de Anzoategui','Taller práctico de elaboración de cerveza en Anzoategui',
'Cata guiada de cervezas artesanales de Apure','Recorrido por la cervecería local de Apure','Festival con las mejores cervezas de Apure','Cena de maridaje con cervezas y platos típicos de Apure','Taller práctico de elaboración de cerveza en Apure',
'Cata guiada de cervezas artesanales de Aragua','Recorrido por la cervecería local de Aragua','Festival con las mejores cervezas de Aragua','Cena de maridaje con cervezas y platos típicos de Aragua','Taller práctico de elaboración de cerveza en Aragua',
'Cata guiada de cervezas artesanales de Barinas','Recorrido por la cervecería local de Barinas','Festival con las mejores cervezas de Barinas','Cena de maridaje con cervezas y platos típicos de Barinas','Taller práctico de elaboración de cerveza en Barinas',
'Cata guiada de cervezas artesanales de Bolivar','Recorrido por la cervecería local de Bolivar','Festival con las mejores cervezas de Bolivar','Cena de maridaje con cervezas y platos típicos de Bolivar','Taller práctico de elaboración de cerveza en Bolivar',
'Cata guiada de cervezas artesanales de Carabobo','Recorrido por la cervecería local de Carabobo','Festival con las mejores cervezas de Carabobo','Cena de maridaje con cervezas y platos típicos de Carabobo','Taller práctico de elaboración de cerveza en Carabobo',
'Cata guiada de cervezas artesanales de Cojedes','Recorrido por la cervecería local de Cojedes','Festival con las mejores cervezas de Cojedes','Cena de maridaje con cervezas y platos típicos de Cojedes','Taller práctico de elaboración de cerveza en Cojedes',
'Cata guiada de cervezas artesanales de Delta Amacuro','Recorrido por la cervecería local de Delta Amacuro','Festival con las mejores cervezas de Delta Amacuro','Cena de maridaje con cervezas y platos típicos de Delta Amacuro','Taller práctico de elaboración de cerveza en Delta Amacuro',
'Cata guiada de cervezas artesanales de Distrito Capital','Recorrido por la cervecería local de Distrito Capital','Festival con las mejores cervezas de Distrito Capital','Cena de maridaje con cervezas y platos típicos de Distrito Capital','Taller práctico de elaboración de cerveza en Distrito Capital',
'Cata guiada de cervezas artesanales de Falcon','Recorrido por la cervecería local de Falcon','Festival con las mejores cervezas de Falcon','Cena de maridaje con cervezas y platos típicos de Falcon','Taller práctico de elaboración de cerveza en Falcon',
'Cata guiada de cervezas artesanales de Guarico','Recorrido por la cervecería local de Guarico','Festival con las mejores cervezas de Guarico','Cena de maridaje con cervezas y platos típicos de Guarico','Taller práctico de elaboración de cerveza en Guarico',
'Cata guiada de cervezas artesanales de La Guaira','Recorrido por la cervecería local de La Guaira','Festival con las mejores cervezas de La Guaira','Cena de maridaje con cervezas y platos típicos de La Guaira','Taller práctico de elaboración de cerveza en La Guaira',
'Cata guiada de cervezas artesanales de Lara','Recorrido por la cervecería local de Lara','Festival con las mejores cervezas de Lara','Cena de maridaje con cervezas y platos típicos de Lara','Taller práctico de elaboración de cerveza en Lara',
'Cata guiada de cervezas artesanales de Merida','Recorrido por la cervecería local de Merida','Festival con las mejores cervezas de Merida','Cena de maridaje con cervezas y platos típicos de Merida','Taller práctico de elaboración de cerveza en Merida',
'Cata guiada de cervezas artesanales de Miranda','Recorrido por la cervecería local de Miranda','Festival con las mejores cervezas de Miranda','Cena de maridaje con cervezas y platos típicos de Miranda','Taller práctico de elaboración de cerveza en Miranda',
'Cata guiada de cervezas artesanales de Monagas','Recorrido por la cervecería local de Monagas','Festival con las mejores cervezas de Monagas','Cena de maridaje con cervezas y platos típicos de Monagas','Taller práctico de elaboración de cerveza en Monagas',
'Cata guiada de cervezas artesanales de Nueva Esparta','Recorrido por la cervecería local de Nueva Esparta','Festival con las mejores cervezas de Nueva Esparta','Cena de maridaje con cervezas y platos típicos de Nueva Esparta','Taller práctico de elaboración de cerveza en Nueva Esparta',
'Cata guiada de cervezas artesanales de Portuguesa','Recorrido por la cervecería local de Portuguesa','Festival con las mejores cervezas de Portuguesa','Cena de maridaje con cervezas y platos típicos de Portuguesa','Taller práctico de elaboración de cerveza en Portuguesa',
'Cata guiada de cervezas artesanales de Sucre','Recorrido por la cervecería local de Sucre','Festival con las mejores cervezas de Sucre','Cena de maridaje con cervezas y platos típicos de Sucre','Taller práctico de elaboración de cerveza en Sucre',
'Cata guiada de cervezas artesanales de Tachira','Recorrido por la cervecería local de Tachira','Festival con las mejores cervezas de Tachira','Cena de maridaje con cervezas y platos típicos de Tachira','Taller práctico de elaboración de cerveza en Tachira',
'Cata guiada de cervezas artesanales de Trujillo','Recorrido por la cervecería local de Trujillo','Festival con las mejores cervezas de Trujillo','Cena de maridaje con cervezas y platos típicos de Trujillo','Taller práctico de elaboración de cerveza en Trujillo',
'Cata guiada de cervezas artesanales de Yaracuy','Recorrido por la cervecería local de Yaracuy','Festival con las mejores cervezas de Yaracuy','Cena de maridaje con cervezas y platos típicos de Yaracuy','Taller práctico de elaboración de cerveza en Yaracuy',
'Cata guiada de cervezas artesanales de Zulia','Recorrido por la cervecería local de Zulia','Festival con las mejores cervezas de Zulia','Cena de maridaje con cervezas y platos típicos de Zulia','Taller práctico de elaboración de cerveza en Zulia'
] :: text[],

-- Precios de entradas
ARRAY[
15.00,20.00,25.00,30.00,18.00,16.00,21.00,26.00,31.00,19.00,35.00,40.00,45.00,50.00,38.00,17.00,22.00,27.00,32.00,20.00,18.50,23.00,28.00,33.00,21.00,19.50,24.00,29.00,34.00,22.00,20.50,25.00,30.00,35.00,23.00,21.50,26.00,31.00,36.00,24.00,22.50,27.00,32.00,37.00,25.00,23.50,28.00,33.00,38.00,26.00,24.50,29.00,34.00,39.00,27.00,25.50,30.00,35.00,40.00,28.00,26.50,31.00,36.00,41.00,29.00,27.50,32.00,37.00,42.00,30.00,28.50,33.00,38.00,43.00,31.00,29.50,34.00,39.00,44.00,32.00,30.50,35.00,40.00,45.00,33.00,31.50,36.00,41.00,46.00,34.00,32.50,37.00,42.00,47.00,35.00,33.50,38.00,43.00,48.00,36.00,34.50,39.00,44.00,49.00,37.00,35.50,40.00,45.00,50.00,38.00,36.50,41.00,46.00,51.00,39.00,37.50,42.00,47.00,52.00,40.00,38.50,43.00,48.00,53.00,41.00,39.50,44.00,49.00,54.00,42.00,40.50,45.00,50.00,55.00
] :: numeric (8,2) [],

-- Cantidad máxima de entradas (igual que capacidad)
ARRAY[
100,120,80,150,90,110,130,85,140,95,200,180,160,220,170,105,125,95,155,100,115,135,90,145,98,108,128,88,138,93,112,132,92,142,97,107,127,87,137,91,109,129,89,139,94,106,126,86,136,99,111,131,91,141,96,104,124,84,134,101,113,133,83,143,102,114,134,82,144,103,116,136,81,146,104,117,137,80,147,105,118,138,79,148,106,119,139,78,149,107,120,140,77,150,108,121,141,76,151,109,122,142,75,152,110,123,143,74,153,111,124,144,73,154,112,125,145,72,155,113,126,146,71,156,114,127,147,70,157,115,128,148,69,158,116,129,149,68,159,117,130,150,67,160,118,131,151,66,161,119,132,152,65,162,120,133,153,64,163,121,134,154,63,164,122,135,155,62,165,123,136,156,61,166,124,137,157,60,167,125,138,158,59,168,126,139,159,58,169,127,140,160
] :: integer[],

-- Tipos de eventos (alternando los 10 tipos)
ARRAY[
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros',
'Cata de cervezas','Recorrido por cerveceria','Festival de Cervezas','Cena de Maridaje','Taller de Elaboracion de Cerveza',
'Fiesta de Lanzamiento de Cervezas de Temporada','Noche de Musica en Vivo','Noche de Trivia','Evento de Cerveza y Arte','Evento de Networking Para Cerveceros'
] :: varchar(60)[],

-- Parroquias (cada 5 de un estado distinto)
ARRAY[
'Fernando Giron Tovar','Luis Alberto Gomez','Parhueña','Platanillal','La Esmeralda',
'Anaco','San Joaquin','Cachipo','Aragua de Barcelona','Lecheria',
'Achaguas','Apurito','El Yagual','Guachara','Mucuritas',
'Choroni','Las Delicias','Cagua','Turmero','Jose Felix Ribas',
'Barinas','Alfredo Arvelo Larriva','Libertad','Obispos','Sabaneta',
'Cachamay','Vista al Sol','Upata','Tumeremo','El Callao',
'Urbana San Blas','Simon Bolivar','Urbana Naguanagua Valencia','Guacara','San Diego Valencia',
'Cojedes','El Pao','Tinaquillo','Macapo','San Carlos de Austria',
'Curiapo','Imataca','Pedernales','San Jose','Curiapo',
'23 de Enero','Antimano','Catedral','El Valle','La Pastora',
'Capadare','Aracua','Bariro','Norte','La Vela de Coro',
'Camaguan','Chaguaramas','El Socorro','Tucupido','San Juan de los Morros',
'Caraballeda','Carayaca','Catia La Mar','Maiquetia','Macuto',
'Quebrada Honda de Guache','Freitez','Anzoategui','Cabudare','Buria',
'Presidente Betancourt','Santa Cruz de Mora','La Azulita','Aricagua','Fernandez Peña',
'Aragüita','Cumbo','El Cafetal','Higuerote','Mamporal',
'San Antonio de Maturin','Aguasay','Caripito','El Tejero','Alto de los Godos',
'Antolin del Campo','San Juan Bautista','Garcia','Bolivar','Aguirre',
'Araure','Agua Blanca','Piritu','Cordova','Guanarito',
'Mariño','San Jose de Areocuar','Rio Caribe','El Pilar','Santa Catalina',
'Cordero','Virgen del Carmen','San Juan de Colon','Isaias Medina Angarita','Amenodoro Rangel Lamus',
'Santa Isabel','Bocono','Sabana Grande','Chejende','Carache',
'Aristides Bastidas','Bolivar','Chivacoa','Cocorote','Independencia',
'Isla de Toas','San Timoteo','Ambrosio','Encontrados','San Carlos del Zulia'
] :: varchar(40)[],

-- Estados (24, uno por cada grupo de 5 eventos)
ARRAY[
'Amazonas','Anzoategui','Apure','Aragua','Barinas','Bolivar','Carabobo','Cojedes','Delta Amacuro','Distrito Capital','Falcon','Guarico','La Guaira','Lara','Merida','Miranda','Monagas','Nueva Esparta','Portuguesa','Sucre','Tachira','Trujillo','Yaracuy','Zulia'
] :: varchar(40)[]
);