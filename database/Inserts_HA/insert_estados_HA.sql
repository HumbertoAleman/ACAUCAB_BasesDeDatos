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


CREATE OR REPLACE FUNCTION insert_parroquias(varchar(40)[], text) RETURNS void AS $$
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

-- States
SELECT insert_estados(ARRAY ['Amazonas', 'Anzoategui', 'Apure', 'Aragua', 'Barinas', 'Bolivar', 'Carabobo', 'Cojedes', 'Delta Amacuro', 'Distrito Capital', 'Falcon', 'Guarico', 'La Guaira', 'Lara', 'Merida', 'Miranda', 'Monagas', 'Nueva Esparta', 'Portuguesa', 'Sucre', 'Tachira', 'Trujillo', 'Yaracuy', 'Zulia']);

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
SELECT insert_parroquias(ARRAY['Cachamay', 'Chirica', 'Dalla Costa', 'Once de Abril', 'Simón Bolívar', 'Unare', 'Universidad', 'Vista al Sol', 'Pozo Verde', 'Yocoima', '5 de Julio'], 'Caroní');
SELECT insert_parroquias(ARRAY['Cedeño', 'Altagracia', 'Ascensión Farreras', 'Guaniamo', 'La Urbana', 'Pijiguaos'], 'Cedeño');
SELECT insert_parroquias(ARRAY['El Callao'], 'El Callao');
SELECT insert_parroquias(ARRAY['Gran Sabana', 'Ikabarú'], 'Gran Sabana');
SELECT insert_parroquias(ARRAY['Catedral', 'Zea', 'Orinoco', 'José Antonio Páez', 'Marhuanta', 'Agua Salada', 'Vista Hermosa', 'La Sabanita', 'Panapana'], 'Heres');
SELECT insert_parroquias(ARRAY['Padre Pedro Chien'], 'Padre Pedro Chien');
SELECT insert_parroquias(ARRAY['Andrés Eloy Blanco', 'Pedro Cova', 'Upata'], 'Piar');
SELECT insert_parroquias(ARRAY['Raúl Leoni', 'Barceloneta', 'Santa Bárbara', 'San Francisco'], 'Angostura (Raúl Leoni)');
SELECT insert_parroquias(ARRAY['Roscio', 'Salóm'], 'Roscio');
SELECT insert_parroquias(ARRAY['Tumeremo', 'Dalla Costa', 'San Isidro'], 'Sifontes');
SELECT insert_parroquias(ARRAY['Sucre', 'Aripao', 'Guarataro', 'Las Majadas', 'Moitaco'], 'Sucre');

-- Carabobo
SELECT insert_municipios(ARRAY['Bejuma','Carlos Arvelo','Diego Ibarra','Guacara','Juan José Mora','Libertador','Los Guayos','Miranda','Montalbán','Naguanagua','Puerto Cabello','San Diego','San Joaquín','Valencia'],'Carabobo');
SELECT insert_parroquias(ARRAY['Canoabo', 'Simón Bolívar'], 'Bejuma');
SELECT insert_parroquias(ARRAY['Güigüe', 'Belén', 'Tacarigua'], 'Carlos Arvelo');
SELECT insert_parroquias(ARRAY['Mariara', 'Aguas Calientes'], 'Diego Ibarra');
SELECT insert_parroquias(ARRAY['Ciudad Alianza', 'Guacara', 'Yagua'], 'Guacara');
SELECT insert_parroquias(ARRAY['Morón', 'Urama'], 'Juan José Mora');
SELECT insert_parroquias(ARRAY['Tocuyito Valencia', 'Independencia Campo Carabobo'], 'Libertador');
SELECT insert_parroquias(ARRAY['Los Guayos Valencia'], 'Los Guayos');
SELECT insert_parroquias(ARRAY['Miranda'], 'Miranda');
SELECT insert_parroquias(ARRAY['Montalbán'], 'Montalbán');
SELECT insert_parroquias(ARRAY['Urbana Naguanagua Valencia'], 'Naguanagua');
SELECT insert_parroquias(ARRAY['Bartolomé Salóm', 'Democracia', 'Fraternidad', 'Goaigoaza', 'Juan José Flores', 'Unión', 'Borburata', 'Patanemo'], 'Puerto Cabello');
SELECT insert_parroquias(ARRAY['San Diego Valencia'], 'San Diego');
SELECT insert_parroquias(ARRAY['San Joaquín'], 'San Joaquín');
SELECT insert_parroquias(ARRAY['Urbana Candelaria', 'Urbana Catedral', 'Urbana El Socorro', 'Urbana Miguel Peña', 'Urbana Rafael Urdaneta', 'Urbana San Blas', 'Urbana San José', 'Urbana Santa Rosa', 'Rural Negro Primero'], 'Valencia');

-- Cojedes
SELECT insert_municipios(ARRAY['Anzoategui','Pao de San Juan Bautista','Tinaquillo','Girardot','Lima Blanco','Ricaurte','Romulo Gallegos','Ezequiel Zamora','Tinaco'],'Cojedes');
SELECT insert_parroquias(ARRAY['Cojedes', 'Juan de Mata Suárez'], 'Anzoategui');
SELECT insert_parroquias(ARRAY['El Pao'], 'Pao de San Juan Bautista');
SELECT insert_parroquias(ARRAY['Tinaquillo'], 'Tinaquillo');
SELECT insert_parroquias(ARRAY['El Baúl', 'Sucre'], 'Girardot');
SELECT insert_parroquias(ARRAY['La Aguadita', 'Macapo'], 'Lima Blanco');
SELECT insert_parroquias(ARRAY['El Amparo', 'Libertad de Cojedes'], 'Ricaurte');
SELECT insert_parroquias(ARRAY['Rómulo Gallegos (Las Vegas)'], 'Romulo Gallegos');
SELECT insert_parroquias(ARRAY['San Carlos de Austria', 'Juan Ángel Bravo', 'Manuel Manrique'], 'Ezequiel Zamora');
SELECT insert_parroquias(ARRAY['General en Jefe Jos Laurencio Silva'], 'Tinaco');

