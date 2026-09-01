-- ============================================================
-- TABLAS — Esquema sync
-- Archivo: 01_ddl/03_tables/007_create_sync_tables.sql
-- Descripción: Creación de las 3 tablas del esquema sync
--              para gestión de sincronización multidispositivo,
--              cola de acciones en modo offline y
--              copias de seguridad del sistema
-- Dependencias: 00_extensions, 01_schemas, auth.user
-- ============================================================

-- ============================================================
-- TABLA: sync.synchronization
-- Descripción: Registra el historial de sincronizaciones
--              realizadas entre dispositivos y el servidor,
--              tanto automáticas como manuales
-- Referencia SRS: RF5.1, RF5.2
-- ============================================================
CREATE TABLE IF NOT EXISTS sync.synchronization (
  id_synchronization           UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_user                      UUID        NOT NULL,
  type                         VARCHAR(20) NOT NULL,
  status                       VARCHAR(20) NOT NULL,
  synchronized_devices   SMALLINT    NULL,
  errors                      TEXT        NULL,
  created_at                   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_synchronization         PRIMARY KEY (id_synchronization),
  CONSTRAINT ck_synchronization_tipo    CHECK (type   IN ('automatica', 'manual')),
  CONSTRAINT ck_synchronization_estado  CHECK (status IN ('exitosa', 'fallida', 'parcial')),
  CONSTRAINT ck_synchronization_dispos  CHECK (
    synchronized_devices IS NULL OR
    synchronized_devices >= 0
  ),
  CONSTRAINT ck_synchronization_errores CHECK (
    (status = 'exitosa' AND errors IS NULL) OR
    (status IN ('fallida', 'parcial'))
  )
);

-- ============================================================
-- TABLA: sync.backup
-- Descripción: Registra las copias de seguridad generadas
--              del sistema, tanto automáticas como manuales.
--              Solo administradores pueden ejecutar
--              restauraciones (RF5.3)
-- Referencia SRS: RF5.3, RNF4.4, RNF5.5
-- ============================================================
CREATE TABLE IF NOT EXISTS sync.backup (
  id_backup      UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_user        UUID        NULL,
  type           VARCHAR(20) NOT NULL,
  scope        VARCHAR(20) NOT NULL DEFAULT 'completo',
  location      TEXT        NOT NULL,
  size_bytes  BIGINT      NULL,
  status         VARCHAR(20) NOT NULL DEFAULT 'completado',
  description    TEXT        NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_backup           PRIMARY KEY (id_backup),
  CONSTRAINT ck_backup_tipo      CHECK (type    IN ('automatico', 'manual')),
  CONSTRAINT ck_backup_alcance   CHECK (scope IN ('completo', 'parcial')),
  CONSTRAINT ck_backup_estado    CHECK (status  IN ('en_proceso', 'completado', 'fallido')),
  CONSTRAINT ck_backup_tamanio   CHECK (size_bytes IS NULL OR size_bytes > 0)
);