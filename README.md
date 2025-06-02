# Proyecto Bases de Datos

- Humberto Aleman
- Alfredo Rondon
- Oscar Manrique

## Estructura del repostitorio

### Ramas

Trabajaremos en 4 ramas

- **main**: Rama sobre la que se subiran los cambios una vez funcionen, **ESTA RAMA SIEMPRE DEBE FUNCIONAR PARA QUE SI ALGO PASA Y LA CAGAMOS, SIEMPRE PODEMOS ENTREGAR LO QUE ESTA EN MAIN Y NO HAY PEO**.
- **dev**: Rama sobre la que se subiran los cambios experimentales, no necesita ser funcional.
- **front**: Rama sobre la que se trabajaran los cambios al frontend.
- **back**: Rama sobre la que se trabajaran los cambios al backend y los scrits de SQL.

### Commits

Los commits seran nombrados de la siguiente manera:

- feat: <contenido> (logramos implementar algo, los merge son feat).
- chore: <contenido> (una tarea fastidiosa, como actualizar el README.md).
- fix: <contenido> (solucion a un problema).
- BREAKING CHANGE: <contenido> (cuando un cambio realizado aqui rompe funcionalidad en otra parte, como cambiar el URL de una ruta en el backend, o cambiar la estructura de una entidad).

No creo que trabajemos con mas que eso, porque no estaremos haciendo ni tests, ni builds, no ci ni nada de eso.

## Desarrollo

Para desarrollar el proyecto se tiene que correr:

- **frontend**: React + Bun
- **backend**: Bun HTTP
- **database**: Postgres + PGAdmin4 (opcional)

Para correr todo esto sin tener que instalar las dependencias -- para evitar peos de versiones y compatibilidad -- descarguen [Docker Desktop](https://www.docker.com/products/docker-desktop/) y corranlo para que utilice el archivo [compose.yaml](https://github.com/HumbertoAleman/ACAUCAB_BasesDeDatos/blob/main/compose.yaml). Este archivo tiene declarado 4 contenedores, los cuales correran todas las dependencias.

- Frontend corre en el [puerto 3000](127.0.0.1:3000)
- Backend corre en el [puerto 3001](127.0.0.1:3001)
- Postgres corre en el [puerto 5432](127.0.0.1:5432)
- PGAdmin corre en el [puerto 8080](127.0.0.1:8080)

## Conectando Postgres con PGAdmin

### Usuario Default

Para conectar postgres con PGAdmin el usuario default y contraseña es:

- Usuario: admin@admin.com
- Contraseña: admin

### Agregando la Conexion

Para agregar la conexion de pgadmin con postgres le dan a Add New Server, y en el menu de Connection, se deben cambiar los siguientes parametros:

- host: db (se le coloca esto porque es el nombre del contenedor que tiene postgres)
- port: 5432 (le dejamos el port default de postgres)
- username: postgres (una vez mas, el nombre default del usuario de la base de datos
- password: admin (contraseña default que le coloque)

Una vez hecha la conexion tendran una base de datos en su propia computadora con la que pueden trabajar
