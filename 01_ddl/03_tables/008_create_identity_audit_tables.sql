-- ============================================================
-- TABLA: identity_audit.audit_log
-- Almacena eventos de auditoría SEMÁNTICOS enviados
-- explícitamente por NestJS (§20, §24). PostgreSQL solo persiste;
-- no clasifica ni genera automáticamente estos registros.
-- Referencia: §25, §26, §27 del alcance actualizado; RF7.1
-- ============================================================
CREATE TABLE IF NOT EXISTS identity_audit.audit_log (
  id_audit_log UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_user      UUID        NULL,
  id_home      UUID        NULL,
  action       VARCHAR(60) NOT NULL,
  module       VARCHAR(50) NOT NULL,
  entity       VARCHAR(50) NULL,
  id_entity    UUID        NULL,
  result       VARCHAR(10) NOT NULL DEFAULT 'success',
  detail       TEXT        NULL,
  metadata     JSONB       NULL,
  ip_address   VARCHAR(45) NULL,
  user_agent   TEXT        NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_audit_log        PRIMARY KEY (id_audit_log),
  CONSTRAINT ck_audit_log_result CHECK (result IN ('success', 'failure'))
);

COMMENT ON TABLE identity_audit.audit_log IS
  'Registro inmutable de eventos de auditoría semántica. Las filas las inserta NestJS explícitamente (no triggers de PostgreSQL) tras evaluar qué constituye un evento auditable, según §20/§24 del alcance.';
COMMENT ON COLUMN identity_audit.audit_log.action   IS 'Nombre del evento en convención "modulo.evento", ej: auth.login_success, home.created, member.invited, device.control_executed.';
COMMENT ON COLUMN identity_audit.audit_log.metadata IS 'Contexto mínimo necesario del evento (nunca snapshot completo de fila). Ej: {"previous_role":"MEMBER","new_role":"OWNER"}. Nunca contraseñas, hashes, JWT, tokens ni secretos (§27).';