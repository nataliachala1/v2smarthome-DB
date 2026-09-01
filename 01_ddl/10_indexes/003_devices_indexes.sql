-- ============================================================
-- ÍNDICES — Esquema devices
-- Archivo: 01_ddl/09_indexes/003_devices_indexes.sql
-- Descripción: Índices de búsqueda y optimización para las
--              tablas del esquema devices. Cubre los patrones
--              de consulta de dispositivos, horarios, umbrales,
--              historial de estados e integración con asistentes
--              de voz.
-- ============================================================
-- TABLA: devices.type_device
-- ============================================================

-- Búsqueda por nombre de tipo de dispositivo
CREATE INDEX IF NOT EXISTS idx_type_device_nombre
  ON devices.device_type (name)
  WHERE deleted_at IS NULL;

-- ============================================================
-- TABLA: devices.device
-- ============================================================

-- Búsqueda de dispositivos por hogar
CREATE INDEX IF NOT EXISTS idx_device_id_home
  ON devices.device (id_home)
  WHERE deleted_at IS NULL;

-- Búsqueda de dispositivos por zona
CREATE INDEX IF NOT EXISTS idx_device_id_zone
  ON devices.device (id_zone)
  WHERE deleted_at IS NULL;

-- Filtrado por estado del dispositivo
CREATE INDEX IF NOT EXISTS idx_device_estado
  ON devices.device (status)
  WHERE deleted_at IS NULL;

-- Búsqueda por MAC address (identificación física del dispositivo)
CREATE INDEX IF NOT EXISTS idx_device_mac_address
  ON devices.device (manufacturer_device_id)
  WHERE deleted_at IS NULL;

-- Filtrado por tipo de dispositivo
CREATE INDEX IF NOT EXISTS idx_device_id_type_device
  ON devices.device (id_device_type)
  WHERE deleted_at IS NULL;

-- Dispositivos encendidos por hogar (dashboard en tiempo real)
CREATE INDEX IF NOT EXISTS idx_device_id_home_encendido
  ON devices.device (id_home, is_on)
  WHERE deleted_at IS NULL;

-- Compuesto: hogar + estado (dispositivos activos de un hogar)
CREATE INDEX IF NOT EXISTS idx_device_id_home_estado
  ON devices.device (id_home, status)
  WHERE deleted_at IS NULL;

-- Compuesto: hogar + nombre (validación de nombre único por hogar)
CREATE INDEX IF NOT EXISTS idx_device_id_home_nombre
  ON devices.device (id_home, name)
  WHERE deleted_at IS NULL;

-- ============================================================
-- TABLA: devices.smart_device
-- ============================================================

-- Búsqueda por dispositivo
CREATE INDEX IF NOT EXISTS idx_smart_device_id_device
  ON devices.smart_device (id_device);

-- ============================================================
-- TABLA: devices.device_schedule
-- ============================================================

-- Búsqueda de horarios por dispositivo
CREATE INDEX IF NOT EXISTS idx_schedule_id_device
  ON devices.device_schedule (id_device)
  WHERE deleted_at IS NULL;

-- Filtrado de horarios activos (job de ejecución automática)
CREATE INDEX IF NOT EXISTS idx_schedule_activo
  ON devices.device_schedule (is_active)
  WHERE activo = TRUE AND deleted_at IS NULL;

-- Compuesto: dispositivo + activo (horarios activos de un dispositivo)
CREATE INDEX IF NOT EXISTS idx_schedule_id_device_activo
  ON devices.device_schedule (id_device, is_active)
  WHERE deleted_at IS NULL;
