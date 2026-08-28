# v2smarthome-DB
Base de datos versión 2 del proyecto smarthome


Grupo 1 — Estructura de migración (Paso 3)

changelog/changelog-master.yaml
01_ddl/changelog.yaml y los changelog.yaml de cada subcarpeta de 01_ddl (schemas, tables, alter, functions, procedures, triggers, indexes, views, materialized_views)
02_dml/changelog.yaml, 03_dcl/changelog.yaml, 04_tcl/changelog.yaml

Grupo 2 — Modelo de autenticación y hogares (Pasos 5 y 6)

01_ddl/01_schemas/001_create_schemas_auth.sql y 008_create_schemas_identity_audit.sql
01_ddl/03_tables/001_create_auth_tables.sql
01_ddl/03_tables/002_create_homes_tables.sql
01_ddl/04_alter/001_add_alter_auth.sql y 002_add_alter_homes.sql

Grupo 3 — Dispositivos y zonas (Paso 7)

01_ddl/03_tables/003_create_devices_tables.sql
01_ddl/04_alter/003_add_alter_devices.sql y 009_add_alter_home_device_integrity.sql

Grupo 4 — Consumo/telemetría (Paso 8)

01_ddl/03_tables/004_create_consumption_tables.sql
01_ddl/06_materialized_views/001_mv_resumen_diario_homes.sql y 002_mv_resumen_mensual_homes.sql

Grupo 5 — RLS y DCL (Pasos 9 y 10)

Todo 03_dcl/00_roles, 03_dcl/01_grants, 03_dcl/02_policies (ya tengo la versión documentada, pero necesito el SQL real actual para saber qué cambió)

Grupo 6 — Auditoría (Paso 11)

01_ddl/03_tables/008_create_identity_audit_tables.sql
01_ddl/07_functions/002_audit_log_functions.sql

Hola, estoy cambiando unas cosas de mi base de datos, te envio los documentos correspondientes. dime que archivos te envio para que me ayudes a corregir e implementar los cambios. a los changelogs ya les coloque su id, ese paso podemos darlo por completado. tambien te comparto el arbol.

