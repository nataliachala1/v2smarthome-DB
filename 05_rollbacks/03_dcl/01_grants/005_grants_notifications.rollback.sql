-- ============================================================
-- ROLLBACK — GRANTS esquema notifications
-- ============================================================


-- ============================================================
-- notifications.notification
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE notifications.notification
FROM smarthome_admin;


REVOKE INSERT
ON TABLE notifications.notification
FROM smarthome_worker;


REVOKE INSERT
ON TABLE notifications.notification
FROM smarthome_ingest;


REVOKE UPDATE (
  status,
  updated_at
)
ON TABLE notifications.notification
FROM smarthome_app;


REVOKE SELECT
ON TABLE notifications.notification
FROM smarthome_app;


-- ============================================================
-- notifications.alert
-- ============================================================

REVOKE SELECT, INSERT
ON TABLE notifications.alert
FROM smarthome_admin;


REVOKE INSERT
ON TABLE notifications.alert
FROM smarthome_ingest;


REVOKE SELECT
ON TABLE notifications.alert
FROM smarthome_app;


-- ============================================================
-- notifications.alert_rule
-- ============================================================

REVOKE SELECT
ON TABLE notifications.alert_rule
FROM smarthome_ingest;


REVOKE SELECT, INSERT, UPDATE
ON TABLE notifications.alert_rule
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- Esquema notifications
-- ============================================================

REVOKE USAGE ON SCHEMA notifications
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly,
  smarthome_ingest,
  smarthome_worker;