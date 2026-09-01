-- ============================================================
-- ROLLBACK — GRANTS esquema homes
-- Archivo:
-- 05_rollbacks/03_dcl/01_grants/002_grants_homes.rollback.sql
-- ============================================================


-- ============================================================
-- homes.electricity_tariff
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE homes.electricity_tariff
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- homes.home_member
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE homes.home_member
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- homes.zone
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE homes.zone
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- homes.home
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE homes.home
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- Esquema homes
-- ============================================================

REVOKE USAGE ON SCHEMA homes
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;