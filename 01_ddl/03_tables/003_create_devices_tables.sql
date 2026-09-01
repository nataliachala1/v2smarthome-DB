-- ============================================================
-- TABLAS — Esquema devices
-- Archivo: 01_ddl/03_tables/004_create_devices_tables.sql
-- Descripción: Dispositivos IoT, horarios automáticos,
--              umbrales de consumo, historial y telemetría cruda,
--              alineado con el alcance actualizado (ago-2026).
-- Cambios respecto a la versión anterior:
--   - Eliminadas devices.manual_device y devices.voice_assistant_token (fuera de alcance)
--   - id_area -> id_zone (referencia homes.zone)
--   - estado dividido en: status (ciclo de vida), connectivity_status, is_on
--   - protocolo dividido en: transport_type (wifi/bluetooth) y messaging_protocol (mqtt)
--   - mac_address -> manufacturer_device_id (genérico, no acoplado a formato MAC)
--   - Columnas en inglés snake_case
-- Dependencias: 00_extensions, 01_schemas, auth.user, homes.home, homes.zone
-- ============================================================

-- ============================================================
-- TABLA: devices.device_type
-- Catálogo de tipos de dispositivos disponibles en el sistema.
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.device_type (
  id_device_type UUID         NOT NULL DEFAULT gen_random_uuid(),
  name           VARCHAR(100) NOT NULL,
  description    TEXT         NULL,
  icon           VARCHAR(100) NULL,
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at     TIMESTAMPTZ  NULL,

  CONSTRAINT pk_device_type      PRIMARY KEY (id_device_type),
  CONSTRAINT uq_device_type_name UNIQUE (name)
);

-- ============================================================
-- TABLA: devices.device
-- Dispositivo IoT registrado. Pertenece obligatoriamente a una
-- zona (alcance §4: "Un dispositivo debe estar asociado a una zona").
-- El hogar se conserva como columna redundante controlada por FK
-- compuesta (id_zone, id_home) para performance de RLS.
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.device (
  id_device               UUID          NOT NULL DEFAULT gen_random_uuid(),
  id_home                 UUID          NOT NULL,
  id_zone                 UUID          NOT NULL,
  id_device_type          UUID          NOT NULL,
  name                    VARCHAR(100)  NOT NULL,
  status                  VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
  connectivity_status     VARCHAR(20)   NOT NULL DEFAULT 'OFFLINE',
  is_on                   BOOLEAN       NOT NULL DEFAULT FALSE,
  current_power_w         NUMERIC(10,2) NULL,
  manufacturer_device_id  VARCHAR(100)  NULL,
  transport_type          VARCHAR(20)   NULL,
  messaging_protocol      VARCHAR(20)   NULL,
  created_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at              TIMESTAMPTZ   NULL,

  CONSTRAINT pk_device                     PRIMARY KEY (id_device),
  CONSTRAINT uq_device_name                UNIQUE (id_home, name),
  CONSTRAINT uq_device_manufacturer_id     UNIQUE (manufacturer_device_id),
  CONSTRAINT ck_device_status              CHECK (status IN ('ACTIVE', 'DEACTIVATED')),
  CONSTRAINT ck_device_connectivity_status CHECK (connectivity_status IN ('ONLINE', 'OFFLINE')),
  CONSTRAINT ck_device_transport_type      CHECK (
    transport_type IS NULL OR transport_type IN ('WIFI', 'BLUETOOTH')
  ),
  CONSTRAINT ck_device_messaging_protocol  CHECK (
    messaging_protocol IS NULL OR messaging_protocol IN ('MQTT')
  ),
  CONSTRAINT ck_device_current_power       CHECK (current_power_w IS NULL OR current_power_w >= 0),

  -- FK compuesta: garantiza que la zona pertenezca al mismo hogar (alcance §4)
  CONSTRAINT fk_device_zone_home
    FOREIGN KEY (id_zone, id_home) REFERENCES homes.zone (id_zone, id_home)
);

-- ============================================================
-- TABLA: devices.smart_device
-- Datos extendidos de fabricante/modelo. Se mantiene genérico
-- (no acoplado a Shelly) según alcance §3 y §13.
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.smart_device (
  id_smart_device   UUID          NOT NULL DEFAULT gen_random_uuid(),
  id_device         UUID          NOT NULL,
  manufacturer      VARCHAR(100)  NULL,
  model             VARCHAR(100)  NULL,
  firmware_version  VARCHAR(50)   NULL,
  max_capacity_w    NUMERIC(10,2) NULL,
  supports_matter   BOOLEAN       NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_smart_device        PRIMARY KEY (id_smart_device),
  CONSTRAINT uq_smart_device_device UNIQUE (id_device),
  CONSTRAINT ck_smart_device_max_capacity CHECK (max_capacity_w IS NULL OR max_capacity_w > 0)
);

-- ============================================================
-- TABLA: devices.device_schedule
-- Horarios automáticos de encendido/apagado.
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.device_schedule (
  id_device_schedule    UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_device      UUID        NOT NULL,
  action         VARCHAR(10) NOT NULL,
  time_of_day    TIME        NOT NULL,
  days_of_week   SMALLINT[]  NOT NULL,
  is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at     TIMESTAMPTZ NULL,

  CONSTRAINT pk_device_schedule        PRIMARY KEY (id_device_schedule),
  CONSTRAINT ck_device_schedule_action CHECK (action IN ('ON', 'OFF'))
);



-- ============================================================
-- TABLA: devices.device_telemetry_raw
-- Payload crudo del dispositivo (JSONB) para diagnóstico.
-- Los campos operacionalmente relevantes se normalizan en
-- consumption.consumption (Grupo 4).
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.device_telemetry_raw (
  id_device_telemetry_raw UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_device               UUID        NOT NULL,
  payload                 JSONB       NOT NULL,
  captured_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_device_telemetry_raw PRIMARY KEY (id_device_telemetry_raw)
);