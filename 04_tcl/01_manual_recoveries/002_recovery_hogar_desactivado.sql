-- Recuperación manual de hogar desactivado
BEGIN;

  UPDATE homes.home
  SET status = 'activo', updated_at = NOW()
  WHERE id_home = :id_home AND status = 'desactivado';

  INSERT INTO identity_audit.audit_log (
    id_audit_log, id_user, accion, modulo,
    entidad, id_entidad, resultado, detalle, created_at
  ) VALUES (
    gen_random_uuid(), :id_user, 'recuperacion', 'homes',
    'home', :id_home, 'exitoso',
    'Recuperación manual de hogar desactivado', NOW()
  );

COMMIT;

-- En caso de error
-- ROLLBACK;
