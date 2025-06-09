INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Amazonas', 'Estado', NULL),
    ('Anzoategui', 'Estado', NULL),
    ('Apure', 'Estado', NULL),
    ('Aragua', 'Estado', NULL),
    ('Barinas', 'Estado', NULL),
    ('Bolivar', 'Estado', NULL),
    ('Carabobo', 'Estado', NULL),
    ('Cojedes', 'Estado', NULL),
    ('Delta Amacuro', 'Estado', NULL),
    ('Falcon', 'Estado', NULL),
    ('Guarico', 'Estado', NULL),
    ('Lara', 'Estado', NULL),
    ('Merida', 'Estado', NULL),
    ('Miranda', 'Estado', NULL),
    ('Monagas', 'Estado', NULL),
    ('Nueva Esparta', 'Estado', NULL),
    ('Portuguesa', 'Estado', NULL),
    ('Sucre', 'Estado', NULL),
    ('Tachira', 'Estado', NULL),
    ('Trujillo', 'Estado', NULL),
    ('Yaracuy', 'Estado', NULL),
    ('Zulia', 'Estado', NULL);

-- Insertar en Amazonas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Altures', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado')),
    ('Alto Orinoco', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado')),
    ('Atabapo', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado')),
    ('Autana', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado')),
    ('Manapiare', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado')),
    ('Rio Negro', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado')),
    ('Maroa', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Amazonas' AND tipo_luga = 'Estado'));

-- Insertar en Amazonas-Altures
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Fernando Giron Tovar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Altures' AND tipo_luga = 'Municipio')),
    ('Luis Alberto Gomez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Altures' AND tipo_luga = 'Municipio')),
    ('Parhueña', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Altures' AND tipo_luga = 'Municipio')),
    ('Platanillal', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Altures' AND tipo_luga = 'Municipio'));

-- Insertar en Amazonas-Alto Orinoco
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('La Esmeralda', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Alto Orinoco' AND tipo_luga = 'Municipio')),
    ('Marawaka', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Alto Orinoco' AND tipo_luga = 'Municipio')),
    ('Mavaca', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Alto Orinoco' AND tipo_luga = 'Municipio')),
    ('Sierra Parima', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Alto Orinoco' AND tipo_luga = 'Municipio'));

-- Insertar en Amazonas-Atabapo
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Fernando de Atabapo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Atabapo' AND tipo_luga = 'Municipio')),
    ('Laja Lisa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Atabapo' AND tipo_luga = 'Municipio')),
    ('Santa Barbara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Atabapo' AND tipo_luga = 'Municipio')),
    ('Guarinuma', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Atabapo' AND tipo_luga = 'Municipio'));

-- Insertar en Amazonas-Autana
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Isla Raton', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Autana' AND tipo_luga = 'Municipio')),
    ('San Pedro del Orinoco', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Autana' AND tipo_luga = 'Municipio')),
    ('Pendare', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Autana' AND tipo_luga = 'Municipio')),
    ('Manduapo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Autana' AND tipo_luga = 'Municipio')),
    ('Samariapo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Autana' AND tipo_luga = 'Municipio'));

-- Insertar en Amazonas-Manapiare
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Juan de Manapiare', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manapiare' AND tipo_luga = 'Municipio')),
    ('Camani', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manapiare' AND tipo_luga = 'Municipio')),
    ('Capure', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manapiare' AND tipo_luga = 'Municipio')),
    ('Manueta', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manapiare' AND tipo_luga = 'Municipio'));

-- Insertar en Amazonas-Maroa
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Maroa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Maroa' AND tipo_luga = 'Municipio')),
    ('Comunidad', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Maroa' AND tipo_luga = 'Municipio')),
    ('Victorino', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Maroa' AND tipo_luga = 'Municipio'));

-- Insertar en Amazonas-Rio Negro
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Carlos de Rio Negro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rio Negro' AND tipo_luga = 'Municipio')),
    ('Solano', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rio Negro' AND tipo_luga = 'Municipio')),
    ('Curimacare', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rio Negro' AND tipo_luga = 'Municipio')),
    ('Santa Lucia', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rio Negro' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Anaco', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Aragua', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Diego Bautista Urbaneja', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Fernando de Peñalver', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Francisco del Carmen Carvajal', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Francisco de Miranda', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Guanta', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Independencia', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Jose Gregorio Monagas', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Juan Antonio Sotillo', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Juan Manuel Cajigal', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Libertad', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Manuel Ezequiel Bruzual', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Pedro Maria Freites', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Piritu', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Guanipa', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('San Juan de Capistrano', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Santa Ana', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Simon Bolivar', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Simon Rodriguez', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado')),
    ('Sir Arthur McGregor', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anzoategui' AND tipo_luga = 'Estado'));

-- Insertar en Anzoategui-Anaco
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Anaco', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anaco' AND tipo_luga = 'Municipio')),
    ('San Joaquin', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Anaco' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Aragua
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Cachipo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Municipio')),
    ('Aragua de Barcelona', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Diego Bautista Urbaneja
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Lecheria', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Diego Bautista Urbaneja' AND tipo_luga = 'Municipio')),
    ('El Morro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Diego Bautista Urbaneja' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Fernando de Peñalver
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Puerto Piritu', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Fernando de Peñalver' AND tipo_luga = 'Municipio')),
    ('San Miguel', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Fernando de Peñalver' AND tipo_luga = 'Municipio')),
    ('Sucre', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Fernando de Peñalver' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Francisco del Carmen Carvajal
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Valle de Guanape', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Francisco del Carmen Carvajal' AND tipo_luga = 'Municipio')),
    ('Santa Barbara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Francisco del Carmen Carvajal' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Francisco de Miranda
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Atapirire', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Francisco de Miranda' AND tipo_luga = 'Municipio')),
    ('Boca del Pao', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Francisco de Miranda' AND tipo_luga = 'Municipio')),
    ('El Pao', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Francisco de Miranda' AND tipo_luga = 'Municipio')),
    ('Pariaguan', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Francisco de Miranda' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Guanta
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Guanta', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Guanta' AND tipo_luga = 'Municipio')),
    ('Chorreron', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Guanta' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Independencia
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Mamo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Independencia' AND tipo_luga = 'Municipio')),
    ('Soledad', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Independencia' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Jose Gregorio Monagas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Mapire', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Gregorio Monagas' AND tipo_luga = 'Municipio')),
    ('Piar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Gregorio Monagas' AND tipo_luga = 'Municipio')),
    ('Santa Clara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Gregorio Monagas' AND tipo_luga = 'Municipio')),
    ('San Diego de Cabrutica', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Gregorio Monagas' AND tipo_luga = 'Municipio')),
    ('Uverito', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Gregorio Monagas' AND tipo_luga = 'Municipio')),
    ('Zuata', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Gregorio Monagas' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Juan Antonio Sotillo
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Puerto La Cruz', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Juan Antonio Sotillo' AND tipo_luga = 'Municipio')),
    ('Pozuelos', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Juan Antonio Sotillo' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Juan Manuel Cajigal
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
VALUES ('Onoto', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Juan Manuel Cajigal' AND tipo_luga = 'Municipio')),
('San Pablo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Juan Manuel Cajigal' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Libertad
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Mateo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Libertad' AND tipo_luga = 'Municipio')),
    ('El Carito', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Libertad' AND tipo_luga = 'Municipio')),
    ('Santa Ines', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Libertad' AND tipo_luga = 'Municipio')),
    ('La Romereña', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Libertad' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Manuel Ezequiel Bruzual
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Clarines', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manuel Ezequiel Bruzual' AND tipo_luga = 'Municipio')),
    ('Guanape', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manuel Ezequiel Bruzual' AND tipo_luga = 'Municipio')),
    ('Sabana de Uchire', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Manuel Ezequiel Bruzual' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Pedro Maria Freites
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Cantaura', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Maria Freites' AND tipo_luga = 'Municipio')),
    ('Libertador', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Maria Freites' AND tipo_luga = 'Municipio')),
    ('Santa Rosa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Maria Freites' AND tipo_luga = 'Municipio')),
    ('Urica', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Maria Freites' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Piritu
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Piritu', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Piritu' AND tipo_luga = 'Municipio')),
    ('San Francisco', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Piritu' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-San Jose de Guanipa
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Jose de Guanipa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Guanipa' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-San Juan de Capistrano
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Boca de Uchire', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Juan de Capistrano' AND tipo_luga = 'Municipio')),
    ('Boca de Chavez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Juan de Capistrano' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Santa Ana
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Pueblo Nuevo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santa Ana' AND tipo_luga = 'Municipio')),
    ('Santa Ana', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santa Ana' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Simon Bolivar
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Bergantin', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Bolivar' AND tipo_luga = 'Municipio')),
    ('Caigua', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Bolivar' AND tipo_luga = 'Municipio')),
    ('El Carmen', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Bolivar' AND tipo_luga = 'Municipio')),
    ('El Pilar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Bolivar' AND tipo_luga = 'Municipio')),
    ('Naricual', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Bolivar' AND tipo_luga = 'Municipio')),
    ('San Cristobal', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Bolivar' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Simon Rodriguez
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Edmundo Barrios', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Rodriguez' AND tipo_luga = 'Municipio')),
    ('Miguel Otero Silva', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Simon Rodriguez' AND tipo_luga = 'Municipio'));

-- Insertar en Anzoategui-Sir Arthur McGregor
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('El Chaparro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sir Arthur McGregor' AND tipo_luga = 'Municipio')),
    ('Tomas Alfaro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sir Arthur McGregor' AND tipo_luga = 'Municipio')),
    ('Calatrava', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sir Arthur McGregor' AND tipo_luga = 'Municipio'));

-- Insertar en Apure
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Achaguas', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado')),
    ('Biruaca', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado')),
    ('Muñoz', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado')),
    ('Paez', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado')),
    ('Pedro Camejo', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado')),
    ('Romulo Gallegos', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado')),
    ('San Fernando', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Apure' AND tipo_luga = 'Estado'));

-- Insertar en Apure-Achaguas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Achaguas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Achaguas' AND tipo_luga = 'Municipio')),
    ('Apurito', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Achaguas' AND tipo_luga = 'Municipio')),
    ('El Yagual', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Achaguas' AND tipo_luga = 'Municipio')),
    ('Guachara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Achaguas' AND tipo_luga = 'Municipio')),
    ('Mucuritas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Achaguas' AND tipo_luga = 'Municipio')),
    ('Queseras del Medio', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Achaguas' AND tipo_luga = 'Municipio'));

-- Insertar en Apure-Biruaca
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Biruaca', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Biruaca' AND tipo_luga = 'Municipio'));

-- Insertar en Apure-Muñoz
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Bruzual', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Muñoz' AND tipo_luga = 'Municipio')),
    ('Santa Barbara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Muñoz' AND tipo_luga = 'Municipio'));

-- Insertar en Apure-Paez
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Guasdualito', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('Aramendi', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('El Amparo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('San Camilo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('Urdaneta', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('Canagua', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('Dominga Ortíz de Paez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio')),
    ('Santa Rosalia', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Paez' AND tipo_luga = 'Municipio'));;

-- Insertar en Apure-Pedro Camejo
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Juan de Payara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Camejo' AND tipo_luga = 'Municipio')),
    ('Codazzi', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Camejo' AND tipo_luga = 'Municipio')),
    ('Cunaviche', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedro Camejo' AND tipo_luga = 'Municipio'));

-- Insertar en Apure-Romulo Gallegos
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Elorza', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Romulo Gallegos' AND tipo_luga = 'Municipio')),
    ('La Trinidad de Orichuna', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Romulo Gallegos' AND tipo_luga = 'Municipio'));

-- Insertar en Apure-San Fernando
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('El Recreo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Fernando' AND tipo_luga = 'Municipio')),
    ('Peñalver', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Fernando' AND tipo_luga = 'Municipio')),
    ('San Fernando de Apure', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Fernando' AND tipo_luga = 'Municipio')),
    ('San Rafael de Atamaica', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Fernando' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Girardot', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Bolivar', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Mario Briceño Iragorry', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Santos Michelena', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Sucre', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Santiago Mariño', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Jose angel Lamas', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Linares Alcantara', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('San Casimiro', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Urdaneta', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Jose Felix Ribas', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Jose Rafael Revenga', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Ocumare de la Costa de Oro', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Tovar', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Camatagua', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Zamora', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('San Sebastian', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado')),
    ('Libertador', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Aragua' AND tipo_luga = 'Estado'));

-- Insertar en Aragua-Bolivar
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Bolivar (San Mateo)', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Camatagua
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Camatagua', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Camatagua' AND tipo_luga = 'Municipio')),
    ('Carmen de Cura', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Camatagua' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Francisco Linares Alcantara
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Santa Rita', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Linares Alcantara' AND tipo_luga = 'Municipio')),
    ('Francisco de Miranda', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Linares Alcantara' AND tipo_luga = 'Municipio')),
    ('Moseñor Feliciano Gonzalez (Paraparal)', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Linares Alcantara' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Atanasio Girardot
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Pedro Jose Ovalles', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Joaquin Crespo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Jose Casanova Godoy', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Madre Maria de San Jose', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Andres Eloy Blanco', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Los Tacarigua', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Las Delicias', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio')),
    ('Choroni', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Girardot' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Jose angel Lamas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Santa Cruz', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose angel Lamas' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Jose Felix Ribas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Jose Felix Ribas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Felix Ribas' AND tipo_luga = 'Municipio')),
    ('Castor Nieves Rios', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Felix Ribas' AND tipo_luga = 'Municipio')),
    ('Las Guacamayas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Felix Ribas' AND tipo_luga = 'Municipio')),
    ('Pao de Zarate', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Felix Ribas' AND tipo_luga = 'Municipio')),
    ('Zuata', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Felix Ribas' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Jose Rafael Revenga
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Jose Rafael Revenga', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Jose Rafael Revenga' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Libertador
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Palo Negro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Libertador' AND tipo_luga = 'Municipio')),
    ('San Martin de Porres', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Libertador' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Mario Briceño Iragorry
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
VALUES ('El Limon', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Mario Briceño Iragorry' AND tipo_luga = 'Municipio')),
('Caña de Azucar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Mario Briceño Iragorry' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Ocumare de la Costa de Oro
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Ocumare de la Costa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Ocumare de la Costa de Oro' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-San Casimiro
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Casimiro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Casimiro' AND tipo_luga = 'Municipio')),
    ('Güiripa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Casimiro' AND tipo_luga = 'Municipio')),
    ('Ollas de Caramacate', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Casimiro' AND tipo_luga = 'Municipio')),
    ('Valle Morin', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Casimiro' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-San Sebastian
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('San Sebastian', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'San Sebastian' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Santiago Mariño
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Turmero', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santiago Mariño' AND tipo_luga = 'Municipio')),
    ('Arevalo Aponte', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santiago Mariño' AND tipo_luga = 'Municipio')),
    ('Chuao', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santiago Mariño' AND tipo_luga = 'Municipio')),
    ('Saman de Güere', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santiago Mariño' AND tipo_luga = 'Municipio')),
    ('Alfredo Pacheco Miranda', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santiago Mariño' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Santos Michelena
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Santos Michelena', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santos Michelena' AND tipo_luga = 'Municipio')),
    ('Tiara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Santos Michelena' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Sucre
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Cagua', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sucre' AND tipo_luga = 'Municipio')),
    ('Bella Vista', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sucre' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Tovar
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Tovar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Tovar' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Urdaneta
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Urdaneta', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Urdaneta' AND tipo_luga = 'Municipio')),
    ('Las Peñitas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Urdaneta' AND tipo_luga = 'Municipio')),
    ('San Francisco de Cara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Urdaneta' AND tipo_luga = 'Municipio')),
    ('Taguay', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Urdaneta' AND tipo_luga = 'Municipio'));

-- Insertar en Aragua-Zamora
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Zamora', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Zamora' AND tipo_luga = 'Municipio')),
    ('Magdaleno', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Zamora' AND tipo_luga = 'Municipio')),
    ('San Francisco de Asis', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Zamora' AND tipo_luga = 'Municipio')),
    ('Valles de Tucutunemo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Zamora' AND tipo_luga = 'Municipio')),
    ('Augusto Mijares', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Zamora' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Alberto Arvelo Torrealba', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Andrés Eloy Blanco', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Antonio José de Sucre', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Arismendi', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Barinas', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Bolívar', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Cruz Paredes', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Ezequiel Zamora', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Obispos', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Pedraza', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Sosa', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado')),
    ('Rojas', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Estado'));

-- Insertar en Barinas-Arismendi
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Arismendi', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Arismendi' AND tipo_luga = 'Municipio')),
    ('Guadarrama', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Arismendi' AND tipo_luga = 'Municipio')),
    ('La Unión', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Arismendi' AND tipo_luga = 'Municipio')),
    ('San Antonio', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Arismendi' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Barinas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Barinas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Alfredo Arvelo Larriva', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('San Silvestre', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Santa Inés', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Santa Lucía', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Torunos', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('El Carmen', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Rómulo Betancourt', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Corazón de Jesús', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Ramón Ignacio Méndez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Alto Barinas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Manuel Palacio Fajardo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Juan Antonio Rodríguez Domínguez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio')),
    ('Dominga Ortiz de Páez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Barinas' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Andrés Eloy Blanco
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('El Cantón', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Andrés Eloy Blanco' AND tipo_luga = 'Municipio')),
    ('Santa Cruz de Guacas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Andrés Eloy Blanco' AND tipo_luga = 'Municipio')),
    ('Puerto Vivas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Andrés Eloy Blanco' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Bolívar
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Barinitas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolívar' AND tipo_luga = 'Municipio')),
    ('Altamira de Cáceres', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolívar' AND tipo_luga = 'Municipio')),
    ('Calderas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolívar' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Cruz Paredes
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Masparrito', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Cruz Paredes' AND tipo_luga = 'Municipio')),
    ('El Socorro', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Cruz Paredes' AND tipo_luga = 'Municipio')),
    ('Barrancas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Cruz Paredes' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Obispos
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Obispos', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Obispos' AND tipo_luga = 'Municipio')),
    ('El Real', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Obispos' AND tipo_luga = 'Municipio')),
    ('La Luz', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Obispos' AND tipo_luga = 'Municipio')),
    ('Los Guasimitos', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Obispos' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Pedraza
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Ciudad Bolivia', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedraza' AND tipo_luga = 'Municipio')),
    ('Ignacio Briceño', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedraza' AND tipo_luga = 'Municipio')),
    ('José Félix Ribas', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedraza' AND tipo_luga = 'Municipio')),
    ('Páez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Pedraza' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Rojas
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Libertad', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rojas' AND tipo_luga = 'Municipio')),
    ('Dolores', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rojas' AND tipo_luga = 'Municipio')),
    ('Santa Rosa', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rojas' AND tipo_luga = 'Municipio')),
    ('Simón Rodríguez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rojas' AND tipo_luga = 'Municipio')),
    ('Palacio Fajardo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Rojas' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Sosa
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Ciudad de Nutrias', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sosa' AND tipo_luga = 'Municipio')),
    ('El Regalo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sosa' AND tipo_luga = 'Municipio')),
    ('Puerto Nutrias', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sosa' AND tipo_luga = 'Municipio')),
    ('Santa Catalina', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sosa' AND tipo_luga = 'Municipio')),
    ('Simón Bolívar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Sosa' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Antonio José de Sucre
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Ticoporo', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Antonio José de Sucre' AND tipo_luga = 'Municipio')),
    ('Nicolás Pulido', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Antonio José de Sucre' AND tipo_luga = 'Municipio')),
    ('Andrés Bello', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Antonio José de Sucre' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Alberto Arvelo Torrealba
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Sabaneta', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Alberto Arvelo Torrealba' AND tipo_luga = 'Municipio')),
    ('Juan Antonio Rodríguez Domínguez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Alberto Arvelo Torrealba' AND tipo_luga = 'Municipio'));

-- Insertar en Barinas-Ezequiel Zamora
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Santa Bárbara', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Ezequiel Zamora' AND tipo_luga = 'Municipio')),
    ('Pedro Briceño Méndez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Ezequiel Zamora' AND tipo_luga = 'Municipio')),
    ('Ramón Ignacio Méndez', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Ezequiel Zamora' AND tipo_luga = 'Municipio')),
    ('José Ignacio del Pumar', 'Parroquia', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Ezequiel Zamora' AND tipo_luga = 'Municipio'));

-- Insertar en Bolívar
INSERT INTO Lugar (nombre_luga, tipo_luga, fk_luga)
    VALUES ('Caroní', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Cedeño', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('El Callao', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Gran Sabana', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Heres', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Padre Pedro Chien', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Piar', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Angostura', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Roscio', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Sifontes', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado')),
    ('Sucre', 'Municipio', (SELECT cod_luga FROM Lugar WHERE nombre_luga = 'Bolivar' AND tipo_luga = 'Estado'));