-- ============================================================
-- ROLLBACK — RLS devices
-- ============================================================


-- ============================================================
-- devices.device_telemetry_raw
-- ============================================================

DROP POLICY IF EXISTS
telemetry_raw_ingest_insert_policy
ON devices.device_telemetry_raw;

ALTER TABLE devices.device_telemetry_raw
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE devices.device_telemetry_raw
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- devices.device_schedule
-- ============================================================

DROP POLICY IF EXISTS
device_schedule_update_policy
ON devices.device_schedule;

DROP POLICY IF EXISTS
device_schedule_insert_policy
ON devices.device_schedule;

DROP POLICY IF EXISTS
device_schedule_select_policy
ON devices.device_schedule;

ALTER TABLE devices.device_schedule
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE devices.device_schedule
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- devices.smart_device
-- ============================================================

DROP POLICY IF EXISTS
smart_device_ingest_select_policy
ON devices.smart_device;

DROP POLICY IF EXISTS
smart_device_app_update_policy
ON devices.smart_device;

DROP POLICY IF EXISTS
smart_device_app_insert_policy
ON devices.smart_device;

DROP POLICY IF EXISTS
smart_device_app_select_policy
ON devices.smart_device;

ALTER TABLE devices.smart_device
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE devices.smart_device
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- devices.device
-- ============================================================

DROP POLICY IF EXISTS
device_ingest_update_policy
ON devices.device;

DROP POLICY IF EXISTS
device_ingest_select_policy
ON devices.device;

DROP POLICY IF EXISTS
device_app_update_policy
ON devices.device;

DROP POLICY IF EXISTS
device_app_insert_policy
ON devices.device;

DROP POLICY IF EXISTS
device_app_select_policy
ON devices.device;

ALTER TABLE devices.device
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE devices.device
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- EXECUTE helpers
-- ============================================================

REVOKE EXECUTE
ON FUNCTION devices.fn_is_ingestable_device(UUID)
FROM smarthome_ingest;


REVOKE EXECUTE
ON FUNCTION devices.fn_device_app_update_allowed(
    UUID,
    UUID,
    UUID,
    UUID,
    TEXT,
    TEXT,
    BOOLEAN,
    TEXT,
    TEXT,
    TIMESTAMPTZ
)
FROM smarthome_app;


REVOKE EXECUTE
ON FUNCTION devices.fn_can_manage_device(UUID)
FROM smarthome_app;


REVOKE EXECUTE
ON FUNCTION devices.fn_can_view_device(UUID, TEXT[])
FROM smarthome_app;


REVOKE EXECUTE
ON FUNCTION devices.fn_is_device_owner(UUID)
FROM smarthome_app;


REVOKE EXECUTE
ON FUNCTION devices.fn_is_active_device_type(UUID)
FROM smarthome_app;


REVOKE EXECUTE
ON FUNCTION devices.fn_is_active_zone(UUID, UUID)
FROM smarthome_app;


REVOKE EXECUTE
ON FUNCTION homes.fn_is_home_active(UUID)
FROM smarthome_app;