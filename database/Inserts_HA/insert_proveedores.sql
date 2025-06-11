-- Generated Using https://www.coderstool.com/sql-test-data-generator
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

DELETE FROM Usuario
WHERE fk_rol = 100;

DELETE FROM Rol
WHERE nombre_rol = 'Miembro';

DELETE FROM Miembro;

INSERT INTO Rol
    VALUES (100, 'Miembro', 'Proveedor de cerveza, les compramos');

CALL add_miembro ('J-66346', 'Blacks International ', 'Interior Mutual S.A', '6287 Holmcroft, Simi Valley, Rhode Island, 54650', 'https://crowd.nationwide/ver.php', 1, 1);

CALL add_miembro ('J-69163', 'Gulf Corp', 'Stewart ', '8208 Melland Avenue, Fort Worth, Indiana, 05019', 'https://www.innocent.com/vienna.html', 1, 1);

CALL add_miembro ('J-08316', 'Closes International Company', 'Invest Stores Corp', '2639 Mill, Richmond County, New York, 45183', 'http://simpson.com/positive', 1, 1);

CALL add_miembro ('J-39048', 'Recording Corporation', 'Transferred ', '2612 Maynestone Road, Leominster, Louisiana, 82578', 'https://bargain.com/involve.php', 1, 1);

CALL add_miembro ('J-37802', 'Animation Stores SIA', 'Liver B.V', '1885 Sherbrooke Street, Spokane, Ohio, 23210', 'https://www.despite.com/japanese.aspx', 1, 1);

CALL add_miembro ('J-59401', 'Brooks ', 'Largely Holdings Company', '9875 Light Circle, Brighton, Montana, 87266', 'https://www.historical.com/mumbai.aspx', 1, 1);

CALL add_miembro ('J-64201', 'Professional Company', 'Equilibrium International SIA', '7220 Tedder, Miramar, Indiana, 73039', 'https://xerox.com/portuguese.aspx#genuine', 1, 1);

CALL add_miembro ('J-27169', 'Clear Energy Corporation', 'Sara LLC', '6027 Radclyffe Circle, Kenosha, Iowa, 91275', 'https://lexington.com/peter.php#ones', 1, 1);

CALL add_miembro ('J-62556', 'Commander Industries A.G', 'Shaft Stores Corporation', '0635 Pelham Circle, Henderson, Delaware, 25851', 'https://www.employees.com/angry.php', 1, 1);

CALL add_miembro ('J-65703', 'Pete Mutual GmbH', 'Pearl International Corporation', '3457 Cardus Avenue, Sacramento, Nebraska, 54606', 'https://www.money.com/antonio', 1, 1);

CALL add_miembro ('J-64464', 'Tail Stores SIA', 'International Software Inc', '6904 Talkin Circle, Overland Park, Alaska, 44352', 'http://www.occupational.com/vernon', 1, 1);

CALL add_miembro ('J-08283', 'Agreements SIA', 'Repository Holdings ', '9571 Caldecott, Detroit, Kansas, 48806', 'http://nebraska.com/responded.aspx', 1, 1);

CALL add_miembro ('J-38915', 'Fog Industries GmbH', 'Designing Mutual S.A', '9500 Coke, Pittsburgh, Tennessee, 46878', 'https://globe.com/atlanta.aspx', 1, 1);

CALL add_miembro ('J-57872', 'Sold Industries S.A', 'Associates Industries ', '3553 Stonepail Road, Tempe, Alabama, 53812', 'https://automobile.com/circus.html', 1, 1);

CALL add_miembro ('J-09215', 'Itunes International ', 'Earlier LLC', '5637 Beech Street, Newburgh, Georgia, 52735', 'http://www.isolation.manchester.museum/revelation', 1, 1);

CALL add_miembro ('J-50018', 'Syndication Mutual S.A', 'Solar Holdings Corp', '0717 Wincombe Avenue, Ogden, Nebraska, 31435', 'https://www.myrtle.freebox-os.com/suspect.php', 1, 1);

CALL add_miembro ('J-57937', 'Gpl Stores LLC', 'Caution Holdings GmbH', '1009 Thirlwater Road, Anaheim, Rhode Island, 34589', 'https://instant.com/currencies.aspx', 1, 1);

CALL add_miembro ('J-60693', 'Kernel Energy ', 'Peru B.V', '5593 Hollinhurst Lane, Tulsa, Rhode Island, 72951', 'http://conducting.com/mess.php', 1, 1);

CALL add_miembro ('J-26976', 'Upc Industries SIA', 'Ending International S.A', '9767 Raydon Avenue, Provo, Florida, 56944', 'https://www.navigator.bømlo.no/lucy', 1, 1);

CALL add_miembro ('J-08025', 'Coordinate Industries Company', 'Emotions International ', '9059 Reddisher Circle, Grand Prairie, Maine, 73188', 'http://condos.com/rock.aspx', 1, 1);

SELECT
    *
FROM
    Usuario
WHERE
	fk_rol = 100;

