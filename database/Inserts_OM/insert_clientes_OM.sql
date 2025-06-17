-- Busca una parroquia cualquiera
CREATE OR REPLACE FUNCTION get_parroquia_random ()
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
        tipo_luga = 'Parroquia'
    ORDER BY
        RANDOM()
    LIMIT 1 INTO id_parroquia;
    RETURN id_parroquia;
END
$$
LANGUAGE plpgsql;

-- Agregar Telefono
CREATE OR REPLACE PROCEDURE add_tlf (cod_area integer, numero integer, cliente varchar(20), contacto integer, miembro varchar(20))
    AS $$
BEGIN
    INSERT INTO Telefono (cod_area_tele, num_tele, fk_clie, fk_pers, fk_miem)
        VALUES (cod_area, numero, cliente, contacto, miembro);
END
$$
LANGUAGE plpgsql;

-- Agregar Correo
CREATE OR REPLACE PROCEDURE add_correo (prefijo varchar(40), dominio varchar(40), cliente varchar(20), contacto integer, miembro varchar(20), empleado integer)
    AS $$
BEGIN
    INSERT INTO Correo (prefijo_corr, dominio_corr, fk_clie, fk_empl, fk_pers, fk_miem)
        VALUES (prefijo, dominio, cliente, empleado, contacto, miembro);
END
$$
LANGUAGE plpgsql;

-- Obtener una parroquia
CREATE OR REPLACE FUNCTION get_parroquia (nom_parroquia varchar(40), nom_estado varchar(40))
    RETURNS integer
    AS $$
DECLARE
    id_parroquia integer;
BEGIN
    SELECT
        l1.cod_luga
    FROM
        Lugar l1,
        Lugar l2,
        Lugar l3
    WHERE
        l1.fk_luga = l2.cod_luga
        AND l2.fk_luga = l3.cod_luga
        AND l3.nombre_luga = nom_estado
        AND l1.tipo_luga = 'Parroquia'
        AND l1.nombre_luga = nom_parroquia
    LIMIT 1 INTO id_parroquia;
    RETURN id_parroquia;
END
$$
LANGUAGE plpgsql;

-- --------------------------------------------------------------------------
-- Cliente Natural
-- Normal
CREATE OR REPLACE PROCEDURE add_cliente_natural (rif varchar(20), fiscal text, fisica text, parroquia_fiscal varchar(40), estado_fiscal varchar(40), parroquia_fisica varchar(40), estado_fisica varchar(40), p_nom varchar(40), s_nom varchar(40), p_ape varchar(40), s_ape varchar(40), ci integer, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, primer_nom_natu, segundo_nom_natu, primer_ape_natu, segundo_ape_natu, ci_natu)
        VALUES (rif, fiscal, fisica, get_parroquia (parroquia_fiscal, estado_fiscal), get_parroquia (parroquia_fisica, estado_fisica), 'Natural', p_nom, s_nom, p_ape, s_ape, ci)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', p_nom || ' ' || p_ape, 200, id_clie);
END
$$
LANGUAGE plpgsql;

-- Random
CREATE OR REPLACE PROCEDURE add_cliente_natural_random (rif varchar(20), fiscal text, fisica text, p_nom varchar(40), s_nom varchar(40), p_ape varchar(40), s_ape varchar(40), ci integer, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, primer_nom_natu, segundo_nom_natu, primer_ape_natu, segundo_ape_natu, ci_natu)
        VALUES (rif, fiscal, fisica, get_parroquia_random (), get_parroquia_random (), 'Natural', p_nom, s_nom, p_ape, s_ape, ci)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', p_nom || ' ' || p_ape, 200, id_clie);
END
$$
LANGUAGE plpgsql;

-- Cliente Jurídico
-- Normal
CREATE OR REPLACE PROCEDURE add_cliente_juridico (rif varchar(20), fiscal text, fisica text, parroquia_fiscal varchar(40), estado_fiscal varchar(40), parroquia_fisica varchar(40), estado_fisica varchar(40), razon varchar(40), denom varchar(40), capital numeric(8, 2), pag text, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, razon_social_juri, denom_comercial_juri, capital_juri, pag_web_juri)
        VALUES (rif, fiscal, fisica, get_parroquia (parroquia_fiscal, estado_fiscal), get_parroquia (parroquia_fisica, estado_fisica), 'Juridico', razon, denom, capital, pag)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', razon, 201, id_clie);
