-- ============================================================
-- TRIGGERS: updated_at
-- Archivo: 01_ddl/06_triggers/001_trg_updated_at.sql
-- Descripción: Aplica la función fn_updated_at a todas las
--              tablas del sistema que tienen el campo
--              updated_at para mantener trazabilidad
--              automática de modificaciones
-- Autor: Karen Daniela Holguín Cruz, Natalia Chala Chala,
--        Kevin Stiven López Amaya
-- Institución: SENA — Análisis y Desarrollo de Software
-- Ficha: 3145555
-- Versión: 1.0.0
-- Fecha: 2025
-- Dependencias: 03_tables, 05_functions/001_fn_updated_at.sql
-- ============================================================

-- ============================================================
-- Esquema: auth
-- ============================================================

CREATE TRIGGER trg_updated_at_role
  BEFORE UPDATE ON auth.role
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_permission
  BEFORE UPDATE ON auth.permission
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_user
  BEFORE UPDATE ON auth.user
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_session
  BEFORE UPDATE ON auth.session
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

-- ============================================================
-- Esquema: config
-- ============================================================

CREATE TRIGGER trg_updated_at_configuration_user
  BEFORE UPDATE ON config.configuration_user
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

-- ============================================================
-- Esquema: homes
-- ============================================================

CREATE TRIGGER trg_updated_at_home
  BEFORE UPDATE ON homes.home
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_zone
  BEFORE UPDATE ON homes.zone
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_tariff
  BEFORE UPDATE ON homes.electricity_tariff
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

-- ============================================================
-- Esquema: devices
-- ============================================================

CREATE TRIGGER trg_updated_at_type_device
  BEFORE UPDATE ON devices.device_type
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_device
  BEFORE UPDATE ON devices.device
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_smart_device
  BEFORE UPDATE ON devices.smart_device
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_device_schedule
  BEFORE UPDATE ON devices.device_schedule
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();


-- ============================================================
-- Esquema: consumption
-- ============================================================

CREATE TRIGGER trg_updated_at_consumption_metric
  BEFORE UPDATE ON consumption.consumption_metric
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_updated_at_recommendation
  BEFORE UPDATE ON consumption.recommendation
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

-- ============================================================
-- Esquema: notifications
-- ============================================================

CREATE TRIGGER trg_updated_at_notification
  BEFORE UPDATE ON notifications.notification
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
