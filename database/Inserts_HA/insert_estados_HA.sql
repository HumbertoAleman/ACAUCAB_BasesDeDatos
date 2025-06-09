CREATE OR REPLACE FUNCTION insert_estados(varchar(40)[]) RETURNS void AS $$
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

CREATE OR REPLACE FUNCTION insert_municipios(varchar(40)[], text) RETURNS void AS $$
DECLARE
  x varchar(40);
BEGIN
  FOREACH x IN ARRAY $1
  LOOP
	INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = $2 AND tipo_luga = 'Estado' LIMIT 1));
  END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_parroquias(varchar(40)[], text) RETURNS void AS $$
DECLARE
  x varchar(40);
BEGIN
  FOREACH x IN ARRAY $1
  LOOP
	INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
		VALUES (x, 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = $2 AND tipo_luga = 'Municipio' LIMIT 1));
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DELETE FROM Lugar;

-- States
SELECT insert_estados(ARRAY ['Amazonas', 'Anzoategui', 'Apure', 'Aragua', 'Barinas', 'Bolivar', 'Carabobo', 'Cojedes', 'Delta Amacuro', 'Falcon', 'Guarico', 'Lara', 'Merida', 'Miranda', 'Monagas', 'Nueva Esparta', 'Portuguesa', 'Sucre', 'Tachira', 'Trujillo', 'Yaracuy', 'Zulia']);

-- Amazonas
SELECT insert_municipios(ARRAY['Altures', 'Alto Orinoco', 'Atabapo', 'Autana', 'Manapiare', 'Maroa', 'Rio Negro'], 'Amazonas');
SELECT insert_parroquias(ARRAY['Fernando Giron Tovar', 'Luis Alberto Gomez', 'Parhueña', 'Platanillal'], 'Altures');
SELECT insert_parroquias(ARRAY['La Esmeralda', 'Marawaka', 'Mavaca', 'Sierra Parima'], 'Alto Orinoco');
SELECT insert_parroquias(ARRAY['San Fernando de Atabapo', 'Laja Lisa', 'Santa Barbara', 'Guarinuma'], 'Atabapo');
SELECT insert_parroquias(ARRAY['Isla Raton', 'San Pedro del Orinoco', 'Pendare', 'Manduapo', 'Samariapo'], 'Autana');
SELECT insert_parroquias(ARRAY['San Juan de Manapiare', 'Camani', 'Capure', 'Manueta'], 'Manapiare');
SELECT insert_parroquias(ARRAY['Maroa', 'Comunidad', 'Victorino'], 'Maroa');
SELECT insert_parroquias(ARRAY['San Carlos de Rio Negro', 'Solano', 'Curimacare', 'Santa Lucia'], 'Rio Negro');

-- Anzoategui
SELECT insert_municipios(ARRAY['Anaco', 'Aragua', 'Diego Bautista Urbaneja', 'Fernando de Peñalver', 'Francisco del Carmen Carvajal', 'Francisco de Miranda', 'Guanta', 'Independencia', 'Jose Gregorio Monagas', 'Juan Antonio Sotillo', 'Juan Manuel Cajigal', 'Libertad', 'Manuel Ezequiel Bruzual', 'Pedro Maria Freites', 'Piritu', 'Guanipa', 'San Juan de Capistrano', 'Santa Ana', 'Simon Bolivar', 'Simon Rodriguez', 'Sir Arthur McGregor'], 'Amazonas');
SELECT insert_parroquias(ARRAY['Anaco', 'San Joaquin'], 'Anaco');
SELECT insert_parroquias(ARRAY['Cachipo', 'Aragua de Barcelona'], 'Aragua');
SELECT insert_parroquias(ARRAY['Lecheria', 'El Morro'], 'Diego Bautista Urbaneja');
SELECT insert_parroquias(ARRAY['San Miguel', 'Sucre'], 'Fernando de Peñalver');
SELECT insert_parroquias(ARRAY['Valle de Guanape', 'Santa Barbara'], 'Francisco del Carmen Carvajal');
SELECT insert_parroquias(ARRAY['Atapirire', 'Boca del Pao', 'El Pao', 'Pariaguan'], 'Francisco de Miranda');
SELECT insert_parroquias(ARRAY['Guanta', 'Chorreron'], 'Guanta');
SELECT insert_parroquias(ARRAY['Mamo', 'Soledad'], 'Independencia');
SELECT insert_parroquias(ARRAY['Mapire', 'Piar', 'Santa Clara', 'San Diego de Cabrutica', 'Uverito', 'Zuata'], 'Jose Gregorio Monagas');
SELECT insert_parroquias(ARRAY['Puerto La Cruz', 'Pozuelos'], 'Juan Antonio Sotillo');
SELECT insert_parroquias(ARRAY['Onoto', 'San Pablo'], 'Juan Manuel Cajigal');
SELECT insert_parroquias(ARRAY['San Mateo', 'El Carito', 'Santa Ines', 'La Romereña'], 'Libertad');
SELECT insert_parroquias(ARRAY['Clarines', 'Guanape', 'Sabana de Uchire'], 'Manuel Ezequiel Bruzual');
SELECT insert_parroquias(ARRAY['Cantaura', 'Libertador', 'Santa Rosa', 'Urica'], 'Pedro Maria Freites');
SELECT insert_parroquias(ARRAY['Piritu', 'San Francisco'], 'Piritu');
SELECT insert_parroquias(ARRAY['San Jose de Guanipa'], 'San Jose de Guanipa');
SELECT insert_parroquias(ARRAY['Boca de Uchire', 'Boca de Chavez'], 'San Juan de Capistrano');
SELECT insert_parroquias(ARRAY['Pueblo Nuevo', 'Santa Ana'], 'Santa Ana');
SELECT insert_parroquias(ARRAY['Bergantin', 'El Pilar', 'Naricual', 'San Cristobal'], 'Simon Bolivar');
SELECT insert_parroquias(ARRAY['Edmundo Barrios', 'Miguel Otero Silva'], 'Simon Rodriguez');
SELECT insert_parroquias(ARRAY['El Chaparro', 'Tomas Alfaro', 'Calatrava'], 'Sir Arthur McGregor');