-- Delta Amacuro
SELECT insert_municipios(ARRAY['Antonio Díaz','Casacoima','Pedernales','Tucupita'],'Delta Amacuro');
SELECT insert_parroquias(ARRAY['Curiapo','Almirante Luis Brión','Francisco Aniceto Lugo','Manuel Renaud','Padre Barral','Santos de Abelgas'],'Antonio Díaz');
SELECT insert_parroquias(ARRAY['Imataca','Juan Bautista Arismendi','Manuel Piar','Rómulo Gallegos'],'Casacoima');
SELECT insert_parroquias(ARRAY['Pedernales','Luis Beltrán Prieto Figueroa'],'Pedernales');
SELECT insert_parroquias(ARRAY['San José','José Vidal Marcano','Leonardo Ruiz Pineda','Mariscal Antonio José de Sucre','Monseñor Argimiro García','Virgen del Valle','San Rafael','Juan Millán'],'Tucupita');

-- Distrito Federal
SELECT insert_municipios(ARRAY['Libertador'],'Distrito Capital');
SELECT insert_parroquias(ARRAY['23 de Enero','Altagracia','Antímano','Caricuao','Catedral','Coche','El Junquito','El Paraíso','El Recreo','El Valle','La Candelaria','La Pastora','La Vega','Macarao','San Agustín','San Bernardino','San José','San Juan','San Pedro','Santa Rosalía','Santa Teresa','Sucre'],'Libertador');

-- Falcon
SELECT insert_municipios(ARRAY['Acosta','Bolívar','Buchivacoa','Cacique Manaure','Carirubana','Colina','Dabajuro','Democracia','Falcón','Federación','Jacura','Los Taques','Mauroa','Miranda','Monseñor Iturriza','Palmasola','Petit','Píritu','San Francisco','Silva','Sucre','Tocopero','Unión','Urumaco','Zamora'],'Falcon');
SELECT insert_parroquias(ARRAY['Capadare', 'La Pastora', 'Libertador', 'San Juan de los Cayos'], 'Acosta');
SELECT insert_parroquias(ARRAY['Aracua', 'La Peña', 'San Luis'], 'Bolívar');
SELECT insert_parroquias(ARRAY['Bariro', 'Borojó', 'Capatárida', 'Guajiro', 'Seque', 'Valle de Eroa', 'Zazárida'], 'Buchivacoa');
SELECT insert_parroquias(ARRAY['Cacique Manaure (Yaracal)'], 'Cacique Manaure');
SELECT insert_parroquias(ARRAY['Norte', 'Carirubana', 'Santa Ana', 'Urbana Punta Cardón'], 'Carirubana');
SELECT insert_parroquias(ARRAY['La Vela de Coro', 'Acurigua', 'Guaibacoa', 'Las Calderas', 'Mataruca'], 'Colina');
SELECT insert_parroquias(ARRAY['Dabajuro'], 'Dabajuro');
SELECT insert_parroquias(ARRAY['Agua Clara', 'Avaria', 'Pedregal', 'Piedra Grande', 'Purureche'], 'Democracia');
SELECT insert_parroquias(ARRAY['Adaure', 'Adícora', 'Baraived', 'Buena Vista', 'Jadacaquiva', 'El Vínculo', 'El Hato', 'Moruy', 'Pueblo Nuevo'], 'Falcón');
SELECT insert_parroquias(ARRAY['Agua Larga', 'Churuguara', 'El Paují', 'Independencia', 'Mapararí'], 'Federación');
SELECT insert_parroquias(ARRAY['Agua Linda', 'Araurima', 'Jacura'], 'Jacura');
SELECT insert_parroquias(ARRAY['Tucacas', 'Boca de Aroa'], 'José Laurencio Silva');
SELECT insert_parroquias(ARRAY['Los Taques', 'Judibana'], 'Los Taques');
SELECT insert_parroquias(ARRAY['Mene de Mauroa', 'San Félix', 'Casigua'], 'Mauroa');
SELECT insert_parroquias(ARRAY['Guzmán Guillermo', 'Mitare', 'Río Seco', 'Sabaneta', 'San Antonio', 'San Gabriel', 'Santa Ana'], 'Miranda');
SELECT insert_parroquias(ARRAY['Boca del Tocuyo', 'Chichiriviche', 'Tocuyo de la Costa'], 'Monseñor Iturriza');
SELECT insert_parroquias(ARRAY['Palmasola'], 'Palmasola');
SELECT insert_parroquias(ARRAY['Cabure', 'Colina', 'Curimagua'], 'Petit');
SELECT insert_parroquias(ARRAY['San José de la Costa', 'Píritu'], 'Píritu');
SELECT insert_parroquias(ARRAY['Capital San Francisco Mirimire'], 'San Francisco');
SELECT insert_parroquias(ARRAY['Sucre', 'Pecaya'], 'Sucre');
SELECT insert_parroquias(ARRAY['Tocópero'], 'Tocópero');
SELECT insert_parroquias(ARRAY['El Charal', 'Las Vegas del Tuy', 'Santa Cruz de Bucaral'], 'Unión');
SELECT insert_parroquias(ARRAY['Bruzual', 'Urumaco'], 'Urumaco');
SELECT insert_parroquias(ARRAY['Puerto Cumarebo', 'La Ciénaga', 'La Soledad', 'Pueblo Cumarebo', 'Zazárida'], 'Zamora');

