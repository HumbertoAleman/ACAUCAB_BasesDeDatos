-- Busca una parroquia cualquiera
CREATE OR REPLACE PROCEDURE get_parroquia (OUT id_parroquia INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT cod_luga into id_parroquia FROM Lugar WHERE tipo_luga = 'Parroquia' ORDER BY RANDOM() LIMIT 1;
END
$$

-- Cliente Natural
CREATE OR REPLACE PROCEDURE add_cliente_natural (rif varchar(20), fiscal text, fisica text, p_nom varchar(40), s_nom varchar(40), p_ape varchar(40), s_ape varchar(40), ci integer )
LANGUAGE plpgsql
AS $$
DECLARE
    id_clie integer;
    luga1 integer; 
    luga2 integer;
BEGIN
    CALL get_parroquia(luga1);
    CALL get_parroquia(luga2);
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, primer_nom_natu, segundo_nom_natu, primer_ape_natu, segundo_ape_natu, ci_natu)
    VALUES (rif, fiscal, fisica, luga1, luga2, 'Natural', p_nom, s_nom, p_ape, s_ape, ci)
    RETURNING rif_clie INTO id_clie;

    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
    VALUES ('admin', p_nom ||' '|| p_ape, 200, id_clie);
END
$$

-- Cliente Jurídico
CREATE OR REPLACE PROCEDURE add_cliente_juridico (rif varchar(20), fiscal text, fisica text, razon varchar(40), denom varchar(40), capital numeric(8, 2), pag text)
LANGUAGE plpgsql
AS $$
DECLARE
    id_clie integer;
    luga1 integer; 
    luga2 integer;
BEGIN
    CALL get_parroquia(luga1);
    CALL get_parroquia(luga2);
    INSERT INTO Cliente (rif_clie, direccion_fiscal_clie, direccion_fisica_clie, fk_luga_1, fk_luga_2, tipo_clie, razon_social_juri, denom_comercial_juri, capital_juri, pag_web_juri)
    VALUES (rif, fiscal, fisica, luga1, luga2, 'Juridico', razon, denom, capital, pag)
    RETURNING rif_clie INTO id_clie;

    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_clie)
    VALUES ('admin', razon , 201, id_clie);
END
$$

-- Agregados Clientes Naturales
CALL add_cliente_natural('J402357691', '22 Briar Crest Way', '823 Fair Oaks Parkway', 'Cam', 'Aharon', 'Biddlestone', 'Ellings', 50828613);
CALL add_cliente_natural('J314865203', '26961 Prairieview Lane', '82 Arrowood Crossing', 'Christiano', 'Janenna', 'Galego', 'Carayol', 73611427);
CALL add_cliente_natural('J487265390', '9 Raven Avenue', '686 Bobwhite Point', 'Nancey', 'Rosabel', 'Hurt', 'Southerill', 97572920);
CALL add_cliente_natural('J325410879', '7569 Prairie Rose Point', '4784 Mandrake Circle', 'Brandon', 'Margareta', 'Girk', 'Latliff', 57086318);
CALL add_cliente_natural('J419872635', '66 Lotheville Avenue', '5776 Birchwood Plaza', 'Pollyanna', 'Rowena', 'Shawyers', 'Osment', 48709114);
CALL add_cliente_natural('J392645108', '337 Dakota Road', '85836 Johnson Alley', 'Ashlee', 'Alidia', 'Androli', 'Da Costa', 74670125);
CALL add_cliente_natural('J450328179', '64 Mayfield Trail', '71 Havey Trail', 'Dalila', 'Engracia', 'Vaissiere', 'Cudd', 33678051);
CALL add_cliente_natural('J312478569', '26489 Lunder Center', '85655 Harbort Junction', 'Charissa', 'Nick', 'Sowman', 'Ransfield', 8410079);
CALL add_cliente_natural('J431209786', '0 Maple Point', '0608 Oneill Park', 'Cherie', 'Abey', 'Vlach', 'Korpolak', 12775958);
CALL add_cliente_natural('J324589106', '62 Schlimgen Junction', '0 Moland Hill', 'Ted', 'Axel', 'Brocklesby', 'Aggas', 6184964);
CALL add_cliente_natural('J467381205', '16 Pearson Hill', '66755 Hoepker Terrace', 'Rupert', 'Pegeen', 'McSharry', 'Rodder', 2326653);
CALL add_cliente_natural('J405716892', '43369 Northridge Court', '8314 Lakeland Pass', 'Hanna', 'Fin', 'Blaxton', 'Pele', 2603386);
CALL add_cliente_natural('J318472569', '36696 Aberg Trail', '6 Calypso Circle', 'Kalie', 'Broderic', 'Gloyens', 'Delacour', 67259492);
CALL add_cliente_natural('J429105738', '0271 Granby Road', '539 Colorado Avenue', 'Raven', 'Jaimie', 'Pettigree', 'Venning', 26022647);
CALL add_cliente_natural('J375486219', '6114 Laurel Terrace', '2979 Coleman Way', 'Lynett', 'Marsh', 'Bednall', 'Govan', 72583336);
CALL add_cliente_natural('J480327561', '15 Clove Alley', '0264 Cardinal Point', 'Aarika', 'Matias', 'Cubbit', 'Rivard', 19835736);
CALL add_cliente_natural('J329175086', '369 Rowland Crossing', '6825 Duke Point', 'Leontine', 'Meridith', 'Poag', 'Nelius', 29679721);
CALL add_cliente_natural('J412638075', '4695 Eagle Crest Street', '4 Northfield Hill', 'Tedra', 'Ben', 'MacMillan', 'Pavyer', 91952089);
CALL add_cliente_natural('J354708962', '16930 Pearson Parkway', '76613 Merry Parkway', 'Cecelia', 'Theobald', 'Clemoes', 'Chasle', 4507000);
CALL add_cliente_natural('J498261375', '016 Debs Alley', '17767 Pearson Court', 'Roderic', 'Geri', 'Veal', 'Bradfield', 15685628);