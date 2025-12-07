# Portafolio5
# **Componentes básicos de una base de datos**

* Tabla: estructura que almacena datos de un único “tipo” (p. ej., clientes, pedidos).
* Registro (fila/tupla): una instancia dentro de la tabla (un cliente, un pedido).
* Campo (columna/atributo): una característica del registro (nombre, email, total).
* Clave primaria (PK): identificador único de la fila dentro de su tabla (p. ej., cliente\_id).
* Clave foránea (FK): columna que apunta a la PK de otra tabla para crear la relación (p. ej., pedidos.cliente\_id → clientes.cliente\_id).

##### ¿Cómo se gestionan y almacenan los datos y la relación?
1. Almacenamiento y gestión
El RDBMS (PostgreSQL) guarda los datos en tablas como conjuntos de filas con columnas tipadas.
La integridad se asegura con restricciones (PRIMARY KEY, UNIQUE, CHECK, NOT NULL).
Las operaciones se hacen en transacciones (ACID) y el rendimiento se mejora con indices.

2\. Relación entre tablas
pedidos.cliente\_id es una FK que exige que cada pedido pertenezca a un cliente existente en clientes.
La regla ON DELETE RESTRICT impide borrar un cliente si tiene pedidos (evita datos “huérfanos”).
Gracias a la relación, la organización puede consultar fácilmente: “todos los pedidos de un cliente”, “el total vendido por cliente”, etc., cumpliendo necesidades como seguimiento de clientes, ventas y reportería.
