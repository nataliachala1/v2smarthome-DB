-- ============================================================
-- TABLAS — Esquema auth
-- Archivo: 01_ddl/03_tables/001_create_auth_tables.sql
-- Descripción: Creación de las 9 tablas del esquema auth
--              para gestión de usuarios, autenticación,
--              roles, permisos y seguridad del sistema
-- Autor: Karen Daniela Holguín Cruz, Natalia Chala Chala,
--        Kevin Stiven López Amaya
-- Institución: SENA — Análisis y Desarrollo de Software
-- Ficha: 3145555
-- Versión: 1.0.0
-- Fecha: 2025
-- Dependencias: 00_extensions, 01_schemas
-- ============================================================

-- ============================================================
-- TABLA: auth.role
-- Descripción: Define los roles disponibles en el sistema
--              que determinan los niveles de acceso
-- Referencia SRS: RF1.3
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.role (
  id_role     UUID          NOT NULL DEFAULT uuid_generate_v4(),
  nombre      VARCHAR(50)   NOT NULL,
  descripcion TEXT          NULL,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ   NULL,

  CONSTRAINT pk_role 
        PRIMARY KEY (id_role),
  CONSTRAINT uq_role_nombre 
        UNIQUE (nombre)
);

-- ============================================================
-- TABLA: auth.permission
-- Descripción: Catálogo de permisos disponibles en el sistema,
--              asociados a módulos y acciones específicas
-- Referencia SRS: RF1.3
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.permission (
  id_permission UUID          NOT NULL DEFAULT uuid_generate_v4(),
  nombre        VARCHAR(100)  NOT NULL,
  modulo        VARCHAR(50)   NOT NULL,
  accion        VARCHAR(50)   NOT NULL,
  descripcion   TEXT          NULL,
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ   NULL,

  CONSTRAINT pk_permission 
        PRIMARY KEY (id_permission),
  CONSTRAINT uq_permission_nombre 
        UNIQUE (nombre)
);

-- ============================================================
-- TABLA: auth.user
-- Descripción: Almacena los usuarios registrados en el sistema.
--              Incluye datos personales, credenciales y estado
-- Referencia SRS: RF1.1, RF1.2, RF1.5, RF1.6, RF1.7, RF1.8
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.user (
  id_user           UUID          NOT NULL DEFAULT uuid_generate_v4(),
  nombre            VARCHAR(100)  NOT NULL,
  apellido          VARCHAR(100)  NOT NULL,
  username          VARCHAR(50)   NOT NULL,
  email             VARCHAR(255)  NOT NULL,
  password_hash     TEXT          NOT NULL,
  tipo_documento    VARCHAR(20)   NOT NULL,
  numero_documento  VARCHAR(30)   NOT NULL,
  estado            VARCHAR(20)   NOT NULL DEFAULT 'pendiente',
  email_verificado  BOOLEAN       NOT NULL DEFAULT FALSE,
  intentos_fallidos SMALLINT      NOT NULL DEFAULT 0,
  bloqueado_hasta   TIMESTAMPTZ   NULL,
  mfa_habilitado    BOOLEAN       NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ   NULL,

  CONSTRAINT pk_user                PRIMARY KEY (id_user),
  CONSTRAINT uq_user_email          UNIQUE (email),
  CONSTRAINT uq_user_username       UNIQUE (username),
  CONSTRAINT uq_user_documento      UNIQUE (numero_documento),
  CONSTRAINT ck_user_estado         CHECK (estado IN ('pendiente', 'activo', 'desactivado', 'bloqueado')),
  CONSTRAINT ck_user_tipo_documento CHECK (tipo_documento IN ('CC', 'CE', 'PAS')),
  CONSTRAINT ck_user_intentos       CHECK (intentos_fallidos >= 0)
);

-- ============================================================
-- TABLA: auth.user_role
-- Descripción: Relación muchos a muchos entre usuarios y roles
-- Referencia SRS: RF1.3
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.user_role (
  id_user_role UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user      UUID        NOT NULL,
  id_role      UUID        NOT NULL,
  asignado_por UUID        NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at   TIMESTAMPTZ NULL,

  CONSTRAINT pk_user_role         
         PRIMARY KEY (id_user_role),
  CONSTRAINT uq_user_role        
          UNIQUE (id_user, id_role),
);

