-- ============================================================
-- FUNCIÓN: fn_audit_log
-- Archivo: 01_ddl/05_functions/002_fn_audit_log.sql
-- Descripción: Función genérica que registra automáticamente
--              en identity_audit.audit_log cualquier operación de
--              INSERT, UPDATE o DELETE realizada sobre
--              las tablas críticas del sistema.
--              Captura el estado anterior y nuevo del registro
--              para trazabilidad completa
-- Autor: Karen Daniela Holguín Cruz, Natalia Chala Chala,
--        Kevin Stiven López Amaya
-- Institución: SENA — Análisis y Desarrollo de Software
-- Ficha: 3145555
-- Versión: 1.0.0
-- Fecha: 2025
-- Dependencias: 01_schemas, 03_tables/auth,
--               03_tables/identity_audit
-- ============================================================

CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_action         VARCHAR(50);
  v_datos_ant      JSONB;
  v_datos_nuevos   JSONB;
  v_id_entidad     UUID;
  v_id_user        UUID;
  v_entidad        VARCHAR(50);
BEGIN

  IF TG_OP = 'INSERT' THEN
    v_action        := 'crear';
    v_datos_ant    := NULL;
    v_datos_nuevos := to_jsonb(NEW);
    v_id_entidad   := (to_jsonb(NEW)->>'id_' || TG_TABLE_NAME)::UUID;

  ELSIF TG_OP = 'UPDATE' THEN
    -- Verificar si la tabla tiene deleted_at antes de accederlo
    IF (to_jsonb(OLD) ? 'deleted_at')
       AND (to_jsonb(OLD)->>'deleted_at') IS NULL
       AND (to_jsonb(NEW)->>'deleted_at') IS NOT NULL THEN
      v_action := 'eliminar';
    ELSE
      v_action := 'editar';
    END IF;
    v_datos_ant    := to_jsonb(OLD);
    v_datos_nuevos := to_jsonb(NEW);
    v_id_entidad   := (to_jsonb(NEW)->>'id_' || TG_TABLE_NAME)::UUID;

  ELSIF TG_OP = 'DELETE' THEN
    v_action       := 'eliminar';
    v_datos_ant    := to_jsonb(OLD);
    v_datos_nuevos := NULL;
    v_id_entidad   := (to_jsonb(OLD)->>'id_' || TG_TABLE_NAME)::UUID;

  END IF;

  BEGIN
    IF TG_OP = 'DELETE' THEN
      v_id_user := (to_jsonb(OLD)->>'id_user')::UUID;
    ELSE
      v_id_user := (to_jsonb(NEW)->>'id_user')::UUID;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    v_id_user := NULL;
  END;

  v_entidad := TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME;

  IF v_datos_ant IS NOT NULL THEN
    v_datos_ant := v_datos_ant
      - 'password_hash'
      - 'token'
      - 'refresh_token'
      - 'access_token'
      - 'codigo_secreto'
      - 'ultimo_codigo_hash';
  END IF;

  IF v_datos_nuevos IS NOT NULL THEN
    v_datos_nuevos := v_datos_nuevos
      - 'password_hash'
      - 'token'
      - 'refresh_token'
      - 'access_token'
      - 'codigo_secreto'
      - 'ultimo_codigo_hash';
  END IF;

  INSERT INTO identity_audit.audit_log (
    id_audit_log,
    id_user,
    action,
    module,
    entity,
    id_entity,
    datos_anteriores,
    datos_nuevos,
    resultado,
    created_at
  )
  VALUES (
    gen_random_uuid(),
    v_id_user,
    v_action,
    TG_TABLE_SCHEMA,
    v_entidad,
    v_id_entidad,
    v_datos_ant,
    v_datos_nuevos,
    'exitoso',
    NOW()
  );

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;

  RETURN NEW;

END;
$$;

COMMENT ON FUNCTION fn_audit_log()
  IS 'Registra automáticamente en identity_audit.audit_log cualquier INSERT, UPDATE o DELETE sobre tablas críticas. Ofusca campos sensibles antes de guardar.';