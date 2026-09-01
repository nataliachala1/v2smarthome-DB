ALTER TABLE auth.token_blacklist DROP CONSTRAINT IF EXISTS fk_token_blacklist_user;
ALTER TABLE auth.session DROP CONSTRAINT IF EXISTS fk_session_user;
ALTER TABLE auth.role_permission DROP CONSTRAINT IF EXISTS fk_role_permission_permission;
ALTER TABLE auth.role_permission DROP CONSTRAINT IF EXISTS fk_role_permission_role;
ALTER TABLE auth.user_role DROP CONSTRAINT IF EXISTS fk_user_role_assigned_by;
ALTER TABLE auth.user_role DROP CONSTRAINT IF EXISTS fk_user_role_role;
ALTER TABLE auth.user_role DROP CONSTRAINT IF EXISTS fk_user_role_user;
