ALTER TABLE identity_audit.audit_log
    ADD CONSTRAINT fk_audit_log_user
        FOREIGN KEY (id_user)
        REFERENCES auth.user(id_user),

    ADD CONSTRAINT fk_audit_log_home
        FOREIGN KEY (id_home)
        REFERENCES homes.home(id_home);
ALTER TABLE identity_audit.audit_log
ADD CONSTRAINT ck_audit_log_metadata_object
CHECK (
    jsonb_typeof(metadata) = 'object'
);