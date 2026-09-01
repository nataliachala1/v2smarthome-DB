-- ============================================================
-- ROLLBACK — GRANTS esquema devices
-- Archivo:
-- 05_rollbacks/03_dcl/01_grants/003_grants_devices.rollback.sql
-- ============================================================


-- ============================================================
-- devices.device_telemetry_raw
-- ============================================================

REVOKE SELECT
ON TABLE devices.device_telemetry_raw
FROM smarthome_admin;

REVOKE INSERT
ON TABLE devices.device_telemetry_raw
FROM smarthome_ingest;


-- ============================================================
-- devices.device_schedule
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE devices.device_schedule
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- devices.smart_device
-- ============================================================

REVOKE SELECT
ON TABLE devices.smart_device
FROM smarthome_ingest;

REVOKE SELECT, INSERT, UPDATE
ON TABLE devices.smart_device
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- devices.device
-- ============================================================
REVOKE UPDATE (
    id_zone,
    id_device_type,
    name,
    status,
    is_on,
    transport_type,
    messaging_protocol,
    updated_at,
    deleted_at
)
ON TABLE devices.device
FROM smarthome_app;

REVOKE SELECT
ON TABLE devices.device
FROM smarthome_ingest;


REVOKE SELECT, INSERT, UPDATE
ON TABLE devices.device
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- devices.device_type
-- ============================================================

REVOKE SELECT
ON TABLE devices.device_type
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;


-- ============================================================
-- Esquema devices
-- ============================================================

REVOKE USAGE ON SCHEMA devices
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly,
  smarthome_ingest;