-- Guárico
SELECT insert_municipios(ARRAY['Infante','Mellado','Miranda','Monagas','Ribas','Roscio','Zaraza','Camaguán','San José de Guaribe','Las Mercedes','El Socorro','Ortiz','Santa María de Ipire','Chaguaramas','San Jerónimo de Guayabal'],'Guarico');
SELECT insert_parroquias(ARRAY['Camaguán', 'Puerto Miranda', 'Uverito'], 'Camaguán');
SELECT insert_parroquias(ARRAY['Chaguaramas'], 'Chaguaramas');
SELECT insert_parroquias(ARRAY['El Socorro'], 'El Socorro');
SELECT insert_parroquias(ARRAY['El Calvario', 'El Rastro', 'Guardatinajas', 'Capital Urbana Calabozo'], 'Francisco de Miranda');
SELECT insert_parroquias(ARRAY['Tucupido', 'San Rafael de Laya'], 'José Félix Ribas');
SELECT insert_parroquias(ARRAY['Altagracia de Orituco', 'San Rafael de Orituco', 'San Francisco Javier de Lezama', 'Paso Real de Macaira', 'Carlos Soublette', 'San Francisco de Macaira', 'Libertad de Orituco'], 'José Tadeo Monagas');
SELECT insert_parroquias(ARRAY['Cantagallo', 'San Juan de los Morros', 'Parapara'], 'Juan Germán Roscio');
SELECT insert_parroquias(ARRAY['El Sombrero', 'Sosa'], 'Julián Mellado');
SELECT insert_parroquias(ARRAY['Las Mercedes', 'Cabruta', 'Santa Rita de Manapire'], 'Juan Jose Rondon');
SELECT insert_parroquias(ARRAY['Valle de la Pascua', 'Espino'], 'Leonardo Infante');
SELECT insert_parroquias(ARRAY['San José de Tiznados', 'San Francisco de Tiznados', 'San Lorenzo de Tiznados', 'Ortiz'], 'Ortiz');
SELECT insert_parroquias(ARRAY['San José de Unare', 'Zaraza'], 'Pedro Zaraza');
SELECT insert_parroquias(ARRAY['Guayabal', 'Cazorla'], 'San Jerónimo de Guayabal');
SELECT insert_parroquias(ARRAY['San José de Guaribe'], 'San José de Guaribe');
SELECT insert_parroquias(ARRAY['Santa María de Ipire', 'Altamira'], 'Santa María de Ipire');

-- La Guaira
SELECT insert_municipio(ARRAY['Vargas'], 'La Guaira');
SELECT insert_parroquias(ARRAY['Caraballeda','Carayaca','Carlos Soublette','Caruao','Catia La Mar','El Junko','La Guaira','Macuto','Maiquetía','Naiguatá','Urimare'],'Vargas');

-- Lara
SELECT insert_municipios(ARRAY['Iribarren','Jiménez','Crespo','Andrés Eloy Blanco','Urdaneta','Torres','Palavecino','Morán','Simón Planas'],'Lara');
SELECT insert_parroquias(ARRAY['Quebrada Honda de Guache', 'Pio Tamayo', 'Yacambú'], 'Andrés Eloy Blanco');
SELECT insert_parroquias(ARRAY['Freitez', 'José María Blanco'], 'Crespo');
SELECT insert_parroquias(ARRAY['Anzoátegui', 'Bolívar', 'Guárico', 'Hilario Luna y Luna', 'Humocaro Bajo', 'Humocaro Alto', 'La Candelaria', 'Morán'], 'Morán');
SELECT insert_parroquias(ARRAY['Cabudare', 'José Gregorio Bastidas', 'Agua Viva'], 'Palavecino');
SELECT insert_parroquias(ARRAY['Buría', 'Gustavo Vega', 'Sarare'], 'Simón Planas');
SELECT insert_parroquias(ARRAY['Altagracia', 'Antonio Díaz', 'Camacaro', 'Castañeda', 'Cecilio Zubillaga', 'Chiquinquira', 'El Blanco', 'Espinoza de los Monteros', 'Heriberto Arrollo', 'Lara', 'Las Mercedes', 'Manuel Morillo', 'Montaña Verde', 'Montes de Oca', 'Reyes de Vargas', 'Torres', 'Trinidad Samuel'], 'Torres');
SELECT insert_parroquias(ARRAY['Xaguas', 'Siquisique', 'San Miguel', 'Moroturo'], 'Urdaneta');
SELECT insert_parroquias(ARRAY['Aguedo Felipe Alvarado', 'Buena Vista', 'Catedral', 'Concepción', 'El Cují', 'Juares', 'Guerrera Ana Soto', 'Santa Rosa', 'Tamaca', 'Unión'], 'Iribarren');
SELECT insert_parroquias(ARRAY['Juan Bautista Rodríguez', 'Cuara', 'Diego de Lozada', 'Paraíso de San José', 'San Miguel', 'Tintorero', 'José Bernardo Dorante', 'Coronel Mariano Peraza'], 'Jiménez');

