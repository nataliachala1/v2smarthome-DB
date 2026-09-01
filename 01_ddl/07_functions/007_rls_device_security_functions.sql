-- ============================================================
-- FUNCIONES TÉCNICAS — RLS devices
-- Archivo:
-- 01_ddl/07_functions/007_rls_device_security_functions.sql
--
-- Estas funciones apoyan autorización e integridad de RLS.
-- No implementan los casos de uso del backend.
-- ============================================================


-- ============================================================
-- ¿El hogar está operativo?
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_is_home_active(
    p_id_home UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, homes
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home h
        WHERE h.id_home = p_id_home
          AND h.status = 'ACTIVE'
          AND h.deleted_at IS NULL
    );
$$;


-- ============================================================
-- ¿La zona existe, pertenece al hogar y está activa?
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_is_active_zone(
    p_id_zone UUID,
    p_id_home UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, homes, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.zone z
        WHERE z.id_zone = p_id_zone
          AND z.id_home = p_id_home
          AND z.deleted_at IS NULL
          AND homes.fn_is_home_active(z.id_home)
    );
$$;


-- ============================================================
-- ¿El tipo de dispositivo está disponible?
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_is_active_device_type(
    p_id_device_type UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device_type dt
        WHERE dt.id_device_type = p_id_device_type
          AND dt.deleted_at IS NULL
    );
$$;


-- ============================================================
-- ¿El usuario actual es OWNER del dispositivo?
--
-- No exige que el hogar/dispositivo esté activo.
-- Sirve para poder consultar registros desactivados.
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_is_device_owner(
    p_id_device UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device d
        WHERE d.id_device = p_id_device
          AND homes.fn_is_home_owner(d.id_home)
    );
$$;


-- ============================================================
-- ¿Puede consultar/usar un dispositivo activo?
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_can_view_device(
    p_id_device UUID,
    p_roles TEXT[] DEFAULT ARRAY[
        'OWNER',
        'MEMBER',
        'GUEST'
    ]::TEXT[]
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device d
        WHERE d.id_device = p_id_device

          AND d.status = 'ACTIVE'
          AND d.deleted_at IS NULL

          AND homes.fn_is_home_active(d.id_home)

          AND homes.fn_is_home_member(
              d.id_home,
              p_roles
          )
    );
$$;


-- ============================================================
-- ¿El OWNER puede administrar el dispositivo?
--
-- El hogar sí debe estar ACTIVE.
-- El dispositivo puede estar DEACTIVATED porque el OWNER
-- debe poder reactivarlo.
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_can_manage_device(
    p_id_device UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device d
        WHERE d.id_device = p_id_device
          AND homes.fn_can_manage_home(d.id_home)
    );
$$;


-- ============================================================
-- ¿El dispositivo puede aceptar telemetría IoT?
--
-- No exige que el hogar esté ACTIVE porque el hardware puede
-- continuar enviando payloads aunque el hogar esté desactivado.
-- La telemetría raw sigue siendo útil para diagnóstico.
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_is_ingestable_device(
    p_id_device UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device d
        WHERE d.id_device = p_id_device
          AND d.status = 'ACTIVE'
          AND d.deleted_at IS NULL
    );
$$;


-- ============================================================
-- Validación de UPDATE realizado mediante smarthome_app
--
-- OWNER:
--   puede modificar configuración permitida por GRANT.
--
-- MEMBER:
--   únicamente puede cambiar is_on.
--
-- GUEST:
--   no puede modificar el dispositivo.
--
-- La función compara NEW con la fila anterior para evitar que
-- un MEMBER utilice el UPDATE general del rol técnico para
-- cambiar nombre, zona, estado, tipo o configuración.
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_device_app_update_allowed(
    p_id_device              UUID,
    p_id_home                UUID,
    p_id_zone                UUID,
    p_id_device_type         UUID,
    p_name                   TEXT,
    p_status                 TEXT,
    p_is_on                  BOOLEAN,
    p_transport_type         TEXT,
    p_messaging_protocol     TEXT,
    p_deleted_at             TIMESTAMPTZ
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device old_d
        WHERE old_d.id_device = p_id_device

          -- Un dispositivo nunca cambia de hogar mediante
          -- una actualización normal.
          AND old_d.id_home = p_id_home

          AND (
              -- ==============================================
              -- OWNER
              -- ==============================================
              (
                  homes.fn_can_manage_home(old_d.id_home)

                  AND devices.fn_is_active_zone(
                      p_id_zone,
                      old_d.id_home
                  )

                  AND devices.fn_is_active_device_type(
                      p_id_device_type
                  )

                  AND (
                      (
                          p_status = 'ACTIVE'
                          AND p_deleted_at IS NULL
                      )
                      OR
                      (
                          p_status = 'DEACTIVATED'
                          AND p_deleted_at IS NOT NULL
                      )
                  )
              )

              OR

              -- ==============================================
              -- MEMBER
              --
              -- Solo puede cambiar is_on.
              -- Todo lo demás debe seguir idéntico.
              -- ==============================================
              (
                  old_d.status = 'ACTIVE'
                  AND old_d.deleted_at IS NULL

                  AND homes.fn_is_home_active(old_d.id_home)

                  AND homes.fn_is_home_member(
                      old_d.id_home,
                      ARRAY['MEMBER']::TEXT[]
                  )

                  AND p_id_zone = old_d.id_zone

                  AND p_id_device_type = old_d.id_device_type

                  AND p_name
                      IS NOT DISTINCT FROM old_d.name

                  AND p_status
                      IS NOT DISTINCT FROM old_d.status

                  AND p_transport_type
                      IS NOT DISTINCT FROM old_d.transport_type

                  AND p_messaging_protocol
                      IS NOT DISTINCT FROM old_d.messaging_protocol

                  AND p_deleted_at
                      IS NOT DISTINCT FROM old_d.deleted_at

                  -- p_is_on deliberadamente NO se compara.
                  -- Es la única propiedad funcional que
                  -- MEMBER puede modificar.
              )
          )
    );
$$;


-- ============================================================
-- Seguridad de SECURITY DEFINER
-- ============================================================

REVOKE ALL
ON FUNCTION homes.fn_is_home_active(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_is_active_zone(UUID, UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_is_active_device_type(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_is_device_owner(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_can_view_device(UUID, TEXT[])
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_can_manage_device(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_is_ingestable_device(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION devices.fn_device_app_update_allowed(
    UUID,
    UUID,
    UUID,
    UUID,
    TEXT,
    TEXT,
    BOOLEAN,
    TEXT,
    TEXT,
    TIMESTAMPTZ
)
FROM PUBLIC;