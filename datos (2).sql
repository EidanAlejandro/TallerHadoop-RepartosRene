-- Active: 1756570385265@@127.0.0.1@5432@repartos_rene
-- =========================================
-- Geografía
-- =========================================
CREATE TABLE pais (
  pais_id      SERIAL PRIMARY KEY,
  nombre       VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE region (
  region_id    SERIAL PRIMARY KEY,
  nombre       VARCHAR(100) NOT NULL,
  pais_id      INT NOT NULL REFERENCES pais(pais_id)
);
CREATE INDEX idx_region_pais ON region(pais_id);

CREATE TABLE ciudad (
  ciudad_id    SERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  region_id    INT NOT NULL REFERENCES region(region_id)
);
CREATE INDEX idx_ciudad_region ON ciudad(region_id);

CREATE TABLE comuna (
  comuna_id    SERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  ciudad_id    INT NOT NULL REFERENCES ciudad(ciudad_id)
);
CREATE INDEX idx_comuna_ciudad ON comuna(ciudad_id);

-- =========================================
-- Direcciones y entidades
-- =========================================
CREATE TABLE direccion (
  direccion_id  SERIAL PRIMARY KEY,
  nombre        VARCHAR(120),              -- opcional: alias de dirección (ej. "Casa", "Oficina")
  calle         VARCHAR(150) NOT NULL,
  numero        VARCHAR(20),
  codigo_postal VARCHAR(20),
  comuna_id     INT NOT NULL REFERENCES comuna(comuna_id)
);
CREATE INDEX idx_direccion_comuna ON direccion(comuna_id);

CREATE TABLE cliente (
  cliente_id   SERIAL PRIMARY KEY,
  nombre       VARCHAR(80)  NOT NULL,
  apellido     VARCHAR(80)  NOT NULL,
  correo       VARCHAR(160) NOT NULL UNIQUE,
  telefono     VARCHAR(40),
  direccion_id INT REFERENCES direccion(direccion_id)
);
CREATE INDEX idx_cliente_direccion ON cliente(direccion_id);

CREATE TABLE sucursal (
  sucursal_id  SERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  direccion_id INT NOT NULL REFERENCES direccion(direccion_id)
);
CREATE INDEX idx_sucursal_direccion ON sucursal(direccion_id);

CREATE TABLE repartidor (
  repartidor_id SERIAL PRIMARY KEY,
  nombre        VARCHAR(80)  NOT NULL,
  apellido      VARCHAR(80)  NOT NULL,
  telefono      VARCHAR(40),
  sucursal_id   INT NOT NULL REFERENCES sucursal(sucursal_id)
);
CREATE INDEX idx_repartidor_sucursal ON repartidor(sucursal_id);

CREATE TABLE destinatario (
  destinatario_id SERIAL PRIMARY KEY,
  nombre          VARCHAR(80)  NOT NULL,
  apellido        VARCHAR(80)  NOT NULL,
  correo          VARCHAR(160),
  telefono        VARCHAR(40)
);

-- =========================================
-- Rutas
-- =========================================
CREATE TABLE ruta (
  ruta_id          SERIAL PRIMARY KEY,
  tipo_ruta        VARCHAR(20) NOT NULL,          -- 'terrestre','maritima','aerea','mixta'
  distancia_km     NUMERIC(10,2),
  tiempo_estimado_min INT
);

CREATE TABLE ruta_pais (
  ruta_pais_id SERIAL PRIMARY KEY,
  ruta_id      INT NOT NULL REFERENCES ruta(ruta_id) ON DELETE CASCADE,
  pais_id      INT NOT NULL REFERENCES pais(pais_id),
  -- evita duplicidad del mismo país para la misma ruta
  UNIQUE (ruta_id, pais_id)
);
CREATE INDEX idx_ruta_pais_ruta  ON ruta_pais(ruta_id);
CREATE INDEX idx_ruta_pais_pais  ON ruta_pais(pais_id);

-- =========================================
-- Órdenes de transporte
-- =========================================
CREATE TABLE orden_transporte (
  orden_transporte_id   SERIAL PRIMARY KEY,
  repartidor_id         INT REFERENCES repartidor(repartidor_id),
  cliente_id            INT NOT NULL REFERENCES cliente(cliente_id),
  direccion_id_origen   INT NOT NULL REFERENCES direccion(direccion_id),
  direccion_id_destino  INT NOT NULL REFERENCES direccion(direccion_id),
  sucursal_id           INT REFERENCES sucursal(sucursal_id),
  ruta_id               INT REFERENCES ruta(ruta_id),
  destinatario_id       INT REFERENCES destinatario(destinatario_id),
  fecha_envio           TIMESTAMP NOT NULL,
  fecha_entrega_estimada TIMESTAMP,
  estado                VARCHAR(40),               -- ej. 'creada','en_transito','entregada','cancelada'
  observacion           TEXT,
  fecha_entrega_real    TIMESTAMP                  -- añadido para medir retrasos
);
CREATE INDEX idx_ot_cliente    ON orden_transporte(cliente_id);
CREATE INDEX idx_ot_ruta       ON orden_transporte(ruta_id);
CREATE INDEX idx_ot_sucursal   ON orden_transporte(sucursal_id);
CREATE INDEX idx_ot_envio      ON orden_transporte(fecha_envio);
CREATE INDEX idx_ot_entrega    ON orden_transporte(fecha_entrega_real);


-- =========================================
-- Reseñas e inconvenientes
-- =========================================
CREATE TABLE resena (
  resena_id           SERIAL PRIMARY KEY,
  orden_transporte_id INT NOT NULL REFERENCES orden_transporte(orden_transporte_id) ON DELETE CASCADE,
  puntuacion          SMALLINT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
  comentario          TEXT,
  fecha_calificacion  TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_resena_ot   ON resena(orden_transporte_id);
CREATE INDEX idx_resena_fecha ON resena(fecha_calificacion);

CREATE TABLE inconveniente (
  inconveniente_id    SERIAL PRIMARY KEY,
  orden_transporte_id INT NOT NULL REFERENCES orden_transporte(orden_transporte_id) ON DELETE CASCADE,
  descripcion         TEXT,
  fecha_informe       TIMESTAMP NOT NULL DEFAULT NOW(),
  tipo                VARCHAR(60),         -- ej. 'retraso','danio','direccion_invalida'
  resuelto            BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_inc_ot     ON inconveniente(orden_transporte_id);
CREATE INDEX idx_inc_tipo   ON inconveniente(tipo);
CREATE INDEX idx_inc_fecha  ON inconveniente(fecha_informe);



-- LLENADO DE LA BASE DE DATOS

-- ================================
-- 1) Geografía
-- ================================
INSERT INTO pais (nombre)
VALUES ('Chile'),('Argentina'),('Peru'),('Brasil'),('Uruguay'),('Paraguay'),('Colombia'),('Mexico');

-- 3 regiones por país
INSERT INTO region (nombre, pais_id)
SELECT 'Region '||g.rn||' de '||p.nombre, p.pais_id
FROM pais p CROSS JOIN generate_series(1,3) AS g(rn);

-- 4 ciudades por región
INSERT INTO ciudad (nombre, region_id)
SELECT 'Ciudad '||g.rn||' (R'||r.region_id||')', r.region_id
FROM region r CROSS JOIN generate_series(1,4) AS g(rn);

-- 5 comunas por ciudad
INSERT INTO comuna (nombre, ciudad_id)
SELECT 'Comuna '||g.rn||' (C'||c.ciudad_id||')', c.ciudad_id
FROM ciudad c CROSS JOIN generate_series(1,5) AS g(rn);

-- ================================
-- 2) Direcciones (30k)
-- ================================
WITH pick AS (
  SELECT (SELECT min(comuna_id) FROM comuna) AS mi,
         (SELECT max(comuna_id) FROM comuna) AS mx
)
INSERT INTO direccion (nombre, calle, numero, codigo_postal, comuna_id)
SELECT
  NULL,
  'Calle '||gs,
  ((random()*999)::int)::text,
  LPAD(((random()*999999)::int)::text, 6, '0'),
  (SELECT mi + (random()*(mx-mi))::int + gs - gs FROM pick)
FROM generate_series(1,30000) gs;

-- ================================
-- 3) Sucursales (60) y Repartidores (800)
-- ================================
INSERT INTO sucursal (nombre, direccion_id)
SELECT 'Sucursal '||gs,
       (SELECT direccion_id FROM direccion ORDER BY CASE WHEN gs < 0 THEN 1 ELSE random() END LIMIT 1)