-- ============================================================
-- TABLA: auth.role_permission
-- Descripción: Relación muchos a muchos entre roles y permisos
-- Referencia SRS: RF1.3
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.role_permission (
  id_role_permission UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_role            UUID        NOT NULL,
  id_permission      UUID        NOT NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at         TIMESTAMPTZ NULL,

  CONSTRAINT pk_role_permission     
         PRIMARY KEY (id_role_permission),
  CONSTRAINT uq_role_permission     
         UNIQUE (id_role, id_permission),
 
);

-- ============================================================
-- TABLA: auth.session
-- Descripción: Registra las sesiones activas de los usuarios,
--              incluyendo token de acceso y datos del dispositivo
-- Referencia SRS: RF1.2, RF1.4, RNF5.4
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.session (
  id_session    UUID         NOT NULL DEFAULT uuid_generate_v4(),
  id_user       UUID         NOT NULL,
  token         TEXT         NOT NULL,
  refresh_token TEXT         NULL,
  ip_address    VARCHAR(45)  NULL,
  user_agent    TEXT         NULL,
  recordar_sesion BOOLEAN    NOT NULL DEFAULT FALSE,
  expira_en     TIMESTAMPTZ  NOT NULL,
  activa        BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ  NULL,

  CONSTRAINT pk_session           PRIMARY KEY (id_session),
  CONSTRAINT uq_session_token     UNIQUE (token),
  CONSTRAINT uq_session_refresh   UNIQUE (refresh_token),
);

-- ============================================================
-- TABLA: auth.mfa
-- Descripción: Almacena la configuración de autenticación
--              multifactor (MFA) por usuario
-- Referencia SRS: RF1.3.1
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.mfa (
  id_mfa            UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user           UUID        NOT NULL,
  metodo            VARCHAR(20) NOT NULL,
  codigo_secreto    TEXT        NULL,
  habilitado        BOOLEAN     NOT NULL DEFAULT FALSE,
  ultimo_codigo_hash TEXT       NULL,
  expira_en         TIMESTAMPTZ NULL,
  intentos_fallidos SMALLINT    NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_mfa         PRIMARY KEY (id_mfa),
  CONSTRAINT uq_mfa_user    UNIQUE (id_user),
  CONSTRAINT ck_mfa_metodo  CHECK (metodo IN ('sms', 'email', 'app')),
  CONSTRAINT ck_mfa_intentos CHECK (intentos_fallidos >= 0)
);

-- ============================================================
-- TABLA: auth.recovery_token
-- Descripción: Tokens temporales para recuperación de contraseña
--              y activación/reactivación de cuenta
-- Referencia SRS: RF1.6, RF1.8
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.recovery_token (
  id_recovery_token UUID        NOT NULL DEFAULT uuid_generate_v4(),
  id_user           UUID        NOT NULL,
  token             TEXT        NOT NULL,
  tipo              VARCHAR(30) NOT NULL,
  expira_en         TIMESTAMPTZ NOT NULL,
  usado             BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_recovery_token      PRIMARY KEY (id_recovery_token),
  CONSTRAINT uq_recovery_token      UNIQUE (token),
  CONSTRAINT ck_recovery_token_tipo CHECK (tipo IN ('recuperacion_password', 'activacion_cuenta', 'reactivacion_cuenta'))
);

-- ============================================================
-- TABLA: auth.token_blacklist
-- Descripción: Registra los tokens JWT revocados para impedir
--              su reutilización después del cierre de sesión
-- Referencia SRS: RF1.4, RNF5.2
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.token_blacklist (
  id_token_blacklist UUID        NOT NULL DEFAULT uuid_generate_v4(),
  token              TEXT        NOT NULL,
  id_user            UUID        NOT NULL,
  motivo             VARCHAR(50) NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expira_en          TIMESTAMPTZ NOT NULL,

  CONSTRAINT pk_token_blacklist      PRIMARY KEY (id_token_blacklist),
  CONSTRAINT uq_token_blacklist      UNIQUE (token),
  CONSTRAINT ck_token_blacklist_motivo CHECK (motivo IN ('logout', 'cambio_password', 'desactivacion', 'expiracion'))
);