END
$$
LANGUAGE plpgsql;

-- Random
CREATE OR REPLACE PROCEDURE add_cliente_juridico_random (rif varchar(20), fiscal text, fisica text, razon varchar(40), denom varchar(40), capital numeric(8, 2), pag text, cod_area integer, numero integer, prefijo varchar(40), dominio varchar(40))
    AS $$
DECLARE
    id_clie varchar(20);
BEGIN
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, razon_social_juri, denom_comercial_juri, capital_juri, pag_web_juri)
        VALUES (rif, fiscal, fisica, get_parroquia_random (), get_parroquia_random (), 'Juridico', razon, denom, capital, pag)
    RETURNING
        rif_clie INTO id_clie;
    CALL add_tlf (cod_area, numero, id_clie, NULL, NULL);
    CALL add_correo (prefijo, dominio, id_clie, NULL, NULL, NULL);
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
        VALUES ('admin', razon, 201, id_clie);
END
$$
LANGUAGE plpgsql;

-- Agregar Clientes Naturales
CALL add_cliente_natural_random ('J402357691', '22 Briar Crest Way', '823 Fair Oaks Parkway', 'Cam', 'Aharon', 'Biddlestone', 'Ellings', 50828613, 0412, 1234567, 'cam.aharone@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J314865203', '26961 Prairieview Lane', '82 Arrowood Crossing', 'Christiano', 'Janenna', 'Galego', 'Carayol', 73611427, 0414, 2345678, 'christiano.janenna@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J487265390', '9 Raven Avenue', '686 Bobwhite Point', 'Nancey', 'Rosabel', 'Hurt', 'Southerill', 97572920, 0416, 3456789, 'nancey.rosabel@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J325410879', '7569 Prairie Rose Point', '4784 Mandrake Circle', 'Brandon', 'Margareta', 'Girk', 'Latliff', 57086318, 0424, 4567890, 'brandon.margareta@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J419872635', '66 Lotheville Avenue', '5776 Birchwood Plaza', 'Pollyanna', 'Rowena', 'Shawyers', 'Osment', 48709114, 0426, 5678901, 'pollyanna.rowena@ejemplo.com', 'yahoo.com');

CALL add_cliente_natural_random ('J392645108', '337 Dakota Road', '85836 Johnson Alley', 'Ashlee', 'Alidia', 'Androli', 'Da Costa', 74670125, 0412, 6789012, 'ashlee.alidia@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J450328179', '64 Mayfield Trail', '71 Havey Trail', 'Dalila', 'Engracia', 'Vaissiere', 'Cudd', 33678051, 0414, 7890123, 'dalila.engracia@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J312478569', '26489 Lunder Center', '85655 Harbort Junction', 'Charissa', 'Nick', 'Sowman', 'Ransfield', 8410079, 0416, 8901234, 'charissa.nick@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J431209786', '0 Maple Point', '0608 Oneill Park', 'Cherie', 'Abey', 'Vlach', 'Korpolak', 12775958, 0424, 9012345, 'cherie.abey@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J324589106', '62 Schlimgen Junction', '0 Moland Hill', 'Ted', 'Axel', 'Brocklesby', 'Aggas', 6184964, 0426, 1122334, 'ted.axel@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J467381205', '16 Pearson Hill', '66755 Hoepker Terrace', 'Rupert', 'Pegeen', 'McSharry', 'Rodder', 2326653, 0412, 2233445, 'rupert.pegeen@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J405716892', '43369 Northridge Court', '8314 Lakeland Pass', 'Hanna', 'Fin', 'Blaxton', 'Pele', 2603386, 0414, 3344556, 'hanna.fin@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J318472569', '36696 Aberg Trail', '6 Calypso Circle', 'Kalie', 'Broderic', 'Gloyens', 'Delacour', 67259492, 0416, 4455667, 'kalie.broderic@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J429105738', '0271 Granby Road', '539 Colorado Avenue', 'Raven', 'Jaimie', 'Pettigree', 'Venning', 26022647, 0424, 5566778, 'raven.jaimie@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J375486219', '6114 Laurel Terrace', '2979 Coleman Way', 'Lynett', 'Marsh', 'Bednall', 'Govan', 72583336, 0426, 6677889, 'lynett.marsh@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J480327561', '15 Clove Alley', '0264 Cardinal Point', 'Aarika', 'Matias', 'Cubbit', 'Rivard', 19835736, 0412, 7788990, 'aarika.matias@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J329175086', '369 Rowland Crossing', '6825 Duke Point', 'Leontine', 'Meridith', 'Poag', 'Nelius', 29679721, 0414, 8899001, 'leontine.meridith@ejemplo.com', 'outlook.com');

