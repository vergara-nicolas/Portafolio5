/*PORTAFOLIO MÓDULO 5*/
-- 1) Distinguir las características, rol y elementos fundamentales de una base de datos relacional para la gestión de la información en una organización.
-- Tabla principal: CLIENTES
CREATE TABLE clientes (
  cliente_id   BIGSERIAL PRIMARY KEY,        -- PK
  nombre       VARCHAR(120) NOT NULL,
  email        VARCHAR(120) UNIQUE,
  telefono     VARCHAR(30),
  direccion    VARCHAR(200),
  creado_en    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabla dependiente: PEDIDOS
CREATE TABLE pedidos (
  pedido_id    BIGSERIAL PRIMARY KEY,        -- PK
  cliente_id   BIGINT NOT NULL
               REFERENCES clientes(cliente_id)  -- FK a clientes
               ON DELETE RESTRICT,              -- evita borrar cliente con pedidos
  fecha        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  estado       VARCHAR(20) NOT NULL
               CHECK (estado IN ('PENDIENTE','ENVIADO','CANCELADO','COMPLETADO')),
  total        NUMERIC(12,2) NOT NULL CHECK (total >= 0)
);

-- Datos de prueba mínimos
INSERT INTO clientes (nombre, email) VALUES
  ('ACME Ltda', 'ventas@acme.cl'),
  ('Beta SpA',  'contacto@beta.cl');

INSERT INTO pedidos (cliente_id, estado, total) VALUES
  (1, 'PENDIENTE', 125000),
  (1, 'ENVIADO',    89000),
  (2, 'PENDIENTE',  45000);


-- 2) Consulta que obtiene todos los pedidos realizados por un cliente específico.
-- Por ID de cliente
SELECT clientes.cliente_id, clientes.nombre,
       pedidos.pedido_id, pedidos.fecha, pedidos.estado, pedidos.total
FROM clientes
JOIN pedidos ON pedidos.cliente_id = clientes.cliente_id
WHERE clientes.cliente_id = 1
ORDER BY pedidos.fecha DESC;


-- 3) Utilizar lenguaje de manipulación de datos (DML) para la modificación de los datos existentes
-- INSERT: crear (o asegurar) un cliente y registrar un pedido PENDIENTE
INSERT INTO clientes (nombre, email, telefono, direccion)
VALUES ('Gamma SpA', 'hola@gamma.cl', '56-2-600000', 'Av. Innovación 789, La Serena, Coquimbo');

INSERT INTO pedidos (cliente_id, estado, total)
SELECT clientes.cliente_id, 'PENDIENTE', 73500
FROM clientes
WHERE clientes.email = 'hola@gamma.cl'
RETURNING pedido_id, cliente_id, estado, total, fecha;

-- UPDATE: actualizar la dirección de un cliente (por ID o por email)
UPDATE clientes
SET direccion = 'Av. Los Leones 1234, Providencia, RM'
WHERE email = 'ventas@acme.cl'
RETURNING cliente_id, nombre, email, direccion;

-- DELETE: eliminar un pedido que NO fue procesado (solo si está PENDIENTE)
DELETE FROM pedidos
WHERE pedido_id IN (
  SELECT pedidos.pedido_id
  FROM pedidos
  JOIN clientes ON clientes.cliente_id = pedidos.cliente_id
  WHERE clientes.nombre = 'Beta SpA'
    AND pedidos.estado = 'PENDIENTE'
  ORDER BY pedidos.fecha DESC
  LIMIT 1
)
RETURNING pedido_id, cliente_id, estado, total, fecha;

