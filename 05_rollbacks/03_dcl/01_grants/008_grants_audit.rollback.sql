-- ============================================================
-- ROLLBACK — GRANTS esquema identity_audit
-- ============================================================


-- ============================================================
-- identity_audit.audit_log
-- ============================================================

REVOKE SELECT, INSERT
ON TABLE identity_audit.audit_log
FROM smarthome_admin;


REVOKE SELECT, INSERT
ON TABLE identity_audit.audit_log
FROM smarthome_app;


-- ============================================================
-- Esquema identity_audit
-- ============================================================

REVOKE USAGE ON SCHEMA identity_audit
FROM
  smarthome_admin,
  smarthome_app;