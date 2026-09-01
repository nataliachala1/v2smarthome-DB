-- ============================================================
-- ROLLBACK — GRANTS esquema consumption
-- ============================================================


-- ============================================================
-- Función de particiones
-- ============================================================

REVOKE EXECUTE
ON FUNCTION consumption.fn_ensure_consumption_partitions(INT)
FROM
  smarthome_admin,
  smarthome_worker;


-- No restauramos EXECUTE TO PUBLIC.
-- El rollback de permisos no debe reabrir innecesariamente
-- una función SECURITY DEFINER.


-- ============================================================
-- consumption.recommendation
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE consumption.recommendation
FROM
  smarthome_admin,
  smarthome_worker;


REVOKE UPDATE (
  status,
  updated_at
)
ON TABLE consumption.recommendation
FROM smarthome_app;


REVOKE SELECT
ON TABLE consumption.recommendation
FROM smarthome_app;


-- ============================================================
-- consumption.consumption_metric
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE consumption.consumption_metric
FROM
  smarthome_admin,
  smarthome_worker;


REVOKE SELECT
ON TABLE consumption.consumption_metric
FROM smarthome_app;


-- ============================================================
-- consumption.consumption
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE consumption.consumption
FROM smarthome_admin;


REVOKE SELECT
ON TABLE consumption.consumption
FROM smarthome_worker;


REVOKE SELECT (
  id_device,
  energy_total_kwh,
  read_at
)
ON TABLE consumption.consumption
FROM smarthome_ingest;


REVOKE INSERT
ON TABLE consumption.consumption
FROM smarthome_ingest;


REVOKE SELECT
ON TABLE consumption.consumption
FROM smarthome_app;


-- ============================================================
-- Schema
-- ============================================================

REVOKE USAGE ON SCHEMA consumption
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly,
  smarthome_ingest,
  smarthome_worker;