-- ============================================================
-- TABLAS — Esquema devices
-- Archivo: 01_ddl/03_tables/004_create_devices_tables.sql
-- Descripción: Creación de las 7 tablas del esquema devices
--              para gestión de dispositivos IoT, horarios
--              automáticos, umbrales de consumo e historial
-- Dependencias: 00_extensions, 01_schemas, auth.user,
--               homes.home, homes.area
-- ============================================================

-- ============================================================
-- TABLA: devices.type_device
-- Descripción: Catálogo de tipos de dispositivos disponibles
--              en el sistema Smart Home
-- Referencia SRS: RF3.1
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.type_device (
  id_type_device UUID         NOT NULL DEFAULT uuid_generate_v4(),
  nombre         VARCHAR(100) NOT NULL,
  descripcion    TEXT         NULL,
  icono          VARCHAR(100) NULL,
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at     TIMESTAMPTZ  NULL,

  CONSTRAINT pk_type_device       PRIMARY KEY (id_type_device),
  CONSTRAINT uq_type_device_nombre UNIQUE (nombre)
);

-- ============================================================
-- TABLA: devices.device
-- Descripción: Almacena los dispositivos inteligentes o
--              sensores registrados, vinculados a un hogar
--              y zona específica
-- Referencia SRS: RF3.1, RF3.2, RF3.3, RF3.4, RF3.5
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.device (
  id_device        UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_home          UUID          NOT NULL,
  id_area          UUID          NULL,
  id_type_device   UUID          NOT NULL,
  nombre           VARCHAR(100)  NOT NULL,
  estado           VARCHAR(20)   NOT NULL DEFAULT 'desconectado',
  encendido        BOOLEAN       NOT NULL DEFAULT FALSE,
  consumo_actual_w NUMERIC(10,2) NULL,
  mac_address      VARCHAR(17)   NULL,
  protocolo        VARCHAR(20)   NULL,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMPTZ   NULL,

  CONSTRAINT pk_device              PRIMARY KEY (id_device),
  CONSTRAINT uq_device_nombre       UNIQUE (id_home, nombre),
  CONSTRAINT uq_device_mac          UNIQUE (mac_address),
  CONSTRAINT ck_device_estado       CHECK (estado IN ('conectado', 'desconectado', 'activo', 'desactivado')),
  CONSTRAINT ck_device_protocolo    CHECK (
    protocolo IS NULL OR
    protocolo IN ('wifi', 'bluetooth', 'mqtt')
  ),
  CONSTRAINT ck_device_consumo      CHECK (consumo_actual_w IS NULL OR consumo_actual_w >= 0),
  CONSTRAINT ck_device_mac          CHECK (
    mac_address IS NULL OR
    mac_address ~ '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$'
  )
);

-- ============================================================
-- TABLA: devices.smart_device
-- Descripción: Datos extendidos para dispositivos inteligentes
--              con capacidades avanzadas de control
-- Referencia SRS: RF3.1, RF3.5
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.smart_device (
  id_smart_device    UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_device          UUID          NOT NULL,
  firmware_version   VARCHAR(50)   NULL,
  modelo             VARCHAR(100)  NULL,
  fabricante         VARCHAR(100)  NULL,
  capacidad_maxima_w NUMERIC(10,2) NULL,
  created_at         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_smart_device           PRIMARY KEY (id_smart_device),
  CONSTRAINT uq_smart_device_device    UNIQUE (id_device),
  CONSTRAINT ck_smart_device_capacidad CHECK (capacidad_maxima_w IS NULL OR capacidad_maxima_w > 0)
);

-- ============================================================
-- TABLA: devices.manual_device
-- Descripción: Datos extendidos para dispositivos manuales
--              cuyo consumo se registra de forma estimada
-- Referencia SRS: RF3.1
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.manual_device (
  id_manual_device    UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_device           UUID          NOT NULL,
  consumo_estimado_w  NUMERIC(10,2) NULL,
  horas_uso_diario    NUMERIC(5,2)  NULL,
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_manual_device              PRIMARY KEY (id_manual_device),
  CONSTRAINT uq_manual_device_device       UNIQUE (id_device),
  CONSTRAINT ck_manual_device_consumo      CHECK (consumo_estimado_w IS NULL OR consumo_estimado_w > 0),
  CONSTRAINT ck_manual_device_horas        CHECK (
    horas_uso_diario IS NULL OR
    horas_uso_diario BETWEEN 0 AND 24
  )
);

