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

-- States
CALL insert_estados(ARRAY ['Amazonas', 'Anzoategui', 'Apure', 'Aragua', 'Barinas', 'Bolivar', 'Carabobo', 'Cojedes', 'Delta Amacuro', 'Distrito Capital', 'Falcon', 'Guarico', 'Lara', 
'Merida', 'Miranda', 'Monagas', 'Nueva Esparta', 'Portuguesa', 'Sucre', 
'Tachira', 'Trujillo', 'Yaracuy', 'Zulia']);

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
CALL insert_municipios(ARRAY['Anaco', 'Aragua', 'Diego Bautista Urbaneja', 'Fernando de Peñalver', 'Francisco del Carmen Carvajal', 'Francisco de Miranda', 'Guanta', 'Independencia', 'Jose Gregorio Monagas', 'Juan Antonio Sotillo', 'Juan Manuel Cajigal', 'Libertad', 'Manuel Ezequiel Bruzual', 'Pedro Maria Freites', 'Piritu', 'Guanipa', 'San Juan de Capistrano', 'Santa Ana', 'Simon Bolivar', 'Simon Rodriguez', 'Sir Arthur McGregor'], 'Amazonas');
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
CALL insert_parroquias(ARRAY['San Jose de Guanipa'], 'San Jose de Guanipa');
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
CALL insert_parroquias(ARRAY['Guasdualito', 'Aramendi', 'El Amparo', 'San Camilo', 'Urdaneta', 'Canagua', 'Dominga Ortíz de Paez', 'Santa Rosalia'], 'Paez');
CALL insert_parroquias(ARRAY['San Juan de Payara', 'Codazzi', 'Cunaviche'], 'Pedro Camejo');
CALL insert_parroquias(ARRAY['Elorza', 'La Trinidad de Orichuna'], 'Romulo Gallegos');
CALL insert_parroquias(ARRAY['El Recreo', 'Peñalver', 'San Fernando de Apure', 'San Rafael de Atamaica'], 'San Fernando');

-- Aragua 
CALL insert_municipios(ARRAY['Anastasio Girardot', 'Bolivar', 'Mario Briceño Iragorry', 'Santos Michelena', 'Sucre', 'Santiago Mariño', 'Jose angel Lamas', 'Francisco Linares Alcantara', 'San Casimiro', 'Urdaneta', 'Jose Felix Ribas', 'Jose Rafael Revenga', 'Ocumare de la Costa de Oro', 'Tovar', 'Camatagua', 'Zamora', 'San Sebastian', 'Libertador'], 'Aragua'); CALL insert_parroquias(ARRAY['Bolivar San Mateo'], 'Bolivar');
CALL insert_parroquias(ARRAY['Camatagua', 'Carmen de Cura'], 'Camatagua');
CALL insert_parroquias(ARRAY['Santa Rita', 'Francisco de Miranda', 'Moseñor Feliciano Gonzalez Paraparal'], 'Francisco Linares Alcantara');
CALL insert_parroquias(ARRAY['Pedro Jose Ovalles', 'Joaquin Crespo', 'Jose Casanova Godoy', 'Madre Maria de San Jose', 'Andres Eloy Blanco', 'Los Tacarigua', 'Las Delicias', 'Choroni'], 'Atanasio Girardot');
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
CALL insert_municipios(ARRAY['Alberto Arvelo Torrealba', 'Andrés Eloy Blanco', 'Antonio José de Sucre', 'Arismendi', 'Barinas', 'Bolívar', 'Cruz Paredes', 'Ezequiel Zamora', 'Obispos', 'Pedraza', 'Sosa', 'Rojas'], 'Barinas');
CALL insert_parroquias(ARRAY['Arismendi', 'Guadarrama', 'La Unión', 'San Antonio'], 'Arismendi');
CALL insert_parroquias(ARRAY['Barinas', 'Alfredo Arvelo Larriva', 'San Silvestre', 'Santa Inés', 'Santa Lucía', 'Torunos', 'El Carmen', 'Rómulo Betancourt', 'Corazón de Jesús', 'Ramón Ignacio Méndez', 'Alto Barinas', 'Manuel Palacio Fajardo', 'Juan Antonio Rodríguez Domínguez', 'Dominga Ortiz de Páez'], 'Barinas');
CALL insert_parroquias(ARRAY['El Cantón', 'Santa Cruz de Guacas', 'Puerto Vivas'], 'Andrés Eloy Blanco');
CALL insert_parroquias(ARRAY['Barinitas', 'Altamira de Cáceres', 'Calderas'], 'Bolívar');
CALL insert_parroquias(ARRAY['Masparrito', 'El Socorro', 'Barrancas'], 'Cruz Paredes');
CALL insert_parroquias(ARRAY['Obispos', 'El Real', 'La Luz', 'Los Guasimitos'], 'Obispos');
CALL insert_parroquias(ARRAY['Ciudad Bolivia', 'Ignacio Briceño', 'José Félix Ribas', 'Páez'], 'Pedraza');
CALL insert_parroquias(ARRAY['Libertad', 'Dolores', 'Santa Rosa', 'Simón Rodríguez', 'Palacio Fajardo'], 'Rojas');
CALL insert_parroquias(ARRAY['Ciudad de Nutrias', 'El Regalo', 'Puerto Nutrias', 'Santa Catalina', 'Simón Bolívar'], 'Sosa');
CALL insert_parroquias(ARRAY['Ticoporo', 'Nicolás Pulido', 'Andrés Bello'], 'Antonio José de Sucre');
CALL insert_parroquias(ARRAY['Sabaneta', 'Juan Antonio Rodríguez Domínguez'], 'Alberto Arvelo Torrealba');
CALL insert_parroquias(ARRAY['Santa Bárbara', 'Pedro Briceño Méndez', 'Ramón Ignacio Méndez', 'José Ignacio del Pumar'], 'Ezequiel Zamora');

