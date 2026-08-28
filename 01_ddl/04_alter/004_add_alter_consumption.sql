ALTER TABLE consumption.consumption
  ADD CONSTRAINT fk_consumption_device FOREIGN KEY (id_device) REFERENCES devices.device (id_device),
  ADD CONSTRAINT fk_consumption_home FOREIGN KEY (id_home) REFERENCES homes.home (id_home);
ALTER TABLE consumption.consumption_metric
  ADD CONSTRAINT fk_consumption_metric_device FOREIGN KEY (id_device) REFERENCES devices.device (id_device),
  ADD CONSTRAINT fk_consumption_metric_home FOREIGN KEY (id_home) REFERENCES homes.home (id_home);
ALTER TABLE consumption.recommendation
  ADD CONSTRAINT fk_recommendation_home FOREIGN KEY (id_home) REFERENCES homes.home (id_home),
  ADD CONSTRAINT fk_recommendation_device FOREIGN KEY (id_device) REFERENCES devices.device (id_device) ON DELETE SET NULL;
