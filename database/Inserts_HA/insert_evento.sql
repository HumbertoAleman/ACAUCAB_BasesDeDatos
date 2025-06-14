CREATE OR REPLACE FUNCTION get_tipo_even (text)
    RETURNS integer
    AS $$
DECLARE
    res integer;
BEGIN
    SELECT
        cod_tipo_even
    FROM
        Tipo_Evento
    WHERE
        nombre_tipo_even = $1 INTO res;
    RETURN res;
END
$$
LANGUAGE plpgsql;

INSERT INTO Evento (nombre_even, fecha_hora_fin_even, fecha_hora_fin_even, direccion_even, capacidad_even, descripcion_even, precio_entrada_even, cant_entradas_evento, fk_tipo_even, fk_luga)
    VALUES ('Sabor y Espuma: Cata de Cervezas Artesanales', '2025-06-20 18:00:00', '2025-06-20 21:00:00', 'Av. Francisco de Miranda, Edificio Centro Plaza, Local 5', 50, 'Disfruta de una experiencia sensorial única mientras degustas una selección de cervezas artesanales, guiado por expertos que compartirán sus secretos y maridajes ideales', 20, 50, get_tipo_even ('Cata de Cervezas')),
    ('Tras las Huellas de la Cerveza: Tour por la Cervecería', '2025-06-25 14:00:00', '2025-06-25 16:00:00', 'Calle La Paz, Cervecería Artesanal La Guaira, La Guaira', 30, 'Acompáñanos en un recorrido fascinante por nuestra cervecería, donde descubrirás el proceso de elaboración de la cerveza y conocerás las historias detrás de cada estilo', 15, 30, get_tipo_even ('Tour por la Cerveceria')),
    ('Fiesta de la Cerveza: Celebración de Sabores', '2025-07-01 12:00:00', '2025-07-01 22:00:00', 'Parque del Este, Av. Francisco de Miranda', 20, 'Únete a la fiesta más grande del año, donde podrás disfrutar de una variedad de cervezas locales, música en vivo y deliciosas opciones gastronómicas en un ambiente festivo', 10, 200, get_tipo_even ('Celebracion de Sabores')),
    ('Cerveza y Gourmet: Cena de Maridaje Exclusiva', '2025-07-05 19:00:00', '2025-07-05 22:00:00', 'Restaurante El Mercado, Av. Urdaneta', 40, 'Deléitate con una cena de maridaje exclusiva, donde cada plato ha sido cuidadosamente seleccionado para complementar una variedad de cervezas artesanales, creando una experiencia culinaria inolvidable', 50, 40, get_tipo_even ('Cena de Maridaje Exclusiva')),
    ('Maestro Cervecero: Taller de Elaboración de Cerveza', '2025-07-10 10:00:00', '2025-07-10 13:00:00', 'Calle El Bosque, Cervecería El Ávila', 25, 'Aprende los fundamentos de la elaboración de cerveza en este taller práctico, donde los participantes tendrán la oportunidad de crear su propia cerveza bajo la guía de un maestro cervecero', 30, 25, get_tipo_even ('Taller de Elaboracion de Cerveza')),
    ('Brindis de Temporada: Fiesta de Lanzamiento de Nuevas Cervezas', '2025-07-15 17:00:00', '2025-07-15 20:00:00', 'Av. Bolívar, Centro Cultural Chacao, Chacao', 100, 'Celebra el lanzamiento de nuestras cervezas de temporada con un brindis especial, donde podrás ser uno de los primeros en probar estas exclusivas y limitadas creaciones', 25, 100, get_tipo_even ('Fiesta de Lanzamiento de Nuevas Cervezas')),
    ('Ritmos y Cervezas: Noche de Música en Vivo', '2025-07-20 20:00:00', '2025-07-20 23:00:00', 'Plaza Altamira, Altamira', 150, 'Disfruta de una noche llena de buena música y cervezas refrescantes en un ambiente vibrante, donde artistas locales se presentarán en vivo para animar la velada', 15, 150, get_tipo_even ('Noche de Musica en Vivo')),
    ('Trivia y Tragos: Noche de Preguntas Cerveceras', '2025-07-25 19:00:00', '2025-07-25 21:00:00', 'Bar La Cerveza, Av. Sucre, Los Dos Caminos', 60, 'Pon a prueba tus conocimientos cerveceros en una divertida noche de trivia, donde podrás competir con amigos mientras disfrutas de deliciosas cervezas y premios emocionantes', 10, 60, get_tipo_even ('Noche de Preguntas Cerveceras')),
    ('Arte y Espuma: Encuentro de Cerveza y Creatividad', '2025-07-30 16:00:00', '2025-07-30 19:00:00', 'Galería de Arte Nacional, Av. México', 80, 'Une el arte y la cerveza en este evento único, donde artistas locales exhibirán sus obras mientras los asistentes disfrutan de cervezas artesanales en un ambiente creativo', 20, 80, get_tipo_even ('Encuentro de Cerveza y Creatividad')),
    ('Conexiones Cerveceras: Evento de Networking para Profesionales', '2025-08-05 18:00:00', '2025-08-05 21:00:00', 'Hotel Tamanaco, Av. Libertador', 100, 'Conéctate con otros profesionales de la industria cervecera en este evento de networking, donde podrás intercambiar ideas, establecer contactos y explorar oportunidades de colaboración', 40, 100, get_tipo_even ('Evento de Networking para Profesionales'));
