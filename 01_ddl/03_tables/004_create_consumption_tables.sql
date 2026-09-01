-- ============================================================
-- TABLAS — Esquema consumption
-- Archivo: 01_ddl/03_tables/005_create_consumption_tables.sql
-- Descripción: Creación de las 3 tablas del esquema consumption
--              para gestión de lecturas de consumo energético
--              en tiempo real (particionada por mes), métricas
--              agregadas y recomendaciones de ahorro.
-- Dependencias: 00_extensions, 01_schemas, auth.user,
--               homes.home, devices.device
-- ============================================================

-- ============================================================
-- TABLA: consumption.consumption
-- Descripción: Lecturas de consumo eléctrico en tiempo real
--              de cada dispositivo. Particionada por rango
--              mensual sobre read_at (Paso 8 de la auditoría).
--
--   power_w           -> potencia instantánea de la lectura
--   energy_delta_kwh  -> energía consumida SOLO en este
--                        intervalo (desde la lectura anterior).
--                        Es la columna que se debe SUMAR en
--                        reportes y materialized views.
--   energy_total_kwh  -> contador crudo acumulado que reporta
--                        el dispositivo físico (si lo entrega).
--                        Uso exclusivamente diagnóstico; NUNCA
--                        se debe sumar en agregados.
--
-- Referencia SRS: RF4.1, RF4.2, RNF1.5
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption.consumption (
  id_consumption    UUID          NOT NULL DEFAULT gen_random_uuid(),
  id_device         UUID          NOT NULL,
  id_home           UUID          NOT NULL,
  power_w           NUMERIC(10,4) NOT NULL,
  energy_delta_kwh  NUMERIC(12,6) NOT NULL DEFAULT 0,
  energy_total_kwh  NUMERIC(14,6) NULL,
  estimated_cost    NUMERIC(12,4) NULL,
  read_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_consumption           PRIMARY KEY (id_consumption, read_at),
  CONSTRAINT ck_consumption_power     CHECK (power_w >= 0),
  CONSTRAINT ck_consumption_delta     CHECK (energy_delta_kwh >= 0),
  CONSTRAINT ck_consumption_total     CHECK (energy_total_kwh IS NULL OR energy_total_kwh >= 0),
  CONSTRAINT ck_consumption_costo     CHECK (estimated_cost IS NULL OR estimated_cost >= 0)
) PARTITION BY RANGE (read_at);

-- Nota: id_consumption ya no es único por sí solo (requisito de
-- Postgres para tablas particionadas: la clave de partición debe
-- estar incluida en toda PK/UNIQUE). Si algún servicio necesita
-- id_consumption como referencia única global, generar el UUID
-- en la aplicación y tratarlo como identificador lógico, no como
-- FK entrante desde otra tabla.

-- Índices sobre la tabla padre: Postgres los propaga
-- automáticamente a cada partición existente y futura.
CREATE INDEX IF NOT EXISTS idx_consumption_id_device ON consumption.consumption (id_device);
CREATE INDEX IF NOT EXISTS idx_consumption_id_home    ON consumption.consumption (id_home);
CREATE INDEX IF NOT EXISTS idx_consumption_read_at    ON consumption.consumption (read_at);

-- Partición por defecto: red de seguridad para filas cuyo
-- read_at caiga fuera de las particiones mensuales creadas
-- (ej. relojes desincronizados, datos de prueba). Sin esto,
-- un INSERT fuera de rango falla en vez de quedar registrado.
CREATE TABLE IF NOT EXISTS consumption.consumption_default
  PARTITION OF consumption.consumption DEFAULT;

-- ============================================================
-- TABLA: consumption.consumption_metric
-- Descripción: Métricas agregadas de consumo por periodo
--              para optimizar gráficos y reportes sin
--              consultar lecturas individuales.
--              kwh_total se calcula sumando energy_delta_kwh
--              de las lecturas del periodo (ver 07_functions).
-- Referencia SRS: RF4.2, RF4.3, RF4.1
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption.consumption_metric (
  id_consumption_metric UUID          NOT NULL DEFAULT gen_random_uuid(),
  id_device             UUID          NOT NULL,
  id_home               UUID          NOT NULL,
  period               VARCHAR(10)   NOT NULL,
  start_at          TIMESTAMPTZ   NOT NULL,
  end_at             TIMESTAMPTZ   NOT NULL,
  kwh_total             NUMERIC(12,6) NOT NULL DEFAULT 0,
  total_cost           NUMERIC(12,4) NULL,
  average_watts        NUMERIC(10,4) NULL,
  max_watts          NUMERIC(10,4) NULL,
  min_watts          NUMERIC(10,4) NULL,
  created_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_consumption_metric          PRIMARY KEY (id_consumption_metric),
  CONSTRAINT uq_consumption_metric          UNIQUE (id_device, period, start_at),
  CONSTRAINT ck_consumption_metric_periodo  CHECK (period IN ('hora', 'dia', 'semana', 'mes')),
  CONSTRAINT ck_consumption_metric_fechas   CHECK (end_at > start_at),
  CONSTRAINT ck_consumption_metric_kwh      CHECK (kwh_total >= 0),
  CONSTRAINT ck_consumption_metric_costo    CHECK (total_cost IS NULL OR total_cost >= 0),
  CONSTRAINT ck_consumption_metric_watts    CHECK (
    (average_watts IS NULL OR average_watts >= 0) AND
    (max_watts   IS NULL OR max_watts   >= 0) AND
    (min_watts   IS NULL OR min_watts   >= 0)
  ),
  CONSTRAINT ck_consumption_metric_max_min  CHECK (
    max_watts IS NULL OR
    min_watts IS NULL OR
    max_watts >= min_watts
  )
);

-- ============================================================
-- TABLA: consumption.recommendation
-- Sin cambios respecto a la versión anterior: no presenta
-- observaciones de la auditoría (RF4.4, RF4.4.1).
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption.recommendation (
  id_recommendation      UUID          NOT NULL DEFAULT gen_random_uuid(),
  id_home                UUID          NOT NULL,
  id_device              UUID          NULL,
  title                 VARCHAR(200)  NOT NULL,
  description            TEXT          NOT NULL,
  estimated_savings_kwh    NUMERIC(10,4) NULL,
  estimated_savings_cost  NUMERIC(12,4) NULL,
  priority              VARCHAR(10)   NOT NULL DEFAULT 'media',
  status                 VARCHAR(20)   NOT NULL DEFAULT 'pendiente',
  created_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at             TIMESTAMPTZ   NULL,

  CONSTRAINT pk_recommendation           PRIMARY KEY (id_recommendation),
  CONSTRAINT ck_recommendation_prioridad CHECK (priority IN ('alta', 'media', 'baja')),
  CONSTRAINT ck_recommendation_estado    CHECK (status IN ('pendiente', 'implementada', 'descartada')),
  CONSTRAINT ck_recommendation_ahorro_kwh  CHECK (estimated_savings_kwh  IS NULL OR estimated_savings_kwh  > 0),
  CONSTRAINT ck_recommendation_ahorro_cost CHECK (estimated_savings_cost IS NULL OR estimated_savings_cost > 0)
);