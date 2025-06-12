CREATE OR REPLACE FUNCTION get_cerv (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_cerv
    FROM
        Cerveza
    WHERE
        nombre_cerv = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

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

CREATE OR REPLACE PROCEDURE relate_cara_cerv (text, text, text)
    AS $$
DECLARE
    x integer;
BEGIN
    INSERT INTO CERV_CARA (fk_cerv, fk_cara, valor_cara)
        VALUES (get_cerv ($1), get_cara ($2), $3);
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

DELETE FROM TIPO_CARA;

DELETE FROM RECE_INGR;

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

CALL insert_tipo_cerveza ('American Pale Ale', 'American Amber Ale');

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

-- Venezolanas -- NOTE: Potencialmente son Cervezas, no tipo
CALL insert_tipo_cerveza ('Destilo', 'Ale');

CALL insert_tipo_cerveza ('Dos Leones Latin American Pale Ale', 'American IPA');

CALL insert_tipo_cerveza ('Benitz Pale Ale', 'Pale Ale');

CALL insert_tipo_cerveza ('Cervecería Lago Ángel o Demonio', 'Belgian Golden Strong Ale');

CALL insert_tipo_cerveza ('Barricas Saison Belga', 'Belgian Specialty Ale');

CALL insert_tipo_cerveza ('Aldarra Mantuana', 'Blonde Ale');

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

-- American Amber Ale
CALL relate_ingr ('American Amber Ale', 'Malta Best Malz Pale Ale', '5kg');

CALL relate_ingr ('American Amber Ale', 'Malta Best Malz Aromatic', '0.5kg');

CALL relate_ingr ('American Amber Ale', 'Malta Best Malz Caramel Light', '0.4kg');

CALL relate_ingr ('American Amber Ale', 'Lupulo Columbus', '17gr');

CALL relate_ingr ('American Amber Ale', 'Lupulo Cascade', '37gr');

-- NOTE: Deberiamos de verdad agregarle una unique ID a TIPO_CARA para poder agregar
-- muchos valores a la caracteristica
CALL relate_cara ('American Amber Ale', 'Aroma', 'Cítrico, Floral, Resinoso, Herbal...');

CALL relate_cara ('American Amber Ale', 'Sabor', 'Dulzura Inicial, seguida de Caramelo');

CALL relate_cara ('American Amber Ale', 'Color', 'Entre Ambar y Marron Cobrizo (10 - 17)');

CALL relate_cara ('American Amber Ale', 'Color de Espuma', 'Blanca');

CALL relate_cara ('American Amber Ale', 'Retencion de Espuma', 'Buena');

CALL relate_cara ('American Amber Ale', 'Amargor (IBUs)', '25 - 40');

CALL relate_cara ('American Amber Ale', 'Cuerpo', 'Medio ~ Alto');

CALL relate_cara ('American Amber Ale', 'Carbonatacion', 'Media ~ Alta');

CALL relate_cara ('American Amber Ale', 'Acabado', 'Suave, Sin Astringencia');

CALL relate_cara ('American Amber Ale', 'Densidad Inicial', '1.045 – 1.060');

CALL relate_cara ('American Amber Ale', 'Densidad Final', '1.010 – 1.015');

CALL relate_cara ('American Amber Ale', 'Graduacion', '4.5% ~ 6.2%');

-- American IPA
CALL relate_cara ('American IPA', 'Aroma', 'A Lupulo, Floral, hasta Citrico o resinoso');

CALL relate_cara ('American IPA', 'Sabor', 'A Lupulo, Floral, hasta Citrico o resinoso');

-- NOTE: SAbor a malta medio bajo y puede tener maltosidad dulce
CALL relate_cara ('American IPA', 'Amargor (IBUs)', '40 ~ 60');

CALL relate_cara ('American IPA', 'Graduacion', '5 ~ 7.5 grados');

-- American Pale Ale
-- NOTE: Aqui tambien
CALL relate_ingr ('American Pale Ale', 'Ester', 'De Nulo a Moderado');

CALL relate_cara ('American Pale Ale', 'Aroma', 'A Lupulo, Moderado o Fuerte, Citrico, A Malta, bajo o moderado');

CALL relate_cara ('American Pale Ale', 'Color', 'De Palido a Ambar');

CALL relate_cara ('American Pale Ale', 'Color de Espuma', 'De Blanca a Blancuza');

CALL relate_cara ('American Pale Ale', 'Retencion de Espuma', 'Buena');

CALL relate_cara ('American Pale Ale', 'Sabor', 'A Lupulo Moderado, A Malta Moderado, A Caramelo: Ausente');

CALL relate_cara ('American Pale Ale', 'Amargor (IBUs)', 'De Moderado a Alto');

CALL relate_cara ('American Pale Ale', 'Acabado', 'Moderadamente Seco, Suave, Sin Astringencias');

CALL relate_cara ('American Pale Ale', 'Cuerpo', 'Medio-Liviano');

CALL relate_cara ('American Pale Ale', 'Carbonatacion', 'Moderada a Alta');

-- Belgian Dubbel
CALL relate_ingr ('Belgian Dubbel', 'Styrian Goldings', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Levadura Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Agua', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Malta Pils Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Malta Pale Ale', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'CaraVienna', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'CaraMunich', 'Sin Especificar');

CALL relate_ingr ('Belgian Dubbel', 'Ester', 'Moderados');

CALL relate_ingr ('Belgian Dubbel', 'Fenol', 'Sin Especificar');

CALL relate_cara ('Belgian Dubbel', 'Aroma', 'Dulzor, Notas de Chocolate, Caramelo, Tostado');

CALL relate_cara ('Belgian Dubbel', 'Color', 'Ambar Oscuro a Cobre');

CALL relate_cara ('Belgian Dubbel', 'Color de Espuma', 'Blancuzca');

CALL relate_cara ('Belgian Dubbel', 'Retencion de Espuma', 'Cremosa, Persiste');

CALL relate_cara ('Belgian Dubbel', 'Sabor', 'Dulzor de Malta, A Pasas, Frutas Secas');

CALL relate_cara ('Belgian Dubbel', 'Amargor (IBUs)', 'Medio-Bajo');

CALL relate_cara ('Belgian Dubbel', 'Acabado', 'Moderadamente Seco');

CALL relate_cara ('Belgian Dubbel', 'Cuerpo', 'Medio-Pleno');

CALL relate_cara ('Belgian Dubbel', 'Carbonatacion', 'Media-Alta');

CALL relate_cara ('Belgian Dubbel', 'Graduacion', '6.5% ~ 7%');

-- Belgian Golden Strong Ale
CALL relate_ingr ('Belgian Golden Strong Ale', 'Levadura Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Golden Strong Ale', 'Styrian Goldings', 'Sin Especificar');

CALL relate_ingr ('Belgian Golden Strong Ale', 'Malta Pils Belga', 'Sin Especificar');

CALL relate_ingr ('Belgian Golden Strong Ale', 'Agua', 'Sin Especificar');

CALL relate_cara ('Belgian Golden Strong Ale', 'Color', 'Amarillo a dorado medio');

CALL relate_cara ('Belgian Golden Strong Ale', 'Turbidez', 'Buena claridad');

CALL relate_cara ('Belgian Golden Strong Ale', 'Color de Espuma', 'Blanca');

CALL relate_cara ('Belgian Golden Strong Ale', 'Retencion de Espuma', 'Densa, masiva, persistente');

CALL relate_cara ('Belgian Golden Strong Ale', 'Sabor', 'Combinación de sabores frutados (peras, naranjas, manzanas), especiados (pimienta) y alcohólicos, con un suave carácter a malta');

CALL relate_cara ('Belgian Golden Strong Ale', 'Regusto', 'Leve a moderadamente amargo');

CALL relate_cara ('Belgian Golden Strong Ale', 'Textura', 'Suave pero evidente tibieza por alcohol; jamás caliente o solventada');

CALL relate_cara ('Belgian Golden Strong Ale', 'Cuerpo', 'Liviano a medio');

CALL relate_cara ('Belgian Golden Strong Ale', 'Carbonatacion', 'Altamente carbonatada');

CALL relate_cara ('Belgian Golden Strong Ale', 'Acabado', 'Seco');

CALL relate_cara ('Belgian Golden Strong Ale', 'Amargor (IBUs)', 'Medio a alto');

CALL relate_cara ('Belgian Golden Strong Ale', 'Aroma', 'Complejo, con aroma a ésteres frutados, moderado a especias, y bajos a moderados aromas a alcohol y lúpulo');

-- Belgian Specialty Ale
CALL relate_ingr ('Belgian Specialty Ale', 'Levadura', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Ester', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Fenol', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Lupulo', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Malta', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Malta de Trigo', 'Sin Especifica');

CALL relate_ingr ('Belgian Specialty Ale', 'Sugar Candy', 'Puede incluirse');

CALL relate_ingr ('Belgian Specialty Ale', 'Miel', 'Puede incluirse');

CALL relate_ingr ('Belgian Specialty Ale', 'Agua', 'Sin Especifica');

CALL relate_cara ('Belgian Specialty Ale', 'Color', 'Varía considerablemente de dorado pálido a muy oscuro');

CALL relate_cara ('Belgian Specialty Ale', 'Turbidez', 'Puede ser desde turbia hasta cristalina');

CALL relate_cara ('Belgian Specialty Ale', 'Retencion de Espuma', 'Generalmente buena');

CALL relate_cara ('Belgian Specialty Ale', 'Sabor', 'Se encuentran una gran variedad de sabores, con maltosidad de ligera a algo sabrosa y un sabor y amargor del lúpulo de bajo a alto');

CALL relate_cara ('Belgian Specialty Ale', 'Textura', 'Puede haber una sensación de "fruncimiento de boca" debido a la acidez');

CALL relate_cara ('Belgian Specialty Ale', 'Cuerpo', 'Algunas están bien atenuadas, por lo que tendrán un cuerpo más liviano, mientras que otras son espesas y densas');

CALL relate_cara ('Belgian Specialty Ale', 'Carbonatacion', 'Usualmente de moderada a alta');

CALL relate_cara ('Belgian Specialty Ale', 'Aroma', 'Variable, con distintas cantidades de ésteres frutados, fenoles especiados, aromas de levadura, y puede incluir aromas de adiciones de especias');

-- Dos Leones Latin American Pale Ale
CALL relate_cara ('Dos Leones Latin American Pale Ale', 'Sabor', 'Tonos cítricos');

-- Benitz Pale Ale
CALL relate_cara ('Benitz Pale Ale', 'Sabor', 'Dulce de Maltas');

CALL relate_cara ('Benitz Pale Ale', 'Amargor (IBUs)', 'Suave');

CALL relate_cara ('Benitz Pale Ale', 'Acabado', 'Suave y fluido');

--Cervecería Lago Ángel o Demonio
CALL relate_cara ('Cervecería Lago Ángel o Demonio', 'Color', 'Dorado');

CALL relate_cara ('Cervecería Lago Ángel o Demonio', 'Color de Espuma', 'Blanca');

-- Aldarra Mantuana
CALL relate_cara ('Aldarra Mantuana', 'Color', 'Dorado');

CALL relate_cara ('Aldarra Mantuana', 'Sabor', 'Ligero');

CALL relate_cara ('Aldarra Mantuana', 'Cuerpo', 'Liviano, Sin Astringencias');

CALL relate_cara ('Aldarra Mantuana', 'Aroma', 'Recuerda a Frutas Tropicales');

CALL relate_cara ('Aldarra Mantuana', 'Carbonatacion', 'Media');

-- NOTE: Te quedaste en Belgian Golden Strong Ale
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

-- Insert cervezas reales
-- Pilsen Fuente: https://birrapedia.com/polar-pilsen/f-56d6d147f70fb5ca0c7e71ed
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Polar Pilsen', get_tipo_cerv ('Pilsener'));

CALL relate_cara_cerv ('Polar Pilsen', 'Color', 'Dorado');

CALL relate_cara_cerv ('Polar Pilsen', 'Color de Espuma', 'Blanca');

CALL relate_cara_cerv ('Polar Pilsen', 'Aroma', 'Ligero a Malta y Maiz');

CALL relate_cara_cerv ('Polar Pilsen', 'Cuerpo', 'Ligero');

CALL relate_cara_cerv ('Polar Pilsen', 'Sabor', 'Algo dulce, a malta y maiz');

-- Solera Clasica: https://birrapedia.com/polar-pilsen/f-56d6d147f70fb5ca0c7e71ed
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera Clasica', get_tipo_cerv ('Munich Helles'));

CALL relate_cara_cerv ('Solera Clasica', 'Cuerpo', 'Pronunciado');

CALL relate_cara_cerv ('Solera Clasica', 'Graduacion', '6%');

CALL relate_cara_cerv ('Solera Clasica', 'Color', 'Amarillo');

-- Solera Light https://birrapedia.com/solera-light/f-598abdbd1603dad60e8d39c8
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera Light', get_tipo_cerv ('Lager'));

CALL relate_cara_cerv ('Solera Light', 'Carbonatacion', 'Bajo');

CALL relate_cara_cerv ('Solera Light', 'Graduacion', '4%');

CALL relate_cara_cerv ('Solera Light', 'Color', 'Amarillo');

-- Solera IPA https://birrapedia.com/solera-ipa/f-5aff60251603dacb688b4a00
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera IPA', get_tipo_cerv ('Indian Pale Ale'));

-- Solera Kriek https://birrapedia.com/solera-kriek/f-5d489aed1603dae30d8b4807
-- TODO: Relacionar con Polar "J-00041312-6"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Solera Kriek', get_tipo_cerv ('Fruit Lambic'));

CALL relate_cara_cerv ('Solera Kriek', 'Aroma', 'Frutal a cereza, persistente');

CALL relate_cara_cerv ('Solera Kriek', 'Sabor', 'Entre acido, amargo y dulcel');

CALL relate_cara_cerv ('Solera Kriek', 'Color', 'Rojo macerado');

CALL relate_cara_cerv ('Solera Kriek', 'Amargor (IBUs)', 'Ligero');

CALL relate_cara_cerv ('Solera Kriek', 'Cuerpo', 'Medio');

CALL relate_cara_cerv ('Solera Kriek', 'Graduacion', '4%');

-- Mito Brewhouse Momoy https://birrapedia.com/mito-brewhouse-momoy/f-577cc4dd1603dad47a4bb481
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Momoy', get_tipo_cerv ('Witbier'));

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Graduacion', '4.6%');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Sabor', 'Recuerda a canela o clavo');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Carbonatacion', 'Alta');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Aroma', 'Hierba o pino fresco');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Color', 'Palido');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Retencion de Espuma', 'Estable y Consistente');