CALL add_cliente_natural_random ('J412638075', '4695 Eagle Crest Street', '4 Northfield Hill', 'Tedra', 'Ben', 'MacMillan', 'Pavyer', 91952089, 0416, 9900112, 'tedra.ben@ejemplo.com', 'gmail.com');

CALL add_cliente_natural_random ('J354708962', '16930 Pearson Parkway', '76613 Merry Parkway', 'Cecelia', 'Theobald', 'Clemoes', 'Chasle', 4507000, 0424, 1011123, 'cecelia.theobald@ejemplo.com', 'hotmail.com');

CALL add_cliente_natural_random ('J498261375', '016 Debs Alley', '17767 Pearson Court', 'Roderic', 'Geri', 'Veal', 'Bradfield', 15685628, 0426, 1213141, 'roderic.geri@ejemplo.com', 'gmail.com');

-- Agregar Clientes Jurídicos
CALL add_cliente_juridico_random ('J402571893', '70 Oriole Point', '3 Bashford Drive', 'West, Hodkiewicz and Cronin', 'Hudson Inc', 40888.36, 'https://hudsoninc.com', 0412, 2345678, 'contacto@hudsoninc.com', 'hudsoninc.com');

CALL add_cliente_juridico_random ('J310958472', '8 Jenifer Point', '17642 Clove Pass', 'Emmerich-Botsford', 'Fritsch-Morissette', 22701.15, 'https://fritsch-morissette.com', 0414, 3456789, 'info@fritsch-morissette.com', 'fritsch-morissette.com');

CALL add_cliente_juridico_random ('J437025819', '5075 Spaight Point', '12 Glendale Court', 'Lind, Bashirian and Ratke', 'Reinger and Sons', 49454.82, 'https://reingerandsons.com', 0416, 4567890, 'contacto@reingerandsons.com', 'reingerandsons.com');

CALL add_cliente_juridico_random ('J324510987', '9 Bellgrove Drive', '4 Fieldstone Trail', 'Baumbach, Hackett and Murray', 'Heidenreich Group', 34814.19, 'https://heidenreichgroup.com', 0424, 5678901, 'info@heidenreichgroup.com', 'heidenreichgroup.com');

CALL add_cliente_juridico_random ('J479368251', '55968 Sloan Pass', '9724 Hovde Avenue', 'Wilkinson-Lang', 'Herzog-Schuppe', 10656.13, 'https://herzog-schuppe.com', 0426, 6789012, 'contacto@herzog-schuppe.com', 'herzog-schuppe.com');

CALL add_cliente_juridico_random ('J395720618', '823 Buhler Street', '579 Hollow Ridge Hill', 'Koepp and Sons', 'Reilly, Koss and Rogahn', 22512.14, 'https://reillykossandrogahn.com', 0412, 7890123, 'info@reillykossandrogahn.com', 'reillykossandrogahn.com');

CALL add_cliente_juridico_random ('J480216739', '0453 Bobwhite Plaza', '156 Surrey Terrace', 'Conroy-McLaughlin', 'Toy and Sons', 14469.88, 'https://toyandsons.com', 0414, 8901234, 'contacto@toyandsons.com', 'toyandsons.com');

CALL add_cliente_juridico_random ('J321759048', '257 Doe Crossing Park', '9 Arapahoe Hill', 'Anderson Group', 'Franecki, Kuhlman and Orn', 15964.06, 'https://franeckikuhlmanandorn.com', 0416, 9012345, 'info@franeckikuhlmanandorn.com', 'franeckikuhlmanandorn.com');