-- 4) Implementar estructuras de datos relacionales utilizando lenguaje de definición de datos (DDL)
-- Crea Tabla de empleados
CREATE TABLE empleados (
  empleado_id   BIGSERIAL PRIMARY KEY,
  nombre        VARCHAR(120) NOT NULL,
  email         VARCHAR(120) UNIQUE,
  salario       NUMERIC(12,2) NOT NULL CHECK (salario >= 0),
  fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE,
  cargo         VARCHAR(80),
  activo        BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Búsqueda/orden por nombre
CREATE INDEX IF NOT EXISTS ix_empleados_nombre ON empleados(nombre);

-- Filtro por estado activo
CREATE INDEX IF NOT EXISTS ix_empleados_activo ON empleados(activo);

-- Consultas por fecha de ingreso
CREATE INDEX IF NOT EXISTS ix_empleados_fecha_ingreso ON empleados(fecha_ingreso);

-- Agregar columna 'departamento' con valor por defecto
ALTER TABLE empleados
ADD COLUMN IF NOT EXISTS departamento VARCHAR(80) DEFAULT 'General';

-- Asegurar NOT NULL en 'cargo' (primero dar valor a posibles NULL)
UPDATE empleados SET cargo = COALESCE(cargo, 'Sin asignar');
ALTER TABLE empleados
ALTER COLUMN cargo SET NOT NULL;

-- Borrar índices de empleados
DROP INDEX IF EXISTS ix_empleados_nombre;
DROP INDEX IF EXISTS ix_empleados_activo;
DROP INDEX IF EXISTS ix_empleados_fecha_ingreso;

-- Borrar la tabla
DROP TABLE IF EXISTS empleados CASCADE;

-- 5) Elaborar un modelo de datos de acuerdo a los estándares de modelamiento
-- MODELO DE DATOS – Tienda en línea (extiende clientes/pedidos existentes) */

/* 1) PRODUCTOS */
CREATE TABLE IF NOT EXISTS productos (
  producto_id     BIGSERIAL PRIMARY KEY,
  nombre          VARCHAR(120) NOT NULL,
  sku             VARCHAR(50)  UNIQUE NOT NULL,
  precio          NUMERIC(12,2) NOT NULL CHECK (precio >= 0),
  stock           INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_productos_nombre ON productos(nombre);
CREATE INDEX IF NOT EXISTS ix_productos_activo ON productos(activo);

/* 2) DETALLE DE PEDIDOS (líneas del pedido) */
CREATE TABLE IF NOT EXISTS pedido_items (
  item_id         BIGSERIAL PRIMARY KEY,
  pedido_id       BIGINT  NOT NULL
                  REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
  producto_id     BIGINT  NOT NULL
                  REFERENCES productos(producto_id),
  cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0)
);

CREATE INDEX IF NOT EXISTS ix_pedido_items_pedido   ON pedido_items(pedido_id);
CREATE INDEX IF NOT EXISTS ix_pedido_items_producto ON pedido_items(producto_id);

/* 3) MÉTODOS DE PAGO (catálogo) */
CREATE TABLE IF NOT EXISTS metodos_pago (
  metodo_pago_id  SMALLSERIAL PRIMARY KEY,
  nombre          VARCHAR(40) UNIQUE NOT NULL,   -- TARJETA, TRANSFERENCIA, EFECTIVO, etc.
  activo          BOOLEAN NOT NULL DEFAULT TRUE
);

/* 4) PAGOS (puede haber uno o varios por pedido) */
CREATE TABLE IF NOT EXISTS pagos (
  pago_id         BIGSERIAL PRIMARY KEY,
  pedido_id       BIGINT   NOT NULL
                  REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
  metodo_pago_id  SMALLINT NOT NULL
                  REFERENCES metodos_pago(metodo_pago_id),
  monto           NUMERIC(12,2) NOT NULL CHECK (monto >= 0),
  estado          VARCHAR(20) NOT NULL
                  CHECK (estado IN ('PENDIENTE','APROBADO','RECHAZADO','ANULADO')),
  fecha           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  transaccion_ref VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS ix_pagos_pedido  ON pagos(pedido_id);
CREATE INDEX IF NOT EXISTS ix_pagos_metodo  ON pagos(metodo_pago_id);

/* (Recomendado) Índice para tus joins ya existentes */
CREATE INDEX IF NOT EXISTS ix_pedidos_cliente ON pedidos(cliente_id);



