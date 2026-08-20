-- ============================================================
-- TABLAS — Esquema notifications
-- Descripción: Creación de las 3 tablas del esquema
--              notifications para gestión de notificaciones,
--              alertas por umbral y recordatorios programados
-- Dependencias: 00_extensions, 01_schemas, auth.user,
--               homes.home, devices.device,
--               devices.threshold_rule
-- ============================================================

-- ============================================================
-- TABLA: notifications.notification
-- Descripción: Almacena todas las notificaciones generadas
--              por el sistema hacia los usuarios, incluyendo
--              alertas, recomendaciones y eventos del sistema
-- Referencia SRS: RF4.5, RF4.6, RNF4.3
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications.notification (
  id_notification UUID         NOT NULL DEFAULT uuid_generate_v4(),
  id_user         UUID         NOT NULL,
  id_home         UUID         NULL,
  id_device       UUID         NULL,
  tipo            VARCHAR(30)  NOT NULL,
  titulo          VARCHAR(200) NOT NULL,
  mensaje         TEXT         NOT NULL,
  prioridad       VARCHAR(10)  NOT NULL DEFAULT 'media',
  leida           BOOLEAN      NOT NULL DEFAULT FALSE,
  canal           VARCHAR(20)  NOT NULL DEFAULT 'app',
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ  NULL,

  CONSTRAINT pk_notification              PRIMARY KEY (id_notification),
  CONSTRAINT ck_notification_tipo         CHECK (tipo IN (
    'consumo_elevado',
    'dispositivo_desconectado',
    'nueva_recomendacion',
    'umbral_superado',
    'sistema'
  )),
  CONSTRAINT ck_notification_prioridad    CHECK (prioridad IN ('alta', 'media', 'baja')),
  CONSTRAINT ck_notification_canal        CHECK (canal IN ('app', 'email', 'push'))
);

-- ============================================================
-- TABLA: notifications.alert
-- Descripción: Alertas específicas generadas cuando un
--              dispositivo supera los umbrales de consumo
--              configurados por el usuario
-- Referencia SRS: RF3.2, RF3.5, RF4.5
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications.alert (
  id_alert                UUID          NOT NULL DEFAULT uuid_generate_v4(),
  id_threshold_rule       UUID          NOT NULL,
  id_device               UUID          NOT NULL,
  id_home                 UUID          NOT NULL,
  consumo_detectado_kwh   NUMERIC(12,6) NOT NULL,
  limite_kwh              NUMERIC(10,4) NOT NULL,
  accion_ejecutada        VARCHAR(20)   NULL,
  created_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_alert                   PRIMARY KEY (id_alert),
  CONSTRAINT ck_alert_limite            CHECK (limite_kwh > 0),
  CONSTRAINT ck_alert_accion            CHECK (
    accion_ejecutada IS NULL OR
    accion_ejecutada IN ('alertar', 'apagar')
  ),
  CONSTRAINT ck_alert_consumo_supera    CHECK (consumo_detectado_kwh > limite_kwh)
);

-- ============================================================
-- TABLA: notifications.reminder_notification
-- Descripción: Recordatorios programados para enviar
--              a los usuarios en fechas y horas específicas
-- Referencia SRS: RF4.5, RF4.6
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications.reminder_notification (
  id_reminder_notification UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user                  UUID        NOT NULL,
  id_home                  UUID        NULL,
  mensaje                  TEXT        NOT NULL,
  programado_para          TIMESTAMPTZ NOT NULL,
  enviado                  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at               TIMESTAMPTZ NULL,

  CONSTRAINT pk_reminder_notification         PRIMARY KEY (id_reminder_notification),
  CONSTRAINT ck_reminder_notification_fecha   CHECK (programado_para > created_at)
);