ALTER TABLE config.configuration_user
  ADD CONSTRAINT fk_configuration_user_user FOREIGN KEY (id_user) REFERENCES auth.user (id_user);
