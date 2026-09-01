-- ============================================================
-- FUNCIONES TÉCNICAS — RLS notifications
-- ============================================================


-- ============================================================
-- Usuario destinatario activo
-- ============================================================

CREATE OR REPLACE FUNCTION auth.fn_is_active_user(
    p_id_user UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM auth.user u
        WHERE u.id_user = p_id_user
          AND u.status = 'ACTIVE'
    );
$$;


-- ============================================================
-- Verifica membresía de un destinatario específico.
--
-- A diferencia de homes.fn_is_home_member(), esta función
-- recibe explícitamente el usuario porque se utiliza desde
-- actores técnicos como ingest/worker.
-- ============================================================

CREATE OR REPLACE FUNCTION notifications.fn_recipient_has_home_role(
    p_id_user   UUID,
    p_id_home   UUID,
    p_roles     TEXT[],
    p_statuses  TEXT[] DEFAULT ARRAY['ACTIVE']::TEXT[]
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, homes, notifications
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM homes.home_member hm
        JOIN auth.user u
          ON u.id_user = hm.id_user
        WHERE hm.id_user = p_id_user
          AND hm.id_home = p_id_home
          AND hm.role = ANY(p_roles)
          AND hm.status = ANY(p_statuses)
          AND u.status = 'ACTIVE'
    );
$$;


-- ============================================================
-- ¿Puede generarse esta alerta?
--
-- THRESHOLD:
--   necesita regla activa del mismo dispositivo.
--
-- ANOMALY / DEVICE_EVENT:
--   no necesitan alert_rule.
--
-- En todos los casos:
--   dispositivo ACTIVE
--   hogar ACTIVE
--   device pertenece a home
-- ============================================================

CREATE OR REPLACE FUNCTION notifications.fn_can_generate_alert(
    p_id_alert_rule UUID,
    p_id_device     UUID,
    p_id_home       UUID,
    p_alert_type    TEXT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, homes, devices, notifications
AS $$
    SELECT

        homes.fn_is_home_active(p_id_home)

        AND devices.fn_is_ingestable_device(p_id_device)

        AND devices.fn_device_belongs_to_home(
            p_id_device,
            p_id_home
        )

        AND (
            (
                p_alert_type = 'THRESHOLD'

                AND p_id_alert_rule IS NOT NULL

                AND EXISTS (
                    SELECT 1
                    FROM notifications.alert_rule ar
                    WHERE ar.id_alert_rule = p_id_alert_rule
                      AND ar.id_device = p_id_device
                      AND ar.active = TRUE
                      AND ar.deleted_at IS NULL
                )
            )

            OR

            (
                p_alert_type IN (
                    'ANOMALY',
                    'DEVICE_EVENT'
                )

                AND p_id_alert_rule IS NULL
            )
        );
$$;


-- ============================================================
-- Transición permitida del estado visual de notificación.
--
-- UNREAD -> READ
-- UNREAD -> DISMISSED
-- READ   -> DISMISSED
--
-- Se permite también mantener el mismo estado para hacer
-- operaciones idempotentes.
-- ============================================================

CREATE OR REPLACE FUNCTION notifications.fn_notification_status_transition_allowed(
    p_id_notification UUID,
    p_id_user         UUID,
    p_new_status      TEXT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, auth, notifications
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM notifications.notification n
        WHERE n.id_notification = p_id_notification

          AND n.id_user = p_id_user

          AND p_id_user = auth.fn_current_user_id()

          AND (
              p_new_status = n.status

              OR (
                  n.status = 'UNREAD'
                  AND p_new_status IN (
                      'READ',
                      'DISMISSED'
                  )
              )

              OR (
                  n.status = 'READ'
                  AND p_new_status = 'DISMISSED'
              )
          )
    );
$$;


-- ============================================================
-- Seguridad SECURITY DEFINER
-- ============================================================

REVOKE ALL
ON FUNCTION auth.fn_is_active_user(UUID)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION notifications.fn_recipient_has_home_role(
    UUID,
    UUID,
    TEXT[],
    TEXT[]
)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION notifications.fn_can_generate_alert(
    UUID,
    UUID,
    UUID,
    TEXT
)
FROM PUBLIC;

REVOKE ALL
ON FUNCTION notifications.fn_notification_status_transition_allowed(
    UUID,
    UUID,
    TEXT
)
FROM PUBLIC;