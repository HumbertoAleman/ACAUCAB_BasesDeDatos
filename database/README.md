## Herramientas Generadoras de Datos

- Simple, Efectiva: [SQL Test Data Generator](https://www.coderstool.com/sql-test-data-generator)

## Entidades con 10 Inserts

- [x] Asistencia
- [x] Banco
- [x] Beneficio
- [x] CERV_CARA
- [x] CERV_PRES
- [x] Caracteristica
- [x] Cargo
- [x] Cerveza
- [x] Cheque
- [x] Cliente
- [ ] Compra
- [x] Contacto
- [x] Correo
- [ ] Cuota
- [ ] DESC_CERV
- [x] Departamento
- [x] Descuento
- [ ] Detalle_Compra
- [x] Detalle_Venta
- [x] EMPL_BENE
- [x] EMPL_CARG
- [x] EMPL_HORA
- [ ] ESTA_COMP
- [x] ESTA_EVEN
- [x] ESTA_VENT
- [x] Efectivo
- [x] Empleado
- [x] Estatus
- [x] Evento
- [x] Horario
- [x] Ingrediente
- [x] Instruccion
- [x] Inventario_Evento
- [x] Inventario_Tienda
- [x] Juez
- [x] Lugar (Geografia de Venezuela Completa)
- [x] Lugar_Tienda
- [x] Metodo_Pago
- [x] Miembro
- [x] PRIV_ROL
- [x] PUNT_CLIE
- [x] Pago
- [x] Presentacion
- [x] Privilegio
- [x] Punto_Canjeo
- [x] RECE_INGR
- [x] Receta
- [ ] Registro_Evento
- [x] Rol
- [x] TIPO_CARA
- [x] Tarjeta
- [x] Tasa
- [x] Telefono
- [x] Tienda
- [x] Tipo_Cerveza
- [x] Tipo_Evento
- [x] Usuario
- [x] Vacacion
- [x] Venta

Se puede correr la siguiente query para revisar las cantidades:

```sql
SELECT relname AS table_name, n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY table_name;
```

Si prefieres ver el porcentaje que llevamos hecho:

```sql
SELECT 100 * SUM(CASE WHEN n_live_tup > 9 THEN 1 ELSE 0 END) / COUNT(*) AS "Porcentaje %"
FROM pg_stat_user_tables;
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
