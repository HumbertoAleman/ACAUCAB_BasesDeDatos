CREATE OR REPLACE FUNCTION get_tipo_cerv (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tipo_cerv
    FROM
        Tipo_Cerveza
    WHERE
        nombre_tipo_cerv = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_rece_by_type (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        fk_rece
    FROM
        Tipo_Cerveza
    WHERE
        nombre_tipo_cerv = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cara (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_cara
    FROM
        Caracteristica
    WHERE
        nombre_cara = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_ingr (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_ingr
    FROM
        Ingrediente
    WHERE
        nombre_ingr = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_tipo_cerveza (text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO Receta (nombre_rece)
        VALUES ('Receta para cervezas de tipo ' || $1)
    RETURNING
        cod_rece INTO x;
    INSERT INTO Tipo_Cerveza (nombre_tipo_cerv, fk_rece, fk_tipo_cerv)
        VALUES ($1, x, get_tipo_cerv ($2));
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE relate_cara (text, text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO TIPO_CARA (fk_tipo_cerv, fk_cara, valor_cara)
        VALUES (get_tipo_cerv ($1), get_cara ($2), $3);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE relate_ingr (text, text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO RECE_INGR (fk_rece, fk_ingr, cant_ingr)
        VALUES (get_rece_by_type ($1), get_ingr ($2), $3);
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

CALL insert_tipo_cerveza ('Guiness Irlandesa', 'Stout');

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
    ('Levadura Ale'),
    ('Levadura Belga'),
    ('Ester'),
    ('Fenol'),
    ('Lupulo'),
    ('Lupulo Americano'),
    ('Lupulo Columbus'),
    ('Lupulo Cascade'),
    ('Styrian Goldings'),
    ('Malta'),
    ('Malta Ambar'),
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
    ('Regusto'),
    ('Textura'),
    ('Cuerpo'),
    ('Carbonatacion'),
    ('Acabado'),
    ('Densidad Inicial'),
    ('Densidad Final'),
    ('IBUs'),
    ('Amargor (IBUs)'),
    ('Aroma');

-- Lager
CALL relate_ingr ('Lager', 'Malta Clara', 'Alto Porcentaje');

CALL relate_ingr ('Lager', 'Malta Tostada', 'Poco o Nada');

CALL relate_ingr ('Lager', 'Malta Caramelizada', 'Poco o Nada');

CALL relate_ingr ('Lager', 'Malta de Trigo', 'Poco o Nada');

CALL relate_ingr ('Lager', 'Levadura Lager', 'Sin Especificar');

CALL relate_ingr ('Lager', 'Lupulo', 'Poco');

CALL relate_cara ('Lager', 'Temperatura de Fermentado', 'Menor a 10 Grados Celcius');

CALL relate_cara ('Lager', 'Tiempo de Fermentado', '1 a 3 Meses');

CALL relate_cara ('Lager', 'Color', 'Claro');

CALL relate_cara ('Lager', 'Graduacion', '3.5% ~ 5%');

-- Ale
CALL relate_ingr ('Ale', 'Malta', 'Sin Especificar');

CALL relate_ingr ('Ale', 'Levadura Ale', 'Sin Especificar');

CALL relate_ingr ('Ale', 'Lupulo', 'Bastante');

CALL relate_cara ('Ale', 'Temperatura de Fermentado', '~19 Grados Celcius');

CALL relate_cara ('Ale', 'Tiempo de Fermentado', '5 a 7 Dias');

CALL relate_cara ('Ale', 'Graduacion', 'Elevado');

-- De Trigo
CALL relate_ingr ('De Trigo', 'Levadura Ale', 'Sin Especificar');

CALL relate_ingr ('De Trigo', 'Malta de Trigo', 'Muy Algo Porcentaje');

CALL relate_cara ('De Trigo', 'Color', 'Claro');

CALL relate_cara ('De Trigo', 'Graduacion', 'Baja');

-- Bock
CALL relate_ingr ('Bock', 'Lupulo', 'Poco');

CALL relate_ingr ('Bock', 'Levadura Lager', 'Sin Especificar');

CALL relate_ingr ('Bock', 'Malta Tostada', 'Alta Cantidad');

CALL relate_cara ('Bock', 'Color', 'Muy Oscuro');

CALL relate_cara ('Bock', 'Color de Espuma', 'Blanco');

CALL relate_cara ('Bock', 'Graduacion', '7%');

-- NOTE: Potencialmente agregar para poner multiples de la misma caracteristica, como sabor
CALL relate_cara ('Bock', 'Sabor', 'A malta, Algo de Dulzor');

-- Pale Ale
CALL relate_ingr ('Pale Ale', 'Malta Tostada', 'Bajo Porcentaje');

CALL relate_ingr ('Pale Ale', 'Lupulo', 'Mucho');

CALL relate_cara ('Pale Ale', 'Color', 'Claro');

CALL relate_cara ('Pale Ale', 'Sabor', 'Mucho');

CALL relate_cara ('Pale Ale', 'Amargor (IBUs)', 'Bastante');

-- Indian Pale Ale
CALL relate_ingr ('Indian Pale Ale', 'Lupulo', 'Mucho');

CALL relate_cara ('Indian Pale Ale', 'Graduacion', 'Alta');

-- Dark Ale
CALL relate_cara ('Dark Ale', 'Color', 'Muy Oscuro');

-- Stout
CALL relate_ingr ('Stout', 'Malta Tostada', 'Grande Porcentaje');

CALL relate_ingr ('Stout', 'Malta Caramelizada', 'Grande Porcentaje');

CALL relate_cara ('Stout', 'Color', 'Muy Oscuro');

-- NOTE: Lo mismo que la nota de arriba
CALL relate_cara ('Stout', 'Textura', 'Espesa y Cremosa');

CALL relate_cara ('Stout', 'Aroma', 'A malta');

CALL relate_cara ('Stout', 'Regusto', 'Dulce');

-- Imperial Stout
CALL relate_cara ('Stout', 'Graduacion', 'Muy Alta');

-- Chocolate, Coffee, Milk Stout (Se nos dice que las 3 tienen leche)
CALL relate_ingr ('Chocolate Stout', 'Chocolate', 'Sin Especificar');

CALL relate_ingr ('Chocolate Stout', 'Leche', 'Sin Especificar');

CALL relate_cara ('Chocolate Stout', 'Sabor', 'Dulce');

CALL relate_ingr ('Coffee Stout', 'Cafe', 'Sin Especificar');

CALL relate_ingr ('Coffee Stout', 'Leche', 'Sin Especificar');

CALL relate_cara ('Coffee Stout', 'Sabor', 'Dulce');

CALL relate_ingr ('Milk Stout', 'Leche', 'Sin Especificar');

CALL relate_cara ('Milk Stout', 'Sabor', 'Dulce');

-- Porter
CALL relate_ingr ('Porter', 'Lupulo', 'Buena Cantidad');

CALL relate_cara ('Porter', 'Color', 'Medio-Oscuro');

-- Belgas
CALL relate_ingr ('Belga', 'Lupulo', 'Buena Cantidad');

CALL relate_ingr ('Belga', 'Malta Ambar', 'Sin Especificar');

CALL relate_ingr ('Belga', 'Malta Cristal', 'Sin Especificar');

CALL relate_cara ('Belga', 'Color', 'Palidas ~ Oscuras, Tonos Rojizos o Rubias');

CALL relate_cara ('Belga', 'Sabor', 'Intenso, Fondo Dulce');

-- Abadía, la Trapense, la Ámbar o la Flamenca
CALL relate_cara ('Abadia', 'Graduacion', '6% ~ 7%');

CALL relate_cara ('Trapense', 'Graduacion', '6% ~ 7%');

CALL relate_cara ('Ambar', 'Graduacion', '6% ~ 7%');

CALL relate_cara ('Flamenca', 'Graduacion', '6% ~ 7%');

-- Pilsener
CALL relate_cara ('Pilsener', 'Sabor', 'Ligero pero Intenso');

CALL relate_cara ('Pilsener', 'Graduacion', 'Medio');

-- NOTE: TE QUEDASTE EN AMERICAN AMBER ALE
--
-- Dame los tipos de cervezas, y a que supertipo pertenecen
SELECT
    Cat.nombre_tipo_cerv,
    T.nombre_tipo_cerv
FROM
    Tipo_Cerveza AS T,
    Tipo_Cerveza AS Cat
WHERE
    Cat.fk_tipo_cerv = T.cod_tipo_cerv;

-- Dame los tipos de cervezas, con los ingredientes que van en sus recetas
SELECT
    nombre_tipo_cerv AS "Tipo de Cerveza",
    nombre_ingr AS "Ingrediente",
    cant_ingr AS "Cantidad en Receta"
FROM
    Tipo_Cerveza AS T,
    Ingrediente AS I,
    Receta AS R,
    RECE_INGR AS R_T
WHERE
    T.fk_rece = R.cod_rece
    AND R.cod_rece = R_T.fk_rece
    AND I.cod_ingr = R_T.fk_ingr;

-- Dame los tipos de cervezas con sus caracteristicas
SELECT
    nombre_tipo_cerv AS "Tipo de Cerveza",
    nombre_cara AS "Caracteristica",
    valor_cara AS "Valor"
FROM
    Tipo_Cerveza AS T,
    Caracteristica AS C,
    TIPO_CARA AS T_C
WHERE
    T.cod_tipo_cerv = T_C.fk_tipo_cerv
    AND T_C.fk_cara = C.cod_cara;