-- Apure
SELECT insert_municipios(ARRAY['Achaguas', 'Biruaca', 'Muñoz', 'Paez', 'Pedro Camejo', 'Romulo Gallegos', 'San Fernando'], 'Apure');
SELECT insert_parroquias(ARRAY['Achaguas', 'Apurito', 'El Yagual', 'Guachara', 'Mucuritas', 'Queseras del Medio'], 'Achaguas');
SELECT insert_parroquias(ARRAY['Biruaca'], 'Biruaca');
SELECT insert_parroquias(ARRAY['Bruzual', 'Santa Barbara'], 'Muñoz');
SELECT insert_parroquias(ARRAY['Guasdualito', 'Aramendi', 'El Amparo', 'San Camilo', 'Urdaneta', 'Canagua', 'Dominga Ortíz de Paez', 'Santa Rosalia'], 'Paez');
SELECT insert_parroquias(ARRAY['San Juan de Payara', 'Codazzi', 'Cunaviche'], 'Pedro Camejo');
SELECT insert_parroquias(ARRAY['Elorza', 'La Trinidad de Orichuna'], 'Romulo Gallegos');
SELECT insert_parroquias(ARRAY['El Recreo', 'Peñalver', 'San Fernando de Apure', 'San Rafael de Atamaica'], 'San Fernando');

-- Aragua 
SELECT insert_municipios(ARRAY['Anastasio Girardot', 'Bolivar', 'Mario Briceño Iragorry', 'Santos Michelena', 'Sucre', 'Santiago Mariño', 'Jose angel Lamas', 'Francisco Linares Alcantara', 'San Casimiro', 'Urdaneta', 'Jose Felix Ribas', 'Jose Rafael Revenga', 'Ocumare de la Costa de Oro', 'Tovar', 'Camatagua', 'Zamora', 'San Sebastian', 'Libertador'], 'Aragua'); SELECT insert_parroquias(ARRAY['Bolivar San Mateo'], 'Bolivar');
SELECT insert_parroquias(ARRAY['Camatagua', 'Carmen de Cura'], 'Camatagua');
SELECT insert_parroquias(ARRAY['Santa Rita', 'Francisco de Miranda', 'Moseñor Feliciano Gonzalez Paraparal'], 'Francisco Linares Alcantara');
SELECT insert_parroquias(ARRAY['Pedro Jose Ovalles', 'Joaquin Crespo', 'Jose Casanova Godoy', 'Madre Maria de San Jose', 'Andres Eloy Blanco', 'Los Tacarigua', 'Las Delicias', 'Choroni'], 'Atanasio Girardot');
SELECT insert_parroquias(ARRAY['Santa Cruz'], 'Jose angel Lamas');
SELECT insert_parroquias(ARRAY['Jose Felix Ribas', 'Castor Nieves Rios', 'Las Guacamayas', 'Pao de Zarate', 'Zuata'], 'Jose Felix Ribas');
SELECT insert_parroquias(ARRAY['Jose Rafael Revenga'], 'Jose Rafael Revenga');
SELECT insert_parroquias(ARRAY['Palo Negro', 'San Martin de Porres'], 'Libertador');
SELECT insert_parroquias(ARRAY['El Limon', 'Caña de Azucar'], 'Mario Briceño Iragorry');
SELECT insert_parroquias(ARRAY['Ocumare de la Costa'], 'Ocumare de la Costa de Oro');
SELECT insert_parroquias(ARRAY['San Casimiro', 'Güiripa', 'Ollas de Caramacate', 'Valle Morin'], 'San Casimiro');
SELECT insert_parroquias(ARRAY['San Sebastian'], 'San Sebastian');
SELECT insert_parroquias(ARRAY['Turmero', 'Arevalo Aponte', 'Chuao', 'Saman de Güere', 'Alfredo Pacheco Miranda'], 'Santiago Mariño');
SELECT insert_parroquias(ARRAY['Santos Michelena', 'Tiara'], 'Santos Michelena');
SELECT insert_parroquias(ARRAY['Cagua', 'Bella Vista'], 'Sucre');
SELECT insert_parroquias(ARRAY['Tovar'], 'Tovar');
SELECT insert_parroquias(ARRAY['Urdaneta', 'Las Peñitas', 'San Francisco de Cara', 'Taguay'], 'Urdaneta');
SELECT insert_parroquias(ARRAY['Zamora', 'Magdaleno', 'San Francisco de Asis', 'Valles de Tucutunemo', 'Augusto Mijares'], 'Zamora');

