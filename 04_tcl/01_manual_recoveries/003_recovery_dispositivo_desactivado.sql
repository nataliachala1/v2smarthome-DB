-- Recuperación manual de dispositivo desactivado
BEGIN;

  UPDATE devices.device
  SET status = 'activo', encendido = FALSE, updated_at = NOW()
  WHERE id_device = :id_device AND status = 'desactivado';

  INSERT INTO identity_audit.audit_log (
    id_audit_log, id_user, accion, modulo,
    entidad, id_entidad, resultado, detalle, created_at
  ) VALUES (
    gen_random_uuid(), :id_user, 'recuperacion', 'devices',
    'device', :id_device, 'exitoso',
    'Recuperación manual de dispositivo desactivado', NOW()
  );

COMMIT;

-- En caso de error
-- ROLLBACK;
