--[[[ FUNCTION BEGIN ]]]--

-- Buscar Empleado
CREATE OR REPLACE FUNCTION get_empleado (ci integer)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_empl
    FROM
        Empleado
    WHERE
        ci_empl = ci INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Buscar Cargo
CREATE OR REPLACE FUNCTION get_cargo (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_carg
    FROM
        Cargo
    WHERE
        nombre_carg = nombre INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Get parroquia from name
CREATE OR REPLACE FUNCTION get_parroquia (nom_parroquia varchar(40))
    RETURNS integer
    AS $$
DECLARE
    id_parroquia integer;
BEGIN
    SELECT
        cod_luga
    FROM
        Lugar
    WHERE
        nombre_luga = nom_parroquia
        AND tipo_luga = 'Parroquia'
    LIMIT 1 INTO id_parroquia;
    RETURN id_parroquia;
END
$$
LANGUAGE plpgsql;

-- Get first tienda
CREATE OR REPLACE FUNCTION get_tienda_1 ()
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tien
    FROM
        Tienda
    ORDER BY
        cod_tien
    LIMIT 1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Buscar Departamento In Tienda 1
CREATE OR REPLACE FUNCTION get_departamento_1 (nombre varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_depa
    FROM
        Departamento
    WHERE
        fk_tien = get_tienda_1 ()
        AND nombre_depa = nombre INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

-- Get tienda from parroquia, estado
CREATE OR REPLACE FUNCTION get_tienda (parroquia varchar(40), estado varchar(40), tienda varchar(40))
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        t.cod_tien
    FROM
        Tienda t,
        Lugar l1,
        Lugar l2,
        Lugar l3
    WHERE
        t.fk_luga = l1.cod_luga
        AND l1.fk_luga = l2.cod_luga
        AND l2.fk_luga = l3.cod_luga
        AND t.nombre_tien = tienda
        AND l1.nombre_luga = parroquia
        AND l3.nombre_luga = estado;
    RETURN res;
END
$$
LANGUAGE plpgsql;

--[[[ FUNCTION END ]]]---

-- [[ PROCEDURE Lugar, INDEPENDENT ]]--
CREATE OR REPLACE PROCEDURE insert_estados(varchar(40)[]) AS $$
DECLARE
    x varchar(40);
BEGIN
    FOREACH x IN ARRAY $1
    LOOP
	    INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Estado', NULL);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_municipios(varchar(40)[], text) AS $$
DECLARE
    found_id integer = (SELECT cod_luga FROM Lugar WHERE nombre_luga = $2 AND tipo_luga = 'Estado' LIMIT 1);
    x varchar(40);
BEGIN
    FOREACH x IN ARRAY $1
    LOOP
	    INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Municipio', found_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_parroquias(varchar(40)[], text) AS $$
DECLARE
    found_id integer = (SELECT cod_luga FROM Lugar WHERE nombre_luga = $2 AND tipo_luga = 'Municipio' LIMIT 1);
    x varchar(40);
BEGIN
    FOREACH x IN ARRAY $1
    LOOP
	    INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Parroquia', found_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

DELETE FROM Lugar;

--[[ PROCEDURE TIENDA,
-- DEPENDENT get_parroquia() ]]--
CREATE OR REPLACE PROCEDURE add_tienda (nombre varchar(40), fecha date, direccion text, nom_parroquia varchar(40), nom_estado varchar(40))
    AS $$
BEGIN
    INSERT INTO Tienda (nombre_tien, fecha_apertura_tien, direccion_tien, fk_luga)
        VALUES (nombre, fecha, direccion, get_parroquia (nom_parroquia));
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_departamento (nombre varchar(40), parroquia varchar(40), estado varchar(40), tienda varchar(40))
    AS $$
BEGIN
    INSERT INTO Departamento (fk_tien, nombre_depa)
        VALUES (get_tienda (parroquia, estado, tienda), nombre);
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_departamento_tienda_1 (nombre varchar(40))
    AS $$
BEGIN
    INSERT INTO Departamento (fk_tien, nombre_depa)
        VALUES (get_tienda_1 (), nombre);
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE EMPLEADO, INDEPENDENT ]]--

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
        VALUES ('admin', p_nom || ' ' || p_ape, 300, x);
END;
$$;

-- [[ PROCEDURE EMPL_CARG
-- DEPENDENT get_tienda_1, get_departamento_1 ]]--

CREATE OR REPLACE PROCEDURE add_empl_carg_to_tien_1 (ci integer, nombre_carg varchar(40), ini date, fin date, montoTotal integer, nombre_derp varchar(40))
    AS $$
DECLARE
    fk_depa1 integer;
BEGIN
    INSERT INTO EMPL_CARG (fk_empl, fk_carg, fecha_ini, fecha_fin, cantidad_total_salario, fk_depa_1, fk_depa_2)
        VALUES (get_empleado (ci), get_cargo (nombre_carg), ini, fin, montoTotal, get_departamento (nombre_derp), get_tienda_1 ());
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE EMPL_BENE ]]--
CREATE OR REPLACE PROCEDURE give_benefits ()
    AS $$
DECLARE
    bene integer;
    e_c record;
BEGIN
    FOR e_c IN (
        SELECT
            *
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO EMPL_BENE (fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3, fk_bene, monto_bene)
                VALUES (e_c.fk_empl, e_c.fk_carg, e_c.cod_empl_carg, (
                        SELECT
                            cod_bene
                        FROM
                            Beneficio
                        ORDER BY
                            RANDOM()
                        LIMIT 1),
                    100);
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE VACACION ]]--
CREATE OR REPLACE PROCEDURE create_vacaciones ()
    AS $$
DECLARE
    e_c record;
