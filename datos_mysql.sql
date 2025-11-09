-- =========================================================
-- Esquema base (opcional)
-- =========================================================
-- CREATE DATABASE IF NOT EXISTS repartos_rene CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE repartos_rene;

-- =========================================================
-- Geografía
-- =========================================================
CREATE TABLE pais (
  pais_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE region (
  region_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(100) NOT NULL,
  pais_id   INT UNSIGNED NOT NULL,
  KEY idx_region_pais (pais_id),
  CONSTRAINT fk_region_pais FOREIGN KEY (pais_id) REFERENCES pais(pais_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ciudad (
  ciudad_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(120) NOT NULL,
  region_id INT UNSIGNED NOT NULL,
  KEY idx_ciudad_region (region_id),
  CONSTRAINT fk_ciudad_region FOREIGN KEY (region_id) REFERENCES region(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE comuna (
  comuna_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(120) NOT NULL,
  ciudad_id INT UNSIGNED NOT NULL,
  KEY idx_comuna_ciudad (ciudad_id),
  CONSTRAINT fk_comuna_ciudad FOREIGN KEY (ciudad_id) REFERENCES ciudad(ciudad_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Direcciones y entidades
-- =========================================================
CREATE TABLE direccion (
  direccion_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(120),             -- alias: "Casa", "Oficina", etc.
  calle         VARCHAR(150) NOT NULL,
  numero        VARCHAR(20),
  codigo_postal VARCHAR(20),
  comuna_id     INT UNSIGNED NOT NULL,
  KEY idx_direccion_comuna (comuna_id),
  CONSTRAINT fk_direccion_comuna FOREIGN KEY (comuna_id) REFERENCES comuna(comuna_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cliente (
  cliente_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(80)  NOT NULL,
  apellido     VARCHAR(80)  NOT NULL,
  correo       VARCHAR(160) NOT NULL UNIQUE,
  telefono     VARCHAR(40),
  direccion_id INT UNSIGNED,
  KEY idx_cliente_direccion (direccion_id),
  CONSTRAINT fk_cliente_direccion FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sucursal (
  sucursal_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  direccion_id INT UNSIGNED NOT NULL,
  KEY idx_sucursal_direccion (direccion_id),
  CONSTRAINT fk_sucursal_direccion FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE repartidor (
  repartidor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80) NOT NULL,
  apellido      VARCHAR(80) NOT NULL,
  telefono      VARCHAR(40),
  sucursal_id   INT UNSIGNED NOT NULL,
  KEY idx_repartidor_sucursal (sucursal_id),
  CONSTRAINT fk_repartidor_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursal(sucursal_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE destinatario (
  destinatario_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(80) NOT NULL,
  apellido        VARCHAR(80) NOT NULL,
  correo          VARCHAR(160),
  telefono        VARCHAR(40)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Rutas
-- =========================================================
CREATE TABLE ruta (
  ruta_id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tipo_ruta           VARCHAR(20) NOT NULL,  -- 'terrestre','maritima','aerea','mixta'
  distancia_km        DECIMAL(10,2),
  tiempo_estimado_min INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ruta_pais (
  ruta_pais_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ruta_id      INT UNSIGNED NOT NULL,
  pais_id      INT UNSIGNED NOT NULL,
  UNIQUE KEY uq_ruta_pais (ruta_id, pais_id),
  KEY idx_ruta_pais_ruta (ruta_id),
  KEY idx_ruta_pais_pais (pais_id),
  CONSTRAINT fk_ruta_pais_ruta FOREIGN KEY (ruta_id) REFERENCES ruta(ruta_id) ON DELETE CASCADE,
  CONSTRAINT fk_ruta_pais_pais FOREIGN KEY (pais_id) REFERENCES pais(pais_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Órdenes
-- =========================================================
CREATE TABLE orden_transporte (
  orden_transporte_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  repartidor_id         INT UNSIGNED,
  cliente_id            INT UNSIGNED NOT NULL,
  direccion_id_origen   INT UNSIGNED NOT NULL,
  direccion_id_destino  INT UNSIGNED NOT NULL,
  sucursal_id           INT UNSIGNED,
  ruta_id               INT UNSIGNED,
  destinatario_id       INT UNSIGNED,
  fecha_envio           DATETIME NOT NULL,
  fecha_entrega_estimada DATETIME,
  estado                VARCHAR(40),
  observacion           TEXT,
  fecha_entrega_real    DATETIME,
  KEY idx_ot_cliente   (cliente_id),
  KEY idx_ot_ruta      (ruta_id),
  KEY idx_ot_sucursal  (sucursal_id),
  KEY idx_ot_envio     (fecha_envio),
  KEY idx_ot_entrega   (fecha_entrega_real),
  CONSTRAINT fk_ot_repartidor   FOREIGN KEY (repartidor_id)        REFERENCES repartidor(repartidor_id),
  CONSTRAINT fk_ot_cliente      FOREIGN KEY (cliente_id)           REFERENCES cliente(cliente_id),
  CONSTRAINT fk_ot_dir_origen   FOREIGN KEY (direccion_id_origen)  REFERENCES direccion(direccion_id),
  CONSTRAINT fk_ot_dir_destino  FOREIGN KEY (direccion_id_destino) REFERENCES direccion(direccion_id),
  CONSTRAINT fk_ot_sucursal     FOREIGN KEY (sucursal_id)          REFERENCES sucursal(sucursal_id),
  CONSTRAINT fk_ot_ruta         FOREIGN KEY (ruta_id)              REFERENCES ruta(ruta_id),
  CONSTRAINT fk_ot_destinatario FOREIGN KEY (destinatario_id)      REFERENCES destinatario(destinatario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Reseñas e inconvenientes
-- =========================================================
CREATE TABLE resena (
  resena_id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  orden_transporte_id INT UNSIGNED NOT NULL,
  puntuacion          TINYINT UNSIGNED NOT NULL,  -- valida 1..5 en app/proceso
  comentario          TEXT,
  fecha_calificacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_resena_ot (orden_transporte_id),
  KEY idx_resena_fecha (fecha_calificacion),
  CONSTRAINT fk_resena_ot FOREIGN KEY (orden_transporte_id)
    REFERENCES orden_transporte(orden_transporte_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inconveniente (
  inconveniente_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  orden_transporte_id INT UNSIGNED NOT NULL,
  descripcion         TEXT,
  fecha_informe       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo                VARCHAR(60),
  resuelto            TINYINT(1) NOT NULL DEFAULT 0,
  KEY idx_inc_ot (orden_transporte_id),
  KEY idx_inc_tipo (tipo),
  KEY idx_inc_fecha (fecha_informe),
  CONSTRAINT fk_inc_ot FOREIGN KEY (orden_transporte_id)
    REFERENCES orden_transporte(orden_transporte_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;




-- ACA COMENZAMOS A LLENAR LA DB
-- Aumentar el tope de recursión de CTEs
SET SESSION cte_max_recursion_depth = 60000;

-- ================================
-- 1) Países
-- ================================
INSERT INTO pais (nombre)
VALUES ('Chile'),('Argentina'),('Peru'),('Brasil'),('Uruguay'),('Paraguay'),('Colombia'),('Mexico');

-- ================================
-- 2) Regiones (3 por país)
-- ================================
INSERT INTO region (nombre, pais_id)
SELECT CONCAT('Region ', r.rn, ' de ', p.nombre) AS nombre, p.pais_id
FROM pais p
JOIN (SELECT 1 rn UNION ALL SELECT 2 UNION ALL SELECT 3) r;

-- ================================
-- 3) Ciudades (4 por región)
-- ================================
INSERT INTO ciudad (nombre, region_id)
SELECT CONCAT('Ciudad ', c.rn, ' (R', r.region_id, ')'), r.region_id
FROM region r
JOIN (SELECT 1 rn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) c;

-- ================================
-- 4) Comunas (5 por ciudad)
-- ================================
INSERT INTO comuna (nombre, ciudad_id)
SELECT CONCAT('Comuna ', k.rn, ' (C', c.ciudad_id, ')'), c.ciudad_id
FROM ciudad c
JOIN (SELECT 1 rn UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) k;

-- ================================
-- 5) Direcciones (30k) con CTE recursivo
-- ================================
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 30000
)
INSERT INTO direccion (nombre, calle, numero, codigo_postal, comuna_id)
SELECT
  NULL,
  CONCAT('Calle ', n),
  LPAD(FLOOR(RAND()*999), 1, '0'),
  LPAD(FLOOR(RAND()*999999), 6, '0'),
  (SELECT comuna_id FROM comuna ORDER BY RAND() LIMIT 1)
FROM seq;

-- ================================
-- 6) Sucursales (60) y Repartidores (800)
-- ================================
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 60
)
INSERT INTO sucursal (nombre, direccion_id)
SELECT CONCAT('Sucursal ', n),
       (SELECT direccion_id FROM direccion ORDER BY RAND() LIMIT 1)
FROM seq;

WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 800
)
INSERT INTO repartidor (nombre, apellido, telefono, sucursal_id)
SELECT CONCAT('Rep_', n), CONCAT('RR_', n),
       CONCAT('+56 9 ', LPAD(FLOOR(RAND()*9999999), 7, '0')),
       (SELECT sucursal_id FROM sucursal ORDER BY RAND() LIMIT 1)
FROM seq;

-- ================================
-- 7) Clientes (20k) y Destinatarios (30k)
-- ================================
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 20000
)
INSERT INTO cliente (nombre, apellido, correo, telefono, direccion_id)
SELECT CONCAT('Nombre_', n), CONCAT('Apellido_', n),
       CONCAT('user', n, '@correo.com'),
       CONCAT('+56 9 ', LPAD(FLOOR(RAND()*9999999), 7, '0')),
       (SELECT direccion_id FROM direccion ORDER BY RAND() LIMIT 1)
FROM seq;

WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 30000
)
INSERT INTO destinatario (nombre, apellido, correo, telefono)
SELECT CONCAT('Dest_', n), CONCAT('ApDest_', n),
       CONCAT('dest', n, '@mail.com'),
       CONCAT('+56 9 ', LPAD(FLOOR(RAND()*9999999), 7, '0'))
FROM seq;

-- ================================
-- 8) Rutas (500)
-- ================================
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 500
)
INSERT INTO ruta (tipo_ruta, distancia_km, tiempo_estimado_min)
SELECT
  ELT(1 + FLOOR(RAND()*4), 'terrestre','maritima','aerea','mixta'),
  ROUND(50 + RAND()*4950, 2),
  60 + FLOOR(RAND() * (10*24*60))
FROM seq;

-- ================================
-- 9) Países por ruta (2–4 distintos por ruta)
--     Insertamos 3 veces con IGNORE para evitar duplicados.
-- ================================
-- 1ª vuelta
INSERT IGNORE INTO ruta_pais (ruta_id, pais_id)
SELECT r.ruta_id,
       (SELECT pais_id FROM pais ORDER BY RAND() LIMIT 1)
FROM ruta r;

-- 2ª vuelta
INSERT IGNORE INTO ruta_pais (ruta_id, pais_id)
SELECT r.ruta_id,
       (SELECT pais_id FROM pais ORDER BY RAND() LIMIT 1)
FROM ruta r;

-- 3ª vuelta (con probabilidad ~50% para llegar a 3–4 países)
INSERT IGNORE INTO ruta_pais (ruta_id, pais_id)
SELECT r.ruta_id,
       (SELECT pais_id FROM pais ORDER BY RAND() LIMIT 1)
FROM ruta r
WHERE RAND() < 0.5;

-- ================================
-- 10) Órdenes (50k)
-- ================================
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 50000
),
ts AS (
  SELECT
    TIMESTAMPADD(
      HOUR,
      FLOOR(RAND()* (365*24)),
      TIMESTAMP('2024-01-01 00:00:00')
    ) AS ts,
    n
  FROM seq
)
INSERT INTO orden_transporte (
  repartidor_id, cliente_id, direccion_id_origen, direccion_id_destino,
  sucursal_id, ruta_id, destinatario_id,
  fecha_envio, fecha_entrega_estimada, fecha_entrega_real,
  estado, observacion
)
SELECT
  (SELECT repartidor_id FROM repartidor ORDER BY RAND() LIMIT 1) AS repartidor_id,
  (SELECT cliente_id    FROM cliente    ORDER BY RAND() LIMIT 1) AS cliente_id,
  (SELECT direccion_id  FROM direccion  ORDER BY RAND() LIMIT 1) AS dir_origen,
  (SELECT direccion_id  FROM direccion  ORDER BY RAND() LIMIT 1) AS dir_destino,
  (SELECT sucursal_id   FROM sucursal   ORDER BY RAND() LIMIT 1) AS sucursal_id,
  (SELECT ruta_id       FROM ruta       ORDER BY RAND() LIMIT 1) AS ruta_id,
  (SELECT destinatario_id FROM destinatario ORDER BY RAND() LIMIT 1) AS destinatario_id,
  ts.ts                                         AS fecha_envio,
  DATE_ADD(ts.ts, INTERVAL 3 DAY)               AS fecha_entrega_estimada,
  DATE_ADD(ts.ts, INTERVAL 3 DAY + FLOOR(RAND()*240) MINUTE) AS fecha_entrega_real,
  'entregada' AS estado,
  CASE WHEN RAND() < 0.1 THEN 'Prioritaria' ELSE NULL END AS observacion
FROM ts;

-- ================================
-- 11) Reseñas (~65% de órdenes)
-- ================================
INSERT INTO resena (orden_transporte_id, puntuacion, comentario, fecha_calificacion)
SELECT ot.orden_transporte_id,
       1 + FLOOR(RAND()*5),
       CASE WHEN RAND() < 0.25 THEN CONCAT('Comentario ', ot.orden_transporte_id) ELSE NULL END,
       DATE_ADD(ot.fecha_entrega_real, INTERVAL FLOOR(RAND()*1440) MINUTE)
FROM orden_transporte ot
WHERE RAND() < 0.65;

-- ================================
-- 12) Inconvenientes (~18% de órdenes)
-- ================================
INSERT INTO inconveniente (orden_transporte_id, descripcion, fecha_informe, tipo, resuelto)
SELECT ot.orden_transporte_id,
       ELT(1 + FLOOR(RAND()*4), 'Retraso por clima','Paquete daniado','Direccion incompleta','Falla transporte') AS descripcion,
       DATE_ADD(ot.fecha_envio, INTERVAL FLOOR(RAND()*(48*60)) MINUTE) AS fecha_informe,
       ELT(1 + FLOOR(RAND()*4), 'retraso','danio','direccion_invalida','operativo') AS tipo,
       (RAND() < 0.7) AS resuelto
FROM orden_transporte ot
WHERE RAND() < 0.18;
