-- 01_ddl/04_alter/00x_add_alter_notifications.sql

ALTER TABLE notifications.notification
  ADD CONSTRAINT fk_notification_user
  FOREIGN KEY (id_user) REFERENCES auth.user (id_user),
  ADD CONSTRAINT fk_notification_alert
  FOREIGN KEY (id_alert) REFERENCES notifications.alert (id_alert) ON DELETE SET NULL,
  ADD CONSTRAINT fk_notification_home
  FOREIGN KEY (id_home) REFERENCES homes.home (id_home) ON DELETE SET NULL,
  ADD CONSTRAINT fk_notification_device
  FOREIGN KEY (id_device) REFERENCES devices.device (id_device) ON DELETE SET NULL;

ALTER TABLE notifications.alert
  ADD CONSTRAINT fk_alert_alert_rule
  FOREIGN KEY (id_alert_rule) REFERENCES notifications.alert_rule (id_alert_rule),
  ADD CONSTRAINT fk_alert_device
  FOREIGN KEY (id_device) REFERENCES devices.device (id_device),
  ADD CONSTRAINT fk_alert_home
  FOREIGN KEY (id_home) REFERENCES homes.home (id_home);