CREATE INDEX IF NOT EXISTS idx_audit_log_id_user   ON identity_audit.audit_log (id_user);
CREATE INDEX IF NOT EXISTS idx_audit_log_id_home   ON identity_audit.audit_log (id_home);
CREATE INDEX IF NOT EXISTS idx_audit_log_action    ON identity_audit.audit_log (action);
CREATE INDEX IF NOT EXISTS idx_audit_log_module    ON identity_audit.audit_log (module);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity    ON identity_audit.audit_log (entity);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON identity_audit.audit_log (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_result    ON identity_audit.audit_log (result);

CREATE INDEX IF NOT EXISTS idx_audit_log_module_created_at ON identity_audit.audit_log (module, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_created_at   ON identity_audit.audit_log (id_user, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_home_created_at   ON identity_audit.audit_log (id_home, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_action_created_at ON identity_audit.audit_log (action, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_module_action     ON identity_audit.audit_log (module, action);

CREATE INDEX IF NOT EXISTS idx_audit_log_result_created_at
  ON identity_audit.audit_log (result, created_at DESC)
  WHERE result = 'failure';

CREATE INDEX IF NOT EXISTS idx_audit_log_user_module_created_at
  ON identity_audit.audit_log (id_user, module, created_at DESC);