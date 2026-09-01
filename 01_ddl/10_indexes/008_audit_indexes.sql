-- ============================================================
-- ÍNDICES — esquema identity_audit
-- Archivo: 01_ddl/09_indexes/008_audit_indexes.sql
-- Descripción: Índices de búsqueda y optimización para las
--              tablas del esquema identity_audit. Garantiza que la
--              consulta de hasta 10.000 registros no supere
--              los 5 segundos (RF7.1).
-- ==========================================================

-- ============================================================
-- TABLA: identity_audit.audit_log
-- Nota: Esta tabla es de solo INSERT (inmutable). Los índices
-- están orientados exclusivamente a la lectura y filtrado
-- por parte del administrador (RF7.1). No hay índices
-- parciales con deleted_at ya que esta tabla no tiene
-- eliminación lógica.
-- ============================================================

-- Filtrado por usuario (actividad de un usuario específico)
CREATE INDEX IF NOT EXISTS idx_audit_log_id_user
  ON identity_audit.audit_log (id_user);

-- Filtrado por tipo de acción (login, crear, editar, eliminar, etc.)
CREATE INDEX IF NOT EXISTS idx_audit_log_accion
  ON identity_audit.audit_log (action);

-- Filtrado por módulo del sistema
CREATE INDEX IF NOT EXISTS idx_audit_log_modulo
  ON identity_audit.audit_log (module);

-- Filtrado por entidad afectada
CREATE INDEX IF NOT EXISTS idx_audit_log_entidad
  ON identity_audit.audit_log (entity);

-- Filtrado y ordenamiento por fecha (columna más usada en consultas)
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at
  ON identity_audit.audit_log (created_at DESC);

-- Filtrado por resultado de la acción (exitoso / fallido)
CREATE INDEX IF NOT EXISTS idx_audit_log_resultado
  ON identity_audit.audit_log (result);

-- Compuesto: módulo + fecha (actividad de un módulo en un periodo)
CREATE INDEX IF NOT EXISTS idx_audit_log_modulo_created_at
  ON identity_audit.audit_log (module, created_at DESC);

-- Compuesto: usuario + fecha (actividad reciente de un usuario)
CREATE INDEX IF NOT EXISTS idx_audit_log_user_created_at
  ON identity_audit.audit_log (id_user, created_at DESC);

-- Compuesto: acción + fecha (todas las acciones de un tipo en un periodo)
CREATE INDEX IF NOT EXISTS idx_audit_log_accion_created_at
  ON identity_audit.audit_log (action, created_at DESC);

-- Compuesto: módulo + acción (operaciones específicas por módulo)
CREATE INDEX IF NOT EXISTS idx_audit_log_modulo_accion
  ON identity_audit.audit_log (module, action);

-- Compuesto: resultado + fecha (errores recientes del sistema)
CREATE INDEX IF NOT EXISTS idx_audit_log_resultado_created_at
  ON identity_audit.audit_log (result, created_at DESC)
  WHERE result = 'failure';

-- Compuesto: usuario + módulo + fecha (auditoría detallada por usuario y módulo)
CREATE INDEX IF NOT EXISTS idx_audit_log_user_modulo_fecha
  ON identity_audit.audit_log (id_user, module, created_at DESC);