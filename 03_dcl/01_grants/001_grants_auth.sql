
-- ============================================================
-- ACCESO AL ESQUEMA
-- ============================================================

GRANT USAGE ON SCHEMA auth
TO
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;


-- ============================================================
-- auth.role
--
-- Catálogo global:
--   SYSTEM_ADMIN
--   USER
--
-- La aplicación necesita consultarlo, pero no modificarlo.
-- Los cambios del catálogo se realizan mediante migraciones.
-- ============================================================

GRANT SELECT
ON TABLE auth.role
TO
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;


-- ============================================================
-- auth.user
--
-- smarthome_app necesita:
--   SELECT -> login, perfil y validaciones
--   INSERT -> registro
--   UPDATE -> activación, bloqueo, contraseña, desactivación
--
-- No se concede DELETE porque la cuenta se desactiva
-- lógicamente mediante status.
-- ============================================================

GRANT SELECT, INSERT, UPDATE
ON TABLE auth.user
TO
  smarthome_admin,
  smarthome_app;


-- ============================================================
-- auth.recovery_token
--
-- El backend puede:
--   - crear tokens hasheados;
--   - consultarlos para validación;
--   - marcarlos como utilizados.
--
-- Los tokens expirados no necesitan borrarse para invalidarse.
-- ============================================================

GRANT SELECT, INSERT, UPDATE
ON TABLE auth.recovery_token
TO
  smarthome_admin,
  smarthome_app;
