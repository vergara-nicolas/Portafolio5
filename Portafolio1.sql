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