CALL relate_cara_cerv ('Mito Brewhouse Momoy', 'Regusto', 'Bueno');

-- Mito Brewhouse Sayona https://birrapedia.com/mito-brewhouse-sayona/f-577cc62f1603dabe204bd0a6
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Sayona', get_tipo_cerv ('Red Ale'));

CALL relate_cara_cerv ('Mito Brewhouse Sayona', 'Aroma', 'Citrico y Floral');

CALL relate_cara_cerv ('Mito Brewhouse Sayona', 'Sabor', 'Amargo');

CALL relate_cara_cerv ('Mito Brewhouse Sayona', 'Color', 'Rojizo');

-- Mito Brewhouse Silbon https://birrapedia.com/mito-brewhouse-silbon/f-577cc74f1603da5d0c4bfb3f
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Silbon', get_tipo_cerv ('Dry Stout'));

CALL relate_cara_cerv ('Mito Brewhouse Silbon', 'Amargor (IBUs)', '15');

-- Mito Brewhouse Alcántara https://birrapedia.com/mito-brewhouse-alcantara/f-57e8dd271603da873690d05a
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Alcántara', get_tipo_cerv ('Imperial Stout'));

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Color', 'Oscuro Profundo');

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Aroma', 'Intenso');

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Graduacion', 'Alto');

CALL relate_cara_cerv ('Mito Brewhouse Alcántara', 'Sabor', 'Roble, Malta Dulce, de Caramelo, Tostado');

-- Mito Brewhouse Candilleja https://birrapedia.com/mito-brewhouse-candileja/f-57e8de101603da893690d053
-- TODO: Relacionar con Mito Brewhouse "TODO"
INSERT INTO Cerveza (nombre_cerv, fk_tipo_cerv)
    VALUES ('Mito Brewhouse Candileja de Abadía', get_tipo_cerv ('Belgian Dubbel'));

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Cuerpo', 'Denso');

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Color', 'Ambar');

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Aroma', 'Intenso a Caramelo');

CALL relate_cara_cerv ('Mito Brewhouse Candileja de Abadía', 'Carbonatacion', 'Media a Alta');
