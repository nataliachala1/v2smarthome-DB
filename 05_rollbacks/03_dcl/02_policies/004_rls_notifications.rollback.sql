-- ============================================================
-- ROLLBACK — RLS notifications
-- ============================================================


-- ============================================================
-- notification
-- ============================================================

DROP POLICY IF EXISTS
notification_worker_insert_policy
ON notifications.notification;

DROP POLICY IF EXISTS
notification_ingest_insert_policy
ON notifications.notification;

DROP POLICY IF EXISTS
notification_app_update_policy
ON notifications.notification;

DROP POLICY IF EXISTS
notification_app_select_policy
ON notifications.notification;

ALTER TABLE notifications.notification
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE notifications.notification
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- alert
-- ============================================================

DROP POLICY IF EXISTS
alert_ingest_insert_policy
ON notifications.alert;

ALTER TABLE notifications.alert
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE notifications.alert
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- alert_rule
-- ============================================================

DROP POLICY IF EXISTS
alert_rule_ingest_select_policy
ON notifications.alert_rule;

DROP POLICY IF EXISTS
alert_rule_app_update_policy
ON notifications.alert_rule;

DROP POLICY IF EXISTS
alert_rule_app_insert_policy
ON notifications.alert_rule;

DROP POLICY IF EXISTS
alert_rule_app_select_policy
ON notifications.alert_rule;

ALTER TABLE notifications.alert_rule
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE notifications.alert_rule
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- Helpers
-- ============================================================

REVOKE EXECUTE
ON FUNCTION notifications.fn_notification_status_transition_allowed(
    UUID,
    UUID,
    TEXT
)
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION notifications.fn_can_generate_alert(
    UUID,
    UUID,
    UUID,
    TEXT
)
FROM smarthome_ingest;

REVOKE EXECUTE
ON FUNCTION notifications.fn_recipient_has_home_role(
    UUID,
    UUID,
    TEXT[],
    TEXT[]
)
FROM
    smarthome_ingest,
    smarthome_worker;

REVOKE EXECUTE
ON FUNCTION auth.fn_is_active_user(UUID)
FROM
    smarthome_ingest,
    smarthome_worker;