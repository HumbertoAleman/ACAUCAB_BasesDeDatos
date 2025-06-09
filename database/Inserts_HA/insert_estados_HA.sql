INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (1, 'Amazonas', 'Estado', NULL),
    (2, 'Anzoátegui', 'Estado', NULL),
    (3, 'Apure', 'Estado', NULL),
    (4, 'Aragua', 'Estado', NULL), -- municipios
    (5, 'Barinas', 'Estado', NULL), -- municipios
    (6, 'Bolívar', 'Estado', NULL),
    (7, 'Carabobo', 'Estado', NULL),
    (8, 'Cojedes', 'Estado', NULL),
    (9, 'Delta Amacuro', 'Estado', NULL),
    (10, 'Falcón', 'Estado', NULL),
    (11, 'Guárico', 'Estado', NULL),
    (12, 'Lara', 'Estado', NULL),
    (13, 'Merida', 'Estado', NULL),
    (14, 'Miranda', 'Estado', NULL), -- municipios
    (15, 'Monagas', 'Estado', NULL),
    (16, 'Nueva Esparta', 'Estado', NULL), -- municipios
    (17, 'Portuguesa', 'Estado', NULL),
    (18, 'Sucre', 'Estado', NULL),
    (19, 'Táchira', 'Estado', NULL),
    (20, 'Trujillo', 'Estado', NULL),
    (21, 'Yaracuy', 'Estado', NULL),
    (22, 'Zulia', 'Estado', NULL)
    -- municipios
;

-- Insertar en Miranda
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (23, 'Acevedo', 'Municipio', 14),
    (24, 'Andrés Bello', 'Municipio', 14),
    (25, 'Baruta', 'Municipio', 14),
    (26, 'Buroz', 'Municipio', 14),
    (27, 'Carrizal', 'Municipio', 14),
    (28, 'Chacao', 'Municipio', 14),
    (29, 'El Hatillo', 'Municipio', 14),
    (30, 'Guaicaipuro', 'Municipio', 14),
    (31, 'Independencia', 'Municipio', 14),
    (32, 'Los Salias', 'Municipio', 14),
    (33, 'Paz Castillo', 'Municipio', 14),
    (34, 'Sucre', 'Municipio', 14),
    (35, 'Urdaneta', 'Municipio', 14);

-- Insertar en el Hatillo
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (36, 'El Hatillo', 'Parroquia', 29),
    (37, 'La Boyera', 'Parroquia', 29),
    (38, 'Los Naranjos', 'Parroquia', 29),
    (39, 'La Candelaria', 'Parroquia', 29),
    (40, 'El Calvario', 'Parroquia', 29),
    (41, 'La Unión', 'Parroquia', 29);

-- Insertar en Sucre
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (42, 'Caucagüita', 'Parroquia', 34),
    (43, 'La Dolorita', 'Parroquia', 34),
    (44, 'La Urbina', 'Parroquia', 34),
    (45, 'Los Cortijos', 'Parroquia', 34),
    (46, 'Mariche', 'Parroquia', 34),
    (47, 'Petare', 'Parroquia', 34),
    (48, 'San Blas', 'Parroquia', 34),
    (49, 'San Fernando', 'Parroquia', 34),
    (50, 'Santa Eduvigis', 'Parroquia', 34),
    (51, 'Santa Teresa', 'Parroquia', 34),
    (52, 'El Morro', 'Parroquia', 34),
    (53, 'La Paz', 'Parroquia', 34);

-- Insertar en Baruta
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (54, 'Baruta', 'Parroquia', 25),
    (55, 'El Cafetal', 'Parroquia', 25),
    (56, 'La Trinidad', 'Parroquia', 25),
    (57, 'Las Minas', 'Parroquia', 25),
    (58, 'Santa Rosa', 'Parroquia', 25),
    (59, 'Turgua', 'Parroquia', 25),
    (60, 'La Unión', 'Parroquia', 25),
    (61, 'La Palmera', 'Parroquia', 25);

-- Insertar en Chacao
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (62, 'Chacao', 'Parroquia', 28),
    (63, 'El Rosario', 'Parroquia', 28);

-- Insertar en Aragua
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (64, 'Alberto Adriani', 'Municipio', 4),
    (65, 'Bacatete', 'Municipio', 4),
    (66, 'Bolívar', 'Municipio', 4),
    (67, 'Camatagua', 'Municipio', 4),
    (68, 'Francisco Linares Alcántara', 'Municipio', 4),
    (69, 'Girardot', 'Municipio', 4),
    (70, 'José Ángel Lamas', 'Municipio', 4),
    (71, 'José Rafael Revenga', 'Municipio', 4),
    (72, 'Maracay', 'Municipio', 4),
    (73, 'San Casimiro', 'Municipio', 4),
    (74, 'San Sebastián', 'Municipio', 4),
    (75, 'Santiago Mariño', 'Municipio', 4),
    (76, 'Sucre', 'Municipio', 4),
    (77, 'Zamora', 'Municipio', 4);

