-- ============================================================
-- FUNCIÓN: fn_auth_security
-- Archivo: 01_ddl/05_functions/004_fn_auth_security.sql
-- Descripción: Función que gestiona automáticamente la
--              seguridad del proceso de autenticación:
--              incrementa intentos fallidos, bloquea la
--              cuenta tras superar el límite permitido y
--              resetea el contador al autenticarse con éxito.
--              También cierra todas las sesiones activas
--              cuando se desactiva o bloquea una cuenta
-- Autor: Karen Daniela Holguín Cruz, Natalia Chala Chala,
--        Kevin Stiven López Amaya
-- Institución: SENA — Análisis y Desarrollo de Software
-- Ficha: 3145555
-- Versión: 1.0.0
-- Fecha: 2025
-- Dependencias: 01_schemas, 03_tables/auth.user,
--               03_tables/auth.session,
--               03_tables/auth.token_blacklist
-- ============================================================

-- ============================================================
-- FUNCIÓN: fn_auth_intentos_fallidos
-- Descripción: Gestiona el contador de intentos fallidos
--              y el bloqueo automático de cuenta
-- Referencia SRS: RF1.2, RNF5.2
-- ============================================================
CREATE OR REPLACE FUNCTION fn_auth_intentos_fallidos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_max_intentos  CONSTANT SMALLINT    := 5;
  v_tiempo_bloqueo CONSTANT INTERVAL  := INTERVAL '15 minutes';
BEGIN

  -- --------------------------------------------------------
  -- Caso 1: Incremento de intentos fallidos
  -- Se detecta cuando solo cambia intentos_fallidos
  -- --------------------------------------------------------
  IF NEW.intentos_fallidos > OLD.intentos_fallidos
    AND NEW.status = OLD.status THEN

    -- Verificar si se alcanzó el límite máximo
    IF NEW.intentos_fallidos >= v_max_intentos THEN

      -- Bloquear la cuenta automáticamente
      NEW.status          = 'bloqueado';
      NEW.bloqueado_hasta = NOW() + v_tiempo_bloqueo;

    END IF;

  END IF;

  -- --------------------------------------------------------
  -- Caso 2: Reseteo de intentos al autenticarse con éxito
  -- Se detecta cuando el estado cambia a activo
  -- --------------------------------------------------------
  IF NEW.status = 'activo'
    AND OLD.status = 'bloqueado' THEN

    NEW.intentos_fallidos = 0;
    NEW.bloqueado_hasta   = NULL;

  END IF;

  -- --------------------------------------------------------
  -- Caso 3: Cuenta bloqueada o desactivada
  -- Cerrar todas las sesiones activas del usuario
  -- --------------------------------------------------------
  IF (NEW.status IN ('bloqueado', 'desactivado'))
    AND OLD.status NOT IN ('bloqueado', 'desactivado') THEN

    -- Revocar todas las sesiones activas
    UPDATE auth.session
    SET
      activa     = FALSE,
      updated_at = NOW()
    WHERE id_user    = NEW.id_user
      AND activa     = TRUE
      AND deleted_at IS NULL;

    -- Registrar tokens en blacklist
    INSERT INTO auth.token_blacklist (
      id_token_blacklist,
      token,
      id_user,
      motivo,
      created_at,
      expira_en
    )
    SELECT
      gen_random_uuid(),
      token,
      id_user,
      CASE
        WHEN NEW.status = 'bloqueado'    THEN 'desactivacion'
        WHEN NEW.status = 'desactivado'  THEN 'desactivacion'
      END,
      NOW(),
      expira_en
    FROM auth.session
    WHERE id_user    = NEW.id_user
      AND activa     = FALSE
      AND deleted_at IS NULL
      AND token NOT IN (
        SELECT token FROM auth.token_blacklist
      );

  END IF;

  RETURN NEW;

END;
$$;

COMMENT ON FUNCTION fn_auth_intentos_fallidos()
  IS 'Gestiona intentos fallidos de login, bloqueo automático de cuenta tras 5 intentos y cierre de sesiones al desactivar o bloquear.';

-- ============================================================
-- FUNCIÓN: fn_auth_cambio_password
-- Descripción: Cierra todas las sesiones activas del usuario
--              cuando cambia su contraseña, excepto la
--              sesión actual desde donde realizó el cambio
-- Referencia SRS: RF1.7, RF1.8, RNF5.2
-- ============================================================
CREATE OR REPLACE FUNCTION fn_auth_cambio_password()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

  -- --------------------------------------------------------
  -- Detectar cambio de contraseña
  -- --------------------------------------------------------
  IF NEW.password_hash <> OLD.password_hash THEN

    -- Revocar todas las sesiones activas del usuario
    UPDATE auth.session
    SET
      activa     = FALSE,
      updated_at = NOW()
    WHERE id_user    = NEW.id_user
      AND activa     = TRUE
      AND deleted_at IS NULL;

    -- Registrar tokens revocados en blacklist
    INSERT INTO auth.token_blacklist (
      id_token_blacklist,
      token,
      id_user,
      motivo,
      created_at,
      expira_en
    )
    SELECT
      gen_random_uuid(),
      token,
      id_user,
      'cambio_password',
      NOW(),
      expira_en
    FROM auth.session
    WHERE id_user    = NEW.id_user
      AND activa     = TRUE
      AND deleted_at IS NULL
      AND token NOT IN (
        SELECT token FROM auth.token_blacklist
      );

  END IF;

  RETURN NEW;

END;
$$;

COMMENT ON FUNCTION fn_auth_cambio_password()
  IS 'Revoca todas las sesiones activas y registra tokens en blacklist cuando el usuario cambia su contraseña.';
