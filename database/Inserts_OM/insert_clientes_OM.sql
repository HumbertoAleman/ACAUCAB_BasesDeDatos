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

