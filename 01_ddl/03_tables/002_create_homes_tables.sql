-- ============================================================
-- TABLAS — Esquema homes
-- Archivo: 01_ddl/03_tables/003_create_homes_tables.sql
-- Descripción: Creación de las 4 tablas del esquema homes
--              para gestión de hogares, zonas, tarifas
--              y miembros del hogar
-- Dependencias: 00_extensions, 01_schemas, auth.user
-- ============================================================

-- ============================================================
-- TABLA: homes.home
-- Descripción: Almacena los hogares registrados en el sistema.
--              Un usuario puede registrar múltiples hogares
-- Referencia SRS: RF2.1, RF2.2, RF2.4
-- ============================================================
CREATE TABLE IF NOT EXISTS homes.home (
    id_home     UUID         NOT NULL DEFAULT uuid_generate_v4(),
    id_user     UUID         NOT NULL,
    nombre      VARCHAR(100) NOT NULL,
    estrato     SMALLINT     NOT NULL,
    estado      VARCHAR(20)  NOT NULL DEFAULT 'activo',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ  NULL,

    CONSTRAINT pk_home
        PRIMARY KEY (id_home),

    CONSTRAINT uq_home_nombre
        UNIQUE (id_user, nombre),

    CONSTRAINT ck_home_estrato
        CHECK (estrato BETWEEN 1 AND 6),

    CONSTRAINT ck_home_estado
        CHECK (estado IN ('activo', 'desactivado'))
);
-- ============================================================
-- TABLA: homes.area
-- Descripción: Representa las zonas o habitaciones dentro
--              de un hogar para organizar dispositivos
--              por ubicación física
-- Referencia SRS: ERF2.1.1
-- ============================================================
CREATE TABLE IF NOT EXISTS homes.area (
    id_area     UUID         NOT NULL DEFAULT uuid_generate_v4(),
    id_home     UUID         NOT NULL,
    nombre      VARCHAR(100) NOT NULL,
    tipo        VARCHAR(50)  NULL,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ  NULL,

    CONSTRAINT pk_area
        PRIMARY KEY (id_area),

    CONSTRAINT uq_area_nombre
        UNIQUE (id_home, nombre),

    CONSTRAINT ck_area_tipo
        CHECK (
            tipo IS NULL OR
            tipo IN ('sala', 'cocina', 'dormitorio', 'baño', 'exterior', 'otro')
        )
);

-- ============================================================
-- TABLA: homes.tariff
-- Descripción: Almacena las tarifas eléctricas configuradas
--              por hogar para calcular costos y proyecciones
--              de facturación mensual
-- Referencia SRS: RF2.5
-- ============================================================
CREATE TABLE IF NOT EXISTS homes.tariff (
    id_tariff      UUID          NOT NULL DEFAULT uuid_generate_v4(),
    id_home        UUID          NOT NULL,
    costo_kwh      NUMERIC(10,4) NOT NULL,
    moneda         VARCHAR(10)   NOT NULL DEFAULT 'COP',
    vigente_desde  DATE          NOT NULL,
    vigente_hasta  DATE          NULL,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    deleted_at     TIMESTAMPTZ   NULL,

    CONSTRAINT pk_tariff
        PRIMARY KEY (id_tariff),

    CONSTRAINT ck_tariff_costo
        CHECK (costo_kwh > 0),

    CONSTRAINT ck_tariff_vigencia
        CHECK (
            vigente_hasta IS NULL OR
            vigente_hasta > vigente_desde
        )
);
-- ============================================================
-- TABLA: homes.home_member
-- Descripción: Gestiona los miembros adicionales de un hogar.
--              Permite que varios usuarios compartan la gestión
--              de un mismo hogar con roles diferenciados
-- Referencia SRS: RF2.3
-- ============================================================
CREATE TABLE IF NOT EXISTS homes.home_member (
    id_home_member UUID        NOT NULL DEFAULT uuid_generate_v4(),
    id_home        UUID        NOT NULL,
    id_user        UUID        NOT NULL,
    rol_en_hogar   VARCHAR(30) NOT NULL DEFAULT 'miembro',
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at     TIMESTAMPTZ NULL,

    CONSTRAINT pk_home_member
        PRIMARY KEY (id_home_member),

    CONSTRAINT uq_home_member
        UNIQUE (id_home, id_user),

    CONSTRAINT ck_home_member_rol
        CHECK (
            rol_en_hogar IN ('propietario', 'administrador', 'miembro')
        )
);
