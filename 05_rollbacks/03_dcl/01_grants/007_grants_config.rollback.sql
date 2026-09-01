-- ============================================================
-- ROLLBACK — GRANTS esquema config
-- ============================================================


-- config.home_notification_preference

REVOKE SELECT
ON TABLE config.home_notification_preference
FROM
  smarthome_ingest,
  smarthome_worker;

REVOKE SELECT, INSERT, UPDATE
ON TABLE config.home_notification_preference
FROM
  smarthome_admin,
  smarthome_app;


-- config.home_recommendation_preference

REVOKE SELECT
ON TABLE config.home_recommendation_preference
FROM smarthome_worker;

REVOKE SELECT, INSERT, UPDATE
ON TABLE config.home_recommendation_preference
FROM
  smarthome_admin,
  smarthome_app;


-- config.user_preference

REVOKE SELECT, INSERT, UPDATE
ON TABLE config.user_preference
FROM
  smarthome_admin,
  smarthome_app;


-- schema

REVOKE USAGE ON SCHEMA config
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_ingest,
  smarthome_worker;