CALL add_cliente_juridico_random ('J412695038', '46 John Wall Drive', '9061 Longview Plaza', 'Braun-Koepp', 'Turcotte Group', 47698.22, 'https://turcottegroup.com', 0424, 1122334, 'contacto@turcottegroup.com', 'turcottegroup.com');

CALL add_cliente_juridico_random ('J375284609', '3429 Veith Crossing', '83704 La Follette Road', 'O''Hara LLC', 'Davis-Bogisich', 50133.53, 'https://davis-bogisich.com', 0426, 2233445, 'info@davis-bogisich.com', 'davis-bogisich.com');

CALL add_cliente_juridico_random ('J495083217', '44 Veith Street', '68419 Maywood Drive', 'Boehm, Jacobs and Wintheiser', 'Spinka, Cartwright and White', 31396.24, 'https://spinkacartwrightandwhite.com', 0412, 3344556, 'contacto@spinkacartwrightandwhite.com', 'spinkacartwrightandwhite.com');

CALL add_cliente_juridico_random ('J402867531', '8987 Gale Road', '0 Scofield Park', 'Goldner-Harvey', 'Aufderhar-Hahn', 53157.93, 'https://aufderhar-hahn.com', 0414, 4455667, 'info@aufderhar-hahn.com', 'aufderhar-hahn.com');

CALL add_cliente_juridico_random ('J319247685', '4695 Eastlawn Hill', '181 High Crossing Circle', 'Schiller Group', 'Grant, Hermann and Bergstrom', 15622.08, 'https://granthermannandbergstrom.com', 0416, 5566778, 'contacto@granthermannandbergstrom.com', 'granthermannandbergstrom.com');

CALL add_cliente_juridico_random ('J438501296', '134 Arizona Terrace', '5 Waubesa Point', 'Armstrong, Johnson and Aufderhar', 'Schumm, Kemmer and Boehm', 43092.48, 'https://schummkemmerandboehm.com', 0424, 6677889, 'info@schummkemmerandboehm.com', 'schummkemmerandboehm.com');

CALL add_cliente_juridico_random ('J325861074', '121 Pennsylvania Way', '03002 High Crossing Circle', 'Dickinson, Harvey and Reynolds', 'Casper-Reichert', 56565.97, 'https://casper-reichert.com', 0426, 7788990, 'contacto@casper-reichert.com', 'casper-reichert.com');

CALL add_cliente_juridico_random ('J479302518', '9 Mccormick Plaza', '058 Carey Pass', 'Wolff, Bailey and Hermann', 'Balistreri Group', 36211.36, 'https://balistrerigroup.com', 0412, 8899001, 'info@balistrerigroup.com', 'balistrerigroup.com');

CALL add_cliente_juridico_random ('J398571462', '1118 Butterfield Drive', '3106 Fisk Crossing', 'O''Reilly-Hartmann', 'Lynch Inc', 20195.17, 'https://lynchinc.com', 0414, 9900112, 'contacto@lynchinc.com', 'lynchinc.com');

CALL add_cliente_juridico_random ('J412786053', '777 Sloan Street', '911 Briar Crest Parkway', 'Doyle Group', 'Shanahan, Stanton and Lemke', 55376.91, 'https://shanahanstantonandlemke.com', 0416, 1011123, 'info@shanahanstantonandlemke.com', 'shanahanstantonandlemke.com');

CALL add_cliente_juridico_random ('J350917246', '352 Pierstorff Alley', '6 Kinsman Terrace', 'Schmidt Inc', 'Wunsch LLC', 23240.90, 'https://wunschllc.com', 0424, 1213141, 'contacto@wunschllc.com', 'wunschllc.com');

CALL add_cliente_juridico_random ('J487520139', '95 Mccormick Junction', '599 Welch Park', 'Stanton Group', 'Graham, Corkery and Greenfelder', 58473.49, 'https://grahamcorkeryandgreenfelder.com', 0426, 1314151, 'info@grahamcorkeryandgreenfelder.com', 'grahamcorkeryandgreenfelder.com');
