-- ============================================================
-- FUNCIONES TÉCNICAS — RLS consumption
-- ============================================================


-- ============================================================
-- Verifica que un dispositivo pertenezca al hogar indicado.
--
-- No valida si está ACTIVE porque también sirve para
-- históricos de dispositivos desactivados.
-- ============================================================

CREATE OR REPLACE FUNCTION devices.fn_device_belongs_to_home(
    p_id_device UUID,
    p_id_home   UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, devices
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM devices.device d
        WHERE d.id_device = p_id_device
          AND d.id_home = p_id_home
    );
$$;


REVOKE ALL
ON FUNCTION devices.fn_device_belongs_to_home(UUID, UUID)
FROM PUBLIC;