ALTER TABLE identity_audit.audit_log
  ADD CONSTRAINT fk_audit_log_user FOREIGN KEY (id_user) REFERENCES auth.user (id_user) ON DELETE SET NULL,
  ADD CONSTRAINT fk_audit_log_home FOREIGN KEY (id_home) REFERENCES homes.home (id_home) ON DELETE SET NULL;