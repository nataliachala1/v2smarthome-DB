-- ============================================================
-- GRANTS - Esquema consumption
-- Archivo: 03_dcl/01_grants/004_grants_consumption.sql
-- ============================================================

GRANT USAGE ON SCHEMA consumption
TO
  smarthome_admin,
  smarthome_app,
  smarthome_readonly,
  smarthome_ingest,
  smarthome_worker;

-- ============================================================
-- consumption.consumption
-- ============================================================

GRANT SELECT
ON TABLE consumption.consumption
TO smarthome_app;

GRANT INSERT
ON TABLE consumption.consumption
TO smarthome_ingest;

GRANT SELECT (
  id_device,
  energy_total_kwh,
  read_at
)
ON TABLE consumption.consumption
TO smarthome_ingest;

GRANT SELECT
ON TABLE consumption.consumption
TO smarthome_worker;

GRANT SELECT, INSERT, UPDATE
ON TABLE consumption.consumption
TO smarthome_admin;

-- ============================================================
-- consumption.consumption_metric
-- ============================================================

GRANT SELECT
ON TABLE consumption.consumption_metric
TO smarthome_app;

GRANT SELECT, INSERT
ON TABLE consumption.consumption_metric
TO smarthome_worker;

GRANT UPDATE (
  kwh_total,
  total_cost,
  average_watts,
  max_watts,
  min_watts,
  updated_at
)
ON TABLE consumption.consumption_metric
TO smarthome_worker;

GRANT SELECT, INSERT, UPDATE
ON TABLE consumption.consumption_metric
TO smarthome_admin;

-- ============================================================
-- consumption.recommendation
-- ============================================================

GRANT SELECT
ON TABLE consumption.recommendation
TO smarthome_app;

GRANT SELECT, INSERT
ON TABLE consumption.recommendation
TO smarthome_worker;

GRANT UPDATE (
  title,
  description,
  estimated_savings_kwh,
  estimated_savings_cost,
  priority,
  status,
  updated_at,
  deleted_at
)
ON TABLE consumption.recommendation
TO smarthome_worker;

GRANT SELECT, INSERT, UPDATE
ON TABLE consumption.recommendation
TO smarthome_admin;

-- ============================================================
-- Funcion de mantenimiento de particiones
-- ============================================================

REVOKE ALL
ON FUNCTION consumption.fn_ensure_consumption_partitions(INT)
FROM PUBLIC;

GRANT EXECUTE
ON FUNCTION consumption.fn_ensure_consumption_partitions(INT)
TO
  smarthome_admin,
  smarthome_worker;