FROM generate_series(1,60) gs;

INSERT INTO repartidor (nombre, apellido, telefono, sucursal_id)
SELECT 'Rep_'||gs, 'RR_'||gs,
       '+56 9 '||LPAD(((random()*9999999)::int)::text,7,'0'),
       (SELECT sucursal_id FROM sucursal ORDER BY CASE WHEN gs < 0 THEN 1 ELSE random() END LIMIT 1)
FROM generate_series(1,800) gs;

-- ================================
-- 4) Clientes (20k) y Destinatarios (30k)
-- ================================
INSERT INTO cliente (nombre, apellido, correo, telefono, direccion_id)
SELECT
  'Nombre_'||gs, 'Apellido_'||gs,
  'user'||gs||'@correo.com',
  '+56 9 '||LPAD(((random()*9999999)::int)::text,7,'0'),
  (SELECT direccion_id FROM direccion ORDER BY CASE WHEN gs < 0 THEN 1 ELSE random() end LIMIT 1)
FROM generate_series(1,20000) gs;

INSERT INTO destinatario (nombre, apellido, correo, telefono)
SELECT
  'Dest_'||gs, 'ApDest_'||gs,
  'dest'||gs||'@mail.com',
  '+56 9 '||LPAD(((random()*9999999)::int)::text,7,'0')
FROM generate_series(1,30000) gs;

