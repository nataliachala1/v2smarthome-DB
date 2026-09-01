-- 01_ddl/04_alter/00x_add_alter_notifications.sql

ALTER TABLE notifications.notification

ADD CONSTRAINT ck_notification_type
CHECK (
    type IN (
        'ALERT',
        'RECOMMENDATION',
        'SYSTEM'
    )
),

ADD CONSTRAINT ck_notification_device_context
CHECK (
    id_device IS NULL
    OR id_home IS NOT NULL
),

ADD CONSTRAINT ck_notification_alert_context
CHECK (
    id_alert IS NULL
    OR (
        id_home IS NOT NULL
        AND id_device IS NOT NULL
    )
);

ALTER TABLE notifications.notification

    ADD CONSTRAINT fk_notification_user
        FOREIGN KEY (id_user)
        REFERENCES auth.user(id_user),

    ADD CONSTRAINT fk_notification_alert_context
        FOREIGN KEY (
            id_alert,
            id_home,
            id_device
        )
        REFERENCES notifications.alert (
            id_alert,
            id_home,
            id_device
        ),

    ADD CONSTRAINT fk_notification_device_home
        FOREIGN KEY (
            id_device,
            id_home
        )
        REFERENCES devices.device (
            id_device,
            id_home
        );
      
ALTER TABLE notifications.notification
ADD CONSTRAINT fk_notification_home
FOREIGN KEY (id_home)
REFERENCES homes.home(id_home);
-- ============================================================
-- ALERT
-- ============================================================

ALTER TABLE notifications.alert

    ADD CONSTRAINT fk_alert_rule_device
        FOREIGN KEY (
            id_alert_rule,
            id_device
        )
        REFERENCES notifications.alert_rule (
            id_alert_rule,
            id_device
        ),

    ADD CONSTRAINT fk_alert_device_home
        FOREIGN KEY (
            id_device,
            id_home
        )
        REFERENCES devices.device (
            id_device,
            id_home
        );

ALTER TABLE notifications.alert_rule
ADD CONSTRAINT uq_alert_rule_device
UNIQUE (
    id_alert_rule,
    id_device
);