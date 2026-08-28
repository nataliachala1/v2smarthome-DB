-- Habilitar RLS en la tabla devices.device_schedule
ALTER TABLE devices.device_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices.device_schedule FORCE ROW LEVEL SECURITY;

-- Función helper (ya debe existir; si no, créala)
CREATE OR REPLACE FUNCTION auth.current_user_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;
$$;

-- Política SELECT (solo miembros activos del hogar)
CREATE POLICY schedule_select_policy ON devices.device_schedule
  FOR SELECT TO smarthome_app
  USING (
    EXISTS (
      SELECT 1 FROM homes.home_member hm
      WHERE hm.id_home = schedule.id_home
        AND hm.id_user = auth.current_user_id()
        AND hm.status = 'ACTIVE'
    )
    AND deleted_at IS NULL
  );

-- Política INSERT (solo OWNER o MEMBER)
CREATE POLICY schedule_insert_policy ON devices.device_schedule
  FOR INSERT TO smarthome_app
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM homes.home_member hm
      WHERE hm.id_home = schedule.id_home
        AND hm.id_user = auth.current_user_id()
        AND hm.status = 'ACTIVE'
        AND hm.role IN ('OWNER', 'MEMBER')
    )
  );

-- Política UPDATE (solo OWNER o MEMBER)
CREATE POLICY schedule_update_policy ON devices.device_schedule
  FOR UPDATE TO smarthome_app
  USING (
    EXISTS (
      SELECT 1 FROM homes.home_member hm
      WHERE hm.id_home = schedule.id_home
        AND hm.id_user = auth.current_user_id()
        AND hm.status = 'ACTIVE'
        AND hm.role IN ('OWNER', 'MEMBER')
    )
    AND deleted_at IS NULL
  );

-- Política DELETE (solo OWNER)
CREATE POLICY schedule_delete_policy ON devices.device_schedule
  FOR DELETE TO smarthome_app
  USING (
    EXISTS (
      SELECT 1 FROM homes.home_member hm
      WHERE hm.id_home = schedule.id_home
        AND hm.id_user = auth.current_user_id()
        AND hm.status = 'ACTIVE'
        AND hm.role = 'OWNER'
    )
    AND deleted_at IS NULL
  );