-- ============================================================
-- GRANTS - Esquema sync
-- Archivo: 03_dcl/01_grants/006_grants_sync.sql
--
-- Modelo vigente:
--   - sync.backup
--
-- sync.backup almacena metadata de respaldos; no ejecuta
-- fisicamente backup/restore.
-- ============================================================

GRANT USAGE ON SCHEMA sync
TO
  smarthome_admin,
  smarthome_app;

-- SYSTEM_ADMIN consulta mediante smarthome_app + RLS.
GRANT SELECT
ON TABLE sync.backup
TO smarthome_app;

-- El flujo tecnico registra y actualiza metadata real.
GRANT SELECT, INSERT, UPDATE
ON TABLE sync.backup
TO smarthome_admin;
