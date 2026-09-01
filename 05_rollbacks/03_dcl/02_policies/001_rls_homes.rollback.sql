-- ============================================================
-- ROLLBACK — RLS homes
-- ============================================================


-- ============================================================
-- homes.home_member
-- ============================================================

DROP POLICY IF EXISTS
home_member_update_policy
ON homes.home_member;

DROP POLICY IF EXISTS
home_member_insert_policy
ON homes.home_member;

DROP POLICY IF EXISTS
home_member_select_policy
ON homes.home_member;

ALTER TABLE homes.home_member
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE homes.home_member
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- homes.electricity_tariff
-- ============================================================

DROP POLICY IF EXISTS
electricity_tariff_update_policy
ON homes.electricity_tariff;

DROP POLICY IF EXISTS
electricity_tariff_insert_policy
ON homes.electricity_tariff;

DROP POLICY IF EXISTS
electricity_tariff_select_policy
ON homes.electricity_tariff;

ALTER TABLE homes.electricity_tariff
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE homes.electricity_tariff
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- homes.zone
-- ============================================================

DROP POLICY IF EXISTS
zone_update_policy
ON homes.zone;

DROP POLICY IF EXISTS
zone_insert_policy
ON homes.zone;

DROP POLICY IF EXISTS
zone_select_policy
ON homes.zone;

ALTER TABLE homes.zone
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE homes.zone
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- homes.home
-- ============================================================

DROP POLICY IF EXISTS
home_update_policy
ON homes.home;

DROP POLICY IF EXISTS
home_insert_policy
ON homes.home;

DROP POLICY IF EXISTS
home_select_policy
ON homes.home;

ALTER TABLE homes.home
NO FORCE ROW LEVEL SECURITY;

ALTER TABLE homes.home
DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- EXECUTE helpers
-- ============================================================

REVOKE EXECUTE
ON FUNCTION homes.fn_self_membership_transition_allowed(
    UUID, UUID, UUID, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ
)
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION homes.fn_owner_membership_update_allowed(
    UUID, UUID, UUID, TEXT, TEXT, TIMESTAMPTZ
)
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION homes.fn_can_create_initial_owner(UUID, UUID)
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION homes.fn_can_manage_home(UUID)
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION homes.fn_is_home_owner(UUID)
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION homes.fn_is_home_member(UUID, TEXT[])
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION homes.fn_has_home_membership(UUID, TEXT[])
FROM smarthome_app;

REVOKE EXECUTE
ON FUNCTION auth.fn_is_system_admin()
FROM smarthome_app;