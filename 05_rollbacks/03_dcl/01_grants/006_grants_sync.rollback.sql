-- ============================================================
-- ROLLBACK — GRANTS esquema sync
-- Archivo:
-- 05_rollbacks/03_dcl/01_grants/006_grants_sync.rollback.sql
-- ============================================================


-- ============================================================
-- sync.backup
-- ============================================================

REVOKE SELECT, INSERT, UPDATE
ON TABLE sync.backup
FROM smarthome_admin;


REVOKE SELECT
ON TABLE sync.backup
FROM smarthome_app;


-- ============================================================
-- Esquema sync
-- ============================================================

REVOKE USAGE ON SCHEMA sync
FROM
  smarthome_admin,
  smarthome_app;