-- ================================
-- 5) Rutas (500) + países que toca cada ruta (2–4)
-- ================================
INSERT INTO ruta (tipo_ruta, distancia_km, tiempo_estimado_min)
SELECT
  (ARRAY['terrestre','maritima','aerea','mixta'])[1 + (random()*3)::int],
  floor((50 + random()*4950) * 100) / 100.0,
  60 + (random()* (10*24*60))::int    -- hasta ~10 días
FROM generate_series(1,500);

-- para elegir N países aleatorios por ruta sin duplicados
WITH rp AS (
  SELECT r.ruta_id,
         (1 + (random()*2)::int) + 1 AS n -- 2..4 países
  FROM ruta r
),
lst AS (
  SELECT ruta_id,
         (ARRAY(SELECT pais_id FROM pais ORDER BY random() LIMIT (SELECT n FROM rp WHERE rp.ruta_id = r.ruta_id))) AS arr
  FROM ruta r
)
INSERT INTO ruta_pais (ruta_id, pais_id)
SELECT ruta_id, unnest(arr) FROM lst;

-- ================================
-- 6) Órdenes (≥ 50k) con FKs válidas
-- ================================
-- Para respetar sucursal del repartidor, tomamos su sucursal.
WITH bounds AS (
  SELECT (SELECT min(repartidor_id) FROM repartidor) AS rep_min,
         (SELECT max(repartidor_id) FROM repartidor) AS rep_max,
         (SELECT min(cliente_id)    FROM cliente)    AS cli_min,
         (SELECT max(cliente_id)    FROM cliente)    AS cli_max,
         (SELECT min(direccion_id)  FROM direccion)  AS dir_min,
         (SELECT max(direccion_id)  FROM direccion)  AS dir_max,
         (SELECT min(ruta_id)       FROM ruta)       AS ruta_min,
         (SELECT max(ruta_id)       FROM ruta)       AS ruta_max,
         (SELECT min(destinatario_id) FROM destinatario) AS des_min,
         (SELECT max(destinatario_id) FROM destinatario) AS des_max
),
rnd AS (
  SELECT
    (SELECT rep_min + (random()*(rep_max-rep_min))::int + gs - gs FROM bounds) AS repartidor_id,
    (SELECT cli_min + (random()*(cli_max-cli_min))::int + gs - gs FROM bounds) AS cliente_id,
    (SELECT dir_min + (random()*(dir_max-dir_min))::int + gs - gs FROM bounds) AS d1,
    (SELECT dir_min + (random()*(dir_max-dir_min))::int + gs - gs FROM bounds) AS d2,
    (SELECT ruta_min + (random()*(ruta_max-ruta_min))::int + gs - gs FROM bounds) AS ruta_id,
    (SELECT des_min  + (random()*(des_max-des_min))::int + gs - gs FROM bounds) AS destinatario_id,
    ts
  FROM (
    SELECT timestamp '2024-01-01'
           + ((random() * (365*24))::int) * interval '1 hour' AS ts, gs
    FROM generate_series(1,50000) gs
  ) t
)
INSERT INTO orden_transporte (
  repartidor_id, cliente_id, direccion_id_origen, direccion_id_destino,
  sucursal_id, ruta_id, destinatario_id,
  fecha_envio, fecha_entrega_estimada, fecha_entrega_real, estado, observacion
)
SELECT
  r.repartidor_id,
  r.cliente_id,
  r.d1, r.d2,
  (SELECT sucursal_id FROM repartidor rep WHERE rep.repartidor_id = r.repartidor_id),
  r.ruta_id,
  r.destinatario_id,
  r.ts,
  r.ts + interval '3 day',
  r.ts + interval '3 day' + (random()*240 || ' minutes')::interval,  -- 0..4h extra
  'entregada',
  CASE WHEN random() < 0.1 THEN 'Prioritaria' ELSE NULL END
FROM rnd r;

-- ================================
-- 7) Reseñas (≈ 65% de las órdenes)
-- ================================
INSERT INTO resena (orden_transporte_id, puntuacion, comentario, fecha_calificacion)
SELECT ot.orden_transporte_id,
       1 + (random()*4)::int,
       CASE WHEN random() < 0.25 THEN 'Comentario '||ot.orden_transporte_id ELSE NULL END,
       ot.fecha_entrega_real + (random()*1440 || ' minutes')::interval
FROM orden_transporte ot
WHERE random() < 0.65;

-- ================================
-- 8) Inconvenientes (≈ 18% de las órdenes)
-- ================================
INSERT INTO inconveniente (orden_transporte_id, descripcion, fecha_informe, tipo, resuelto)
SELECT ot.orden_transporte_id,
       (ARRAY['Retraso por clima','Paquete daniado','Direccion incompleta','Falla transporte'])[1 + (random()*3)::int],
       ot.fecha_envio + (random()* (48*60) || ' minutes')::interval,
       (ARRAY['retraso','danio','direccion_invalida','operativo'])[1 + (random()*3)::int],
       (random() < 0.7)
FROM orden_transporte ot
WHERE random() < 0.18;
