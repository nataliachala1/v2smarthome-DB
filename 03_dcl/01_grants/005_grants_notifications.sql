GRANT USAGE ON SCHEMA notifications
  TO smarthome_admin, smarthome_app, smarthome_readonly, smarthome_ingest;

-- smarthome_admin: acceso total
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notifications TO smarthome_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA notifications TO smarthome_admin;

-- smarthome_app: usuario final
--   alert_rule: puede ver y configurar (parte de "configurar dispositivo")
--   alert: solo lectura (la genera el pipeline de ingesta, no el usuario)
--   notification: lectura + marcar leída/descartada
GRANT SELECT, INSERT, UPDATE ON notifications.alert_rule TO smarthome_app;
GRANT SELECT ON notifications.alert TO smarthome_app;
GRANT SELECT, UPDATE (status, updated_at) ON notifications.notification TO smarthome_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA notifications TO smarthome_app;

-- smarthome_ingest: evalúa reglas de umbral sobre la telemetría entrante
-- y registra la alerta + notificación resultante
GRANT SELECT ON notifications.alert_rule TO smarthome_ingest;
GRANT INSERT ON notifications.alert TO smarthome_ingest;
GRANT INSERT ON notifications.notification TO smarthome_ingest;

-- smarthome_readonly: solo lectura
GRANT SELECT ON ALL TABLES IN SCHEMA notifications TO smarthome_readonly;

-- Aplicar a tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications
  GRANT SELECT ON TABLES TO smarthome_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications
  GRANT SELECT ON TABLES TO smarthome_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA notifications
  GRANT ALL PRIVILEGES ON TABLES TO smarthome_admin;