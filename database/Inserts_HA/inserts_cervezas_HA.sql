CREATE OR REPLACE PROCEDURE insert_tipo_cerveza (text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO Receta (nombre_rece)
        VALUES ('Receta para cervezas de tipo ' || $1)
    RETURNING
        cod_rece INTO x;
    INSERT INTO Tipo_Cerveza (nombre_tipo_cerv, fk_receta, fk_tipo_cerv)
        VALUES ($1, x, (
                SELECT
                    cod_tipo_cerv
                FROM
                    Tipo_Cerveza
                WHERE
                    nombre_tipo_cerv = $2));
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relate_caracteristica (text, text, text)
    RETURNS void
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO TIPO_CARA (fk_tipo_cerv, fk_cara, valor_cara)
END;
$$
LANGUAGE plpgsql;

DELETE FROM Tipo_Cerveza;

DELETE FROM Receta;

DELETE FROM Ingrediente;

DELETE FROM Caracteristica;

CALL insert_tipo_cerveza ('Lager', NULL);

CALL insert_tipo_cerveza ('Ale', NULL);

CALL insert_tipo_cerveza ('De Trigo', 'Ale');

CALL insert_tipo_cerveza ('Bock', 'Lager');

CALL insert_tipo_cerveza ('Eisbock', 'Bock');

CALL insert_tipo_cerveza ('Pale Ale', 'Ale');

CALL insert_tipo_cerveza ('Indian Pale Ale', 'Pale Ale');

CALL insert_tipo_cerveza ('English Bitter', 'Pale Ale');

CALL insert_tipo_cerveza ('Dark Ale', 'Ale');

CALL insert_tipo_cerveza ('Stout', 'Dark Ale');

CALL insert_tipo_cerveza ('Porter', 'Dark Ale');

CALL insert_tipo_cerveza ('Belga', 'Ale');

CALL insert_tipo_cerveza ('Abadia', 'Belga');

CALL insert_tipo_cerveza ('Trapense', 'Belga');

CALL insert_tipo_cerveza ('Ambar', 'Belga');

CALL insert_tipo_cerveza ('Flamenca', 'Belga');

CALL insert_tipo_cerveza ('Pilsener', 'Ale');

CALL insert_tipo_cerveza ('American Amber Ale', 'Ale');

CALL insert_tipo_cerveza ('American IPA', 'Indian Pale Ale');

CALL insert_tipo_cerveza ('Belgian Dubbel', 'Belga');

CALL insert_tipo_cerveza ('Belgian Golden Strong Ale', 'Belga');

CALL insert_tipo_cerveza ('Belgian Specialty Ale', 'Belga');

CALL insert_tipo_cerveza ('Orval', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Chouffe', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Blond Trappist', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Table Beer', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Artisanal Blond', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Artisanal Amber', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Artisanal Brown', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Belgian Barleywine', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Trappist Quadrupel', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Belgian Spiced Christmass Beer', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Belgian IPA', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Strong Dark Saison', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Flanders Red', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Flanders Brown', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Blonde Ale', 'Ale');

CALL insert_tipo_cerveza ('Bohemian Pilsener', 'Pilsener');

CALL insert_tipo_cerveza ('Dry Stout', 'Stout');

CALL insert_tipo_cerveza ('Düsseldorf Altbier', 'Stout');

CALL insert_tipo_cerveza ('English Pale Ale', 'Pale Ale');

CALL insert_tipo_cerveza ('Extra-Strong Bitter', 'Pale Ale');

CALL insert_tipo_cerveza ('Fruit Lambic', 'Ale');

CALL insert_tipo_cerveza ('Imperial IPA', 'Indian Pale Ale');

CALL insert_tipo_cerveza ('Imperial Stout', 'Stout');

CALL insert_tipo_cerveza ('Munich Helles', 'Lager');

CALL insert_tipo_cerveza ('Oktoberfest-Marzen', 'Lager');

CALL insert_tipo_cerveza ('Red Ale', 'Ale');

CALL insert_tipo_cerveza ('Irish Red Ale', 'Red Ale');

CALL insert_tipo_cerveza ('Schwarzbier', 'Lager');

CALL insert_tipo_cerveza ('Sweet Stout', 'Stout');

CALL insert_tipo_cerveza ('Weizen-Weissbier', 'De Trigo');

CALL insert_tipo_cerveza ('Witbier', 'De Trigo');

CALL insert_tipo_cerveza ('Milk Stout', 'Stout');

CALL insert_tipo_cerveza ('Coffee Stout', 'Stout');

CALL insert_tipo_cerveza ('Chocolate Stout', 'Stout');

CALL insert_tipo_cerveza ('Red IPA', 'Indian Pale Ale');

INSERT INTO Ingrediente (nombre_ingr)
    VALUES ('Levadura'),
    ('Levadura Saccharomyces Carlsbergenesis'),
    ('Levadura Saccharomyces Uvarum'),
    ('Levadura Saccharomyces Cerevisiae'),
    ('Levadura Lager'),
    ('Levadura Belga'),
    ('Ester'),
    ('Fenol'),
    ('Lupulo'),
    ('Lupulo Americano'),
    ('Lupulo Columbus'),
    ('Lupulo Cascade'),
    ('Styrian Goldings'),
    ('Malta de Trigo'),
    ('Malta Clara'),
    ('Malta Tostada'),
    ('Malta Caramelizada'),
    ('Malta Cristal'),
    ('Malta Pale Ale'),
    ('Malta Best Malz Pale Ale'),
    ('Malta Best Malz Aromatic'),
    ('Malta Best Malz Caramel Light'),
    ('Malta Pils Belga'),
    ('Sugar Candy'),
    ('Miel'),
    ('Chocolate'),
    ('Leche'),
    ('Cafe'),
    ('Diacetilo'),
    ('Agua'),
    ('CaraVienna'),
    ('CaraMunich');

INSERT INTO Caracteristica (nombre_cara)
    VALUES ('Color'),
    ('Graduacion'),
    ('Temperatura de Fermentado'),
    ('Tiempo de Fermentado'),
    ('Turbidez'),
    ('Color de Espuma'),
    ('Retencion de Espuma'),
    ('Sabor'),
    ('Textura'),
    ('Cuerpo'),
    ('Carbonatacion'),
    ('Acabado'),
    ('Densidad Inicial'),
    ('Densidad Final'),
    ('IBUs'),
    ('Amargor (IBUs)'),
    ('Aroma');

SELECT
    Cat.nombre_tipo_cerv,
    T.nombre_tipo_cerv
FROM
    Tipo_Cerveza AS T,
    Tipo_Cerveza AS Cat
WHERE
    Cat.fk_tipo_cerv = T.cod_tipo_cerv;