C:.
│   .gitignore
│   README.md
│   REVISION_ESTADO_Y_PASOS_PENDIENTES.md
│   text.md
│   
├───01_ddl
│   │   changelog.yaml
│   │   
│   ├───00_extensions
│   │       .gitkeep
│   │       001_enable_uuid_extension.sql
│   │       changelog.yaml
│   │       
│   ├───01_schemas
│   │       .gitkeep
│   │       001_create_schemas_auth.sql
│   │       002_create_schemas_homes.sql
│   │       003_create_schemas_devices.sql
│   │       004_create_schemas_consumption.sql
│   │       005_create_schemas_notifications.sql
│   │       006_create_schemas_sync.sql
│   │       007_create_schemas_config.sql
│   │       008_create_schemas_identity_audit.sql
│   │       changelog.yaml
│   │       
│   ├───02_types
│   │       .gitkeep
│   │       changelog.yaml
│   │       
│   ├───03_tables
│   │       .gitkeep
│   │       001_create_auth_tables.sql
│   │       002_create_homes_tables.sql
│   │       003_create_devices_tables.sql
│   │       004_create_consumption_tables.sql
│   │       005_create_notifications_tables.sql
│   │       006_create_sync_tables.sql
│   │       007_create_config_tables.sql
│   │       008_create_identity_audit_tables.sql
│   │       changelog.yaml
│   │       
│   ├───04_alter
│   │       .gitkeep
│   │       001_add_alter_auth.sql
│   │       002_add_alter_homes.sql
│   │       003_add_alter_devices.sql
│   │       004_add_alter_consumption.sql
│   │       005_add_alter_notifications.sql
│   │       006_add_alter_sync.sql
│   │       007_add_alter_identity_audit.sql
│   │       008_add_alter_config.sql
│   │       009_add_alter_home_device_integrity.sql
│   │       changelog.yaml
│   │       
│   ├───05_views
│   │       .gitkeep
│   │       001_auth_views.sql
│   │       002_homes_views.sql
│   │       003_devices_views.sql
│   │       004_consumption_views.sql
│   │       005_audit_views.sql
│   │       changelog.yaml
│   │       
│   ├───06_materialized_views
│   │       .gitkeep
│   │       001_mv_resumen_diario_homes.sql
│   │       002_mv_resumen_mensual_homes.sql
│   │       003_mv_raking_devices.sql
│   │       004_mv_estadisticas_mensuales_audit.sql
│   │       changelog.yaml
│   │       
│   ├───07_functions
│   │       .gitkeep
│   │       001_update_functions.sql
│   │       002_audit_log_functions.sql
│   │       003_config_user_functions.sql
│   │       004_auth_security_functions.sql
│   │       005_consumption_partition_functions.sql
│   │       changelog.yaml
│   │       
│   ├───08_procedures
│   │       .gitkeep
│   │       001_sp_registrar_usuario.sql
│   │       002_sp_registrar_hogar.sql
│   │       003_sp_registrar_dispositivo.sql
│   │       004_sp_desactivar_hogar.sql
│   │       005_sp_desactivar_dispositivo.sql
│   │       006_sp_restaurar_backup.sql
│   │       007_sp_cola_offline.sql
│   │       changelog.yaml
│   │       
│   ├───09_triggers
│   │       .gitkeep
│   │       001_update_triggers.sql
│   │       002_audit_log_triggers.sql
│   │       003_config_user_triggers.sql
│   │       004_auth_security_triggers.sql
│   │       changelog.yaml
│   │       
│   └───10_indexes
│           .gitkeep
│           001_auth_indexes.sql
│           002_homes_indexes.sql
│           003_devices_indexes.sql
│           004_consumption_indexes.sql
│           005_notifications_indexes.sql
│           006_sync_indexes.sql
│           007_config_indexes.sql
│           008_audit_indexes.sql
│           changelog.yaml
│           
├───02_dml
│   │   changelog.yaml
│   │   
│   ├───00_inserts
│   │       .gitkeep
│   │       001_insert_roles.sql
│   │       002_insert_permissions.sql
│   │       003_insert_roles_permissions.sql
│   │       004_insert_tipos_dispositivos.sql
│   │       005_insert_admin_user.sql
│   │       006_insert_auditoria_seed.sql
│   │       changelog.yaml
│   │       
│   ├───01_updates
│   │       .gitkeep
│   │       001_update_admin_password.sql
│   │       002_update_estado_usuario.sql
│   │       003_update_config_usuario.sql
│   │       changelog.yaml
│   │       
│   ├───02_deletes
│   │       .gitkeep
│   │       001_soft_delete_usuario.sql
│   │       002_soft_delete_hogar.sql
│   │       003_soft_delete_dispositivo.sql
│   │       changelog.yaml
│   │       
│   ├───03_upserts
│   │       .gitkeep
│   │       changelog.yaml
│   │       
│   └───04_patches
│           .gitkeep
│           001_patch_reset_intentos_fallidos.sql
│           002_patch_invalidar_tokens_expirados.sql
│           003_patch_purgar_blacklist.sql
│           004_patch_recovery_tokens_expirados.sql
│           changelog.yaml
│           
├───03_dcl
│   │   changelog.yaml
│   │   
│   ├───00_roles
│   │       .gitkeep
│   │       001_create_roles.sql
│   │       changelog.yaml
│   │       
│   ├───01_grants
│   │       .gitkeep
│   │       001_grants_auth.sql
│   │       002_grants_homes.sql
│   │       003_grants_devices.sql
│   │       004_grants_consumption.sql
│   │       005_grants_notifications.sql
│   │       006_grants_sync.sql
│   │       007_grants_config.sql
│   │       008_grants_audit.sql
│   │       changelog.yaml
│   │       
│   └───02_policies
│           .gitkeep
│           001_rls_homes.sql
│           002_rls_devices.sql
│           003_rls_consumption.sql
│           004_rls_notifications.sql
│           005_rls_config.sql
│           changelog.yaml
│           
├───04_tcl
│   │   changelog.yaml
│   │   
│   ├───00_transaction_blocks
│   │       .gitkeep
│   │       001_tcl_registro_usuario.sql
│   │       002_tcl_registro_hogar.sql
│   │       003_tcl_registro_dispositivo.sql
│   │       004_tcl_desactivar_hogar.sql
│   │       005_tcl_desactivar_dispositivo.sql
│   │       006_tcl_restaurar_backup.sql
│   │       007_tcl_sincronizacion_offline.sql
│   │       changelog.yaml
│   │       
│   ├───01_manual_recoveries
│   │       .gitkeep
│   │       001_recovery_usuario_bloqueado.sql
│   │       002_recovery_hogar_desactivado.sql
│   │       003_recovery_dispositivo_desactivado.sql
│   │       004_recovery_restauracion_fallida.sql
│   │       changelog.yaml
│   │       
│   └───02_release_tags
│           .gitkeep
│           001_tag_v1_0_0_initial.sql
│           002_tag_v1_0_1_seed.sql
│           changelog.yaml
│           
├───05_rollbacks
│   ├───01_ddl
│   │   ├───00_extensions
│   │   │       .gitkeep
│   │   │       001_enable_uuid_extension.rollback.sql
│   │   │       
│   │   ├───01_schemas
│   │   │       .gitkeep
│   │   │       001_create_schemas_rollback.sql
│   │   │       002_create_schemas_rollback.sql
│   │   │       003_create_schemas.rollback.sql
│   │   │       004_create_schemas.rollback.sql
│   │   │       005_create_schemas.rollback.sql
│   │   │       006_create_schemas_rollback.sql
│   │   │       007_create_schemas_rollback.sql
│   │   │       008_create_schemas_rollback.sql
│   │   │       
│   │   ├───02_types
│   │   │       .gitkeep
│   │   │       
│   │   ├───03_tables
│   │   │       .gitkeep
│   │   │       001_create_auth_tables_rollback.sql
│   │   │       002_create_homes_tables_rollbacks.sql
│   │   │       003_create_devices_tables_rollbacks.sql
│   │   │       004_create_consumption_tables.rollbacks.sql
│   │   │       005_create_notifications_tables.rollbacks.sql
│   │   │       006_create_sync_tables.rollback.sql
│   │   │       007_create_config_tables_rollback.sql
│   │   │       008_create_audit_tables.rollback.sql
│   │   │       
│   │   ├───04_alter
│   │   │       .gitkeep
│   │   │       001_add_alter_auth.rollback.sql
│   │   │       002_add_alter_homes.rollback.sql
│   │   │       003_add_alter_devices.rollback.sql
│   │   │       004_add_alter_consumption.rollback.sql
│   │   │       005_add_alter_notifications.rollback.sql
│   │   │       006_add_alter_sync.rollback.sql
│   │   │       007_add_alter_identity_audit.rollback.sql
│   │   │       008_add_alter_config.rollback.sql
│   │   │       009_add_alter_home_device_integrity.rollback.sql
│   │   │       
│   │   ├───05_views
│   │   │       .gitkeep
│   │   │       001_auth_views_rollback.sql
│   │   │       002_homes_views.rollback.sql
│   │   │       003_devices_views_rollback.sql
│   │   │       004_consumption_views_rollback.sql
│   │   │       005_audit_views_rollback.sql
│   │   │       
│   │   ├───06_materialized_views
│   │   │       .gitkeep
│   │   │       001_mv_resumen_diario_homes_rollback.sql
│   │   │       002_mv_resumen_mensual_homes.rollback.sql
│   │   │       003_mv_raking_devices_rollback.sql
│   │   │       004_mv_estadisticas_mensuales_audit_rollback.sql
│   │   │       
│   │   ├───07_functions
│   │   │       .gitkeep
│   │   │       001_update_functions_rollback.sql
│   │   │       002_audit_log_functions_rollback.sql
│   │   │       003_config_user_functions_rollback.sql
│   │   │       004_auth_security_functions.rollback.sql
│   │   │       
│   │   ├───08_procedures
│   │   │       .gitkeep
│   │   │       001_sp_registrar_usuario_rollback.sql
│   │   │       002_sp_registrar_hogar_rollback.sql
│   │   │       003_sp_registrar_dispositivo_rollback.sql
│   │   │       004_sp_desactivar_hogar_rollback.sql
│   │   │       005_sp_desactivar_dispositivo_rollback.sql
│   │   │       006_sp_restaurar_backup_rollback.sql
│   │   │       007_sp_cola_offline_rollback.sql
│   │   │       
│   │   ├───09_triggers
│   │   │       .gitkeep
│   │   │       
│   │   └───10_indexes
│   │           .gitkeep
│   │           
│   ├───02_dml
│   │   ├───00_inserts
│   │   │       .gitkeep
│   │   │       
│   │   ├───01_updates
│   │   │       .gitkeep
│   │   │       
│   │   ├───02_deletes
│   │   │       .gitkeep
│   │   │       
│   │   ├───03_upserts
│   │   │       .gitkeep
│   │   │       
│   │   └───04_patches
│   │           .gitkeep
│   │           
│   ├───03_dcl
│   │   ├───00_roles
│   │   │       .gitkeep
│   │   │       
│   │   ├───01_grants
│   │   │       .gitkeep
│   │   │       
│   │   └───02_policies
│   │           .gitkeep
│   │           
│   └───04_tcl
│       ├───00_transaction_blocks
│       │       .gitkeep
│       │       
│       └───01_manual_recoveries
│               .gitkeep
│               
└───changelog
        changelog-master.yaml
        