-- ============================================================
-- TABLA: devices.schedule
-- Descripción: Horarios automáticos para encender o apagar
--              dispositivos en días y horas específicas
-- Referencia SRS: RF3.2
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.schedule (
  id_schedule  UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_device    UUID        NOT NULL,
  accion       VARCHAR(10) NOT NULL,
  hora         TIME        NOT NULL,
  dias_semana  SMALLINT[]  NOT NULL,
  activo       BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at   TIMESTAMPTZ NULL,

  CONSTRAINT pk_schedule          PRIMARY KEY (id_schedule),
  CONSTRAINT ck_schedule_accion   CHECK (accion IN ('encender', 'apagar'))
);

-- ============================================================
-- TABLA: devices.threshold_rule
-- Descripción: Reglas de umbral de consumo por dispositivo.
--              Genera alertas o acciones automáticas cuando
--              se supera el límite configurado
-- Referencia SRS: RF3.2, RF3.5
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.threshold_rule (
  id_threshold_rule UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_device         UUID          NOT NULL,
  tipo              VARCHAR(20)   NOT NULL,
  limite_kwh        NUMERIC(10,4) NOT NULL,
  accion            VARCHAR(20)   NOT NULL DEFAULT 'alertar',
  activa            BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ   NULL,

  CONSTRAINT pk_threshold_rule          PRIMARY KEY (id_threshold_rule),
  CONSTRAINT ck_threshold_rule_tipo     CHECK (tipo IN ('diario', 'mensual')),
  CONSTRAINT ck_threshold_rule_accion   CHECK (accion IN ('alertar', 'apagar')),
  CONSTRAINT ck_threshold_rule_limite   CHECK (limite_kwh > 0)
);

-- ============================================================
-- TABLA: devices.device_status_history
-- Descripción: Historial inmutable de cambios de estado
--              de cada dispositivo para trazabilidad
-- Referencia SRS: RF3.5
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.device_status_history (
  id_device_status_history UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_device                UUID        NOT NULL,
  estado_anterior          VARCHAR(20) NULL,
  estado_nuevo             VARCHAR(20) NOT NULL,
  encendido                BOOLEAN     NOT NULL,
  origen                   VARCHAR(20) NOT NULL DEFAULT 'usuario',
  id_user                  UUID        NULL,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_device_status_history       PRIMARY KEY (id_device_status_history),
  CONSTRAINT ck_device_status_history_nuevo CHECK (estado_nuevo IN ('conectado', 'desconectado', 'activo', 'desactivado')),
  CONSTRAINT ck_device_status_history_ant   CHECK (
    estado_anterior IS NULL OR
    estado_anterior IN ('conectado', 'desconectado', 'activo', 'desactivado')
  ),
  CONSTRAINT ck_device_status_history_orig  CHECK (origen IN ('usuario', 'automatico', 'voz', 'sistema'))
);

-- ============================================================
-- TABLA: devices.voice_assistant_token
-- Descripción: Tokens de integración con asistentes de voz
--              como Alexa para control por comandos de voz
-- Referencia SRS: RF3.6
-- ============================================================
CREATE TABLE IF NOT EXISTS devices.voice_assistant_token (
  id_voice_assistant_token UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user                  UUID        NOT NULL,
  asistente                VARCHAR(30) NOT NULL,
  access_token             TEXT        NOT NULL,
  refresh_token            TEXT        NULL,
  expira_en                TIMESTAMPTZ NULL,
  activo                   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at               TIMESTAMPTZ NULL,

  CONSTRAINT pk_voice_assistant_token       PRIMARY KEY (id_voice_assistant_token),
  CONSTRAINT uq_voice_assistant_token       UNIQUE (id_user, asistente),
  CONSTRAINT ck_voice_assistant_token_asist CHECK (asistente IN ('alexa'))
);

--TABLA : devices.device_telemetry_raw
-- Descripción: Almacena los datos de telemetría en bruto
CREATE TABLE devices.device_telemetry_raw (
    id_device_telemetry_raw UUID NOT NULL DEFAULT uuid_generate_v4(),
    id_device               UUID NOT NULL,
    payload                 JSONB NOT NULL,
    fecha_captura           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 
    CONSTRAINT pk_device_telemetry_raw PRIMARY KEY (id_device_telemetry_raw),
    CONSTRAINT fk_device_telemetry_raw_device
        FOREIGN KEY (id_device) REFERENCES devices.device (id_device)
);