-- Merida
SELECT insert_municipios(ARRAY['Antonio Pinto Salinas','Aricagua','Arzobispo Chacón','Campo Elías','Caracciolo Parra Olmedo','Cardenal Quintero','Chacantá','El Mucuy','Guaraque','Julio César Salas','Justo Briceño','Libertador','Luis Cristóbal Moncada','Rivas Dávila','Rangel','Santos Marquina','Tovar','Tulio Febres-Cordero','Alberto Adriani','Andrés Bello','Miranda','Zea','Sucre'],'Merida');
SELECT insert_parroquias(ARRAY['Presidente Betancourt','Presidente Páez','Presidente Rómulo Gallegos','Gabriel Picón González','Héctor Amable Mora','José Nucete Sardi','Pulido Méndez'],'Alberto Adriani');
SELECT insert_parroquias(ARRAY['Santa Cruz de Mora','Mesa Bolívar','Mesa de Las Palmas'],'Antonio Pinto Salinas');
SELECT insert_parroquias(ARRAY['La Azulita'],'Andrés Bello');
SELECT insert_parroquias(ARRAY['Aricagua','San Antonio'],'Aricagua');
SELECT insert_parroquias(ARRAY['Canaguá','Capurí','Chacantá','El Molino','Guaimaral','Mucutuy','Mucuchachí'],'Arzobispo Chacón');
SELECT insert_parroquias(ARRAY['Fernández Peña','Matriz','Montalbán','Acequias','Jají','La Mesa','San José del Sur'],'Campo Elías');
SELECT insert_parroquias(ARRAY['Tucaní','Florencio Ramírez'],'Caracciolo Parra Olmedo');
SELECT insert_parroquias(ARRAY['Santo Domingo','Las Piedras'],'Cardenal Quintero');
SELECT insert_parroquias(ARRAY['Guaraque','Mesa Quintero','Río Negro'],'Guaraque');
SELECT insert_parroquias(ARRAY['Arapuey','Palmira'],'Julio César Salas');
SELECT insert_parroquias(ARRAY['San Cristóbal de Torondoy','Torondoy'],'Justo Briceño');
SELECT insert_parroquias(ARRAY['Antonio Spinetti Dini','Arias','Caracciolo Parra Pérez','Domingo Peña','El Llano','Gonzalo Picón Febres','Jacinto Plaza','Juan Rodríguez Suárez','Lasso de la Vega','Mariano Picón Salas','Milla','Osuna Rodríguez','Sagrario','El Morro','Los Nevados'],'Libertador');
SELECT insert_parroquias(ARRAY['Andrés Eloy Blanco','La Venta','Piñango','Timotes'],'Miranda');
SELECT insert_parroquias(ARRAY['Eloy Paredes','San Rafael de Alcázar','Santa Elena de Arenales'],'Obispo Ramos de Lora');
SELECT insert_parroquias(ARRAY['Santa María de Caparo'],'Padre Noguera');
SELECT insert_parroquias(ARRAY['Pueblo Llano'],'Pueblo Llano');
SELECT insert_parroquias(ARRAY['Cacute','La Toma','Mucuchíes','Mucurubá','San Rafael'],'Rangel');
SELECT insert_parroquias(ARRAY['Gerónimo Maldonado','Bailadores'],'Rivas Dávila');
SELECT insert_parroquias(ARRAY['Tabay'],'Santos Marquina');
SELECT insert_parroquias(ARRAY['Chiguará','Estánques','Lagunillas','La Trampa','Pueblo Nuevo del Sur','San Juan'],'Sucre');
SELECT insert_parroquias(ARRAY['El Amparo','El Llano','San Francisco','Tovar'],'Tovar');
SELECT insert_parroquias(ARRAY['Independencia','María de la Concepción Palacios Blanco','Nueva Bolivia','Santa Apolonia'],'Tulio Febres Cordero');
SELECT insert_parroquias(ARRAY['Caño El Tigre','Zea'],'Zea');

-- Miranda
SELECT insert_municipios(ARRAY['Acevedo','Andrés Bello','Baruta','Brión','Buroz','Carrizal','Chacao','Cristóbal Rojas','El Hatillo','Guaicaipuro','Independencia','Lander','Los Salias','Páez','Paz Castillo','Pedro Gual','Plaza','Simón Bolívar','Sucre','Urdaneta','Zamora'],'Miranda');
SELECT insert_parroquias(ARRAY['Aragüita','Arévalo González','Capaya','Caucagua','Panaquire','Ribas','El Café','Marizapa','Yaguapa'],'Acevedo');
SELECT insert_parroquias(ARRAY['Cumbo','San José de Barlovento'],'Andrés Bello');
SELECT insert_parroquias(ARRAY['El Cafetal','Las Minas','Nuestra Señora del Rosario'],'Baruta');
SELECT insert_parroquias(ARRAY['Higuerote','Curiepe','Tacarigua de Brión','Chirimena','Birongo'],'Brión');
SELECT insert_parroquias(ARRAY['Mamporal'],'Buroz');
SELECT insert_parroquias(ARRAY['Carrizal'],'Carrizal');
SELECT insert_parroquias(ARRAY['Chacao'],'Chacao');
SELECT insert_parroquias(ARRAY['Charallave','Las Brisas'],'Cristóbal Rojas');
SELECT insert_parroquias(ARRAY['Santa Rosalía de Palermo de El Hatillo'],'El Hatillo');
SELECT insert_parroquias(ARRAY['Altagracia de la Montaña','Cecilio Acosta','Los Teques','El Jarillo','San Pedro','Tácata','Paracotos'],'Guaicaipuro');
SELECT insert_parroquias(ARRAY['el Cartanal','Santa Teresa del Tuy'],'Independencia');
SELECT insert_parroquias(ARRAY['La Democracia','Ocumare del Tuy','Santa Bárbara','La Mata','La Cabrera'],'Lander');
SELECT insert_parroquias(ARRAY['San Antonio de los Altos'],'Los Salias');
SELECT insert_parroquias(ARRAY['Río Chico','El Guapo','Tacarigua de la Laguna','Paparo','San Fernando del Guapo'],'Páez');
SELECT insert_parroquias(ARRAY['Santa Lucía del Tuy','Santa Rita','Siquire','Soapire'],'Paz Castillo');
SELECT insert_parroquias(ARRAY['Cúpira','Machurucuto','Guarabe'],'Pedro Gual');
SELECT insert_parroquias(ARRAY['Guarenas'],'Plaza');
SELECT insert_parroquias(ARRAY['San Antonio de Yare','San Francisco de Yare'],'Simón Bolívar');
SELECT insert_parroquias(ARRAY['Cúa','Nueva Cúa'],'Urdaneta');
SELECT insert_parroquias(ARRAY['Leoncio Martínez','Caucagüita','Filas de Mariche','La Dolorita','Petare'],'Sucre');
SELECT insert_parroquias(ARRAY['Guatire','Araira'],'Zamora');

