-- ============================================================
-- RLS: notifications.alert_rule
-- ============================================================
ALTER TABLE notifications.alert_rule ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications.alert_rule FORCE ROW LEVEL SECURITY;

CREATE POLICY alert_rule_select_policy ON notifications.alert_rule
  FOR SELECT TO smarthome_app
  USING (
    id_device IN (
      SELECT id_device FROM devices.device d
      WHERE homes.fn_is_home_member(d.id_home)
        AND d.deleted_at IS NULL
    )
    AND deleted_at IS NULL
  );

CREATE POLICY alert_rule_insert_policy ON notifications.alert_rule
  FOR INSERT TO smarthome_app
  WITH CHECK (
    id_device IN (
      SELECT id_device FROM devices.device d
      WHERE homes.fn_is_home_member(d.id_home, ARRAY['OWNER', 'MEMBER'])
        AND d.deleted_at IS NULL
    )
  );

CREATE POLICY alert_rule_update_policy ON notifications.alert_rule
  FOR UPDATE TO smarthome_app
  USING (
    id_device IN (
      SELECT id_device FROM devices.device d
      WHERE homes.fn_is_home_member(d.id_home, ARRAY['OWNER', 'MEMBER'])
        AND d.deleted_at IS NULL
    )
    AND deleted_at IS NULL
  );

CREATE POLICY alert_rule_ingest_select_policy ON notifications.alert_rule
  FOR SELECT TO smarthome_ingest
  USING (active AND deleted_at IS NULL);

-- ============================================================
-- RLS: notifications.alert
-- ============================================================
ALTER TABLE notifications.alert ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications.alert FORCE ROW LEVEL SECURITY;

CREATE POLICY alert_select_policy ON notifications.alert
  FOR SELECT TO smarthome_app
  USING (
    homes.fn_is_home_member(id_home)
  );

CREATE POLICY alert_ingest_insert_policy ON notifications.alert
  FOR INSERT TO smarthome_ingest
  WITH CHECK (true);

-- ============================================================
-- RLS: notifications.notification
-- ============================================================
ALTER TABLE notifications.notification ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications.notification FORCE ROW LEVEL SECURITY;

CREATE POLICY notification_select_policy ON notifications.notification
  FOR SELECT TO smarthome_app
  USING (
    id_user = auth.fn_current_user_id()
  );

CREATE POLICY notification_update_policy ON notifications.notification
  FOR UPDATE TO smarthome_app
  USING (
    id_user = auth.fn_current_user_id()
  );

CREATE POLICY notification_ingest_insert_policy ON notifications.notification
  FOR INSERT TO smarthome_ingest
  WITH CHECK (true);