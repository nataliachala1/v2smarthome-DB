ALTER TABLE notifications.reminder_notification DROP CONSTRAINT IF EXISTS fk_reminder_notification_home;
ALTER TABLE notifications.reminder_notification DROP CONSTRAINT IF EXISTS fk_reminder_notification_user;
ALTER TABLE notifications.alert DROP CONSTRAINT IF EXISTS fk_alert_home;
ALTER TABLE notifications.alert DROP CONSTRAINT IF EXISTS fk_alert_device;
ALTER TABLE notifications.alert DROP CONSTRAINT IF EXISTS fk_alert_threshold_rule;
ALTER TABLE notifications.notification DROP CONSTRAINT IF EXISTS fk_notification_device;
ALTER TABLE notifications.notification DROP CONSTRAINT IF EXISTS fk_notification_home;
ALTER TABLE notifications.notification DROP CONSTRAINT IF EXISTS fk_notification_user;