-- Bolivar
CALL insert_municipios(ARRAY['Caroní', 'Cedeño', 'El Callao', 'Gran Sabana', 'Heres', 'Padre Pedro Chien', 'Piar', 'Angostura', 'Roscio', 'Sifontes', 'Sucre'], 'Bolívar');
CALL insert_parroquias(ARRAY['Cachamay', 'Chirica', 'Dalla Costa', 'Once de Abril', 'Simón Bolívar', 'Unare', 'Universidad', 'Vista al Sol', 'Pozo Verde', 'Yocoima', '5 de Julio'], 'Caroní');
CALL insert_parroquias(ARRAY['Cedeño', 'Altagracia', 'Ascensión Farreras', 'Guaniamo', 'La Urbana', 'Pijiguaos'], 'Cedeño');
CALL insert_parroquias(ARRAY['El Callao'], 'El Callao');
CALL insert_parroquias(ARRAY['Gran Sabana', 'Ikabarú'], 'Gran Sabana');
CALL insert_parroquias(ARRAY['Catedral', 'Zea', 'Orinoco', 'José Antonio Páez', 'Marhuanta', 'Agua Salada', 'Vista Hermosa', 'La Sabanita', 'Panapana'], 'Heres');
CALL insert_parroquias(ARRAY['Padre Pedro Chien'], 'Padre Pedro Chien');
CALL insert_parroquias(ARRAY['Andrés Eloy Blanco', 'Pedro Cova', 'Upata'], 'Piar');
CALL insert_parroquias(ARRAY['Raúl Leoni', 'Barceloneta', 'Santa Bárbara', 'San Francisco'], 'Angostura (Raúl Leoni)');
CALL insert_parroquias(ARRAY['Roscio', 'Salóm'], 'Roscio');
CALL insert_parroquias(ARRAY['Tumeremo', 'Dalla Costa', 'San Isidro'], 'Sifontes');
CALL insert_parroquias(ARRAY['Sucre', 'Aripao', 'Guarataro', 'Las Majadas', 'Moitaco'], 'Sucre');

-- Carabobo
CALL insert_municipios(ARRAY['Bejuma','Carlos Arvelo','Diego Ibarra','Guacara','Juan José Mora','Libertador','Los Guayos','Miranda','Montalbán','Naguanagua','Puerto Cabello','San Diego','San Joaquín','Valencia'],'Carabobo');
CALL insert_parroquias(ARRAY['Canoabo', 'Simón Bolívar'], 'Bejuma');
CALL insert_parroquias(ARRAY['Güigüe', 'Belén', 'Tacarigua'], 'Carlos Arvelo');
CALL insert_parroquias(ARRAY['Mariara', 'Aguas Calientes'], 'Diego Ibarra');
CALL insert_parroquias(ARRAY['Ciudad Alianza', 'Guacara', 'Yagua'], 'Guacara');
CALL insert_parroquias(ARRAY['Morón', 'Urama'], 'Juan José Mora');
CALL insert_parroquias(ARRAY['Tocuyito Valencia', 'Independencia Campo Carabobo'], 'Libertador');
CALL insert_parroquias(ARRAY['Los Guayos Valencia'], 'Los Guayos');
CALL insert_parroquias(ARRAY['Miranda'], 'Miranda');
CALL insert_parroquias(ARRAY['Montalbán'], 'Montalbán');
CALL insert_parroquias(ARRAY['Urbana Naguanagua Valencia'], 'Naguanagua');
CALL insert_parroquias(ARRAY['Bartolomé Salóm', 'Democracia', 'Fraternidad', 'Goaigoaza', 'Juan José Flores', 'Unión', 'Borburata', 'Patanemo'], 'Puerto Cabello');
CALL insert_parroquias(ARRAY['San Diego Valencia'], 'San Diego');
CALL insert_parroquias(ARRAY['San Joaquín'], 'San Joaquín');
CALL insert_parroquias(ARRAY['Urbana Candelaria', 'Urbana Catedral', 'Urbana El Socorro', 'Urbana Miguel Peña', 'Urbana Rafael Urdaneta', 'Urbana San Blas', 'Urbana San José', 'Urbana Santa Rosa', 'Rural Negro Primero'], 'Valencia');

-- Cojedes
CALL insert_municipios(ARRAY['Anzoategui','Pao de San Juan Bautista','Tinaquillo','Girardot','Lima Blanco','Ricaurte','Romulo Gallegos','Ezequiel Zamora','Tinaco'],'Cojedes');
CALL insert_parroquias(ARRAY['Cojedes', 'Juan de Mata Suárez'], 'Anzoategui');
CALL insert_parroquias(ARRAY['El Pao'], 'Pao de San Juan Bautista');
CALL insert_parroquias(ARRAY['Tinaquillo'], 'Tinaquillo');
CALL insert_parroquias(ARRAY['El Baúl', 'Sucre'], 'Girardot');
CALL insert_parroquias(ARRAY['La Aguadita', 'Macapo'], 'Lima Blanco');
CALL insert_parroquias(ARRAY['El Amparo', 'Libertad de Cojedes'], 'Ricaurte');
CALL insert_parroquias(ARRAY['Rómulo Gallegos (Las Vegas)'], 'Romulo Gallegos');
CALL insert_parroquias(ARRAY['San Carlos de Austria', 'Juan Ángel Bravo', 'Manuel Manrique'], 'Ezequiel Zamora');
CALL insert_parroquias(ARRAY['General en Jefe Jos Laurencio Silva'], 'Tinaco');

-- Delta Amacuro
CALL insert_municipios(ARRAY['Antonio Díaz','Casacoima','Pedernales','Tucupita'],'Delta Amacuro');
CALL insert_parroquias(ARRAY['Curiapo','Almirante Luis Brión','Francisco Aniceto Lugo','Manuel Renaud','Padre Barral','Santos de Abelgas'],'Antonio Díaz');
CALL insert_parroquias(ARRAY['Imataca','Juan Bautista Arismendi','Manuel Piar','Rómulo Gallegos'],'Casacoima');
CALL insert_parroquias(ARRAY['Pedernales','Luis Beltrán Prieto Figueroa'],'Pedernales');
CALL insert_parroquias(ARRAY['San José','José Vidal Marcano','Leonardo Ruiz Pineda','Mariscal Antonio José de Sucre','Monseñor Argimiro García','Virgen del Valle','San Rafael','Juan Millán'],'Tucupita');

