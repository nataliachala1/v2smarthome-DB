-- ============================================================
-- GRANTS - Esquema config
-- Archivo: 03_dcl/01_grants/007_grants_config.sql
--
-- Modelo:
--   - config.user_preference
--   - config.home_recommendation_preference
--   - config.home_notification_preference
-- ============================================================

GRANT USAGE ON SCHEMA config
TO
  smarthome_admin,
  smarthome_app,
  smarthome_ingest,
  smarthome_worker;

-- ============================================================
-- config.user_preference
-- ============================================================

GRANT SELECT, INSERT
ON TABLE config.user_preference
TO
  smarthome_admin,
  smarthome_app;

GRANT UPDATE (
  language,
  theme,
  date_format,
  time_format,
  currency,
  temperature_unit,
  timezone
)
ON TABLE config.user_preference
TO smarthome_app;

GRANT UPDATE
ON TABLE config.user_preference
TO smarthome_admin;

-- ============================================================
-- config.home_recommendation_preference
-- ============================================================

GRANT SELECT, INSERT
ON TABLE config.home_recommendation_preference
TO
  smarthome_admin,
  smarthome_app;

GRANT UPDATE (
  recommendations_enabled,
  recommendation_frequency
)
ON TABLE config.home_recommendation_preference
TO smarthome_app;

GRANT UPDATE
ON TABLE config.home_recommendation_preference
TO smarthome_admin;

GRANT SELECT
ON TABLE config.home_recommendation_preference
TO smarthome_worker;

-- ============================================================
-- config.home_notification_preference
-- ============================================================

GRANT SELECT, INSERT
ON TABLE config.home_notification_preference
TO
  smarthome_admin,
  smarthome_app;

GRANT UPDATE (
  notifications_enabled,
  high_consumption_notifications,
  device_notifications,
  recommendation_notifications,
  minimum_priority
)
ON TABLE config.home_notification_preference
TO smarthome_app;

GRANT UPDATE
ON TABLE config.home_notification_preference
TO smarthome_admin;

GRANT SELECT
ON TABLE config.home_notification_preference
TO
  smarthome_ingest,
  smarthome_worker;
