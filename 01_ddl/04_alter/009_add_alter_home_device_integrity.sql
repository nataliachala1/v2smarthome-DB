ALTER TABLE devices.device
  DROP CONSTRAINT IF EXISTS fk_device_zone_home,
  ALTER COLUMN id_zone SET NOT NULL,
  ADD CONSTRAINT fk_device_zone_home
    FOREIGN KEY (id_zone, id_home)
    REFERENCES homes.zone (id_zone, id_home);