-- Distrito Federal
CALL insert_municipios(ARRAY['Libertador'],'Distrito Capital');
CALL insert_parroquias(ARRAY['23 de Enero','Altagracia','Antímano','Caricuao','Catedral','Coche','El Junquito','El Paraíso','El Recreo','El Valle','La Candelaria','La Pastora','La Vega','Macarao','San Agustín','San Bernardino','San José','San Juan','San Pedro','Santa Rosalía','Santa Teresa','Sucre'],'Libertador');

-- Falcon
CALL insert_municipios(ARRAY['Acosta','Bolívar','Buchivacoa','Cacique Manaure','Carirubana','Colina','Dabajuro','Democracia','Falcón','Federación','Jacura','Los Taques','Mauroa','Miranda','Monseñor Iturriza','Palmasola','Petit','Píritu','San Francisco','Silva','Sucre','Tocopero','Unión','Urumaco','Zamora'],'Falcon');
CALL insert_parroquias(ARRAY['Capadare', 'La Pastora', 'Libertador', 'San Juan de los Cayos'], 'Acosta');
CALL insert_parroquias(ARRAY['Aracua', 'La Peña', 'San Luis'], 'Bolívar');
CALL insert_parroquias(ARRAY['Bariro', 'Borojó', 'Capatárida', 'Guajiro', 'Seque', 'Valle de Eroa', 'Zazárida'], 'Buchivacoa');
CALL insert_parroquias(ARRAY['Cacique Manaure (Yaracal)'], 'Cacique Manaure');
CALL insert_parroquias(ARRAY['Norte', 'Carirubana', 'Santa Ana', 'Urbana Punta Cardón'], 'Carirubana');
CALL insert_parroquias(ARRAY['La Vela de Coro', 'Acurigua', 'Guaibacoa', 'Las Calderas', 'Mataruca'], 'Colina');
CALL insert_parroquias(ARRAY['Dabajuro'], 'Dabajuro');
CALL insert_parroquias(ARRAY['Agua Clara', 'Avaria', 'Pedregal', 'Piedra Grande', 'Purureche'], 'Democracia');
CALL insert_parroquias(ARRAY['Adaure', 'Adícora', 'Baraived', 'Buena Vista', 'Jadacaquiva', 'El Vínculo', 'El Hato', 'Moruy', 'Pueblo Nuevo'], 'Falcón');
CALL insert_parroquias(ARRAY['Agua Larga', 'Churuguara', 'El Paují', 'Independencia', 'Mapararí'], 'Federación');
CALL insert_parroquias(ARRAY['Agua Linda', 'Araurima', 'Jacura'], 'Jacura');
CALL insert_parroquias(ARRAY['Tucacas', 'Boca de Aroa'], 'José Laurencio Silva');
CALL insert_parroquias(ARRAY['Los Taques', 'Judibana'], 'Los Taques');
CALL insert_parroquias(ARRAY['Mene de Mauroa', 'San Félix', 'Casigua'], 'Mauroa');
CALL insert_parroquias(ARRAY['Guzmán Guillermo', 'Mitare', 'Río Seco', 'Sabaneta', 'San Antonio', 'San Gabriel', 'Santa Ana'], 'Miranda');
CALL insert_parroquias(ARRAY['Boca del Tocuyo', 'Chichiriviche', 'Tocuyo de la Costa'], 'Monseñor Iturriza');
CALL insert_parroquias(ARRAY['Palmasola'], 'Palmasola');
CALL insert_parroquias(ARRAY['Cabure', 'Colina', 'Curimagua'], 'Petit');
CALL insert_parroquias(ARRAY['San José de la Costa', 'Píritu'], 'Píritu');
CALL insert_parroquias(ARRAY['Capital San Francisco Mirimire'], 'San Francisco');
CALL insert_parroquias(ARRAY['Sucre', 'Pecaya'], 'Sucre');
CALL insert_parroquias(ARRAY['Tocópero'], 'Tocópero');
CALL insert_parroquias(ARRAY['El Charal', 'Las Vegas del Tuy', 'Santa Cruz de Bucaral'], 'Unión');
CALL insert_parroquias(ARRAY['Bruzual', 'Urumaco'], 'Urumaco');
CALL insert_parroquias(ARRAY['Puerto Cumarebo', 'La Ciénaga', 'La Soledad', 'Pueblo Cumarebo', 'Zazárida'], 'Zamora');

-- Guárico
CALL insert_municipios(ARRAY['Infante','Mellado','Miranda','Monagas','Ribas','Roscio','Zaraza','Camaguán','San José de Guaribe','Las Mercedes','El Socorro','Ortiz','Santa María de Ipire','Chaguaramas','San Jerónimo de Guayabal'],'Guarico');
CALL insert_parroquias(ARRAY['Camaguán', 'Puerto Miranda', 'Uverito'], 'Camaguán');
CALL insert_parroquias(ARRAY['Chaguaramas'], 'Chaguaramas');
CALL insert_parroquias(ARRAY['El Socorro'], 'El Socorro');
CALL insert_parroquias(ARRAY['El Calvario', 'El Rastro', 'Guardatinajas', 'Capital Urbana Calabozo'], 'Francisco de Miranda');
CALL insert_parroquias(ARRAY['Tucupido', 'San Rafael de Laya'], 'José Félix Ribas');
CALL insert_parroquias(ARRAY['Altagracia de Orituco', 'San Rafael de Orituco', 'San Francisco Javier de Lezama', 'Paso Real de Macaira', 'Carlos Soublette', 'San Francisco de Macaira', 'Libertad de Orituco'], 'José Tadeo Monagas');
CALL insert_parroquias(ARRAY['Cantagallo', 'San Juan de los Morros', 'Parapara'], 'Juan Germán Roscio');
CALL insert_parroquias(ARRAY['El Sombrero', 'Sosa'], 'Julián Mellado');
CALL insert_parroquias(ARRAY['Las Mercedes', 'Cabruta', 'Santa Rita de Manapire'], 'Juan Jose Rondon');
CALL insert_parroquias(ARRAY['Valle de la Pascua', 'Espino'], 'Leonardo Infante');
CALL insert_parroquias(ARRAY['San José de Tiznados', 'San Francisco de Tiznados', 'San Lorenzo de Tiznados', 'Ortiz'], 'Ortiz');
CALL insert_parroquias(ARRAY['San José de Unare', 'Zaraza'], 'Pedro Zaraza');
CALL insert_parroquias(ARRAY['Guayabal', 'Cazorla'], 'San Jerónimo de Guayabal');
CALL insert_parroquias(ARRAY['San José de Guaribe'], 'San José de Guaribe');
CALL insert_parroquias(ARRAY['Santa María de Ipire', 'Altamira'], 'Santa María de Ipire');

