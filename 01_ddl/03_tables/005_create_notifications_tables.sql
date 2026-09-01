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
-- Evento de comunicación hacia el usuario. Puede originarse por
-- una alerta (id_alert) o por otros eventos del sistema
-- (recomendación nueva, dispositivo desconectado, etc.).
-- Referencia: RF4.5, RF4.6, §28 del alcance actualizado
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications.notification (
  id_notification UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_user         UUID        NOT NULL,
  id_alert        UUID        NULL,
  id_home         UUID        NULL,
  id_device       UUID        NULL,
  type            VARCHAR(30) NOT NULL,
  title           VARCHAR(200) NOT NULL,
  message         TEXT        NOT NULL,
  status          VARCHAR(10) NOT NULL DEFAULT 'UNREAD',
  priority        VARCHAR(10) NOT NULL DEFAULT 'media',
  channel         VARCHAR(20) NOT NULL DEFAULT 'app',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_notification         PRIMARY KEY (id_notification),
  CONSTRAINT ck_notification_status  CHECK (status IN ('UNREAD', 'READ', 'DISMISSED')),
  CONSTRAINT ck_notification_priority CHECK (priority IN ('alta', 'media', 'baja'))
);
-- Sin deleted_at: "no deberán eliminarse físicamente" (§28).
-- DISMISSED cumple el rol de "ocultar" sin borrar.
-- ============================================================

-- TABLA: notifications.alert
-- Alerta persistente generada cuando una alert_rule se dispara.
-- Es la entidad de dominio; notifications.notification es el
-- evento de comunicación hacia el usuario (pueden originarse
-- una o varias notificaciones a partir de una misma alerta).
-- Referencia: RF4.7

-- ============================================================
CREATE TABLE IF NOT EXISTS notifications.alert (
    id_alert        UUID        NOT NULL DEFAULT gen_random_uuid(),
    id_alert_rule   UUID        NULL,
    id_device       UUID        NOT NULL,
    id_home         UUID        NOT NULL,
    alert_type      VARCHAR(20) NOT NULL,
    detected_value  NUMERIC(12,6) NULL,
    limit_value     NUMERIC(10,4) NULL,
    action_executed VARCHAR(20) NULL,
    metadata        JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_alert PRIMARY KEY (id_alert),

    CONSTRAINT ck_alert_type
        CHECK (
            alert_type IN (
                'THRESHOLD',
                'ANOMALY',
                'DEVICE_EVENT'
            )
        ),

    CONSTRAINT ck_alert_threshold_data
        CHECK (
            (
                alert_type = 'THRESHOLD'
                AND id_alert_rule IS NOT NULL
                AND detected_value IS NOT NULL
                AND limit_value IS NOT NULL
            )
            OR
            (
                alert_type IN ('ANOMALY', 'DEVICE_EVENT')
                AND id_alert_rule IS NULL
            )
        ),

    CONSTRAINT uq_alert_context
        UNIQUE (
            id_alert,
            id_home,
            id_device
        )
);

-- ============================================================
-- TABLA: notifications.alert_rule
-- Reglas de umbral que disparan una alerta. Vive en el esquema
-- notifications porque su único propósito es alimentar el flujo
-- de alertas (RF4.7), no la configuración operativa del dispositivo.
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications.alert_rule (
  id_alert_rule UUID          NOT NULL DEFAULT gen_random_uuid(),
  id_device     UUID          NOT NULL,
  rule_type     VARCHAR(20)   NOT NULL,
  limit_kwh     NUMERIC(10,4) NOT NULL,
  action        VARCHAR(20)   NOT NULL DEFAULT 'alert',
  active        BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ   NULL,

  CONSTRAINT pk_alert_rule           PRIMARY KEY (id_alert_rule),
  CONSTRAINT ck_alert_rule_type      CHECK (rule_type IN ('daily_threshold', 'monthly_threshold')),
  CONSTRAINT ck_alert_rule_limit     CHECK (limit_kwh > 0),
  CONSTRAINT ck_alert_rule_action    CHECK (action IN ('alert', 'turn_off'))
);