## Herramientas Generadoras de Datos

- Simple, Efectiva: [SQL Test Data Generator](https://www.coderstool.com/sql-test-data-generator)

## Entidades con 10 Inserts

- [ ] Asistencia
- [ ] Banco
- [ ] Beneficio
- [ ] CERV_CARA
- [ ] CERV_PRES
- [x] Caracteristica
- [ ] Cargo
- [ ] Cerveza
- [ ] Cheque
- [ ] Cliente
- [ ] Compra
- [ ] Contacto
- [ ] Correo
- [ ] Cuota
- [ ] DESC_CERV
- [ ] Departamento
- [ ] Descuento
- [ ] Detalle_Compra
- [ ] Detalle_Venta
- [ ] EMPL_BENE
- [ ] EMPL_CARG
- [ ] EMPL_HORA
- [ ] ESTA_COMP
- [ ] ESTA_EVEN
- [ ] ESTA_VENT
- [ ] Efectivo
- [x] Empleado
- [ ] Estatus
- [ ] Evento
- [ ] Horario
- [x] Ingrediente
- [ ] Instruccion
- [ ] Inventario_Evento
- [ ] Inventario_Tienda
- [ ] Juez
- [x] Lugar (Geografia de Venezuela Completa)
- [ ] Lugar_Tienda
- [ ] Metodo_Pago
- [x] Miembro
- [ ] PRIV_ROL
- [ ] PUNT_CLIE
- [ ] Pago
- [ ] Presentacion
- [ ] Privilegio
- [ ] Punto_Canjeo
- [x] RECE_INGR
- [x] Receta
- [ ] Registro_Evento
- [x] Rol
- [x] TIPO_CARA
- [ ] Tarjeta
- [ ] Tasa
- [ ] Telefono
- [ ] Tienda
- [x] Tipo_Cerveza
- [ ] Tipo_Evento
- [x] Usuario
- [ ] Vacacion
- [ ] Venta

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