-- Lara
CALL insert_municipios(ARRAY['Iribarren','Jiménez','Crespo','Andrés Eloy Blanco','Urdaneta','Torres','Palavecino','Morán','Simón Planas'],'Lara');
CALL insert_parroquias(ARRAY['Quebrada Honda de Guache', 'Pio Tamayo', 'Yacambú'], 'Andrés Eloy Blanco');
CALL insert_parroquias(ARRAY['Freitez', 'José María Blanco'], 'Crespo');
CALL insert_parroquias(ARRAY['Anzoátegui', 'Bolívar', 'Guárico', 'Hilario Luna y Luna', 'Humocaro Bajo', 'Humocaro Alto', 'La Candelaria', 'Morán'], 'Morán');
CALL insert_parroquias(ARRAY['Cabudare', 'José Gregorio Bastidas', 'Agua Viva'], 'Palavecino');
CALL insert_parroquias(ARRAY['Buría', 'Gustavo Vega', 'Sarare'], 'Simón Planas');
CALL insert_parroquias(ARRAY['Altagracia', 'Antonio Díaz', 'Camacaro', 'Castañeda', 'Cecilio Zubillaga', 'Chiquinquira', 'El Blanco', 'Espinoza de los Monteros', 'Heriberto Arrollo', 'Lara', 'Las Mercedes', 'Manuel Morillo', 'Montaña Verde', 'Montes de Oca', 'Reyes de Vargas', 'Torres', 'Trinidad Samuel'], 'Torres');
CALL insert_parroquias(ARRAY['Xaguas', 'Siquisique', 'San Miguel', 'Moroturo'], 'Urdaneta');
CALL insert_parroquias(ARRAY['Aguedo Felipe Alvarado', 'Buena Vista', 'Catedral', 'Concepción', 'El Cují', 'Juares', 'Guerrera Ana Soto', 'Santa Rosa', 'Tamaca', 'Unión'], 'Iribarren');
CALL insert_parroquias(ARRAY['Juan Bautista Rodríguez', 'Cuara', 'Diego de Lozada', 'Paraíso de San José', 'San Miguel', 'Tintorero', 'José Bernardo Dorante', 'Coronel Mariano Peraza'], 'Jiménez');

-- Merida
CALL insert_municipios(ARRAY['Antonio Pinto Salinas','Aricagua','Arzobispo Chacón','Campo Elías','Caracciolo Parra Olmedo','Cardenal Quintero','Chacantá','El Mucuy','Guaraque','Julio César Salas','Justo Briceño','Libertador','Luis Cristóbal Moncada','Rivas Dávila','Rangel','Santos Marquina','Tovar','Tulio Febres-Cordero','Alberto Adriani','Andrés Bello','Miranda','Zea','Sucre'],'Merida');
CALL insert_parroquias(ARRAY['Presidente Betancourt','Presidente Páez','Presidente Rómulo Gallegos','Gabriel Picón González','Héctor Amable Mora','José Nucete Sardi','Pulido Méndez'],'Alberto Adriani');
CALL insert_parroquias(ARRAY['Santa Cruz de Mora','Mesa Bolívar','Mesa de Las Palmas'],'Antonio Pinto Salinas');
CALL insert_parroquias(ARRAY['La Azulita'],'Andrés Bello');
CALL insert_parroquias(ARRAY['Aricagua','San Antonio'],'Aricagua');
CALL insert_parroquias(ARRAY['Canaguá','Capurí','Chacantá','El Molino','Guaimaral','Mucutuy','Mucuchachí'],'Arzobispo Chacón');
CALL insert_parroquias(ARRAY['Fernández Peña','Matriz','Montalbán','Acequias','Jají','La Mesa','San José del Sur'],'Campo Elías');
CALL insert_parroquias(ARRAY['Tucaní','Florencio Ramírez'],'Caracciolo Parra Olmedo');
CALL insert_parroquias(ARRAY['Santo Domingo','Las Piedras'],'Cardenal Quintero');
CALL insert_parroquias(ARRAY['Guaraque','Mesa Quintero','Río Negro'],'Guaraque');
CALL insert_parroquias(ARRAY['Arapuey','Palmira'],'Julio César Salas');
CALL insert_parroquias(ARRAY['San Cristóbal de Torondoy','Torondoy'],'Justo Briceño');
CALL insert_parroquias(ARRAY['Antonio Spinetti Dini','Arias','Caracciolo Parra Pérez','Domingo Peña','El Llano','Gonzalo Picón Febres','Jacinto Plaza','Juan Rodríguez Suárez','Lasso de la Vega','Mariano Picón Salas','Milla','Osuna Rodríguez','Sagrario','El Morro','Los Nevados'],'Libertador');
CALL insert_parroquias(ARRAY['Andrés Eloy Blanco','La Venta','Piñango','Timotes'],'Miranda');
CALL insert_parroquias(ARRAY['Eloy Paredes','San Rafael de Alcázar','Santa Elena de Arenales'],'Obispo Ramos de Lora');
CALL insert_parroquias(ARRAY['Santa María de Caparo'],'Padre Noguera');
CALL insert_parroquias(ARRAY['Pueblo Llano'],'Pueblo Llano');
CALL insert_parroquias(ARRAY['Cacute','La Toma','Mucuchíes','Mucurubá','San Rafael'],'Rangel');
CALL insert_parroquias(ARRAY['Gerónimo Maldonado','Bailadores'],'Rivas Dávila');
CALL insert_parroquias(ARRAY['Tabay'],'Santos Marquina');
CALL insert_parroquias(ARRAY['Chiguará','Estánques','Lagunillas','La Trampa','Pueblo Nuevo del Sur','San Juan'],'Sucre');
CALL insert_parroquias(ARRAY['El Amparo','El Llano','San Francisco','Tovar'],'Tovar');
CALL insert_parroquias(ARRAY['Independencia','María de la Concepción Palacios Blanco','Nueva Bolivia','Santa Apolonia'],'Tulio Febres Cordero');
CALL insert_parroquias(ARRAY['Caño El Tigre','Zea'],'Zea');

