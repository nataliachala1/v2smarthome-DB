ALTER TABLE devices.device
  DROP CONSTRAINT IF EXISTS fk_device_zone_home,
  ALTER COLUMN id_zone DROP NOT NULL,
  ADD CONSTRAINT fk_device_zone
    FOREIGN KEY (id_zone)
    REFERENCES homes.zone (id_zone)
    ON DELETE SET NULL;

ALTER TABLE homes.zone
  DROP CONSTRAINT IF EXISTS uq_zone_id_zone_home;
