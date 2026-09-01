CREATE OR REPLACE PROCEDURE sp_registrar_usuario(
  IN  p_username      VARCHAR(50),
  IN  p_email         VARCHAR(255),
  IN  p_password_hash TEXT,          -- ya hasheado con Argon2id (o bcrypt) en NestJS
  OUT p_id_user       UUID
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_role_user CONSTANT UUID := 'a1b2c3d4-0001-0000-0000-000000000002'; -- Ajusta al UUID real de USER en auth.role
  v_token_plain  TEXT;
  v_token_hash   TEXT;
BEGIN
  p_id_user := gen_random_uuid();
  v_token_plain := encode(gen_random_bytes(32), 'hex');
  v_token_hash  := crypt(v_token_plain, gen_salt('bf', 12));

  INSERT INTO auth.user (
    id_user, id_role, username, email, password_hash,
    status, email_verified, created_at, updated_at
  ) VALUES (
    p_id_user, v_id_role_user, p_username, p_email, p_password_hash,
    'PENDING', FALSE, NOW(), NOW()
  );

  INSERT INTO auth.recovery_token (
    id_recovery_token, id_user, token_hash, type, expires_at, created_at
  ) VALUES (
    gen_random_uuid(), p_id_user, v_token_hash,
    'ACCOUNT_ACTIVATION', NOW() + INTERVAL '24 hours', NOW()
  );

  -- No devolvemos el token; el backend puede consultarlo después si necesita enviarlo.
EXCEPTION
  WHEN unique_violation THEN
    RAISE EXCEPTION 'El username o email ya están registrados.';
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error al registrar usuario: %', SQLERRM;
END;
$$;