-- Miranda
CALL insert_municipios(ARRAY['Acevedo','Andrés Bello','Baruta','Brión','Buroz','Carrizal','Chacao','Cristóbal Rojas','El Hatillo','Guaicaipuro','Independencia','Lander','Los Salias','Páez','Paz Castillo','Pedro Gual','Plaza','Simón Bolívar','Sucre','Urdaneta','Zamora'],'Miranda');
CALL insert_parroquias(ARRAY['Aragüita','Arévalo González','Capaya','Caucagua','Panaquire','Ribas','El Café','Marizapa','Yaguapa'],'Acevedo');
CALL insert_parroquias(ARRAY['Cumbo','San José de Barlovento'],'Andrés Bello');
CALL insert_parroquias(ARRAY['El Cafetal','Las Minas','Nuestra Señora del Rosario'],'Baruta');
CALL insert_parroquias(ARRAY['Higuerote','Curiepe','Tacarigua de Brión','Chirimena','Birongo'],'Brión');
CALL insert_parroquias(ARRAY['Mamporal'],'Buroz');
CALL insert_parroquias(ARRAY['Carrizal'],'Carrizal');
CALL insert_parroquias(ARRAY['Chacao'],'Chacao');
CALL insert_parroquias(ARRAY['Charallave','Las Brisas'],'Cristóbal Rojas');
CALL insert_parroquias(ARRAY['Santa Rosalía de Palermo de El Hatillo'],'El Hatillo');
CALL insert_parroquias(ARRAY['Altagracia de la Montaña','Cecilio Acosta','Los Teques','El Jarillo','San Pedro','Tácata','Paracotos'],'Guaicaipuro');
CALL insert_parroquias(ARRAY['el Cartanal','Santa Teresa del Tuy'],'Independencia');
CALL insert_parroquias(ARRAY['La Democracia','Ocumare del Tuy','Santa Bárbara','La Mata','La Cabrera'],'Lander');
CALL insert_parroquias(ARRAY['San Antonio de los Altos'],'Los Salias');
CALL insert_parroquias(ARRAY['Río Chico','El Guapo','Tacarigua de la Laguna','Paparo','San Fernando del Guapo'],'Páez');
CALL insert_parroquias(ARRAY['Santa Lucía del Tuy','Santa Rita','Siquire','Soapire'],'Paz Castillo');
CALL insert_parroquias(ARRAY['Cúpira','Machurucuto','Guarabe'],'Pedro Gual');
CALL insert_parroquias(ARRAY['Guarenas'],'Plaza');
CALL insert_parroquias(ARRAY['San Antonio de Yare','San Francisco de Yare'],'Simón Bolívar');
CALL insert_parroquias(ARRAY['Cúa','Nueva Cúa'],'Urdaneta');
CALL insert_parroquias(ARRAY['Leoncio Martínez','Caucagüita','Filas de Mariche','La Dolorita','Petare'],'Sucre');
CALL insert_parroquias(ARRAY['Guatire','Araira'],'Zamora');

-- Monagas
CALL insert_municipios(ARRAY['Acosta','Aguasay','Bolívar','Caripe','Cedeño','Ezequiel Zamora','Libertador','Maturín','Piar','Punceres','Santa Bárbara','Sotillo','Uracoa'],'Monagas');
CALL insert_parroquias(ARRAY['San Antonio de Maturín','San Francisco de Maturín'],'Acosta');
CALL insert_parroquias(ARRAY['Aguasay'],'Aguasay');
CALL insert_parroquias(ARRAY['Caripito'],'Bolívar');
CALL insert_parroquias(ARRAY['El Guácharo','La Guanota','Sabana de Piedra','San Agustín','Teresen','Caripe'],'Caripe');
CALL insert_parroquias(ARRAY['Areo','Capital Cedeño','San Félix de Cantalicio','Viento Fresco'],'Cedeño');
CALL insert_parroquias(ARRAY['El Tejero','Punta de Mata'],'Ezequiel Zamora');
CALL insert_parroquias(ARRAY['Chaguaramas','Las Alhuacas','Tabasca','Temblador'],'Libertador');
CALL insert_parroquias(ARRAY['Alto de los Godos','Boquerón','Las Cocuizas','La Cruz','San Simón','El Corozo','El Furrial','Jusepín','La Pica','San Vicente'],'Maturín');
CALL insert_parroquias(ARRAY['Aparicio','Aragua de Maturín','Chaguaramal','El Pinto','Guanaguana','La Toscana','Taguaya'],'Piar');
CALL insert_parroquias(ARRAY['Cachipo','Quiriquire'],'Punceres');
CALL insert_parroquias(ARRAY['Santa Bárbara','Morón'],'Santa Bárbara');
CALL insert_parroquias(ARRAY['Barrancas','Los Barrancos de Fajardo'],'Sotillo');
CALL insert_parroquias(ARRAY['Uracoa'],'Uracoa');

-- Nueva Esparta
CALL insert_municipios(ARRAY['Antolín del Campo','Arismendi','Díaz','García','Gómez','Maneiro','Marcano','Mariño','Macanao','Tubores','Villalba'],'Nueva Esparta');
CALL insert_parroquias(ARRAY['Antolín del Campo'],'Antolín del Campo');
CALL insert_parroquias(ARRAY['Arismendi'],'Arismendi');
CALL insert_parroquias(ARRAY['San Juan Bautista','Zabala'],'Díaz');
CALL insert_parroquias(ARRAY['García','Francisco Fajardo'],'García');
CALL insert_parroquias(ARRAY['Bolívar','Guevara','Matasiete','Santa Ana','Sucre'],'Gómez');
CALL insert_parroquias(ARRAY['Aguirre','Maneiro'],'Maneiro');
CALL insert_parroquias(ARRAY['Adrián','Juan Griego'],'Marcano');
CALL insert_parroquias(ARRAY['Mariño'],'Mariño');
CALL insert_parroquias(ARRAY['San Francisco de Macanao','Boca de Río'],'Macanao');
CALL insert_parroquias(ARRAY['Tubores','Los Barales'],'Tubores');
CALL insert_parroquias(ARRAY['Vicente Fuentes','Villalba'],'Villalba');

