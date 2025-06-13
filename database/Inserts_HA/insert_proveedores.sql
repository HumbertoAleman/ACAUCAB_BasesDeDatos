CREATE OR REPLACE PROCEDURE add_miembro (rif text, razon_social text, denom_comercial text, direccion_fiscal text, pag_web text, luga_1 integer, luga_2 integer)
LANGUAGE plpgsql
AS $$
DECLARE
    x varchar(20);
BEGIN
    INSERT INTO Miembro (rif_miem, razon_social_miem, denom_comercial_miem, direccion_fiscal_miem, pag_web_miem, fk_luga_1, fk_luga_2)
        VALUES (rif, razon_social, denom_comercial, direccion_fiscal, pag_web, luga_1, luga_2)
    RETURNING
        rif_miem INTO x;
    INSERT INTO Usuario (contra_usua, username_usua, fk_rol, fk_miem)
        VALUES ('admin', razon_social, 100, x);
END;
$$;

--AGREGAR FUNCIÓN QUE GENERE UN REGISTRO DE UN TELÉFONO AL INSERTAR UN NUEVO REGISTRO EN LA TABLA

-- Generated Using https://www.coderstool.com/sql-test-data-generator
CREATE OR REPLACE PROCEDURE add_miembro_random (rif text, razon_social text, denom_comercial text, direccion_fiscal text, pag_web text)
LANGUAGE plpgsql
AS $$
DECLARE
    x varchar(20);
    luga_1 integer;
    luga_2 integer;
BEGIN
    -- Get Parroquia Random Lugar 1
    SELECT
        cod_luga INTO luga_1
    FROM
        Lugar
    WHERE
        tipo_luga = 'Parroquia'
    ORDER BY
        RANDOM()
    LIMIT 1;
    SELECT
        cod_luga INTO luga_2
    FROM
        Lugar
    WHERE
        tipo_luga = 'Parroquia'
    ORDER BY
        RANDOM()
    LIMIT 1;
    CALL add_miembro (rif, razon_social, denom_comercial, direccion_fiscal, pag_web, luga_1, luga_2);
END;
$$;

DELETE FROM Usuario
WHERE fk_rol = 100;

DELETE FROM Rol
WHERE nombre_rol = 'Miembro';

DELETE FROM Miembro;

INSERT INTO Rol
    VALUES (100, 'Miembro', 'Proveedor de cerveza, les compramos');

CALL add_miembro ('J000413126', 'Compañía Anónima Cervecería Polar', 'Polar', 'Avenida José Antonio Páez, Edificio Polar, El Paraíso, Caracas, Venezuela', 'https://empresaspolar.com', 468, 468);

CALL add_miembro_random ('J482367195', 'Blacks International ', 'Interior Mutual S.A', '6287 Holmcroft, Simi Valley, Rhode Island, 54650', 'https://crowd.nationwide/ver.php');
CALL add_miembro_random ('J314982657', 'Gulf Corp', 'Stewart ', '8208 Melland Avenue, Fort Worth, Indiana, 05019', 'https://www.innocent.com/vienna.html');
CALL add_miembro_random ('J471086329', 'Closes International Company', 'Invest Stores Corp', '2639 Mill, Richmond County, New York, 45183', 'http://simpson.com/positive');
CALL add_miembro_random ('J329475018', 'Recording Corporation', 'Transferred ', '2612 Maynestone Road, Leominster, Louisiana, 82578', 'https://bargain.com/involve.php');
CALL add_miembro_random ('J405318762', 'Animation Stores SIA', 'Liver B.V', '1885 Sherbrooke Street, Spokane, Ohio, 23210', 'https://www.despite.com/japanese.aspx');
CALL add_miembro_random ('J387521094', 'Brooks ', 'Largely Holdings Company', '9875 Light Circle, Brighton, Montana, 87266', 'https://www.historical.com/mumbai.aspx');
CALL add_miembro_random ('J412693075', 'Professional Company', 'Equilibrium International SIA', '7220 Tedder, Miramar, Indiana, 73039', 'https://xerox.com/portuguese.aspx#genuine');
CALL add_miembro_random ('J324860917', 'Clear Energy Corporation', 'Sara LLC', '6027 Radclyffe Circle, Kenosha, Iowa, 91275', 'https://lexington.com/peter.php#ones');
CALL add_miembro_random ('J479652130', 'Commander Industries A.G', 'Shaft Stores Corporation', '0635 Pelham Circle, Henderson, Delaware, 25851', 'https://www.employees.com/angry.php');
CALL add_miembro_random ('J358172469', 'Pete Mutual GmbH', 'Pearl International Corporation', '3457 Cardus Avenue, Sacramento, Nebraska, 54606', 'https://www.money.com/antonio');
CALL add_miembro_random ('J490327516', 'Tail Stores SIA', 'International Software Inc', '6904 Talkin Circle, Overland Park, Alaska, 44352', 'http://www.occupational.com/vernon');
CALL add_miembro_random ('J312489075', 'Agreements SIA', 'Repository Holdings ', '9571 Caldecott, Detroit, Kansas, 48806', 'http://nebraska.com/responded.aspx');
CALL add_miembro_random ('J437051298', 'Fog Industries GmbH', 'Designing Mutual S.A', '9500 Coke, Pittsburgh, Tennessee, 46878', 'https://globe.com/atlanta.aspx');
CALL add_miembro_random ('J329748105', 'Sold Industries S.A', 'Associates Industries ', '3553 Stonepail Road, Tempe, Alabama, 53812', 'https://automobile.com/circus.html');
CALL add_miembro_random ('J468230975', 'Itunes International ', 'Earlier LLC', '5637 Beech Street, Newburgh, Georgia, 52735', 'http://www.isolation.manchester.museum/revelation');
CALL add_miembro_random ('J402871639', 'Syndication Mutual S.A', 'Solar Holdings Corp', '0717 Wincombe Avenue, Ogden, Nebraska, 31435', 'https://www.myrtle.freebox-os.com/suspect.php');
CALL add_miembro_random ('J310975842', 'Gpl Stores LLC', 'Caution Holdings GmbH', '1009 Thirlwater Road, Anaheim, Rhode Island, 34589', 'https://instant.com/currencies.aspx');
CALL add_miembro_random ('J438201756', 'Kernel Energy ', 'Peru B.V', '5593 Hollinhurst Lane, Tulsa, Rhode Island, 72951', 'http://conducting.com/mess.php');
CALL add_miembro_random ('J325497068', 'Upc Industries SIA', 'Ending International S.A', '9767 Raydon Avenue, Provo, Florida, 56944', 'https://www.navigator.bømlo.no/lucy');
CALL add_miembro_random ('J471039258', 'Coordinate Industries Company', 'Emotions International ', '9059 Reddisher Circle, Grand Prairie, Maine, 73188', 'http://condos.com/rock.aspx');

SELECT
    *
FROM
    Usuario
WHERE
    fk_rol = 100;