-- Monagas
SELECT insert_municipios(ARRAY['Acosta','Aguasay','Bolívar','Caripe','Cedeño','Ezequiel Zamora','Libertador','Maturín','Piar','Punceres','Santa Bárbara','Sotillo','Uracoa'],'Monagas');
SELECT insert_parroquias(ARRAY['San Antonio de Maturín','San Francisco de Maturín'],'Acosta');
SELECT insert_parroquias(ARRAY['Aguasay'],'Aguasay');
SELECT insert_parroquias(ARRAY['Caripito'],'Bolívar');
SELECT insert_parroquias(ARRAY['El Guácharo','La Guanota','Sabana de Piedra','San Agustín','Teresen','Caripe'],'Caripe');
SELECT insert_parroquias(ARRAY['Areo','Capital Cedeño','San Félix de Cantalicio','Viento Fresco'],'Cedeño');
SELECT insert_parroquias(ARRAY['El Tejero','Punta de Mata'],'Ezequiel Zamora');
SELECT insert_parroquias(ARRAY['Chaguaramas','Las Alhuacas','Tabasca','Temblador'],'Libertador');
SELECT insert_parroquias(ARRAY['Alto de los Godos','Boquerón','Las Cocuizas','La Cruz','San Simón','El Corozo','El Furrial','Jusepín','La Pica','San Vicente'],'Maturín');
SELECT insert_parroquias(ARRAY['Aparicio','Aragua de Maturín','Chaguaramal','El Pinto','Guanaguana','La Toscana','Taguaya'],'Piar');
SELECT insert_parroquias(ARRAY['Cachipo','Quiriquire'],'Punceres');
SELECT insert_parroquias(ARRAY['Santa Bárbara','Morón'],'Santa Bárbara');
SELECT insert_parroquias(ARRAY['Barrancas','Los Barrancos de Fajardo'],'Sotillo');
SELECT insert_parroquias(ARRAY['Uracoa'],'Uracoa');

-- Nueva Esparta
SELECT insert_municipios(ARRAY['Antolín del Campo','Arismendi','Díaz','García','Gómez','Maneiro','Marcano','Mariño','Macanao','Tubores','Villalba'],'Nueva Esparta');
SELECT insert_parroquias(ARRAY['Antolín del Campo'],'Antolín del Campo');
SELECT insert_parroquias(ARRAY['Arismendi'],'Arismendi');
SELECT insert_parroquias(ARRAY['San Juan Bautista','Zabala'],'Díaz');
SELECT insert_parroquias(ARRAY['García','Francisco Fajardo'],'García');
SELECT insert_parroquias(ARRAY['Bolívar','Guevara','Matasiete','Santa Ana','Sucre'],'Gómez');
SELECT insert_parroquias(ARRAY['Aguirre','Maneiro'],'Maneiro');
SELECT insert_parroquias(ARRAY['Adrián','Juan Griego'],'Marcano');
SELECT insert_parroquias(ARRAY['Mariño'],'Mariño');
SELECT insert_parroquias(ARRAY['San Francisco de Macanao','Boca de Río'],'Macanao');
SELECT insert_parroquias(ARRAY['Tubores','Los Barales'],'Tubores');
SELECT insert_parroquias(ARRAY['Vicente Fuentes','Villalba'],'Villalba');

-- Portuguesa
SELECT insert_municipios(ARRAY['Araure','Esteller','Guanare','Guanarito','Ospino','Páez','Sucre','Turen','Monseñor José V. de Unda','Agua Blanca','Papelón','San Genaro de Boconoíto','San Rafael de Onoto','Santa Rosalía'],'Portuguesa');
SELECT insert_parroquias(ARRAY['Araure','Río Acarigua'],'Araure');
SELECT insert_parroquias(ARRAY['Agua Blanca'],'Agua Blanca');
SELECT insert_parroquias(ARRAY['Píritu','Uveral'],'Esteller');
SELECT insert_parroquias(ARRAY['Cordova','Guanare','San José de la Montaña','San Juan de Guanaguanare','Virgen de Coromoto'],'Guanare');
SELECT insert_parroquias(ARRAY['Guanarito','Trinidad de la Capilla','Divina Pastora'],'Guanarito');
SELECT insert_parroquias(ARRAY['Chabasquén','Peña Blanca'],'Monseñor José V. de Unda');
SELECT insert_parroquias(ARRAY['Aparición','La Estación','Ospino'],'Ospino');
SELECT insert_parroquias(ARRAY['Acarigua','Payara','Pimpinela','Ramón Peraza'],'Páez');
SELECT insert_parroquias(ARRAY['Caño Delgadito','Papelón'],'Papelón');
SELECT insert_parroquias(ARRAY['Antolín Tovar Aquino','Boconoíto'],'San Genaro de Boconoíto');
SELECT insert_parroquias(ARRAY['Santa Fé','San Rafael de Onoto','Thelmo Morles'],'San Rafael de Onoto');
SELECT insert_parroquias(ARRAY['Florida','El Playón'],'Santa Rosalía');
SELECT insert_parroquias(ARRAY['Biscucuy','Concepción','San Rafael de Palo Alzado.','San José de Saguaz','Uvencio Antonio Velásquez.','Villa Rosa.'],'Sucre');
SELECT insert_parroquias(ARRAY['Villa Bruzual','Canelones','Santa Cruz','San Isidro Labrador la colonia'],'Turén');

