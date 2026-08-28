
ALTER TABLE sync.synchronization ADD CONSTRAINT fk_synchronization_user FOREIGN KEY (id_user) REFERENCES auth.user (id_user);
ALTER TABLE sync.backup ADD CONSTRAINT fk_backup_user FOREIGN KEY (id_user) REFERENCES auth.user (id_user) ON DELETE SET NULL;
