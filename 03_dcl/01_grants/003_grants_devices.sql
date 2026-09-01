-- ============================================================
-- GRANTS - Esquema devices
-- Archivo: 03_dcl/01_grants/003_grants_devices.sql
-- ============================================================

GRANT USAGE ON SCHEMA devices
TO
  smarthome_admin,
  smarthome_app,
  smarthome_readonly,
  smarthome_ingest;

-- ============================================================
-- devices.device_type
-- ============================================================

GRANT SELECT
ON TABLE devices.device_type
TO
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;

-- ============================================================
-- devices.device
-- ============================================================

GRANT SELECT, INSERT
ON TABLE devices.device
TO smarthome_app;

GRANT UPDATE (
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
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE devices.device
TO smarthome_admin;

GRANT SELECT
ON TABLE devices.device
TO smarthome_ingest;

GRANT UPDATE (
  connectivity_status,
  is_on,
  current_power_w,
  updated_at
)
ON TABLE devices.device
TO smarthome_ingest;

-- ============================================================
-- devices.smart_device
-- ============================================================

GRANT SELECT, INSERT
ON TABLE devices.smart_device
TO smarthome_app;

GRANT UPDATE (
  manufacturer,
  model,
  firmware_version,
  max_capacity_w,
  supports_matter,
  updated_at
)
ON TABLE devices.smart_device
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE devices.smart_device
TO smarthome_admin;

GRANT SELECT
ON TABLE devices.smart_device
TO smarthome_ingest;

-- ============================================================
-- devices.device_schedule
-- ============================================================

GRANT SELECT, INSERT
ON TABLE devices.device_schedule
TO smarthome_app;

GRANT UPDATE (
  action,
  time_of_day,
  days_of_week,
  is_active,
  updated_at,
  deleted_at
)
ON TABLE devices.device_schedule
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE devices.device_schedule
TO smarthome_admin;

-- ============================================================
-- devices.device_telemetry_raw
-- Telemetria cruda append-only para ingesta.
-- ============================================================

GRANT INSERT
ON TABLE devices.device_telemetry_raw
TO smarthome_ingest;

GRANT SELECT
ON TABLE devices.device_telemetry_raw
TO smarthome_admin;