-- Portuguesa
CALL insert_municipios(ARRAY['Araure','Esteller','Guanare','Guanarito','Ospino','Páez','Sucre','Turen','Monseñor José V. de Unda','Agua Blanca','Papelón','San Genaro de Boconoíto','San Rafael de Onoto','Santa Rosalía'],'Portuguesa');
CALL insert_parroquias(ARRAY['Araure','Río Acarigua'],'Araure');
CALL insert_parroquias(ARRAY['Agua Blanca'],'Agua Blanca');
CALL insert_parroquias(ARRAY['Píritu','Uveral'],'Esteller');
CALL insert_parroquias(ARRAY['Cordova','Guanare','San José de la Montaña','San Juan de Guanaguanare','Virgen de Coromoto'],'Guanare');
CALL insert_parroquias(ARRAY['Guanarito','Trinidad de la Capilla','Divina Pastora'],'Guanarito');
CALL insert_parroquias(ARRAY['Chabasquén','Peña Blanca'],'Monseñor José V. de Unda');
CALL insert_parroquias(ARRAY['Aparición','La Estación','Ospino'],'Ospino');
CALL insert_parroquias(ARRAY['Acarigua','Payara','Pimpinela','Ramón Peraza'],'Páez');
CALL insert_parroquias(ARRAY['Caño Delgadito','Papelón'],'Papelón');
CALL insert_parroquias(ARRAY['Antolín Tovar Aquino','Boconoíto'],'San Genaro de Boconoíto');
CALL insert_parroquias(ARRAY['Santa Fé','San Rafael de Onoto','Thelmo Morles'],'San Rafael de Onoto');
CALL insert_parroquias(ARRAY['Florida','El Playón'],'Santa Rosalía');
CALL insert_parroquias(ARRAY['Biscucuy','Concepción','San Rafael de Palo Alzado.','San José de Saguaz','Uvencio Antonio Velásquez.','Villa Rosa.'],'Sucre');
CALL insert_parroquias(ARRAY['Villa Bruzual','Canelones','Santa Cruz','San Isidro Labrador la colonia'],'Turén');

-- Sucre
CALL insert_municipios(ARRAY['Andrés Eloy Blanco','Andrés Mata','Arismendi','Benítez','Bermúdez','Bolívar','Cajigal','Cruz Salmerón Acosta','Libertador','Mariño','Mejía','Montes','Ribero','Sucre','Valdez'],'Sucre');
CALL insert_parroquias(ARRAY['Mariño','Rómulo Gallegos'],'Andrés Eloy Blanco');
CALL insert_parroquias(ARRAY['San José de Areocuar','Tavera Acosta'],'Andrés Mata');
CALL insert_parroquias(ARRAY['Río Caribe','Antonio José de Sucre','El Morro de Puerto Santo','Puerto Santo','San Juan de las Galdonas'],'Arismendi');
CALL insert_parroquias(ARRAY['El Pilar','El Rincón','General Francisco Antonio Vázquez','Guaraúnos','Tunapuicito','Unión'],'Benítez');
CALL insert_parroquias(ARRAY['Santa Catalina','Santa Rosa','Santa Teresa','Bolívar','Maracapana'],'Bermúdez');
CALL insert_parroquias(ARRAY['Marigüitar'],'Bolívar');
CALL insert_parroquias(ARRAY['Libertad','El Paujil','Yaguaraparo'],'Cajigal');
CALL insert_parroquias(ARRAY['Araya','Chacopata','Manicuare'],'Cruz Salmerón Acosta');
CALL insert_parroquias(ARRAY['Tunapuy','Campo Elías'],'Libertador');
CALL insert_parroquias(ARRAY['Irapa','Campo Claro','Marabal','San Antonio de Irapa','Soro'],'Mariño');
CALL insert_parroquias(ARRAY['San Antonio del Golfo'],'Mejía');
CALL insert_parroquias(ARRAY['Cumanacoa','Arenas','Aricagua','Cocollar','San Fernando','San Lorenzo'],'Montes');
CALL insert_parroquias(ARRAY['Cariaco','Catuaro','Rendón','Santa Cruz','Santa María'],'Ribero');
CALL insert_parroquias(ARRAY['Altagracia Cumaná','Santa Inés Cumaná','Valentín Valiente Cumaná','Ayacucho Cumaná','San Juan','Raúl Leoni','Gran Mariscal'],'Sucre');
CALL insert_parroquias(ARRAY['Cristóbal Colón','Bideau','Punta de Piedras','Güiria'],'Valdez');

