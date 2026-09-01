-- ============================================================
-- ROLLBACK — GRANTS esquema auth
-- Archivo:
-- 05_rollbacks/03_dcl/01_grants/001_grants_auth.rollback.sql
-- ============================================================


-- ============================================================
-- auth.recovery_token
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE auth.recovery_token
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- auth.user
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE auth.user
FROM
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- auth.role
-- ============================================================

REVOKE SELECT
ON TABLE auth.role
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;


-- ============================================================
-- Esquema auth
-- ============================================================

REVOKE USAGE ON SCHEMA auth
FROM
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;