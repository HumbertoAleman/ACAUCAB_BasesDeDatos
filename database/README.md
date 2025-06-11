## Herramientas Generadoras de Datos

- Simple, Efectiva: [SQL Test Data Generator](https://www.coderstool.com/sql-test-data-generator)

## Entidades con 10 Inserts

- [ ] Ingrediente
- [ ] Receta
- [ ] Instruccion
- [ ] Tipo_Cerveza
- [ ] Caracteristica
- [ ] Cerveza
- [ ] Presentacion
- [ ] Lugar
- [ ] Tienda
- [ ] Lugar_Tienda
- [ ] Tipo_Evento
- [ ] Evento
- [ ] Empleado
- [ ] Cargo
- [ ] Miembro
- [ ] Contacto
- [ ] Beneficio
- [ ] Departamento
- [ ] EMPL_CARG
- [ ] Vacacion
- [ ] Asistencia
- [ ] Horario
- [ ] Rol
- [ ] Privilegio
- [ ] Tasa
- [ ] Juez
- [ ] Banco
- [ ] Cuota
- [ ] Estatus
- [ ] Compra
- [ ] CERV_PRES
- [ ] Detalle_Compra
- [ ] Cliente
- [ ] Venta
- [ ] Usuario
- [ ] Inventario_Tienda
- [ ] Inventario_Evento
- [ ] Detalle_Venta
- [ ] Metodo_Pago
- [ ] Tarjeta
- [ ] Punto_Canjeo
- [ ] Cheque
- [ ] Efectivo
- [ ] Pago
- [ ] Telefono
- [ ] Correo
- [ ] Descuento
- [ ] Registro_Evento
- [ ] DESC_CERV
- [ ] PRIV_ROL
- [ ] EMPL_HORA
- [ ] EMPL_BENE
- [ ] CERV_CARA
- [ ] TIPO_CARA
- [ ] RECE_INGR
- [ ] ESTA_COMP
- [ ] ESTA_EVEN
- [ ] ESTA_VENT
- [ ] PUNT_CLIE
- [ ] Ingrediente
- [ ] Receta
- [ ] Instruccion
- [ ] Tipo_Cerveza
- [ ] Caracteristica
- [ ] Cerveza
- [ ] Presentacion
- [ ] Lugar
- [ ] Tienda
- [ ] Lugar_Tienda
- [ ] Tipo_Evento
- [ ] Evento
- [ ] Empleado
- [ ] Cargo
- [ ] Miembro
- [ ] Contacto
- [ ] Beneficio
- [ ] Departamento
- [ ] EMPL_CARG
- [ ] Vacacion
- [ ] Asistencia
- [ ] Horario
- [ ] Rol
- [ ] Privilegio
- [ ] Tasa
- [ ] Juez
- [ ] Banco
- [ ] Cuota
- [ ] Estatus
- [ ] Compra
- [ ] CERV_PRES
- [ ] Detalle_Compra
- [ ] Cliente
- [ ] Venta
- [ ] Usuario
- [ ] Inventario_Tienda
- [ ] Inventario_Evento
- [ ] Detalle_Venta
- [ ] Metodo_Pago
- [ ] Tarjeta
- [ ] Punto_Canjeo
- [ ] Cheque
- [ ] Efectivo
- [ ] Pago
- [ ] Telefono
- [ ] Correo
- [ ] Descuento
- [ ] Registro_Evento
- [ ] DESC_CERV
- [ ] PRIV_ROL
- [ ] EMPL_HORA
- [ ] EMPL_BENE
- [ ] CERV_CARA
- [ ] TIPO_CARA
- [ ] RECE_INGR
- [ ] ESTA_COMP
- [ ] ESTA_EVEN
- [ ] ESTA_VENT
- [ ] PUNT_CLIE
- [ ] Ingrediente
- [ ] Receta
- [ ] Instruccion
- [ ] Tipo_Cerveza
- [ ] Caracteristica
- [ ] Cerveza
- [ ] Presentacion
- [ ] Lugar
- [ ] Tienda
- [ ] Lugar_Tienda
- [ ] Tipo_Evento
- [ ] Evento
- [ ] Empleado
- [ ] Cargo
- [ ] Miembro
- [ ] Contacto
- [ ] Beneficio
- [ ] Departamento
- [ ] EMPL_CARG
- [ ] Vacacion
- [ ] Asistencia
- [ ] Horario
- [ ] Rol
- [ ] Privilegio
- [ ] Tasa
- [ ] Juez
- [ ] Banco
- [ ] Cuota
- [ ] Estatus
- [ ] Compra
- [ ] CERV_PRES
- [ ] Detalle_Compra
- [ ] Cliente
- [ ] Venta
- [ ] Usuario
- [ ] Inventario_Tienda
- [ ] Inventario_Evento
- [ ] Detalle_Venta
- [ ] Metodo_Pago
- [ ] Tarjeta
- [ ] Punto_Canjeo
- [ ] Cheque
- [ ] Efectivo
- [ ] Pago
- [ ] Telefono
- [ ] Correo
- [ ] Descuento
- [ ] Registro_Evento
- [ ] DESC_CERV
- [ ] PRIV_ROL
- [ ] EMPL_HORA
- [ ] EMPL_BENE
- [ ] CERV_CARA
- [ ] TIPO_CARA
- [ ] RECE_INGR
- [ ] ESTA_COMP
- [ ] ESTA_EVEN
- [ ] ESTA_VENT
- [ ] PUNT_CLIE

Se puede correr la siguiente query para revisar las cantidades:

```sql
SELECT relname AS table_name, n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY table_name;
```

## Organizacion de Roles

- Miembro:
    - ID: 100
    - Privileges:
        - TODO

- Cliente Natural:
    - ID: 200
    - Privileges:
        - TODO

- Cliente Juridico:
    - ID: 201
    - Privileges:
        - TODO

- Empleado Regular:
    - ID 300:
    - Privileges
        - TODO

- Empleado Ventas en Linea:
    - ID 301
    - Privileges:
        - TODO

- Empleado de Despacho:
    - ID 302
    - Privileges
        - TODO

- Empleado de Entrega:
    - ID 303
    - Privileges
        - TODO

- Empleado de Compras:
    - ID 304
    - Privileges
        - TODO

- Empleado Administrador:
    - ID 400:
    - Privileges
        - TODO

- Administrador de Sistema :
    - ID 500:
    - Privileges
        - TODO