-- Táchira
CALL insert_municipios(ARRAY['Andrés Bello','Antonio Rómulo Acosta','Ayacucho','Bolívar','Cárdenas','Córdoba','Fernández Feo','Francisco de Miranda','García de Hevia','Guásimos','Independencia','Jáuregui','José María Vargas','Junín','Libertad','Libertador','Lobatera','Michelena','Panamericano','Pedro María Ureña','Rafael Urdaneta','Samuel Darío Maldonado','San Cristóbal','San Judas Tadeo','Seboruco','Simón Rodríguez','Táriba','Torbes','Uribante'],'Táchira');
CALL insert_parroquias(ARRAY['Cordero'],'Andrés Bello');
CALL insert_parroquias(ARRAY['Virgen del Carmen'],'Antonio Rómulo Acosta');
CALL insert_parroquias(ARRAY['Rivas Berti','San Juan de Colón','San Pedro del Río'],'Ayacucho');
CALL insert_parroquias(ARRAY['Isaías Medina Angarita','Juan Vicente Gómez','Palotal','San Antonio del Táchira'],'Bolívar');
CALL insert_parroquias(ARRAY['Amenodoro Rangel Lamús','La Florida','Táriba'],'Cárdenas');
CALL insert_parroquias(ARRAY['Santa Ana del Táchira'],'Córdoba');
CALL insert_parroquias(ARRAY['Alberto Adriani','San Rafael del Piñal','Santo Domingo'],'Fernández Feo');
CALL insert_parroquias(ARRAY['San José de Bolívar'],'Francisco de Miranda');
CALL insert_parroquias(ARRAY['Boca de Grita','José Antonio Páez','La Fría'],'García de Hevia');
CALL insert_parroquias(ARRAY['Palmira'],'Guásimos');
CALL insert_parroquias(ARRAY['Capacho Nuevo','Juan Germán Roscio','Román Cárdenas'],'Independencia');
CALL insert_parroquias(ARRAY['Emilio Constantino Guerrero','La Grita','Monseñor Miguel Antonio Salas'],'Jáuregui');
CALL insert_parroquias(ARRAY['El Cobre'],'José María Vargas');
CALL insert_parroquias(ARRAY['Bramón','La Petrólea','Quinimarí','Rubio'],'Junín');
CALL insert_parroquias(ARRAY['Capacho Viejo','Cipriano Castro','Manuel Felipe Rugeles'],'Libertad');
CALL insert_parroquias(ARRAY['Abejales','Doradas','Emeterio Ochoa','San Joaquín de Navay'],'Libertador');
CALL insert_parroquias(ARRAY['Lobatera','Constitución'],'Lobatera');
CALL insert_parroquias(ARRAY['Michelena'],'Michelena');
CALL insert_parroquias(ARRAY['San Pablo','La Palmita'],'Panamericano');
CALL insert_parroquias(ARRAY['Ureña','Nueva Arcadia'],'Pedro María Ureña');
CALL insert_parroquias(ARRAY['Delicias'],'Rafael Urdaneta');
CALL insert_parroquias(ARRAY['Boconó','Hernández','La Tendida'],'Samuel Darío Maldonado');
CALL insert_parroquias(ARRAY['Francisco Romero Lobo','La Concordia','Pedro María Morantes','San Juan Bautista','San Sebastián'],'San Cristóbal');
CALL insert_parroquias(ARRAY['San Judas Tadeo'],'San Judas Tadeo');
CALL insert_parroquias(ARRAY['Seboruco'],'Seboruco');
CALL insert_parroquias(ARRAY['San Simón'],'Simón Rodríguez');
CALL insert_parroquias(ARRAY['Eleazar López Contreras','Capital Sucre','San Pablo'],'Sucre');
CALL insert_parroquias(ARRAY['San Josecito'],'Torbes');
CALL insert_parroquias(ARRAY['Cárdenas','Juan Pablo Peñaloza','Potosí','Pregonero'],'Uribante');

-- Trujillo
CALL insert_municipios(ARRAY['Andrés Bello','Boconó','Bolívar','Candelaria','Carache','Escuque','José Felipe Márquez Cañizales','Juan Vicente Campo Elías','La Ceiba','Miranda','Monte Carmelo','Motatán','Pampán','Pampanito','Rafael Rangel','San Rafael de Carvajal','Sucre','Trujillo','Urdaneta','Valera'],'Trujillo');
CALL insert_parroquias(ARRAY['Santa Isabel','Araguaney','El Jaguito','La Esperanza'],'Andrés Bello');
CALL insert_parroquias(ARRAY['Boconó','Ayacucho','Burbusay','El Carmen','General Ribas','Guaramacal','Monseñor Jáuregui','Mosquey','Rafael Rangel','San José','San Miguel','Vega de Guaramacal'],'Boconó');
CALL insert_parroquias(ARRAY['Sabana Grande','Cheregüé','Granados'],'Bolívar');
CALL insert_parroquias(ARRAY['Chejendé','Arnoldo Gabaldón','Bolivia','Carrillo','Cegarra','Manuel Salvador Ulloa','San José'],'Candelaria');
CALL insert_parroquias(ARRAY['Carache','Cuicas','La Concepción','Panamericana','Santa Cruz'],'Carache');
CALL insert_parroquias(ARRAY['Escuque','La Unión','Sabana Libre','Santa Rita'],'Escuque');
CALL insert_parroquias(ARRAY['El Socorro','Antonio José de Sucre','Los Caprichos'],'José Felipe Márquez Cañizales');
CALL insert_parroquias(ARRAY['Campo Elías','Arnoldo Gabaldón'],'Juan Vicente Campo Elías');
CALL insert_parroquias(ARRAY['Santa Apolonia','El Progreso','La Ceiba','Tres de Febrero'],'La Ceiba');
CALL insert_parroquias(ARRAY['El Dividive','Agua Caliente','Agua Santa','El Cenizo','Valerita'],'Miranda');
CALL insert_parroquias(ARRAY['Monte Carmelo','Buena Vista','Santa María del Horcón'],'Monte Carmelo');
CALL insert_parroquias(ARRAY['Motatán','El Baño','Jalisco'],'Motatán');
CALL insert_parroquias(ARRAY['Pampán','Flor de Patria','La Paz','Santa Ana'],'Pampán');
CALL insert_parroquias(ARRAY['Pampanito','La Concepción','Pampanito II'],'Pampanito');
CALL insert_parroquias(ARRAY['Betijoque','José Gregorio Hernández','La Pueblita','Los Cedros'],'Rafael Rangel');
CALL insert_parroquias(ARRAY['Carvajal','Antonio Nicolás Briceño','Campo Alegre','José Leonardo Suárez'],'San Rafael de Carvajal');
CALL insert_parroquias(ARRAY['Sabana de Mendoza','El Paraíso','Junín','Valmore Rodríguez'],'Sucre');
CALL insert_parroquias(ARRAY['Matriz','Andrés Linares','Chiquinquirá','Cristóbal Mendoza','Cruz Carrillo','Monseñor Carrillo','Tres Esquinas'],'Trujillo');
CALL insert_parroquias(ARRAY['La Quebrada','Cabimbú','Jajó','La Mesa','Santiago','Tuñame'],'Urdaneta');
CALL insert_parroquias(ARRAY['Mercedes Díaz','Juan Ignacio Montilla','La Beatriz','La Puerta','Mendoza del Valle de Momboy','San Luis'],'Valera');