BEGIN
    FOR e_c IN (
        SELECT
            *
        FROM
            EMPL_CARG)
        LOOP
            INSERT INTO Vacacion (fecha_ini_vaca, fecha_fin_vaca, pagada, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                VALUES ('2024-12-12', '2025-01-01', FALSE, e_c.fk_empl, e_c.fk_carg, e_c.cod_empl_carg);
        END LOOP;
END
$$
LANGUAGE plpgsql;

-- [[ PROCEDURE, ASISTENCIA ]]--
CREATE OR REPLACE PROCEDURE generate_asistencia_entries ()
    AS $$
DECLARE
    emp record;
    start_date date := '2024-10-11';
    business_day date;
    start_hour interval;
    end_hour interval;
BEGIN
    FOR emp IN SELECT DISTINCT
        *
    FROM
        EMPL_CARG LOOP
            FOR i IN 0..9 LOOP
                business_day := start_date + i;
                IF RANDOM() >= 0.05 THEN
                    start_hour := INTERVAL '9 hours' + (RANDOM() * INTERVAL '30 minutes');
                    end_hour := INTERVAL '17 hours' + (RANDOM() * INTERVAL '30 minutes');
                    INSERT INTO Asistencia (fecha_hora_ini_asis, fecha_hora_fin_asis, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                        VALUES (business_day + start_hour, business_day + end_hour, emp.fk_empl, emp.fk_carg, emp.cod_empl_carg);
                END IF;
            END LOOP;
        END LOOP;
END
$$
LANGUAGE plpgsql;

--[[ PROCEDURE EMPL_HORA ]]--
CREATE OR REPLACE PROCEDURE insert_empl_hora ()
    AS $$
DECLARE
    rec_horario RECORD;
    rec_empl_carg RECORD;
BEGIN
    FOR rec_horario IN
    SELECT
        *
    FROM
        Horario
    LIMIT 7 LOOP
        FOR rec_empl_carg IN
        SELECT
            *
        FROM
            EMPL_CARG LOOP
                INSERT INTO EMPL_HORA (fk_hora, fk_empl_carg_1, fk_empl_carg_2, fk_empl_carg_3)
                    VALUES (rec_horario.cod_hora, rec_empl_carg.fk_empl, rec_empl_carg.fk_carg, rec_empl_carg.cod_empl_carg);
            END LOOP;
    END LOOP;
END
$$
LANGUAGE plpgsql;

--[[[ INSERT BEGIN ]]]--

--[[ INSERT ROL, INDEPENDENT ]]--
INSERT INTO Rol
    VALUES (100, 'Miembro', 'Proveedor de Cervezas'),
    (200, 'Cliente Natural', 'Persona Natural, compra cervezas'),
    (201, 'Cliente Juridico', 'Persona Juridica, puede comprar cervezas, usualmente en gran cantidad'),
    (300, 'Empleado Regular', 'Empleado del mas bajo nivel'),
    (301, 'Empleado Ventas en Linea', 'Empleado encargado de manejar las ventas en linea'),
    (302, 'Empleado Despacho', 'Empleado encargado de manejar y gestionar inventario y pasillo'),
    (303, 'Empleado Entrega', 'Empleado encargado de la logistica de entrega de cervezas'),
    (304, 'Empleado Compras', 'Empleado encargado de la logistica de compras y ordenes de reposicion'),
    (400, 'Empleado Administrador', 'Empleado encargado de administrar otros empleados'),
    (500, 'Administrador', 'Empleado encargado de administrar todo el sistema');

--[[ INSERT TASA, INDEPENDENT ]]--
INSERT INTO Tasa (tasa_dolar_bcv, tasa_punto, fecha_ini_tasa, fecha_fin_tasa)
    VALUES (36.50, 1.00, '2024-01-01', '2024-01-02'),
    (36.75, 1.00, '2024-01-02', '2024-01-03'),
    (37.00, 1.00, '2024-01-03', '2024-01-04'),
    (37.25, 1.00, '2024-01-04', '2024-01-05'),
    (37.50, 1.00, '2024-01-05', '2024-01-06'),
    (37.80, 1.00, '2024-01-06', '2024-01-07'),
    (38.00, 1.00, '2024-01-07', '2024-01-08'),
    (38.20, 1.00, '2024-01-08', '2024-01-09'),
    (38.50, 1.00, '2024-01-09', '2024-01-10'),
    (38.75, 1.00, '2024-01-10', '2024-01-11');

--[[ INSERT CARGO, INDEPENDENT ]]--
INSERT INTO Cargo (nombre_carg)
    VALUES ('Administrador'),
    ('Gerente'),
    ('Analista'),
    ('Jefe'),
    ('Especialista de Marketing'),
    ('Contador'),
    ('Coordinador de Eventos'),
    ('Gestor de Inventario'),
    ('Especialista de Reportes'),
    ('Empleado'),
    ('Vigilante');

--[[ INSERT BANCO, INDEPENDENT ]]--
INSERT INTO Banco (nombre_banc)
    VALUES ('Banco de Venezuela'),
    ('Bancamiga'),
    ('Banesco'),
    ('Banco Mercantil'),
    ('Banco Nacional de Crédito (BNC)'),
    ('Banco del Tesoro'),
    ('Banco Exterior'),
    ('Banco Provincial'),
    ('Banco Caroní'),
    ('Banco Sofitasa'),
    ('Banca Amiga'),
    ('Banco Agrícola de Venezuela'),
    ('Banco Bicentenario'),
    ('Banco del Caribe');

-- [[ INSERT CUOTA, INDEPENDENT ]]--
INSERT INTO Cuota (nombre_plan_cuot, precio_cuot)
    VALUES ('Monthly Plan January 2024', 50.00),
    ('Monthly Plan February 2024', 50.00),
    ('Monthly Plan March 2024', 50.00),
    ('Monthly Plan April 2024', 50.00),
    ('Monthly Plan May 2024', 50.00),
    ('Monthly Plan June 2024', 50.00),
    ('Monthly Plan July 2024', 50.00),
    ('Monthly Plan August 2024', 50.00),
    ('Monthly Plan September 2024', 50.00),
    ('Monthly Plan October 2024', 50.00);

-- [[ INSERT TIPO_EVENTO, INDEPENDENT ]]--
INSERT INTO Tipo_Evento (nombre_tipo_even)
    VALUES ('Cata de cervezas'),
    ('Recorrido por cerveceria'),
    ('Festival de Cervezas'),
    ('Cena de Maridaje'),
    ('Taller de Elaboracion de Cerveza'),
    ('Fiesta de Lanzamiento de Cervezas de Temporada'),
    ('Noche de Musica en Vivo'),
    ('Noche de Trivia'),
    ('Evento de Cerveza y Arte'),
    ('Evento de Networking Para Cerveceros');

-- [[ INSERT LUGAR_TIENDA, INDEPENDENT ]]--
INSERT INTO Lugar_Tienda (nombre_luga_tien, tipo_luga_tien, fk_luga_tien)
    VALUES ('Almacen Principal', 'Almacen', NULL),
    ('Pasillo 1', 'Pasillo', 1),
    ('Pasillo 2', 'Pasillo', 1),
    ('Anaquel A1', 'Anaquel', 2),
    ('Anaquel A2', 'Anaquel', 2),
    ('Pasillo 3', 'Pasillo', 1),
    ('Anaquel B1', 'Anaquel', 3),
    ('Almacen Secundario', 'Almacen', NULL),
    ('Pasillo 4', 'Pasillo', 8),
    ('Anaquel C1', 'Anaquel', 9);

-- [[ INSERT HORARIO, INDEPENDENT ]]--
INSERT INTO Horario (hora_ini_hora, hora_fin_hora, dia_hora)
    VALUES ('08:00', '16:00', 'Lunes'),
    ('09:00', '17:00', 'Martes'),
    ('10:00', '18:00', 'Miercoles'),
    ('07:30', '15:30', 'Jueves'),
    ('12:00', '20:00', 'Viernes'),
    ('08:00', '14:00', 'Sabado'),
    ('09:00', '13:00', 'Domingo'),
    ('14:00', '22:00', 'Lunes'),
    ('16:00', '00:00', 'Viernes'),
    ('18:00', '02:00', 'Sabado');

-- [[ INSERT BENEFICIO, INDEPENDENT ]]--
INSERT INTO Beneficio (nombre_bene, cantidad_bene)
	VALUES ('Salario Competitivo', 50000),
	('Seguro de Salud', 2000),
	('Vacaciones Pagadas', 3000),
	('Bonificaciones Anuales', 5000),
	('Capacitación y Desarrollo', 1500),
	('Horario Flexible', 0),
	('Trabajo Remoto', 0),
	('Plan de Jubilación', 3000),
	('Días de Enfermedad Pagados', 2000),
	('Beneficios de Bienestar', 1000);

--[[ INSERT ESTADOS, 
-- DEPENDENT on PROCEDURE ESTADOS ]]--
CALL insert_estados(ARRAY ['Amazonas', 'Anzoategui', 'Apure', 'Aragua', 'Barinas', 'Bolivar', 'Carabobo', 'Cojedes', 'Delta Amacuro', 'Distrito Capital', 'Falcon', 'Guarico', 'La Guaira', 'Lara', 'Merida', 'Miranda', 'Monagas', 'Nueva Esparta', 'Portuguesa', 'Sucre', 'Tachira', 'Trujillo', 'Yaracuy', 'Zulia']);

-- Amazonas
CALL insert_municipios(ARRAY['Altures', 'Alto Orinoco', 'Atabapo', 'Autana', 'Manapiare', 'Maroa', 'Rio Negro'], 'Amazonas');
CALL insert_parroquias(ARRAY['Fernando Giron Tovar', 'Luis Alberto Gomez', 'Parhueña', 'Platanillal'], 'Altures');
CALL insert_parroquias(ARRAY['La Esmeralda', 'Marawaka', 'Mavaca', 'Sierra Parima'], 'Alto Orinoco');
CALL insert_parroquias(ARRAY['San Fernando de Atabapo', 'Laja Lisa', 'Santa Barbara', 'Guarinuma'], 'Atabapo');
CALL insert_parroquias(ARRAY['Isla Raton', 'San Pedro del Orinoco', 'Pendare', 'Manduapo', 'Samariapo'], 'Autana');
CALL insert_parroquias(ARRAY['San Juan de Manapiare', 'Camani', 'Capure', 'Manueta'], 'Manapiare');
CALL insert_parroquias(ARRAY['Maroa', 'Comunidad', 'Victorino'], 'Maroa');
CALL insert_parroquias(ARRAY['San Carlos de Rio Negro', 'Solano', 'Curimacare', 'Santa Lucia'], 'Rio Negro');

-- Anzoategui
CALL insert_municipios(ARRAY['Anaco', 'Aragua', 'Diego Bautista Urbaneja', 'Fernando de Peñalver', 'Francisco del Carmen Carvajal', 'Francisco de Miranda', 'Guanta', 'Independencia', 'Jose Gregorio Monagas', 'Juan Antonio Sotillo', 'Juan Manuel Cajigal', 'Libertad', 'Manuel Ezequiel Bruzual', 'Pedro Maria Freites', 'Piritu', 'Guanipa', 'San Juan de Capistrano', 'Santa Ana', 'Simon Bolivar', 'Simon Rodriguez', 'Sir Arthur McGregor'], 'Anzoategui');
CALL insert_parroquias(ARRAY['Anaco', 'San Joaquin'], 'Anaco');
CALL insert_parroquias(ARRAY['Cachipo', 'Aragua de Barcelona'], 'Aragua');
CALL insert_parroquias(ARRAY['Lecheria', 'El Morro'], 'Diego Bautista Urbaneja');
CALL insert_parroquias(ARRAY['San Miguel', 'Sucre'], 'Fernando de Peñalver');
CALL insert_parroquias(ARRAY['Valle de Guanape', 'Santa Barbara'], 'Francisco del Carmen Carvajal');
CALL insert_parroquias(ARRAY['Atapirire', 'Boca del Pao', 'El Pao', 'Pariaguan'], 'Francisco de Miranda');
CALL insert_parroquias(ARRAY['Guanta', 'Chorreron'], 'Guanta');
CALL insert_parroquias(ARRAY['Mamo', 'Soledad'], 'Independencia');
CALL insert_parroquias(ARRAY['Mapire', 'Piar', 'Santa Clara', 'San Diego de Cabrutica', 'Uverito', 'Zuata'], 'Jose Gregorio Monagas');
CALL insert_parroquias(ARRAY['Puerto La Cruz', 'Pozuelos'], 'Juan Antonio Sotillo');
CALL insert_parroquias(ARRAY['Onoto', 'San Pablo'], 'Juan Manuel Cajigal');
CALL insert_parroquias(ARRAY['San Mateo', 'El Carito', 'Santa Ines', 'La Romereña'], 'Libertad');
CALL insert_parroquias(ARRAY['Clarines', 'Guanape', 'Sabana de Uchire'], 'Manuel Ezequiel Bruzual');
CALL insert_parroquias(ARRAY['Cantaura', 'Libertador', 'Santa Rosa', 'Urica'], 'Pedro Maria Freites');
CALL insert_parroquias(ARRAY['Piritu', 'San Francisco'], 'Piritu');
CALL insert_parroquias(ARRAY['San Jose de Guanipa'], 'Guanipa');
CALL insert_parroquias(ARRAY['Boca de Uchire', 'Boca de Chavez'], 'San Juan de Capistrano');
CALL insert_parroquias(ARRAY['Pueblo Nuevo', 'Santa Ana'], 'Santa Ana');
CALL insert_parroquias(ARRAY['Bergantin', 'El Pilar', 'Naricual', 'San Cristobal'], 'Simon Bolivar');
CALL insert_parroquias(ARRAY['Edmundo Barrios', 'Miguel Otero Silva'], 'Simon Rodriguez');
CALL insert_parroquias(ARRAY['El Chaparro', 'Tomas Alfaro', 'Calatrava'], 'Sir Arthur McGregor');

-- Apure
CALL insert_municipios(ARRAY['Achaguas', 'Biruaca', 'Muñoz', 'Paez', 'Pedro Camejo', 'Romulo Gallegos', 'San Fernando'], 'Apure');
CALL insert_parroquias(ARRAY['Achaguas', 'Apurito', 'El Yagual', 'Guachara', 'Mucuritas', 'Queseras del Medio'], 'Achaguas');
CALL insert_parroquias(ARRAY['Biruaca'], 'Biruaca');
CALL insert_parroquias(ARRAY['Bruzual', 'Santa Barbara'], 'Muñoz');
CALL insert_parroquias(ARRAY['Guasdualito', 'Aramendi', 'El Amparo', 'San Camilo', 'Urdaneta', 'Canagua', 'Dominga Ortiz de Paez', 'Santa Rosalia'], 'Paez');
CALL insert_parroquias(ARRAY['San Juan de Payara', 'Codazzi', 'Cunaviche'], 'Pedro Camejo');
CALL insert_parroquias(ARRAY['Elorza', 'La Trinidad de Orichuna'], 'Romulo Gallegos');
CALL insert_parroquias(ARRAY['El Recreo', 'Peñalver', 'San Fernando de Apure', 'San Rafael de Atamaica'], 'San Fernando');

-- Aragua 
CALL insert_municipios(ARRAY['Girardot', 'Bolivar', 'Mario Briceño Iragorry', 'Santos Michelena', 'Sucre', 'Santiago Mariño', 'Jose angel Lamas', 'Francisco Linares Alcantara', 'San Casimiro', 'Urdaneta', 'Jose Felix Ribas', 'Jose Rafael Revenga', 'Ocumare de la Costa de Oro', 'Tovar', 'Camatagua', 'Zamora', 'San Sebastian', 'Libertador'], 'Aragua'); 
CALL insert_parroquias(ARRAY['Bolivar San Mateo'], 'Bolivar');
CALL insert_parroquias(ARRAY['Camatagua', 'Carmen de Cura'], 'Camatagua');
CALL insert_parroquias(ARRAY['Santa Rita', 'Francisco de Miranda', 'Moseñor Feliciano Gonzalez Paraparal'], 'Francisco Linares Alcantara');
CALL insert_parroquias(ARRAY['Pedro Jose Ovalles', 'Joaquin Crespo', 'Jose Casanova Godoy', 'Madre Maria de San Jose', 'Andres Eloy Blanco', 'Los Tacarigua', 'Las Delicias', 'Choroni'], 'Girardot');
CALL insert_parroquias(ARRAY['Santa Cruz'], 'Jose angel Lamas');
CALL insert_parroquias(ARRAY['Jose Felix Ribas', 'Castor Nieves Rios', 'Las Guacamayas', 'Pao de Zarate', 'Zuata'], 'Jose Felix Ribas');
CALL insert_parroquias(ARRAY['Jose Rafael Revenga'], 'Jose Rafael Revenga');
CALL insert_parroquias(ARRAY['Palo Negro', 'San Martin de Porres'], 'Libertador');
CALL insert_parroquias(ARRAY['El Limon', 'Caña de Azucar'], 'Mario Briceño Iragorry');
CALL insert_parroquias(ARRAY['Ocumare de la Costa'], 'Ocumare de la Costa de Oro');
CALL insert_parroquias(ARRAY['San Casimiro', 'Güiripa', 'Ollas de Caramacate', 'Valle Morin'], 'San Casimiro');
CALL insert_parroquias(ARRAY['San Sebastian'], 'San Sebastian');
CALL insert_parroquias(ARRAY['Turmero', 'Arevalo Aponte', 'Chuao', 'Saman de Güere', 'Alfredo Pacheco Miranda'], 'Santiago Mariño');
CALL insert_parroquias(ARRAY['Santos Michelena', 'Tiara'], 'Santos Michelena');
CALL insert_parroquias(ARRAY['Cagua', 'Bella Vista'], 'Sucre');
CALL insert_parroquias(ARRAY['Tovar'], 'Tovar');
CALL insert_parroquias(ARRAY['Urdaneta', 'Las Peñitas', 'San Francisco de Cara', 'Taguay'], 'Urdaneta');
CALL insert_parroquias(ARRAY['Zamora', 'Magdaleno', 'San Francisco de Asis', 'Valles de Tucutunemo', 'Augusto Mijares'], 'Zamora');

-- Barinas
CALL insert_municipios(ARRAY['Alberto Arvelo Torrealba', 'Andres Eloy Blanco', 'Antonio Jose de Sucre', 'Arismendi', 'Barinas', 'Bolivar', 'Cruz Paredes', 'Ezequiel Zamora', 'Obispos', 'Pedraza', 'Sosa', 'Rojas'], 'Barinas');
CALL insert_parroquias(ARRAY['Arismendi', 'Guadarrama', 'La Union', 'San Antonio'], 'Arismendi');
CALL insert_parroquias(ARRAY['Barinas', 'Alfredo Arvelo Larriva', 'San Silvestre', 'Santa Ines', 'Santa Lucia', 'Torunos', 'El Carmen', 'Romulo Betancourt', 'Corazon de Jesus', 'Ramon Ignacio Mendez', 'Alto Barinas', 'Manuel Palacio Fajardo', 'Juan Antonio Rodriguez Dominguez', 'Dominga Ortiz de Paez'], 'Barinas');
CALL insert_parroquias(ARRAY['El Canton', 'Santa Cruz de Guacas', 'Puerto Vivas'], 'Andres Eloy Blanco');
CALL insert_parroquias(ARRAY['Barinitas', 'Altamira de Caceres', 'Calderas'], 'Bolivar');
CALL insert_parroquias(ARRAY['Masparrito', 'El Socorro', 'Barrancas'], 'Cruz Paredes');
CALL insert_parroquias(ARRAY['Obispos', 'El Real', 'La Luz', 'Los Guasimitos'], 'Obispos');
CALL insert_parroquias(ARRAY['Ciudad Bolivia', 'Ignacio Briceño', 'Jose Felix Ribas', 'Paez'], 'Pedraza');
CALL insert_parroquias(ARRAY['Libertad', 'Dolores', 'Santa Rosa', 'Simon Rodriguez', 'Palacio Fajardo'], 'Rojas');
CALL insert_parroquias(ARRAY['Ciudad de Nutrias', 'El Regalo', 'Puerto Nutrias', 'Santa Catalina', 'Simon Bolivar'], 'Sosa');
CALL insert_parroquias(ARRAY['Ticoporo', 'Nicolas Pulido', 'Andres Bello'], 'Antonio Jose de Sucre');
CALL insert_parroquias(ARRAY['Sabaneta', 'Juan Antonio Rodriguez Dominguez'], 'Alberto Arvelo Torrealba');
CALL insert_parroquias(ARRAY['Santa Barbara', 'Pedro Briceño Mendez', 'Ramon Ignacio Mendez', 'Jose Ignacio del Pumar'], 'Ezequiel Zamora');

-- Bolivar
CALL insert_municipios(ARRAY['Caroni', 'Cedeño', 'El Callao', 'Gran Sabana', 'Heres', 'Padre Pedro Chien', 'Piar', 'Angostura', 'Roscio', 'Sifontes', 'Sucre'], 'Bolivar');
CALL insert_parroquias(ARRAY['Cachamay', 'Chirica', 'Dalla Costa', 'Once de Abril', 'Simon Bolivar', 'Unare', 'Universidad', 'Vista al Sol', 'Pozo Verde', 'Yocoima', '5 de Julio'], 'Caroni');
CALL insert_parroquias(ARRAY['Cedeño', 'Altagracia', 'Ascension Farreras', 'Guaniamo', 'La Urbana', 'Pijiguaos'], 'Cedeño');
CALL insert_parroquias(ARRAY['El Callao'], 'El Callao');
CALL insert_parroquias(ARRAY['Gran Sabana', 'Ikabaru'], 'Gran Sabana');
CALL insert_parroquias(ARRAY['Catedral', 'Zea', 'Orinoco', 'Jose Antonio Paez', 'Marhuanta', 'Agua Salada', 'Vista Hermosa', 'La Sabanita', 'Panapana'], 'Heres');
CALL insert_parroquias(ARRAY['Padre Pedro Chien'], 'Padre Pedro Chien');
CALL insert_parroquias(ARRAY['Andres Eloy Blanco', 'Pedro Cova', 'Upata'], 'Piar');
CALL insert_parroquias(ARRAY['Raul Leoni', 'Barceloneta', 'Santa Barbara', 'San Francisco'], 'Angostura');
CALL insert_parroquias(ARRAY['Roscio', 'Salom'], 'Roscio');
CALL insert_parroquias(ARRAY['Tumeremo', 'Dalla Costa', 'San Isidro'], 'Sifontes');
CALL insert_parroquias(ARRAY['Sucre', 'Aripao', 'Guarataro', 'Las Majadas', 'Moitaco'], 'Sucre');

-- Carabobo
CALL insert_municipios(ARRAY['Bejuma','Carlos Arvelo','Diego Ibarra','Guacara','Juan Jose Mora','Libertador','Los Guayos','Miranda','Montalban','Naguanagua','Puerto Cabello','San Diego','San Joaquin','Valencia'],'Carabobo');
CALL insert_parroquias(ARRAY['Canoabo', 'Simon Bolivar'], 'Bejuma');
CALL insert_parroquias(ARRAY['Güigüe', 'Belen', 'Tacarigua'], 'Carlos Arvelo');
CALL insert_parroquias(ARRAY['Mariara', 'Aguas Calientes'], 'Diego Ibarra');
CALL insert_parroquias(ARRAY['Ciudad Alianza', 'Guacara', 'Yagua'], 'Guacara');
CALL insert_parroquias(ARRAY['Moron', 'Urama'], 'Juan Jose Mora');
CALL insert_parroquias(ARRAY['Tocuyito Valencia', 'Independencia Campo Carabobo'], 'Libertador');
CALL insert_parroquias(ARRAY['Los Guayos Valencia'], 'Los Guayos');
CALL insert_parroquias(ARRAY['Miranda'], 'Miranda');
CALL insert_parroquias(ARRAY['Montalban'], 'Montalban');
CALL insert_parroquias(ARRAY['Urbana Naguanagua Valencia'], 'Naguanagua');
CALL insert_parroquias(ARRAY['Bartolome Salom', 'Democracia', 'Fraternidad', 'Goaigoaza', 'Juan Jose Flores', 'Union', 'Borburata', 'Patanemo'], 'Puerto Cabello');
CALL insert_parroquias(ARRAY['San Diego Valencia'], 'San Diego');
CALL insert_parroquias(ARRAY['San Joaquin'], 'San Joaquin');
CALL insert_parroquias(ARRAY['Urbana Candelaria', 'Urbana Catedral', 'Urbana El Socorro', 'Urbana Miguel Peña', 'Urbana Rafael Urdaneta', 'Urbana San Blas', 'Urbana San Jose', 'Urbana Santa Rosa', 'Rural Negro Primero'], 'Valencia');

-- Cojedes
CALL insert_municipios(ARRAY['Anzoategui','Pao de San Juan Bautista','Tinaquillo','Girardot','Lima Blanco','Ricaurte','Romulo Gallegos','Ezequiel Zamora','Tinaco'],'Cojedes');
CALL insert_parroquias(ARRAY['Cojedes', 'Juan de Mata Suarez'], 'Anzoategui');
CALL insert_parroquias(ARRAY['El Pao'], 'Pao de San Juan Bautista');
CALL insert_parroquias(ARRAY['Tinaquillo'], 'Tinaquillo');
CALL insert_parroquias(ARRAY['El Baul', 'Sucre'], 'Girardot');
CALL insert_parroquias(ARRAY['La Aguadita', 'Macapo'], 'Lima Blanco');
CALL insert_parroquias(ARRAY['El Amparo', 'Libertad de Cojedes'], 'Ricaurte');
CALL insert_parroquias(ARRAY['Romulo Gallegos (Las Vegas)'], 'Romulo Gallegos');
CALL insert_parroquias(ARRAY['San Carlos de Austria', 'Juan angel Bravo', 'Manuel Manrique'], 'Ezequiel Zamora');
CALL insert_parroquias(ARRAY['General en Jefe Jos Laurencio Silva'], 'Tinaco');

-- Delta Amacuro
CALL insert_municipios(ARRAY['Antonio Diaz','Casacoima','Pedernales','Tucupita'],'Delta Amacuro');
CALL insert_parroquias(ARRAY['Curiapo','Almirante Luis Brion','Francisco Aniceto Lugo','Manuel Renaud','Padre Barral','Santos de Abelgas'],'Antonio Diaz');
CALL insert_parroquias(ARRAY['Imataca','Juan Bautista Arismendi','Manuel Piar','Romulo Gallegos'],'Casacoima');
CALL insert_parroquias(ARRAY['Pedernales','Luis Beltran Prieto Figueroa'],'Pedernales');
CALL insert_parroquias(ARRAY['San Jose','Jose Vidal Marcano','Leonardo Ruiz Pineda','Mariscal Antonio Jose de Sucre','Monseñor Argimiro Garcia','Virgen del Valle','San Rafael','Juan Millan'],'Tucupita');

-- Distrito Federal
CALL insert_municipios(ARRAY['Libertador'],'Distrito Capital');
CALL insert_parroquias(ARRAY['23 de Enero','Altagracia','Antimano','Caricuao','Catedral','Coche','El Junquito','El Paraiso','El Recreo','El Valle','La Candelaria','La Pastora','La Vega','Macarao','San Agustin','San Bernardino','San Jose','San Juan','San Pedro','Santa Rosalia','Santa Teresa','Sucre'],'Libertador');

-- Falcon
CALL insert_municipios(ARRAY['Acosta','Bolivar','Buchivacoa','Cacique Manaure','Carirubana','Colina','Dabajuro','Democracia','Falcon','Federacion','Jacura','Los Taques','Mauroa','Miranda','Monseñor Iturriza','Palmasola','Petit','Piritu','San Francisco','Jose Laurencio Silva','Sucre','Tocopero','Union','Urumaco','Zamora'],'Falcon');
CALL insert_parroquias(ARRAY['Capadare', 'La Pastora', 'Libertador', 'San Juan de los Cayos'], 'Acosta');
CALL insert_parroquias(ARRAY['Aracua', 'La Peña', 'San Luis'], 'Bolivar');
CALL insert_parroquias(ARRAY['Bariro', 'Borojo', 'Capatarida', 'Guajiro', 'Seque', 'Valle de Eroa', 'Zazarida'], 'Buchivacoa');
CALL insert_parroquias(ARRAY['Cacique Manaure (Yaracal)'], 'Cacique Manaure');
CALL insert_parroquias(ARRAY['Norte', 'Carirubana', 'Santa Ana', 'Urbana Punta Cardon'], 'Carirubana');
CALL insert_parroquias(ARRAY['La Vela de Coro', 'Acurigua', 'Guaibacoa', 'Las Calderas', 'Mataruca'], 'Colina');
CALL insert_parroquias(ARRAY['Dabajuro'], 'Dabajuro');
CALL insert_parroquias(ARRAY['Agua Clara', 'Avaria', 'Pedregal', 'Piedra Grande', 'Purureche'], 'Democracia');
CALL insert_parroquias(ARRAY['Adaure', 'Adicora', 'Baraived', 'Buena Vista', 'Jadacaquiva', 'El Vinculo', 'El Hato', 'Moruy', 'Pueblo Nuevo'], 'Falcon');
CALL insert_parroquias(ARRAY['Agua Larga', 'Churuguara', 'El Pauji', 'Independencia', 'Maparari'], 'Federacion');
CALL insert_parroquias(ARRAY['Agua Linda', 'Araurima', 'Jacura'], 'Jacura');
CALL insert_parroquias(ARRAY['Tucacas', 'Boca de Aroa'], 'Jose Laurencio Silva');
CALL insert_parroquias(ARRAY['Los Taques', 'Judibana'], 'Los Taques');
CALL insert_parroquias(ARRAY['Mene de Mauroa', 'San Felix', 'Casigua'], 'Mauroa');
CALL insert_parroquias(ARRAY['Guzman Guillermo', 'Mitare', 'Rio Seco', 'Sabaneta', 'San Antonio', 'San Gabriel', 'Santa Ana'], 'Miranda');
CALL insert_parroquias(ARRAY['Boca del Tocuyo', 'Chichiriviche', 'Tocuyo de la Costa'], 'Monseñor Iturriza');
CALL insert_parroquias(ARRAY['Palmasola'], 'Palmasola');
CALL insert_parroquias(ARRAY['Cabure', 'Colina', 'Curimagua'], 'Petit');
CALL insert_parroquias(ARRAY['San Jose de la Costa', 'Piritu'], 'Piritu');
CALL insert_parroquias(ARRAY['Capital San Francisco Mirimire'], 'San Francisco');
CALL insert_parroquias(ARRAY['Sucre', 'Pecaya'], 'Sucre');
CALL insert_parroquias(ARRAY['Tocopero'], 'Tocopero');
CALL insert_parroquias(ARRAY['El Charal', 'Las Vegas del Tuy', 'Santa Cruz de Bucaral'], 'Union');
CALL insert_parroquias(ARRAY['Bruzual', 'Urumaco'], 'Urumaco');
CALL insert_parroquias(ARRAY['Puerto Cumarebo', 'La Cienaga', 'La Soledad', 'Pueblo Cumarebo', 'Zazarida'], 'Zamora');

-- Guarico
CALL insert_municipios(ARRAY['Leonardo Infante','Julian Mellado','Francisco de Miranda','Monagas','Ribas','Roscio','Camaguan','San Jose de Guaribe','Las Mercedes','El Socorro','Ortiz','Santa Maria de Ipire','Chaguaramas','San Jeronimo de Guayabal', 'Juan Jose Rondon', 'Jose Felix Ribas', 'Jose Tadeo Monagas','Juan German Roscio','Pedro Zaraza'],'Guarico');
CALL insert_parroquias(ARRAY['Camaguan', 'Puerto Miranda', 'Uverito'], 'Camaguan');
CALL insert_parroquias(ARRAY['Chaguaramas'], 'Chaguaramas');
CALL insert_parroquias(ARRAY['El Socorro'], 'El Socorro');
CALL insert_parroquias(ARRAY['El Calvario', 'El Rastro', 'Guardatinajas', 'Capital Urbana Calabozo'], 'Francisco de Miranda');
CALL insert_parroquias(ARRAY['Tucupido', 'San Rafael de Laya'], 'Jose Felix Ribas');
CALL insert_parroquias(ARRAY['Altagracia de Orituco', 'San Rafael de Orituco', 'San Francisco Javier de Lezama', 'Paso Real de Macaira', 'Carlos Soublette', 'San Francisco de Macaira', 'Libertad de Orituco'], 'Jose Tadeo Monagas');
CALL insert_parroquias(ARRAY['Cantagallo', 'San Juan de los Morros', 'Parapara'], 'Juan German Roscio');
CALL insert_parroquias(ARRAY['El Sombrero', 'Sosa'], 'Julian Mellado');
CALL insert_parroquias(ARRAY['Las Mercedes', 'Cabruta', 'Santa Rita de Manapire'], 'Juan Jose Rondon');
CALL insert_parroquias(ARRAY['Valle de la Pascua', 'Espino'], 'Leonardo Infante');
CALL insert_parroquias(ARRAY['San Jose de Tiznados', 'San Francisco de Tiznados', 'San Lorenzo de Tiznados', 'Ortiz'], 'Ortiz');
CALL insert_parroquias(ARRAY['San Jose de Unare', 'Zaraza'], 'Pedro Zaraza');
CALL insert_parroquias(ARRAY['Guayabal', 'Cazorla'], 'San Jeronimo de Guayabal');
CALL insert_parroquias(ARRAY['San Jose de Guaribe'], 'San Jose de Guaribe');
CALL insert_parroquias(ARRAY['Santa Maria de Ipire', 'Altamira'], 'Santa Maria de Ipire');

-- La Guaira
CALL insert_municipios(ARRAY['Vargas'], 'La Guaira');
CALL insert_parroquias(ARRAY['Caraballeda','Carayaca','Carlos Soublette','Caruao','Catia La Mar','El Junko','La Guaira','Macuto','Maiquetia','Naiguata','Urimare'],'Vargas');

-- Lara
CALL insert_municipios(ARRAY['Iribarren','Jimenez','Crespo','Andres Eloy Blanco','Urdaneta','Torres','Palavecino','Moran','Simon Planas'],'Lara');
CALL insert_parroquias(ARRAY['Quebrada Honda de Guache', 'Pio Tamayo', 'Yacambu'], 'Andres Eloy Blanco');
CALL insert_parroquias(ARRAY['Freitez', 'Jose Maria Blanco'], 'Crespo');
CALL insert_parroquias(ARRAY['Anzoategui', 'Bolivar', 'Guarico', 'Hilario Luna y Luna', 'Humocaro Bajo', 'Humocaro Alto', 'La Candelaria', 'Moran'], 'Moran');
CALL insert_parroquias(ARRAY['Cabudare', 'Jose Gregorio Bastidas', 'Agua Viva'], 'Palavecino');
CALL insert_parroquias(ARRAY['Buria', 'Gustavo Vega', 'Sarare'], 'Simon Planas');
CALL insert_parroquias(ARRAY['Altagracia', 'Antonio Diaz', 'Camacaro', 'Castañeda', 'Cecilio Zubillaga', 'Chiquinquira', 'El Blanco', 'Espinoza de los Monteros', 'Heriberto Arrollo', 'Lara', 'Las Mercedes', 'Manuel Morillo', 'Montaña Verde', 'Montes de Oca', 'Reyes de Vargas', 'Torres', 'Trinidad Samuel'], 'Torres');
CALL insert_parroquias(ARRAY['Xaguas', 'Siquisique', 'San Miguel', 'Moroturo'], 'Urdaneta');
CALL insert_parroquias(ARRAY['Aguedo Felipe Alvarado', 'Buena Vista', 'Catedral', 'Concepcion', 'El Cuji', 'Juares', 'Guerrera Ana Soto', 'Santa Rosa', 'Tamaca', 'Union'], 'Iribarren');
CALL insert_parroquias(ARRAY['Juan Bautista Rodriguez', 'Cuara', 'Diego de Lozada', 'Paraiso de San Jose', 'San Miguel', 'Tintorero', 'Jose Bernardo Dorante', 'Coronel Mariano Peraza'], 'Jimenez');

-- Merida
CALL insert_municipios(ARRAY['Antonio Pinto Salinas','Aricagua','Arzobispo Chacon','Campo Elias','Caracciolo Parra Olmedo','Cardenal Quintero','Chacanta','El Mucuy','Guaraque','Julio Cesar Salas','Justo Briceño','Libertador','Luis Cristobal Moncada','Rivas Davila','Rangel','Santos Marquina','Tovar','Tulio Febres Cordero','Alberto Adriani','Andres Bello','Miranda','Zea','Sucre','Pueblo Llano','Obispo Ramos de Lora','Padre Noguera'],'Merida');
CALL insert_parroquias(ARRAY['Presidente Betancourt','Presidente Paez','Presidente Romulo Gallegos','Gabriel Picon Gonzalez','Hector Amable Mora','Jose Nucete Sardi','Pulido Mendez'],'Alberto Adriani');
CALL insert_parroquias(ARRAY['Santa Cruz de Mora','Mesa Bolivar','Mesa de Las Palmas'],'Antonio Pinto Salinas');
CALL insert_parroquias(ARRAY['La Azulita'],'Andres Bello');
CALL insert_parroquias(ARRAY['Aricagua','San Antonio'],'Aricagua');
CALL insert_parroquias(ARRAY['Canagua','Capuri','Chacanta','El Molino','Guaimaral','Mucutuy','Mucuchachi'],'Arzobispo Chacon');
CALL insert_parroquias(ARRAY['Fernandez Peña','Matriz','Montalban','Acequias','Jaji','La Mesa','San Jose del Sur'],'Campo Elias');
CALL insert_parroquias(ARRAY['Tucani','Florencio Ramirez'],'Caracciolo Parra Olmedo');
CALL insert_parroquias(ARRAY['Santo Domingo','Las Piedras'],'Cardenal Quintero');
CALL insert_parroquias(ARRAY['Guaraque','Mesa Quintero','Rio Negro'],'Guaraque');
CALL insert_parroquias(ARRAY['Arapuey','Palmira'],'Julio Cesar Salas');
CALL insert_parroquias(ARRAY['San Cristobal de Torondoy','Torondoy'],'Justo Briceño');
CALL insert_parroquias(ARRAY['Antonio Spinetti Dini','Arias','Caracciolo Parra Perez','Domingo Peña', 'Gonzalo Picon Febres','Jacinto Plaza','Juan Rodriguez Suarez','Lasso de la Vega','Mariano Picon Salas','Milla','Osuna Rodriguez','Sagrario','El Morro','Los Nevados'],'Libertador');
CALL insert_parroquias(ARRAY['Andres Eloy Blanco','La Venta','Piñango','Timotes'],'Miranda');
CALL insert_parroquias(ARRAY['Eloy Paredes','San Rafael de Alcazar','Santa Elena de Arenales'],'Obispo Ramos de Lora');
CALL insert_parroquias(ARRAY['Santa Maria de Caparo'],'Padre Noguera');
CALL insert_parroquias(ARRAY['Pueblo Llano'],'Pueblo Llano');
CALL insert_parroquias(ARRAY['Cacute','La Toma','Mucuchies','Mucuruba','San Rafael'],'Rangel');
CALL insert_parroquias(ARRAY['Geronimo Maldonado','Bailadores'],'Rivas Davila');
CALL insert_parroquias(ARRAY['Tabay'],'Santos Marquina');
CALL insert_parroquias(ARRAY['Chiguara','Estanques','Lagunillas','La Trampa','Pueblo Nuevo del Sur','San Juan'],'Sucre');
CALL insert_parroquias(ARRAY['El Amparo','El Llano','San Francisco','Tovar'],'Tovar');
CALL insert_parroquias(ARRAY['Independencia','Maria de la Concepcion Palacios Blanco','Nueva Bolivia','Santa Apolonia'],'Tulio Febres Cordero');
CALL insert_parroquias(ARRAY['Caño El Tigre','Zea'],'Zea');

-- Miranda
CALL insert_municipios(ARRAY['Acevedo','Andres Bello','Baruta','Brion','Buroz','Carrizal','Chacao','Cristobal Rojas','El Hatillo','Guaicaipuro','Independencia','Lander','Los Salias','Paez','Paz Castillo','Pedro Gual','Plaza','Simon Bolivar','Sucre','Urdaneta','Zamora'],'Miranda');
CALL insert_parroquias(ARRAY['Aragüita','Arevalo Gonzalez','Capaya','Caucagua','Panaquire','Ribas','El Cafe','Marizapa','Yaguapa'],'Acevedo');
CALL insert_parroquias(ARRAY['Cumbo','San Jose de Barlovento'],'Andres Bello');
CALL insert_parroquias(ARRAY['El Cafetal','Las Minas','Nuestra Señora del Rosario'],'Baruta');
CALL insert_parroquias(ARRAY['Higuerote','Curiepe','Tacarigua de Brion','Chirimena','Birongo'],'Brion');
CALL insert_parroquias(ARRAY['Mamporal'],'Buroz');
CALL insert_parroquias(ARRAY['Carrizal'],'Carrizal');
CALL insert_parroquias(ARRAY['Chacao'],'Chacao');
CALL insert_parroquias(ARRAY['Charallave','Las Brisas'],'Cristobal Rojas');
CALL insert_parroquias(ARRAY['Santa Rosalia de Palermo de El Hatillo'],'El Hatillo');
CALL insert_parroquias(ARRAY['Altagracia de la Montaña','Cecilio Acosta','Los Teques','El Jarillo','San Pedro','Tacata','Paracotos'],'Guaicaipuro');
CALL insert_parroquias(ARRAY['el Cartanal','Santa Teresa del Tuy'],'Independencia');
CALL insert_parroquias(ARRAY['La Democracia','Ocumare del Tuy','Santa Barbara','La Mata','La Cabrera'],'Lander');
CALL insert_parroquias(ARRAY['San Antonio de los Altos'],'Los Salias');
CALL insert_parroquias(ARRAY['Rio Chico','El Guapo','Tacarigua de la Laguna','Paparo','San Fernando del Guapo'],'Paez');
CALL insert_parroquias(ARRAY['Santa Lucia del Tuy','Santa Rita','Siquire','Soapire'],'Paz Castillo');
CALL insert_parroquias(ARRAY['Cupira','Machurucuto','Guarabe'],'Pedro Gual');
CALL insert_parroquias(ARRAY['Guarenas'],'Plaza');
CALL insert_parroquias(ARRAY['San Antonio de Yare','San Francisco de Yare'],'Simon Bolivar');
CALL insert_parroquias(ARRAY['Cua','Nueva Cua'],'Urdaneta');
CALL insert_parroquias(ARRAY['Leoncio Martinez','Caucagüita','Filas de Mariche','La Dolorita','Petare'],'Sucre');
CALL insert_parroquias(ARRAY['Guatire','Araira'],'Zamora');

-- Monagas
CALL insert_municipios(ARRAY['Acosta','Aguasay','Bolivar','Caripe','Cedeño','Ezequiel Zamora','Libertador','Maturin','Piar','Punceres','Santa Barbara','Sotillo','Uracoa'],'Monagas');
CALL insert_parroquias(ARRAY['San Antonio de Maturin','San Francisco de Maturin'],'Acosta');
CALL insert_parroquias(ARRAY['Aguasay'],'Aguasay');
CALL insert_parroquias(ARRAY['Caripito'],'Bolivar');
CALL insert_parroquias(ARRAY['El Guacharo','La Guanota','Sabana de Piedra','San Agustin','Teresen','Caripe'],'Caripe');
CALL insert_parroquias(ARRAY['Areo','Capital Cedeño','San Felix de Cantalicio','Viento Fresco'],'Cedeño');
CALL insert_parroquias(ARRAY['El Tejero','Punta de Mata'],'Ezequiel Zamora');
CALL insert_parroquias(ARRAY['Chaguaramas','Las Alhuacas','Tabasca','Temblador'],'Libertador');
CALL insert_parroquias(ARRAY['Alto de los Godos','Boqueron','Las Cocuizas','La Cruz','San Simon','El Corozo','El Furrial','Jusepin','La Pica','San Vicente'],'Maturin');
CALL insert_parroquias(ARRAY['Aparicio','Aragua de Maturin','Chaguaramal','El Pinto','Guanaguana','La Toscana','Taguaya'],'Piar');
CALL insert_parroquias(ARRAY['Cachipo','Quiriquire'],'Punceres');
CALL insert_parroquias(ARRAY['Santa Barbara','Moron'],'Santa Barbara');
CALL insert_parroquias(ARRAY['Barrancas','Los Barrancos de Fajardo'],'Sotillo');
CALL insert_parroquias(ARRAY['Uracoa'],'Uracoa');

-- Nueva Esparta
CALL insert_municipios(ARRAY['Antolin del Campo','Arismendi','Diaz','Garcia','Gomez','Maneiro','Marcano','Mariño','Macanao','Tubores','Villalba'],'Nueva Esparta');
CALL insert_parroquias(ARRAY['Antolin del Campo'],'Antolin del Campo');
CALL insert_parroquias(ARRAY['Arismendi'],'Arismendi');
CALL insert_parroquias(ARRAY['San Juan Bautista','Zabala'],'Diaz');
CALL insert_parroquias(ARRAY['Garcia','Francisco Fajardo'],'Garcia');
CALL insert_parroquias(ARRAY['Bolivar','Guevara','Matasiete','Santa Ana','Sucre'],'Gomez');
CALL insert_parroquias(ARRAY['Aguirre','Maneiro'],'Maneiro');
CALL insert_parroquias(ARRAY['Adrian','Juan Griego'],'Marcano');
CALL insert_parroquias(ARRAY['Mariño'],'Mariño');
CALL insert_parroquias(ARRAY['San Francisco de Macanao','Boca de Rio'],'Macanao');
CALL insert_parroquias(ARRAY['Tubores','Los Barales'],'Tubores');
CALL insert_parroquias(ARRAY['Vicente Fuentes','Villalba'],'Villalba');

-- Portuguesa
CALL insert_municipios(ARRAY['Araure','Esteller','Guanare','Guanarito','Ospino','Paez','Sucre','Turen','Monseñor Jose V. de Unda','Agua Blanca','Papelon','San Genaro de Boconoito','San Rafael de Onoto','Santa Rosalia'],'Portuguesa');
CALL insert_parroquias(ARRAY['Araure','Rio Acarigua'],'Araure');
CALL insert_parroquias(ARRAY['Agua Blanca'],'Agua Blanca');
CALL insert_parroquias(ARRAY['Piritu','Uveral'],'Esteller');
CALL insert_parroquias(ARRAY['Cordova','Guanare','San Jose de la Montaña','San Juan de Guanaguanare','Virgen de Coromoto'],'Guanare');
CALL insert_parroquias(ARRAY['Guanarito','Trinidad de la Capilla','Divina Pastora'],'Guanarito');
CALL insert_parroquias(ARRAY['Chabasquen','Peña Blanca'],'Monseñor Jose V. de Unda');
CALL insert_parroquias(ARRAY['Aparicion','La Estacion','Ospino'],'Ospino');
CALL insert_parroquias(ARRAY['Acarigua','Payara','Pimpinela','Ramon Peraza'],'Paez');
CALL insert_parroquias(ARRAY['Caño Delgadito','Papelon'],'Papelon');
CALL insert_parroquias(ARRAY['Antolin Tovar Aquino','Boconoito'],'San Genaro de Boconoito');
CALL insert_parroquias(ARRAY['Santa Fe','San Rafael de Onoto','Thelmo Morles'],'San Rafael de Onoto');
CALL insert_parroquias(ARRAY['Florida','El Playon'],'Santa Rosalia');
CALL insert_parroquias(ARRAY['Biscucuy','Concepcion','San Rafael de Palo Alzado.','San Jose de Saguaz','Uvencio Antonio Velasquez.','Villa Rosa.'],'Sucre');
CALL insert_parroquias(ARRAY['Villa Bruzual','Canelones','Santa Cruz','San Isidro Labrador la colonia'],'Turen');

-- Sucre
CALL insert_municipios(ARRAY['Andres Eloy Blanco','Andres Mata','Arismendi','Benitez','Bermudez','Bolivar','Cajigal','Cruz Salmeron Acosta','Libertador','Mariño','Mejia','Montes','Ribero','Sucre','Valdez'],'Sucre');
CALL insert_parroquias(ARRAY['Mariño','Romulo Gallegos'],'Andres Eloy Blanco');
CALL insert_parroquias(ARRAY['San Jose de Areocuar','Tavera Acosta'],'Andres Mata');
CALL insert_parroquias(ARRAY['Rio Caribe','Antonio Jose de Sucre','El Morro de Puerto Santo','Puerto Santo','San Juan de las Galdonas'],'Arismendi');
CALL insert_parroquias(ARRAY['El Pilar','El Rincon','General Francisco Antonio Vazquez','Guaraunos','Tunapuicito','Union'],'Benitez');
CALL insert_parroquias(ARRAY['Santa Catalina','Santa Rosa','Santa Teresa','Bolivar','Maracapana'],'Bermudez');
CALL insert_parroquias(ARRAY['Marigüitar'],'Bolivar');
CALL insert_parroquias(ARRAY['Libertad','El Paujil','Yaguaraparo'],'Cajigal');
CALL insert_parroquias(ARRAY['Araya','Chacopata','Manicuare'],'Cruz Salmeron Acosta');
CALL insert_parroquias(ARRAY['Tunapuy','Campo Elias'],'Libertador');
CALL insert_parroquias(ARRAY['Irapa','Campo Claro','Marabal','San Antonio de Irapa','Soro'],'Mariño');
CALL insert_parroquias(ARRAY['San Antonio del Golfo'],'Mejia');
CALL insert_parroquias(ARRAY['Cumanacoa','Arenas','Aricagua','Cocollar','San Fernando','San Lorenzo'],'Montes');
CALL insert_parroquias(ARRAY['Cariaco','Catuaro','Rendon','Santa Cruz','Santa Maria'],'Ribero');
CALL insert_parroquias(ARRAY['Altagracia Cumana','Santa Ines Cumana','Valentin Valiente Cumana','Ayacucho Cumana','San Juan','Raul Leoni','Gran Mariscal'],'Sucre');
CALL insert_parroquias(ARRAY['Cristobal Colon','Bideau','Punta de Piedras','Güiria'],'Valdez');

-- Tachira
CALL insert_municipios(ARRAY['Andres Bello','Antonio Romulo Acosta','Ayacucho','Bolivar','Cardenas','Cordoba','Fernandez Feo','Francisco de Miranda','Garcia de Hevia','Guasimos','Independencia','Jauregui','Jose Maria Vargas','Junin','Libertad','Libertador','Lobatera','Michelena','Panamericano','Pedro Maria Ureña','Rafael Urdaneta','Samuel Dario Maldonado','San Cristobal','San Judas Tadeo','Seboruco','Simon Rodriguez','Tariba','Torbes','Uribante'],'Tachira');
CALL insert_parroquias(ARRAY['Cordero'],'Andres Bello');
CALL insert_parroquias(ARRAY['Virgen del Carmen'],'Antonio Romulo Acosta');
CALL insert_parroquias(ARRAY['Rivas Berti','San Juan de Colon','San Pedro del Rio'],'Ayacucho');
CALL insert_parroquias(ARRAY['Isaias Medina Angarita','Juan Vicente Gomez','Palotal','San Antonio del Tachira'],'Bolivar');
CALL insert_parroquias(ARRAY['Amenodoro Rangel Lamus','La Florida','Tariba'],'Cardenas');
CALL insert_parroquias(ARRAY['Santa Ana del Tachira'],'Cordoba');
CALL insert_parroquias(ARRAY['Alberto Adriani','San Rafael del Piñal','Santo Domingo'],'Fernandez Feo');
CALL insert_parroquias(ARRAY['San Jose de Bolivar'],'Francisco de Miranda');
CALL insert_parroquias(ARRAY['Boca de Grita','Jose Antonio Paez','La Fria'],'Garcia de Hevia');
CALL insert_parroquias(ARRAY['Palmira'],'Guasimos');
CALL insert_parroquias(ARRAY['Capacho Nuevo','Juan German Roscio','Roman Cardenas'],'Independencia');
CALL insert_parroquias(ARRAY['Emilio Constantino Guerrero','La Grita','Monseñor Miguel Antonio Salas'],'Jauregui');
CALL insert_parroquias(ARRAY['El Cobre'],'Jose Maria Vargas');
CALL insert_parroquias(ARRAY['Bramon','La Petrolea','Quinimari','Rubio'],'Junin');
CALL insert_parroquias(ARRAY['Capacho Viejo','Cipriano Castro','Manuel Felipe Rugeles'],'Libertad');
CALL insert_parroquias(ARRAY['Abejales','Doradas','Emeterio Ochoa','San Joaquin de Navay'],'Libertador');
CALL insert_parroquias(ARRAY['Lobatera','Constitucion'],'Lobatera');
CALL insert_parroquias(ARRAY['Michelena'],'Michelena');
CALL insert_parroquias(ARRAY['San Pablo','La Palmita'],'Panamericano');
CALL insert_parroquias(ARRAY['Ureña','Nueva Arcadia'],'Pedro Maria Ureña');
CALL insert_parroquias(ARRAY['Delicias'],'Rafael Urdaneta');
CALL insert_parroquias(ARRAY['Bocono','Hernandez','La Tendida'],'Samuel Dario Maldonado');
CALL insert_parroquias(ARRAY['Francisco Romero Lobo','La Concordia','Pedro Maria Morantes','San Juan Bautista','San Sebastian'],'San Cristobal');
CALL insert_parroquias(ARRAY['San Judas Tadeo'],'San Judas Tadeo');
CALL insert_parroquias(ARRAY['Seboruco'],'Seboruco');
CALL insert_parroquias(ARRAY['San Simon'],'Simon Rodriguez');
CALL insert_parroquias(ARRAY['Eleazar Lopez Contreras','Capital Sucre','San Pablo'],'Sucre');
CALL insert_parroquias(ARRAY['San Josecito'],'Torbes');
CALL insert_parroquias(ARRAY['Cardenas','Juan Pablo Peñaloza','Potosi','Pregonero'],'Uribante');

-- Trujillo
CALL insert_municipios(ARRAY['Andres Bello','Bocono','Bolivar','Candelaria','Carache','Escuque','Jose Felipe Marquez Cañizales','Juan Vicente Campo Elias','La Ceiba','Miranda','Monte Carmelo','Motatan','Pampan','Pampanito','Rafael Rangel','San Rafael de Carvajal','Sucre','Trujillo','Urdaneta','Valera'],'Trujillo');
CALL insert_parroquias(ARRAY['Santa Isabel','Araguaney','El Jaguito','La Esperanza'],'Andres Bello');
CALL insert_parroquias(ARRAY['Bocono','Ayacucho','Burbusay','El Carmen','General Ribas','Guaramacal','Monseñor Jauregui','Mosquey','Rafael Rangel','San Jose','San Miguel','Vega de Guaramacal'],'Bocono');
CALL insert_parroquias(ARRAY['Sabana Grande','Cheregüe','Granados'],'Bolivar');
CALL insert_parroquias(ARRAY['Chejende','Arnoldo Gabaldon','Bolivia','Carrillo','Cegarra','Manuel Salvador Ulloa','San Jose'],'Candelaria');
CALL insert_parroquias(ARRAY['Carache','Cuicas','La Concepcion','Panamericana','Santa Cruz'],'Carache');
CALL insert_parroquias(ARRAY['Escuque','La Union','Sabana Libre','Santa Rita'],'Escuque');
CALL insert_parroquias(ARRAY['El Socorro','Antonio Jose de Sucre','Los Caprichos'],'Jose Felipe Marquez Cañizales');
CALL insert_parroquias(ARRAY['Campo Elias','Arnoldo Gabaldon'],'Juan Vicente Campo Elias');
CALL insert_parroquias(ARRAY['Santa Apolonia','El Progreso','La Ceiba','Tres de Febrero'],'La Ceiba');
CALL insert_parroquias(ARRAY['El Dividive','Agua Caliente','Agua Santa','El Cenizo','Valerita'],'Miranda');
CALL insert_parroquias(ARRAY['Monte Carmelo','Buena Vista','Santa Maria del Horcon'],'Monte Carmelo');
CALL insert_parroquias(ARRAY['Motatan','El Baño','Jalisco'],'Motatan');
CALL insert_parroquias(ARRAY['Pampan','Flor de Patria','La Paz','Santa Ana'],'Pampan');
CALL insert_parroquias(ARRAY['Pampanito','La Concepcion','Pampanito II'],'Pampanito');
CALL insert_parroquias(ARRAY['Betijoque','Jose Gregorio Hernandez','La Pueblita','Los Cedros'],'Rafael Rangel');
CALL insert_parroquias(ARRAY['Carvajal','Antonio Nicolas Briceño','Campo Alegre','Jose Leonardo Suarez'],'San Rafael de Carvajal');
CALL insert_parroquias(ARRAY['Sabana de Mendoza','El Paraiso','Junin','Valmore Rodriguez'],'Sucre');
CALL insert_parroquias(ARRAY['Matriz','Andres Linares','Chiquinquira','Cristobal Mendoza','Cruz Carrillo','Monseñor Carrillo','Tres Esquinas'],'Trujillo');
CALL insert_parroquias(ARRAY['La Quebrada','Cabimbu','Jajo','La Mesa','Santiago','Tuñame'],'Urdaneta');
CALL insert_parroquias(ARRAY['Mercedes Diaz','Juan Ignacio Montilla','La Beatriz','La Puerta','Mendoza del Valle de Momboy','San Luis'],'Valera');

-- Yaracuy
CALL insert_municipios(ARRAY['Aristides Bastidas','Bolivar','Bruzual','Cocorote','Independencia','Jose Antonio Paez','La Trinidad','Manuel Monge','Nirgua','Peña','San Felipe','Sucre','Urachiche','Veroes'],'Yaracuy');
CALL insert_parroquias(ARRAY['Aristides Bastidas'],'Aristides Bastidas');
CALL insert_parroquias(ARRAY['Bolivar'],'Bolivar');
CALL insert_parroquias(ARRAY['Chivacoa','Campo Elias'],'Bruzual');
CALL insert_parroquias(ARRAY['Cocorote'],'Cocorote');
CALL insert_parroquias(ARRAY['Independencia'],'Independencia');
CALL insert_parroquias(ARRAY['Jose Antonio Paez'],'Jose Antonio Paez');
CALL insert_parroquias(ARRAY['La Trinidad'],'La Trinidad');
CALL insert_parroquias(ARRAY['Manuel Monge'],'Manuel Monge');
CALL insert_parroquias(ARRAY['Salom','Temerla','Nirgua','Cogollos'],'Nirgua');
CALL insert_parroquias(ARRAY['San Andres','Yaritagua'],'Peña');
CALL insert_parroquias(ARRAY['San Javier','Albarico','San Felipe'],'San Felipe');
CALL insert_parroquias(ARRAY['Sucre'],'Sucre');
CALL insert_parroquias(ARRAY['Urachiche'],'Urachiche');
CALL insert_parroquias(ARRAY['El Guayabo','Farriar'],'Veroes');

-- Zulia
CALL insert_municipios(ARRAY['Almirante Padilla','Baralt','Cabimas','Catatumbo','Colon','Francisco Javier Pulgar','Guajira','Jesus Enrique Lossada','Jesus Maria Semprun','La Cañada de Urdaneta','Lagunillas','Machiques de Perija','Mara','Maracaibo','Miranda','Rosario de Perija','San Francisco','Santa Rita','Simon Bolivar','Sucre','Valmore Rodriguez'],'Zulia');
CALL insert_parroquias(ARRAY['Isla de Toas','Monagas'],'Almirante Padilla');
CALL insert_parroquias(ARRAY['San Timoteo','General Urdaneta','Libertador','Marcelino Briceño','Pueblo Nuevo','Manuel Guanipa Matos'],'Baralt');
CALL insert_parroquias(ARRAY['Ambrosio','Aristides Calvani','Carmen Herrera','German Rios Linares','Jorge Hernandez','La Rosa','Punta Gorda','Romulo Betancourt','San Benito'],'Cabimas');
CALL insert_parroquias(ARRAY['Encontrados','Udon Perez'],'Catatumbo');
CALL insert_parroquias(ARRAY['San Carlos del Zulia','Moralito','Santa Barbara','Santa Cruz del Zulia','Urribarri'],'Colon');
CALL insert_parroquias(ARRAY['Simon Rodriguez','Agustin Codazzi','Carlos Quevedo','Francisco Javier Pulgar'],'Francisco Javier Pulgar');
CALL insert_parroquias(ARRAY['Sinamaica','Alta Guajira','Elias Sanchez Rubio','Guajira'],'Guajira');
CALL insert_parroquias(ARRAY['La Concepcion','San Jose','Mariano Parra Leon','Jose Ramon Yepez'],'Jesus Enrique Lossada');
CALL insert_parroquias(ARRAY['Jesus Maria Semprun','Bari'],'Jesus Maria Semprun');
CALL insert_parroquias(ARRAY['Concepcion','Andres Bello','Chiquinquira','El Carmelo','Potreritos'],'La Cañada de Urdaneta');
CALL insert_parroquias(ARRAY['Alonso de Ojeda','Libertad','Eleazar Lopez Contreras','Campo Lara','Venezuela','El Danto'],'Lagunillas');
CALL insert_parroquias(ARRAY['Libertad','Bartolome de las Casas','Rio Negro','San Jose de Perija'],'Machiques de Perija');
CALL insert_parroquias(ARRAY['San Rafael','La Sierrita','Las Parcelas','Luis De Vicente','Monseñor Marcos Sergio Godoy','Ricaurte','Tamare'],'Mara');
CALL insert_parroquias(ARRAY['Antonio Borjas Romero','Bolivar','Cacique Mara','Carracciolo Parra Perez','Cecilio Acosta','Chinquinquira','Coquivacoa','Cristo de Aranza','Francisco Eugenio Bustamante','Idelfonzo Vasquez','Juana de avila','Luis Hurtado Higuera','Manuel Dagnino','Olegario Villalobos','Raul Leoni','San Isidro','Santa Lucia','Venancio Pulgar'],'Maracaibo');
CALL insert_parroquias(ARRAY['Altagracia','Ana Maria Campos','Faria','San Antonio','San Jose'],'Miranda');
CALL insert_parroquias(ARRAY['El Rosario','Donaldo Garcia','Sixto Zambrano'],'Rosario de Perija');
CALL insert_parroquias(ARRAY['San Francisco','El Bajo','Domitila Flores','Francisco Ochoa','Los Cortijos','Marcial Hernandez','Jose Domingo Rus'],'San Francisco');
CALL insert_parroquias(ARRAY['Santa Rita','El Mene','Jose Cenobio Urribarri','Pedro Lucas Urribarri'],'Santa Rita');
CALL insert_parroquias(ARRAY['Manuel Manrique','Rafael Maria Baralt','Rafael Urdaneta'],'Simon Bolivar');
CALL insert_parroquias(ARRAY['Bobures','El Batey','Gibraltar','Heras','Monseñor Arturo alvarez','Romulo Gallegos'],'Sucre');
CALL insert_parroquias(ARRAY['Rafael Urdaneta','La Victoria','Raul Cuenca'],'Valmore Rodriguez');

-- [[ INSERT TIENDA,
-- DEPENDENT add_tienda, Lugar ]]--
CALL add_tienda ('ACAUCAB-La Pastora', '2018-01-15', 'Calle Real de La Pastora, Caracas 1010', 'La Pastora', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-Choroni', '2019-02-20', 'Avenida Principal de Choroni, Choroni 2109', 'Choroni', 'Aragua');

CALL add_tienda ('ACAUCAB-Santa Rosa', '2020-03-10', 'Calle Santa Rosa, Barquisimeto 3001', 'Santa Rosa', 'Lara');

CALL add_tienda ('ACAUCAB-El Valle', '2021-04-05', 'Avenida Intercomunal El Valle, Caracas 1090', 'El Valle', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-Catia La Mar', '2022-05-12', 'Avenida La Armada, Catia La Mar 1162', 'Catia La Mar', 'La Guaira');

CALL add_tienda ('ACAUCAB-San Juan', '2023-06-18', 'Calle San Juan, Caracas 1020', 'San Juan', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-Macuto', '2024-07-22', 'Avenida La Playa, Macuto 1164', 'Macuto', 'La Guaira');

CALL add_tienda ('ACAUCAB-Santa Barbara', '2025-08-30', 'Calle Bolivar, Santa Barbara de Barinas 5216', 'Santa Barbara', 'Barinas');

CALL add_tienda ('ACAUCAB-La Vega', '2026-09-14', 'Calle La Vega, Caracas 1021', 'La Vega', 'Distrito Capital');

CALL add_tienda ('ACAUCAB-El Junko', '2027-10-03', 'Carretera El Junko, El Junko 1204', 'El Junko', 'La Guaira');

-- [[ INSERT DEPARTAMENTO
-- DEPENDENT tienda, add_departamento_1 ]]--
CALL add_departamento_tienda_1 ('Compras');

CALL add_departamento_tienda_1 ('Ventas');

CALL add_departamento_tienda_1 ('Despacho');

CALL add_departamento_tienda_1 ('Entrega');

CALL add_departamento_tienda_1 ('Marketing');

CALL add_departamento_tienda_1 ('Recursos Humanos');

CALL add_departamento_tienda_1 ('Finanzas');

CALL add_departamento_tienda_1 ('Seguridad');

CALL add_departamento_tienda_1 ('Limpieza');

CALL add_departamento_tienda_1 ('Mantenimiento');

-- [[ INSERT EMPLEADO
-- DEPENDENT add_empleado ]]--
CALL add_empleado (31279920, 'Serita', 'Jewel', 'Herrick', 'Blevins', 73.02);

CALL add_empleado (48422996, 'Thora', 'Candra', 'Ferrer', 'Pina', 46.97);

CALL add_empleado (2428796, 'Barney', 'Merlin', 'Atchison', 'Hooker', 18.39);

CALL add_empleado (26806759, 'Stacey', 'Eura', 'Seeley', 'Thomsen', 85.59);

CALL add_empleado (4221028, 'Kati', 'Serafina', 'Valencia', 'Guillory', 53.06);

CALL add_empleado (1418738, 'Loni', 'Hershel', 'Stubblefield', 'Ahmad-Alley', 20.58);

CALL add_empleado (518945, 'Loree', 'Alpha', 'Sparks', 'Sell', 62.83);

CALL add_empleado (46565698, 'Vashti', 'Conchita', 'Sadler', 'Carpenter', 67.6);

CALL add_empleado (42233317, 'Bula', 'Norbert', 'Amaral', 'Wooley', 55.88);

CALL add_empleado (40959596, 'Jewel', 'Elene', 'Bray', 'Penn', 18.01);

-- [[ INSERT EMPL_CARG ]]--

CALL add_empl_carg_to_tien_1 (40959596, 'Empleado', '2024-10-10', NULL, 25000, 'Compras');

CALL add_empl_carg_to_tien_1 (48422996, 'Empleado', '2024-10-10', NULL, 25000, 'Ventas');

CALL add_empl_carg_to_tien_1 (2428796, 'Empleado', '2024-10-10', NULL, 25000, 'Despacho');

CALL add_empl_carg_to_tien_1 (26806759, 'Empleado', '2024-10-10', NULL, 25000, 'Entrega');

CALL add_empl_carg_to_tien_1 (4221028, 'Empleado', '2024-10-10', NULL, 25000, 'Marketing');

CALL add_empl_carg_to_tien_1 (1418738, 'Empleado', '2024-10-10', NULL, 25000, 'Recursos Humanos');

CALL add_empl_carg_to_tien_1 (518945, 'Empleado', '2024-10-10', NULL, 25000, 'Finanzas');

CALL add_empl_carg_to_tien_1 (46565698, 'Empleado', '2024-10-10', NULL, 25000, 'Seguridad');

CALL add_empl_carg_to_tien_1 (42233317, 'Empleado', '2024-10-10', NULL, 25000, 'Limpieza');

CALL add_empl_carg_to_tien_1 (40959596, 'Empleado', '2024-10-10', NULL, 25000, 'Mantenimiento');

--[[ INSERT EMPL_BENE, VACACION, ASISTENCIA, EMPL_HORA ]]--
CALL give_benefits ();

CALL create_vacaciones ();

CALL generate_asistencia_entries ();

CALL insert_empl_hora ();
