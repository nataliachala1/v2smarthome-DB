-- ============================================================
-- TABLAS — Esquema consumption
-- Archivo: 01_ddl/03_tables/005_create_consumption_tables.sql
-- Descripción: Creación de las 3 tablas del esquema consumption
--              para gestión de lecturas de consumo energético
--              en tiempo real, métricas agregadas y
-- Dependencias: 00_extensions, 01_schemas, auth.user,
--               homes.home, devices.device
-- ============================================================

-- ============================================================
-- TABLA: consumption.consumption
-- Descripción: Almacena las lecturas de consumo eléctrico
--              en tiempo real de cada dispositivo.
--              Esta tabla puede crecer muy rápidamente,
--              se recomienda particionar por mes
-- Referencia SRS: RF4.1, RF4.2, RNF1.5
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption.consumption (
  id_consumption   UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_device        UUID          NOT NULL,
  id_home          UUID          NOT NULL,
  watts            NUMERIC(10,4) NOT NULL,
  kwh_acumulado    NUMERIC(12,6) NOT NULL DEFAULT 0,
  costo_estimado   NUMERIC(12,4) NULL,
  fecha_lectura    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_consumption          PRIMARY KEY (id_consumption),
  CONSTRAINT ck_consumption_watts    CHECK (watts >= 0),
  CONSTRAINT ck_consumption_kwh      CHECK (kwh_acumulado >= 0),
  CONSTRAINT ck_consumption_costo    CHECK (costo_estimado IS NULL OR costo_estimado >= 0)
);

-- ============================================================
-- TABLA: consumption.consumption_metric
-- Descripción: Métricas agregadas de consumo por periodo
--              para optimizar gráficos y reportes sin
--              consultar lecturas individuales
-- Referencia SRS: RF4.2, RF4.3, RF4.1
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption.consumption_metric (
  id_consumption_metric UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_device             UUID          NOT NULL,
  id_home               UUID          NOT NULL,
  periodo               VARCHAR(10)   NOT NULL,
  fecha_inicio          TIMESTAMPTZ   NOT NULL,
  fecha_fin             TIMESTAMPTZ   NOT NULL,
  kwh_total             NUMERIC(12,6) NOT NULL DEFAULT 0,
  costo_total           NUMERIC(12,4) NULL,
  watts_promedio        NUMERIC(10,4) NULL,
  watts_maximo          NUMERIC(10,4) NULL,
  watts_minimo          NUMERIC(10,4) NULL,
  created_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_consumption_metric          PRIMARY KEY (id_consumption_metric),
  CONSTRAINT uq_consumption_metric          UNIQUE (id_device, periodo, fecha_inicio),
  CONSTRAINT ck_consumption_metric_periodo  CHECK (periodo IN ('hora', 'dia', 'semana', 'mes')),
  CONSTRAINT ck_consumption_metric_fechas   CHECK (fecha_fin > fecha_inicio),
  CONSTRAINT ck_consumption_metric_kwh      CHECK (kwh_total >= 0),
  CONSTRAINT ck_consumption_metric_costo    CHECK (costo_total IS NULL OR costo_total >= 0),
  CONSTRAINT ck_consumption_metric_watts    CHECK (
    (watts_promedio IS NULL OR watts_promedio >= 0) AND
    (watts_maximo   IS NULL OR watts_maximo   >= 0) AND
    (watts_minimo   IS NULL OR watts_minimo   >= 0)
  ),
  CONSTRAINT ck_consumption_metric_max_min  CHECK (
    watts_maximo IS NULL OR
    watts_minimo IS NULL OR
    watts_maximo >= watts_minimo
  )
);

-- ============================================================
-- TABLA: consumption.recommendation
-- Descripción: Recomendaciones de ahorro energético generadas
--              automáticamente por el sistema para cada hogar
--              basadas en análisis del consumo histórico
-- Referencia SRS: RF4.4, RF4.4.1
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption.recommendation (
  id_recommendation      UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_home                UUID          NOT NULL,
  id_device              UUID          NULL,
  titulo                 VARCHAR(200)  NOT NULL,
  descripcion            TEXT          NOT NULL,
  ahorro_estimado_kwh    NUMERIC(10,4) NULL,
  ahorro_estimado_costo  NUMERIC(12,4) NULL,
  prioridad              VARCHAR(10)   NOT NULL DEFAULT 'media',
  estado                 VARCHAR(20)   NOT NULL DEFAULT 'pendiente',
  created_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at             TIMESTAMPTZ   NULL,

  CONSTRAINT pk_recommendation          PRIMARY KEY (id_recommendation),
  CONSTRAINT ck_recommendation_prioridad CHECK (prioridad IN ('alta', 'media', 'baja')),
  CONSTRAINT ck_recommendation_estado   CHECK (estado IN ('pendiente', 'implementada', 'descartada')),
  CONSTRAINT ck_recommendation_ahorro_kwh  CHECK (ahorro_estimado_kwh  IS NULL OR ahorro_estimado_kwh  > 0),
  CONSTRAINT ck_recommendation_ahorro_cost CHECK (ahorro_estimado_costo IS NULL OR ahorro_estimado_costo > 0)
);