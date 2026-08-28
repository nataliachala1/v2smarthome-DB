ALTER TABLE homes.zone
  ADD CONSTRAINT uq_zone_id_zone_home
    UNIQUE (id_zone, id_home);

ALTER TABLE devices.device
  DROP CONSTRAINT fk_device_zone_home,
  ALTER COLUMN id_zone SET NOT NULL,
  ADD CONSTRAINT fk_device_zone_home
    FOREIGN KEY (id_zone, id_home)
    REFERENCES homes.zone (id_zone, id_home);
