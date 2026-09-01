-- ============================================================
-- TABLAS — Esquema auth
-- Archivo: 01_ddl/03_tables/001_create_auth_tables.sql
-- Descripción: Modelo de autenticación simplificado según el
--              alcance actualizado (ago-2026):
--              - Catálogo mínimo de roles globales (SYSTEM_ADMIN, USER)
--              - Sin RBAC granular (no permission/role_permission/user_role)
--              - Sin MFA, sin auth.session, sin token_blacklist
--              - Columnas en inglés snake_case
-- Dependencias: 00_extensions, 01_schemas
-- ============================================================

-- ============================================================
-- TABLA: auth.role
-- Catálogo mínimo de roles globales de plataforma.
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.role (
  id_role     UUID        NOT NULL DEFAULT gen_random_uuid(),
  name        VARCHAR(20) NOT NULL,
  description TEXT        NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_role      PRIMARY KEY (id_role),
  CONSTRAINT uq_role_name UNIQUE (name),
  CONSTRAINT ck_role_name CHECK (name IN ('SYSTEM_ADMIN', 'USER'))
);

-- ============================================================
-- TABLA: auth.user
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.user (
  id_user               UUID         NOT NULL DEFAULT gen_random_uuid(),
  id_role               UUID         NOT NULL,
  name              VARCHAR(50)  NOT NULL,
  email                 VARCHAR(255) NOT NULL,
  password_hash         TEXT         NOT NULL,
  status                VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  email_verified        BOOLEAN      NOT NULL DEFAULT FALSE,
  failed_login_attempts SMALLINT     NOT NULL DEFAULT 0,
  locked_until          TIMESTAMPTZ  NULL,
  last_login_at         TIMESTAMPTZ  NULL,
  created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_user                 PRIMARY KEY (id_user),
  CONSTRAINT ck_user_status          CHECK (status IN ('PENDING', 'ACTIVE', 'DEACTIVATED', 'LOCKED')),
  CONSTRAINT ck_user_failed_attempts CHECK (failed_login_attempts >= 0)
);

-- Email único e insensible a mayúsculas/minúsculas (Paso 5)
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_email_lower
  ON auth.user (LOWER(email));

-- ============================================================
-- TABLA: auth.recovery_token
-- Recuperación de contraseña y activación/reactivación de cuenta.
-- Solo se almacena el HASH del token (alcance §11).
-- ============================================================
CREATE TABLE IF NOT EXISTS auth.recovery_token (
  id_recovery_token UUID        NOT NULL DEFAULT gen_random_uuid(),
  id_user           UUID        NOT NULL,
  token_hash        TEXT        NOT NULL,
  type              VARCHAR(30) NOT NULL,
  expires_at        TIMESTAMPTZ NOT NULL,
  used_at           TIMESTAMPTZ NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_recovery_token      PRIMARY KEY (id_recovery_token),
  CONSTRAINT uq_recovery_token_hash UNIQUE (token_hash),
  CONSTRAINT ck_recovery_token_type CHECK (
    type IN ('PASSWORD_RESET', 'ACCOUNT_ACTIVATION', 'ACCOUNT_REACTIVATION')
  )
);

CREATE INDEX IF NOT EXISTS idx_recovery_token_user
  ON auth.recovery_token (id_user);