-- Sucre
SELECT insert_municipios(ARRAY['Andrés Eloy Blanco','Andrés Mata','Arismendi','Benítez','Bermúdez','Bolívar','Cajigal','Cruz Salmerón Acosta','Libertador','Mariño','Mejía','Montes','Ribero','Sucre','Valdez'],'Sucre');
SELECT insert_parroquias(ARRAY['Mariño','Rómulo Gallegos'],'Andrés Eloy Blanco');
SELECT insert_parroquias(ARRAY['San José de Areocuar','Tavera Acosta'],'Andrés Mata');
SELECT insert_parroquias(ARRAY['Río Caribe','Antonio José de Sucre','El Morro de Puerto Santo','Puerto Santo','San Juan de las Galdonas'],'Arismendi');
SELECT insert_parroquias(ARRAY['El Pilar','El Rincón','General Francisco Antonio Vázquez','Guaraúnos','Tunapuicito','Unión'],'Benítez');
SELECT insert_parroquias(ARRAY['Santa Catalina','Santa Rosa','Santa Teresa','Bolívar','Maracapana'],'Bermúdez');
SELECT insert_parroquias(ARRAY['Marigüitar'],'Bolívar');
SELECT insert_parroquias(ARRAY['Libertad','El Paujil','Yaguaraparo'],'Cajigal');
SELECT insert_parroquias(ARRAY['Araya','Chacopata','Manicuare'],'Cruz Salmerón Acosta');
SELECT insert_parroquias(ARRAY['Tunapuy','Campo Elías'],'Libertador');
SELECT insert_parroquias(ARRAY['Irapa','Campo Claro','Marabal','San Antonio de Irapa','Soro'],'Mariño');
SELECT insert_parroquias(ARRAY['San Antonio del Golfo'],'Mejía');
SELECT insert_parroquias(ARRAY['Cumanacoa','Arenas','Aricagua','Cocollar','San Fernando','San Lorenzo'],'Montes');
SELECT insert_parroquias(ARRAY['Cariaco','Catuaro','Rendón','Santa Cruz','Santa María'],'Ribero');
SELECT insert_parroquias(ARRAY['Altagracia Cumaná','Santa Inés Cumaná','Valentín Valiente Cumaná','Ayacucho Cumaná','San Juan','Raúl Leoni','Gran Mariscal'],'Sucre');
SELECT insert_parroquias(ARRAY['Cristóbal Colón','Bideau','Punta de Piedras','Güiria'],'Valdez');

-- Táchira
SELECT insert_municipios(ARRAY['Andrés Bello','Antonio Rómulo Acosta','Ayacucho','Bolívar','Cárdenas','Córdoba','Fernández Feo','Francisco de Miranda','García de Hevia','Guásimos','Independencia','Jáuregui','José María Vargas','Junín','Libertad','Libertador','Lobatera','Michelena','Panamericano','Pedro María Ureña','Rafael Urdaneta','Samuel Darío Maldonado','San Cristóbal','San Judas Tadeo','Seboruco','Simón Rodríguez','Táriba','Torbes','Uribante'],'Táchira');
SELECT insert_parroquias(ARRAY['Cordero'],'Andrés Bello');
SELECT insert_parroquias(ARRAY['Virgen del Carmen'],'Antonio Rómulo Acosta');
SELECT insert_parroquias(ARRAY['Rivas Berti','San Juan de Colón','San Pedro del Río'],'Ayacucho');
SELECT insert_parroquias(ARRAY['Isaías Medina Angarita','Juan Vicente Gómez','Palotal','San Antonio del Táchira'],'Bolívar');
SELECT insert_parroquias(ARRAY['Amenodoro Rangel Lamús','La Florida','Táriba'],'Cárdenas');
SELECT insert_parroquias(ARRAY['Santa Ana del Táchira'],'Córdoba');
SELECT insert_parroquias(ARRAY['Alberto Adriani','San Rafael del Piñal','Santo Domingo'],'Fernández Feo');
SELECT insert_parroquias(ARRAY['San José de Bolívar'],'Francisco de Miranda');
SELECT insert_parroquias(ARRAY['Boca de Grita','José Antonio Páez','La Fría'],'García de Hevia');
SELECT insert_parroquias(ARRAY['Palmira'],'Guásimos');
SELECT insert_parroquias(ARRAY['Capacho Nuevo','Juan Germán Roscio','Román Cárdenas'],'Independencia');
SELECT insert_parroquias(ARRAY['Emilio Constantino Guerrero','La Grita','Monseñor Miguel Antonio Salas'],'Jáuregui');
SELECT insert_parroquias(ARRAY['El Cobre'],'José María Vargas');
SELECT insert_parroquias(ARRAY['Bramón','La Petrólea','Quinimarí','Rubio'],'Junín');
SELECT insert_parroquias(ARRAY['Capacho Viejo','Cipriano Castro','Manuel Felipe Rugeles'],'Libertad');
SELECT insert_parroquias(ARRAY['Abejales','Doradas','Emeterio Ochoa','San Joaquín de Navay'],'Libertador');
SELECT insert_parroquias(ARRAY['Lobatera','Constitución'],'Lobatera');
SELECT insert_parroquias(ARRAY['Michelena'],'Michelena');
SELECT insert_parroquias(ARRAY['San Pablo','La Palmita'],'Panamericano');
SELECT insert_parroquias(ARRAY['Ureña','Nueva Arcadia'],'Pedro María Ureña');
SELECT insert_parroquias(ARRAY['Delicias'],'Rafael Urdaneta');
SELECT insert_parroquias(ARRAY['Boconó','Hernández','La Tendida'],'Samuel Darío Maldonado');
SELECT insert_parroquias(ARRAY['Francisco Romero Lobo','La Concordia','Pedro María Morantes','San Juan Bautista','San Sebastián'],'San Cristóbal');
SELECT insert_parroquias(ARRAY['San Judas Tadeo'],'San Judas Tadeo');
SELECT insert_parroquias(ARRAY['Seboruco'],'Seboruco');
SELECT insert_parroquias(ARRAY['San Simón'],'Simón Rodríguez');
SELECT insert_parroquias(ARRAY['Eleazar López Contreras','Capital Sucre','San Pablo'],'Sucre');
SELECT insert_parroquias(ARRAY['San Josecito'],'Torbes');
SELECT insert_parroquias(ARRAY['Cárdenas','Juan Pablo Peñaloza','Potosí','Pregonero'],'Uribante');

