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
-- TABLA: sync.offline_queue
-- Descripción: Cola de acciones realizadas por el usuario
--              en modo offline que se sincronizan al
--              restablecer la conexión a internet
-- Referencia SRS: RF5.4, RNF4.5
-- ============================================================
CREATE TABLE IF NOT EXISTS sync.offline_queue (
  id_offline_queue UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user          UUID        NOT NULL,
  tipo_accion      VARCHAR(50) NOT NULL,
  payload          JSONB       NOT NULL,
  estado           VARCHAR(20) NOT NULL DEFAULT 'pendiente',
  intentos         SMALLINT    NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  procesada_at     TIMESTAMPTZ NULL,

  CONSTRAINT pk_offline_queue           PRIMARY KEY (id_offline_queue),
  CONSTRAINT ck_offline_queue_tipo      CHECK (tipo_accion IN (
    'encender_dispositivo',
    'apagar_dispositivo',
    'actualizar_config',
    'vincular_dispositivo',
    'desvincular_dispositivo',
    'actualizar_dispositivo'
  )),
  CONSTRAINT ck_offline_queue_estado    CHECK (estado IN ('pendiente', 'procesada', 'fallida')),
  CONSTRAINT ck_offline_queue_intentos  CHECK (intentos >= 0),
  CONSTRAINT ck_offline_queue_procesada CHECK (
    (estado = 'pendiente' AND procesada_at IS NULL) OR
    (estado IN ('procesada', 'fallida') AND procesada_at IS NOT NULL)
  )
);

-- ============================================================
-- TABLA: sync.synchronization
-- Descripción: Registra el historial de sincronizaciones
--              realizadas entre dispositivos y el servidor,
--              tanto automáticas como manuales
-- Referencia SRS: RF5.1, RF5.2
-- ============================================================
CREATE TABLE IF NOT EXISTS sync.synchronization (
  id_synchronization           UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user                      UUID        NOT NULL,
  tipo                         VARCHAR(20) NOT NULL,
  estado                       VARCHAR(20) NOT NULL,
  dispositivos_sincronizados   SMALLINT    NULL,
  errores                      TEXT        NULL,
  created_at                   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_synchronization         PRIMARY KEY (id_synchronization),
  CONSTRAINT ck_synchronization_tipo    CHECK (tipo   IN ('automatica', 'manual')),
  CONSTRAINT ck_synchronization_estado  CHECK (estado IN ('exitosa', 'fallida', 'parcial')),
  CONSTRAINT ck_synchronization_dispos  CHECK (
    dispositivos_sincronizados IS NULL OR
    dispositivos_sincronizados >= 0
  ),
  CONSTRAINT ck_synchronization_errores CHECK (
    (estado = 'exitosa' AND errores IS NULL) OR
    (estado IN ('fallida', 'parcial'))
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
  id_backup      UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user        UUID        NULL,
  tipo           VARCHAR(20) NOT NULL,
  alcance        VARCHAR(20) NOT NULL DEFAULT 'completo',
  ubicacion      TEXT        NOT NULL,
  tamanio_bytes  BIGINT      NULL,
  estado         VARCHAR(20) NOT NULL DEFAULT 'completado',
  descripcion    TEXT        NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_backup           PRIMARY KEY (id_backup),
  CONSTRAINT ck_backup_tipo      CHECK (tipo    IN ('automatico', 'manual')),
  CONSTRAINT ck_backup_alcance   CHECK (alcance IN ('completo', 'parcial')),
  CONSTRAINT ck_backup_estado    CHECK (estado  IN ('en_proceso', 'completado', 'fallido')),
  CONSTRAINT ck_backup_tamanio   CHECK (tamanio_bytes IS NULL OR tamanio_bytes > 0)
);