-- Insertar en Maracay
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (78, 'Catedral', 'Parroquia', 72),
    (79, 'Andrés Eloy Blanco', 'Parroquia', 72),
    (80, 'José Casanova Godoy', 'Parroquia', 72),
    (81, 'Las Delicias', 'Parroquia', 72),
    (82, 'La Morita', 'Parroquia', 72),
    (83, 'San Isidro', 'Parroquia', 72),
    (84, 'Santa Rosa', 'Parroquia', 72),
    (85, 'El Limón', 'Parroquia', 72),
    (86, 'La Candelaria', 'Parroquia', 72),
    (87, 'Tucacas', 'Parroquia', 72);

-- Insert into Zulia
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (88, 'Almirante Padilla', 'Municipio', 22),
    (89, 'Baralt', 'Municipio', 22),
    (90, 'Cabimas', 'Municipio', 22),
    (91, 'Colón', 'Municipio', 22),
    (92, 'Francisco Javier Pulgar', 'Municipio', 22),
    (93, 'La Cañada de Urdaneta', 'Municipio', 22),
    (94, 'Lagunillas', 'Municipio', 22),
    (95, 'Maracaibo (the capital city)', 'Municipio', 22),
    (96, 'Mara', 'Municipio', 22),
    (97, 'Miranda', 'Municipio', 22),
    (98, 'Páez', 'Municipio', 22),
    (99, 'San Francisco', 'Municipio', 22),
    (100, 'Santa Rita', 'Municipio', 22),
    (101, 'Simón Bolívar', 'Municipio', 22),
    (102, 'Sucre', 'Municipio', 22),
    (103, 'Valmore Rodríguez', 'Municipio', 22),
    (104, 'Zulia', 'Municipio', 22);

-- Insert into Maracaibo
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (105, 'Catedral', 'Parroquia', 95),
    (106, 'Chiquinquirá', 'Parroquia', 95),
    (107, 'El Empedrado', 'Parroquia', 95),
    (108, 'El Milagro', 'Parroquia', 95),
    (109, 'Francisco Eugenio Bustamante', 'Parroquia', 95),
    (110, 'Idelfonso Vásquez', 'Parroquia', 95),
    (111, 'Juana de Ávila', 'Parroquia', 95),
    (112, 'La Concepción', 'Parroquia', 95),
    (113, 'La Victoria', 'Parroquia', 95),
    (114, 'Los Cortijos', 'Parroquia', 95),
    (115, 'San Isidro', 'Parroquia', 95),
    (116, 'San Jacinto', 'Parroquia', 95),
    (117, 'Santa Lucía', 'Parroquia', 95),
    (118, 'Santa Rita', 'Parroquia', 95),
    (119, 'Sierra Maestra', 'Parroquia', 95),
    (120, 'Venancio Pulgar', 'Parroquia', 95);

-- Insert into Barinas
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (121, 'Barinas', 'Municipio', 5),
    (122, 'Arismendi', 'Municipio', 5),
    (123, 'Barinitas', 'Municipio', 5),
    (124, 'Bolívar', 'Municipio', 5),
    (125, 'Cruz Paredes', 'Municipio', 5),
    (126, 'Ezequiel Zamora', 'Municipio', 5),
    (127, 'Obispos', 'Municipio', 5),
    (128, 'Rojas', 'Municipio', 5),
    (129, 'Sosa', 'Municipio', 5),
    (130, 'Sucre', 'Municipio', 5),
    (131, 'Tovar', 'Municipio', 5);

-- Insert into Barinas (Municipio)
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (132, 'Barinas', 'Parroquia', 121),
    (133, 'Alberto Arvelo Torrealba', 'Parroquia', 121),
    (134, 'Antonio José de Sucre', 'Parroquia', 121),
    (135, 'Cruz Paredes', 'Parroquia', 121),
    (136, 'El Carmen', 'Parroquia', 121),
    (137, 'La Luz', 'Parroquia', 121),
    (138, 'San Silvestre', 'Parroquia', 121),
    (139, 'Santa Bárbara', 'Parroquia', 121),
    (140, 'Santa Rosa', 'Parroquia', 121),
    (141, 'Santo Domingo', 'Parroquia', 121);

-- Insert into Nueva Esparta
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (142, 'Antolín del Campo', 'Municipio', 16),
    (143, 'Arismendi', 'Municipio', 16),
    (144, 'Díaz', 'Municipio', 16),
    (145, 'García', 'Municipio', 16),
    (146, 'Maneiro', 'Municipio', 16),
    (147, 'Marcano', 'Municipio', 16),
    (148, 'Mariño (the capital municipality)', 'Municipio', 16),
    (149, 'Península de Macanao', 'Municipio', 16),
    (150, 'Tubores', 'Municipio', 16);

-- Insert into Mariño
INSERT INTO Lugar (cod_luga, nombre_luga, tipo_luga, fk_luga)
    VALUES (151, 'Porlamar', 'Parroquia', 148),
    (152, 'La Asunción', 'Parroquia', 148),
    (153, 'San Juan Bautista', 'Parroquia', 148),
    (154, 'Santa Rosa', 'Parroquia', 148),
    (155, 'El Espinal', 'Parroquia', 148),
    (156, 'La Caranta', 'Parroquia', 148);