-- Trujillo
SELECT insert_municipios(ARRAY['Andrés Bello','Boconó','Bolívar','Candelaria','Carache','Escuque','José Felipe Márquez Cañizales','Juan Vicente Campo Elías','La Ceiba','Miranda','Monte Carmelo','Motatán','Pampán','Pampanito','Rafael Rangel','San Rafael de Carvajal','Sucre','Trujillo','Urdaneta','Valera'],'Trujillo');
SELECT insert_parroquias(ARRAY['Santa Isabel','Araguaney','El Jaguito','La Esperanza'],'Andrés Bello');
SELECT insert_parroquias(ARRAY['Boconó','Ayacucho','Burbusay','El Carmen','General Ribas','Guaramacal','Monseñor Jáuregui','Mosquey','Rafael Rangel','San José','San Miguel','Vega de Guaramacal'],'Boconó');
SELECT insert_parroquias(ARRAY['Sabana Grande','Cheregüé','Granados'],'Bolívar');
SELECT insert_parroquias(ARRAY['Chejendé','Arnoldo Gabaldón','Bolivia','Carrillo','Cegarra','Manuel Salvador Ulloa','San José'],'Candelaria');
SELECT insert_parroquias(ARRAY['Carache','Cuicas','La Concepción','Panamericana','Santa Cruz'],'Carache');
SELECT insert_parroquias(ARRAY['Escuque','La Unión','Sabana Libre','Santa Rita'],'Escuque');
SELECT insert_parroquias(ARRAY['El Socorro','Antonio José de Sucre','Los Caprichos'],'José Felipe Márquez Cañizales');
SELECT insert_parroquias(ARRAY['Campo Elías','Arnoldo Gabaldón'],'Juan Vicente Campo Elías');
SELECT insert_parroquias(ARRAY['Santa Apolonia','El Progreso','La Ceiba','Tres de Febrero'],'La Ceiba');
SELECT insert_parroquias(ARRAY['El Dividive','Agua Caliente','Agua Santa','El Cenizo','Valerita'],'Miranda');
SELECT insert_parroquias(ARRAY['Monte Carmelo','Buena Vista','Santa María del Horcón'],'Monte Carmelo');
SELECT insert_parroquias(ARRAY['Motatán','El Baño','Jalisco'],'Motatán');
SELECT insert_parroquias(ARRAY['Pampán','Flor de Patria','La Paz','Santa Ana'],'Pampán');
SELECT insert_parroquias(ARRAY['Pampanito','La Concepción','Pampanito II'],'Pampanito');
SELECT insert_parroquias(ARRAY['Betijoque','José Gregorio Hernández','La Pueblita','Los Cedros'],'Rafael Rangel');
SELECT insert_parroquias(ARRAY['Carvajal','Antonio Nicolás Briceño','Campo Alegre','José Leonardo Suárez'],'San Rafael de Carvajal');
SELECT insert_parroquias(ARRAY['Sabana de Mendoza','El Paraíso','Junín','Valmore Rodríguez'],'Sucre');
SELECT insert_parroquias(ARRAY['Matriz','Andrés Linares','Chiquinquirá','Cristóbal Mendoza','Cruz Carrillo','Monseñor Carrillo','Tres Esquinas'],'Trujillo');
SELECT insert_parroquias(ARRAY['La Quebrada','Cabimbú','Jajó','La Mesa','Santiago','Tuñame'],'Urdaneta');
SELECT insert_parroquias(ARRAY['Mercedes Díaz','Juan Ignacio Montilla','La Beatriz','La Puerta','Mendoza del Valle de Momboy','San Luis'],'Valera');