-- Barinas
SELECT insert_municipios(ARRAY['Alberto Arvelo Torrealba', 'Andrés Eloy Blanco', 'Antonio José de Sucre', 'Arismendi', 'Barinas', 'Bolívar', 'Cruz Paredes', 'Ezequiel Zamora', 'Obispos', 'Pedraza', 'Sosa', 'Rojas'], 'Barinas');
SELECT insert_parroquias(ARRAY['Arismendi', 'Guadarrama', 'La Unión', 'San Antonio'], 'Arismendi');
SELECT insert_parroquias(ARRAY['Barinas', 'Alfredo Arvelo Larriva', 'San Silvestre', 'Santa Inés', 'Santa Lucía', 'Torunos', 'El Carmen', 'Rómulo Betancourt', 'Corazón de Jesús', 'Ramón Ignacio Méndez', 'Alto Barinas', 'Manuel Palacio Fajardo', 'Juan Antonio Rodríguez Domínguez', 'Dominga Ortiz de Páez'], 'Barinas');
SELECT insert_parroquias(ARRAY['El Cantón', 'Santa Cruz de Guacas', 'Puerto Vivas'], 'Andrés Eloy Blanco');
SELECT insert_parroquias(ARRAY['Barinitas', 'Altamira de Cáceres', 'Calderas'], 'Bolívar');
SELECT insert_parroquias(ARRAY['Masparrito', 'El Socorro', 'Barrancas'], 'Cruz Paredes');
SELECT insert_parroquias(ARRAY['Obispos', 'El Real', 'La Luz', 'Los Guasimitos'], 'Obispos');
SELECT insert_parroquias(ARRAY['Ciudad Bolivia', 'Ignacio Briceño', 'José Félix Ribas', 'Páez'], 'Pedraza');
SELECT insert_parroquias(ARRAY['Libertad', 'Dolores', 'Santa Rosa', 'Simón Rodríguez', 'Palacio Fajardo'], 'Rojas');
SELECT insert_parroquias(ARRAY['Ciudad de Nutrias', 'El Regalo', 'Puerto Nutrias', 'Santa Catalina', 'Simón Bolívar'], 'Sosa');
SELECT insert_parroquias(ARRAY['Ticoporo', 'Nicolás Pulido', 'Andrés Bello'], 'Antonio José de Sucre');
SELECT insert_parroquias(ARRAY['Sabaneta', 'Juan Antonio Rodríguez Domínguez'], 'Alberto Arvelo Torrealba');
SELECT insert_parroquias(ARRAY['Santa Bárbara', 'Pedro Briceño Méndez', 'Ramón Ignacio Méndez', 'José Ignacio del Pumar'], 'Ezequiel Zamora');

-- Bolivar
SELECT insert_municipios(ARRAY['Caroní', 'Cedeño', 'El Callao', 'Gran Sabana', 'Heres', 'Padre Pedro Chien', 'Piar', 'Angostura', 'Roscio', 'Sifontes', 'Sucre'], 'Bolívar');

-- Check
SELECT sub_L.nombre_luga, sub_L.tipo_luga, sup_L.nombre_luga
FROM Lugar as sup_L, Lugar as sub_L
WHERE
	sup_L.cod_luga = sub_L.fk_luga;
