-- ============================================================
-- GRANTS — Esquema identity_audit
-- Archivo: 03_dcl/01_grants/008_grants_audit.sql
--
-- Modelo:
--   - identity_audit.audit_log
--
-- Principios:
--   - NestJS registra eventos semánticos.
--   - PostgreSQL protege su integridad.
--   - smarthome_app puede INSERT.
--   - smarthome_app puede SELECT únicamente sujeto a RLS.
--   - Solo SYSTEM_ADMIN podrá consultar mediante RLS.
--   - No UPDATE.
--   - No DELETE.
--   - No ALL TABLES.
--   - No ALL PRIVILEGES.
--   - No ALTER DEFAULT PRIVILEGES.
-- ============================================================


-- ============================================================
-- ACCESO AL ESQUEMA
-- ============================================================

GRANT USAGE ON SCHEMA identity_audit
TO
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- identity_audit.audit_log
--
-- smarthome_app:
--   INSERT -> registrar eventos generados por NestJS.
--   SELECT -> únicamente cuando RLS determine SYSTEM_ADMIN.
--
-- Nunca puede:
--   UPDATE
--   DELETE
-- ============================================================

GRANT SELECT, INSERT
ON TABLE identity_audit.audit_log
TO smarthome_app;


-- ============================================================
-- Administración técnica
--
-- Puede consultar y registrar eventos técnicos.
-- Tampoco recibe UPDATE ni DELETE para preservar
-- la inmutabilidad del histórico.
-- ============================================================

GRANT SELECT, INSERT
ON TABLE identity_audit.audit_log
TO smarthome_admin;