-- Yaracuy
SELECT insert_municipios(ARRAY['Arístides Bastidas','Bolívar','Bruzual','Cocorote','Independencia','José Antonio Páez','La Trinidad','Manuel Monge','Nirgua','Peña','San Felipe','Sucre','Urachiche','Veroes'],'Yaracuy');
SELECT insert_parroquias(ARRAY['Arístides Bastidas'],'Arístides Bastidas');
SELECT insert_parroquias(ARRAY['Bolívar'],'Bolívar');
SELECT insert_parroquias(ARRAY['Chivacoa','Campo Elías'],'Bruzual');
SELECT insert_parroquias(ARRAY['Cocorote'],'Cocorote');
SELECT insert_parroquias(ARRAY['Independencia'],'Independencia');
SELECT insert_parroquias(ARRAY['José Antonio Páez'],'José Antonio Páez');
SELECT insert_parroquias(ARRAY['La Trinidad'],'La Trinidad');
SELECT insert_parroquias(ARRAY['Manuel Monge'],'Manuel Monge');
SELECT insert_parroquias(ARRAY['Salóm','Temerla','Nirgua','Cogollos'],'Nirgua');
SELECT insert_parroquias(ARRAY['San Andrés','Yaritagua'],'Peña');
SELECT insert_parroquias(ARRAY['San Javier','Albarico','San Felipe'],'San Felipe');
SELECT insert_parroquias(ARRAY['Sucre'],'Sucre');
SELECT insert_parroquias(ARRAY['Urachiche'],'Urachiche');
SELECT insert_parroquias(ARRAY['El Guayabo','Farriar'],'Veroes');

-- Zulia
SELECT insert_municipios(ARRAY['Almirante Padilla','Baralt','Cabimas','Catatumbo','Colón','Francisco Javier Pulgar','Guajira','Jesús Enrique Lossada','Jesús María Semprún','La Cañada de Urdaneta','Lagunillas','Machiques de Perijá','Mara','Maracaibo','Miranda','Rosario de Perijá','San Francisco','Santa Rita','Simón Bolívar','Sucre','Valmore Rodríguez'],'Zulia');
SELECT insert_parroquias(ARRAY['Isla de Toas','Monagas'],'Almirante Padilla');
SELECT insert_parroquias(ARRAY['San Timoteo','General Urdaneta','Libertador','Marcelino Briceño','Pueblo Nuevo','Manuel Guanipa Matos'],'Baralt');
SELECT insert_parroquias(ARRAY['Ambrosio','Arístides Calvani','Carmen Herrera','Germán Ríos Linares','Jorge Hernández','La Rosa','Punta Gorda','Rómulo Betancourt','San Benito'],'Cabimas');
SELECT insert_parroquias(ARRAY['Encontrados','Udón Pérez'],'Catatumbo');
SELECT insert_parroquias(ARRAY['San Carlos del Zulia','Moralito','Santa Bárbara','Santa Cruz del Zulia','Urribarrí'],'Colón');
SELECT insert_parroquias(ARRAY['Simón Rodríguez','Agustín Codazzi','Carlos Quevedo','Francisco Javier Pulgar'],'Francisco Javier Pulgar');
SELECT insert_parroquias(ARRAY['Sinamaica','Alta Guajira','Elías Sánchez Rubio','Guajira'],'Guajira');
SELECT insert_parroquias(ARRAY['La Concepción','San José','Mariano Parra León','José Ramón Yépez'],'Jesús Enrique Lossada');
SELECT insert_parroquias(ARRAY['Jesús María Semprún','Barí'],'Jesús María Semprún');
SELECT insert_parroquias(ARRAY['Concepción','Andrés Bello','Chiquinquirá','El Carmelo','Potreritos'],'La Cañada de Urdaneta');
SELECT insert_parroquias(ARRAY['Alonso de Ojeda','Libertad','Eleazar López Contreras','Campo Lara','Venezuela','El Danto'],'Lagunillas');
SELECT insert_parroquias(ARRAY['Libertad','Bartolomé de las Casas','Río Negro','San José de Perijá'],'Machiques de Perijá');
SELECT insert_parroquias(ARRAY['San Rafael','La Sierrita','Las Parcelas','Luis De Vicente','Monseñor Marcos Sergio Godoy','Ricaurte','Tamare'],'Mara');
SELECT insert_parroquias(ARRAY['Antonio Borjas Romero','Bolívar','Cacique Mara','Carracciolo Parra Pérez','Cecilio Acosta','Chinquinquirá','Coquivacoa','Cristo de Aranza','Francisco Eugenio Bustamante','Idelfonzo Vásquez','Juana de Ávila','Luis Hurtado Higuera','Manuel Dagnino','Olegario Villalobos','Raúl Leoni','San Isidro','Santa Lucía','Venancio Pulgar'],'Maracaibo');
SELECT insert_parroquias(ARRAY['Altagracia','Ana María Campos','Faría','San Antonio','San José'],'Miranda');
SELECT insert_parroquias(ARRAY['El Rosario','Donaldo García','Sixto Zambrano'],'Rosario de Perijá');
SELECT insert_parroquias(ARRAY['San Francisco','El Bajo','Domitila Flores','Francisco Ochoa','Los Cortijos','Marcial Hernández','José Domingo Rus'],'San Francisco');
SELECT insert_parroquias(ARRAY['Santa Rita','El Mene','José Cenobio Urribarrí','Pedro Lucas Urribarrí'],'Santa Rita');
SELECT insert_parroquias(ARRAY['Manuel Manrique','Rafael Maria Baralt','Rafael Urdaneta'],'Simón Bolívar');
SELECT insert_parroquias(ARRAY['Bobures','El Batey','Gibraltar','Heras','Monseñor Arturo Álvarez','Rómulo Gallegos'],'Sucre');
SELECT insert_parroquias(ARRAY['Rafael Urdaneta','La Victoria','Raúl Cuenca'],'Valmore Rodríguez');

-- Check
SELECT sub_L.nombre_luga, sub_L.tipo_luga, sup_L.nombre_luga
FROM Lugar as sup_L, Lugar as sub_L
WHERE
	sup_L.cod_luga = sub_L.fk_luga;
