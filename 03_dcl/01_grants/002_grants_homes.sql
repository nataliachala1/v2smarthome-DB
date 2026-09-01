-- ============================================================
-- GRANTS - Esquema homes
-- Archivo: 03_dcl/01_grants/002_grants_homes.sql
--
-- Modelo:
--   - homes.home
--   - homes.zone
--   - homes.electricity_tariff
--   - homes.home_member
--
-- Principios:
--   - NestJS utiliza smarthome_app.
--   - OWNER/MEMBER/GUEST se restringen mediante RLS.
--   - No se concede DELETE.
--   - No se utilizan ALL TABLES ni ALTER DEFAULT PRIVILEGES.
-- ============================================================

GRANT USAGE ON SCHEMA homes
TO
  smarthome_admin,
  smarthome_app,
  smarthome_readonly;

-- ============================================================
-- homes.home
-- ============================================================

GRANT SELECT, INSERT
ON TABLE homes.home
TO smarthome_app;

GRANT UPDATE (
  name,
  stratum,
  status,
  updated_at,
  deleted_at
)
ON TABLE homes.home
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE homes.home
TO smarthome_admin;

-- ============================================================
-- homes.zone
-- ============================================================

GRANT SELECT, INSERT
ON TABLE homes.zone
TO smarthome_app;

GRANT UPDATE (
  name,
  type,
  updated_at,
  deleted_at
)
ON TABLE homes.zone
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE homes.zone
TO smarthome_admin;

-- ============================================================
-- homes.home_member
-- ============================================================

GRANT SELECT, INSERT
ON TABLE homes.home_member
TO smarthome_app;

GRANT UPDATE (
  role,
  status,
  accepted_at,
  ended_at,
  updated_at
)
ON TABLE homes.home_member
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE homes.home_member
TO smarthome_admin;

-- ============================================================
-- homes.electricity_tariff
-- ============================================================

GRANT SELECT, INSERT
ON TABLE homes.electricity_tariff
TO smarthome_app;

GRANT UPDATE (
  price_per_kwh,
  currency,
  valid_from,
  valid_to
)
ON TABLE homes.electricity_tariff
TO smarthome_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE homes.electricity_tariff
TO smarthome_admin;
