-- ============================================================
-- FUNCIONES TÉCNICAS — Seguridad RLS
-- Archivo: 01_ddl/07_functions/006_rls_security_functions.sql
--
-- Estas funciones NO implementan casos de uso.
-- Su responsabilidad es únicamente apoyar las políticas RLS.
--
-- IMPORTANTE:
-- Las funciones SECURITY DEFINER deben ser creadas por el
-- propietario técnico de la BD (smarthome_owner).
-- ============================================================


-- ============================================================
-- Usuario actual de aplicación
-- ============================================================

CREATE OR REPLACE FUNCTION auth.fn_current_user_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(
        current_setting('app.current_user_id', TRUE),
        ''
    )::UUID;
$$;


COMMENT ON FUNCTION auth.fn_current_user_id() IS
'Obtiene de forma segura el UUID del usuario actual definido mediante app.current_user_id. Devuelve NULL si el contexto no existe.';


-- ============================================================
-- ¿El usuario actual es SYSTEM_ADMIN?
-- ============================================================

CREATE OR REPLACE FUNCTION auth.fn_is_system_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM auth.user u
        JOIN auth.role r
          ON r.id_role = u.id_role
        WHERE u.id_user = auth.fn_current_user_id()
          AND u.status = 'ACTIVE'
          AND r.name = 'SYSTEM_ADMIN'
    );
$$;


-- ============================================================
-- Membresía del hogar en cualquier estado indicado
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_has_home_membership(
    p_id_home UUID,
    p_statuses TEXT[] DEFAULT ARRAY['ACTIVE']::TEXT[]
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home_member hm
        WHERE hm.id_home = p_id_home
          AND hm.id_user = auth.fn_current_user_id()
          AND hm.status = ANY(p_statuses)
    );
$$;


-- ============================================================
-- Membresía ACTIVE con rol autorizado
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_is_home_member(
    p_id_home UUID,
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
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home_member hm
        WHERE hm.id_home = p_id_home
          AND hm.id_user = auth.fn_current_user_id()
          AND hm.status = 'ACTIVE'
          AND hm.role = ANY(p_roles)
    );
$$;


-- ============================================================
-- OWNER activo
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_is_home_owner(
    p_id_home UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home_member hm
        WHERE hm.id_home = p_id_home
          AND hm.id_user = auth.fn_current_user_id()
          AND hm.role = 'OWNER'
          AND hm.status = 'ACTIVE'
    );
$$;


-- ============================================================
-- OWNER + hogar operativo
--
-- Utilizado para configuraciones críticas.
-- No se utiliza para reactivar el propio hogar porque un
-- hogar DEACTIVATED debe seguir siendo administrable por OWNER.
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_can_manage_home(
    p_id_home UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT
        homes.fn_is_home_owner(p_id_home)
        AND EXISTS (
            SELECT 1
            FROM homes.home h
            WHERE h.id_home = p_id_home
              AND h.status = 'ACTIVE'
              AND h.deleted_at IS NULL
        );
$$;


-- ============================================================
-- Crear OWNER inicial
--
-- Caso especial:
--
-- 1. NestJS crea homes.home.
-- 2. Todavía no existe home_member.
-- 3. Se crea la membresía OWNER inicial.
--
-- Solo puede hacerlo el mismo usuario que creó el hogar.
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_can_create_initial_owner(
    p_id_home UUID,
    p_id_user UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT
        p_id_user = auth.fn_current_user_id()

        AND EXISTS (
            SELECT 1
            FROM homes.home h
            WHERE h.id_home = p_id_home
              AND h.created_by = auth.fn_current_user_id()
              AND h.status = 'ACTIVE'
              AND h.deleted_at IS NULL
        )

        AND NOT EXISTS (
            SELECT 1
            FROM homes.home_member hm
            WHERE hm.id_home = p_id_home
              AND hm.role = 'OWNER'
              AND hm.status = 'ACTIVE'
        );
$$;


-- ============================================================
-- Cambio de membresía ejecutado por OWNER
--
-- El OWNER puede:
-- - cambiar MEMBER <-> GUEST;
-- - revocar una invitación PENDING;
-- - revocar una membresía ACTIVE.
--
-- No puede modificar mediante esta operación:
-- - la membresía OWNER;
-- - id_home;
-- - id_user;
-- - una membresía ya REVOKED/LEFT.
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_owner_membership_update_allowed(
    p_id_home_member UUID,
    p_id_home UUID,
    p_id_user UUID,
    p_role TEXT,
    p_status TEXT,
    p_ended_at TIMESTAMPTZ
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home_member old_hm
        WHERE old_hm.id_home_member = p_id_home_member

          AND homes.fn_can_manage_home(old_hm.id_home)

          AND old_hm.id_home = p_id_home
          AND old_hm.id_user = p_id_user

          AND old_hm.role IN ('MEMBER', 'GUEST')
          AND p_role IN ('MEMBER', 'GUEST')

          AND old_hm.status IN ('PENDING', 'ACTIVE')

          AND (
                p_status = old_hm.status

                OR (
                    p_status = 'REVOKED'
                    AND p_ended_at IS NOT NULL
                )
          )
    );
$$;


-- ============================================================
-- Cambio de la propia membresía
--
-- Permite exclusivamente:
--
-- PENDING -> ACTIVE    aceptar invitación
-- PENDING -> LEFT      rechazar invitación
-- ACTIVE  -> LEFT      abandonar hogar
--
-- MEMBER/GUEST nunca puede cambiarse su propio rol.
-- ============================================================

CREATE OR REPLACE FUNCTION homes.fn_self_membership_transition_allowed(
    p_id_home_member UUID,
    p_id_home UUID,
    p_id_user UUID,
    p_role TEXT,
    p_status TEXT,
    p_accepted_at TIMESTAMPTZ,
    p_ended_at TIMESTAMPTZ
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home_member old_hm
        WHERE old_hm.id_home_member = p_id_home_member

          AND old_hm.id_user = auth.fn_current_user_id()

          -- identidad de la membresía inmutable
          AND old_hm.id_home = p_id_home
          AND old_hm.id_user = p_id_user
          AND old_hm.role = p_role

          -- OWNER no puede abandonar/cambiarse mediante
          -- esta operación genérica.
          AND old_hm.role IN ('MEMBER', 'GUEST')

          AND (
              (
                  old_hm.status = 'PENDING'
                  AND p_status = 'ACTIVE'
                  AND p_accepted_at IS NOT NULL
                  AND p_ended_at IS NULL
              )

              OR

              (
                  old_hm.status = 'PENDING'
                  AND p_status = 'LEFT'
                  AND p_ended_at IS NOT NULL
              )

              OR

              (
                  old_hm.status = 'ACTIVE'
                  AND p_status = 'LEFT'
                  AND p_ended_at IS NOT NULL
              )
          )
    );
$$;


-- ============================================================
-- Seguridad de funciones SECURITY DEFINER
-- ============================================================

REVOKE ALL
ON FUNCTION auth.fn_is_system_admin()
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_has_home_membership(UUID, TEXT[])
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_is_home_member(UUID, TEXT[])
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_is_home_owner(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_can_manage_home(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_can_create_initial_owner(UUID, UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_owner_membership_update_allowed(
    UUID, UUID, UUID, TEXT, TEXT, TIMESTAMPTZ
)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION homes.fn_self_membership_transition_allowed(
    UUID, UUID, UUID, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ
)
FROM PUBLIC;