-- Yaracuy
CALL insert_municipios(ARRAY['Arístides Bastidas','Bolívar','Bruzual','Cocorote','Independencia','José Antonio Páez','La Trinidad','Manuel Monge','Nirgua','Peña','San Felipe','Sucre','Urachiche','Veroes'],'Yaracuy');
CALL insert_parroquias(ARRAY['Arístides Bastidas'],'Arístides Bastidas');
CALL insert_parroquias(ARRAY['Bolívar'],'Bolívar');
CALL insert_parroquias(ARRAY['Chivacoa','Campo Elías'],'Bruzual');
CALL insert_parroquias(ARRAY['Cocorote'],'Cocorote');
CALL insert_parroquias(ARRAY['Independencia'],'Independencia');
CALL insert_parroquias(ARRAY['José Antonio Páez'],'José Antonio Páez');
CALL insert_parroquias(ARRAY['La Trinidad'],'La Trinidad');
CALL insert_parroquias(ARRAY['Manuel Monge'],'Manuel Monge');
CALL insert_parroquias(ARRAY['Salóm','Temerla','Nirgua','Cogollos'],'Nirgua');
CALL insert_parroquias(ARRAY['San Andrés','Yaritagua'],'Peña');
CALL insert_parroquias(ARRAY['San Javier','Albarico','San Felipe'],'San Felipe');
CALL insert_parroquias(ARRAY['Sucre'],'Sucre');
CALL insert_parroquias(ARRAY['Urachiche'],'Urachiche');
CALL insert_parroquias(ARRAY['El Guayabo','Farriar'],'Veroes');

-- Zulia
CALL insert_municipios(ARRAY['Almirante Padilla','Baralt','Cabimas','Catatumbo','Colón','Francisco Javier Pulgar','Guajira','Jesús Enrique Lossada','Jesús María Semprún','La Cañada de Urdaneta','Lagunillas','Machiques de Perijá','Mara','Maracaibo','Miranda','Rosario de Perijá','San Francisco','Santa Rita','Simón Bolívar','Sucre','Valmore Rodríguez'],'Zulia');
CALL insert_parroquias(ARRAY['Isla de Toas','Monagas'],'Almirante Padilla');
CALL insert_parroquias(ARRAY['San Timoteo','General Urdaneta','Libertador','Marcelino Briceño','Pueblo Nuevo','Manuel Guanipa Matos'],'Baralt');
CALL insert_parroquias(ARRAY['Ambrosio','Arístides Calvani','Carmen Herrera','Germán Ríos Linares','Jorge Hernández','La Rosa','Punta Gorda','Rómulo Betancourt','San Benito'],'Cabimas');
CALL insert_parroquias(ARRAY['Encontrados','Udón Pérez'],'Catatumbo');
CALL insert_parroquias(ARRAY['San Carlos del Zulia','Moralito','Santa Bárbara','Santa Cruz del Zulia','Urribarrí'],'Colón');
CALL insert_parroquias(ARRAY['Simón Rodríguez','Agustín Codazzi','Carlos Quevedo','Francisco Javier Pulgar'],'Francisco Javier Pulgar');
CALL insert_parroquias(ARRAY['Sinamaica','Alta Guajira','Elías Sánchez Rubio','Guajira'],'Guajira');
CALL insert_parroquias(ARRAY['La Concepción','San José','Mariano Parra León','José Ramón Yépez'],'Jesús Enrique Lossada');
CALL insert_parroquias(ARRAY['Jesús María Semprún','Barí'],'Jesús María Semprún');
CALL insert_parroquias(ARRAY['Concepción','Andrés Bello','Chiquinquirá','El Carmelo','Potreritos'],'La Cañada de Urdaneta');
CALL insert_parroquias(ARRAY['Alonso de Ojeda','Libertad','Eleazar López Contreras','Campo Lara','Venezuela','El Danto'],'Lagunillas');
CALL insert_parroquias(ARRAY['Libertad','Bartolomé de las Casas','Río Negro','San José de Perijá'],'Machiques de Perijá');
CALL insert_parroquias(ARRAY['San Rafael','La Sierrita','Las Parcelas','Luis De Vicente','Monseñor Marcos Sergio Godoy','Ricaurte','Tamare'],'Mara');
CALL insert_parroquias(ARRAY['Antonio Borjas Romero','Bolívar','Cacique Mara','Carracciolo Parra Pérez','Cecilio Acosta','Chinquinquirá','Coquivacoa','Cristo de Aranza','Francisco Eugenio Bustamante','Idelfonzo Vásquez','Juana de Ávila','Luis Hurtado Higuera','Manuel Dagnino','Olegario Villalobos','Raúl Leoni','San Isidro','Santa Lucía','Venancio Pulgar'],'Maracaibo');
CALL insert_parroquias(ARRAY['Altagracia','Ana María Campos','Faría','San Antonio','San José'],'Miranda');
CALL insert_parroquias(ARRAY['El Rosario','Donaldo García','Sixto Zambrano'],'Rosario de Perijá');
CALL insert_parroquias(ARRAY['San Francisco','El Bajo','Domitila Flores','Francisco Ochoa','Los Cortijos','Marcial Hernández','José Domingo Rus'],'San Francisco');
CALL insert_parroquias(ARRAY['Santa Rita','El Mene','José Cenobio Urribarrí','Pedro Lucas Urribarrí'],'Santa Rita');
CALL insert_parroquias(ARRAY['Manuel Manrique','Rafael Maria Baralt','Rafael Urdaneta'],'Simón Bolívar');
CALL insert_parroquias(ARRAY['Bobures','El Batey','Gibraltar','Heras','Monseñor Arturo Álvarez','Rómulo Gallegos'],'Sucre');
CALL insert_parroquias(ARRAY['Rafael Urdaneta','La Victoria','Raúl Cuenca'],'Valmore Rodríguez');

-- Check
SELECT sub_L.nombre_luga, sub_L.tipo_luga, sup_L.nombre_luga
FROM Lugar as sup_L, Lugar as sub_L
WHERE
	sup_L.cod_luga = sub_L.fk_luga;

SELECT COUNT(*) FROM Lugar WHERE tipo_luga = 'Estado'; 
SELECT COUNT(*) FROM Lugar WHERE tipo_luga = 'Municipio'; 
SELECT COUNT(*) FROM Lugar WHERE tipo_luga = 'Parroquia'; 
