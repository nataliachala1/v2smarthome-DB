-- ============================================================
-- TABLA: identity_audit.audit_log
--
-- Auditoría semántica generada explícitamente por NestJS.
-- PostgreSQL persiste y protege la integridad del histórico.
--
-- NO utiliza snapshots completos OLD/NEW.
-- NO contiene contraseñas, hashes, JWT, tokens originales,
-- credenciales MQTT ni secretos de integraciones.
-- ============================================================

CREATE TABLE IF NOT EXISTS identity_audit.audit_log (

    id_audit_log UUID NOT NULL DEFAULT gen_random_uuid(),

    -- Usuario que originó la operación.
    -- Puede ser NULL para eventos de sistema o usuarios
    -- todavía no identificados, por ejemplo login fallido.
    id_user UUID NULL,

    -- Hogar relacionado cuando el evento sea contextual.
    id_home UUID NULL,

    -- Tipo lógico de actor.
    actor_type VARCHAR(20) NOT NULL DEFAULT 'USER',

    -- Evento semántico.
    -- Ejemplos:
    -- AUTH_LOGIN_SUCCESS
    -- AUTH_LOGIN_FAILED
    -- HOME_CREATED
    -- HOME_MEMBER_INVITED
    -- DEVICE_DEACTIVATED
    -- DEVICE_CONTROL_ON
    action VARCHAR(80) NOT NULL,

    -- Dominio que genera el evento.
    -- AUTH, HOMES, DEVICES, CONFIG, etc.
    module VARCHAR(50) NOT NULL,

    -- Entidad relacionada.
    entity VARCHAR(50) NULL,

    -- Identificador de la entidad cuando corresponda.
    id_entity UUID NULL,

    -- Resultado cuando aplique.
    result VARCHAR(20) NULL,

    -- Únicamente contexto sanitizado necesario.
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    -- Datos técnicos opcionales.
    ip_address INET NULL,
    user_agent TEXT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_audit_log
        PRIMARY KEY (id_audit_log),

    CONSTRAINT ck_audit_log_actor_type
        CHECK (
            actor_type IN (
                'USER',
                'SYSTEM',
                'INFRASTRUCTURE'
            )
        ),

    CONSTRAINT ck_audit_log_result
        CHECK (
            result IS NULL
            OR result IN ('SUCCESS', 'FAILURE')
        )
);


COMMENT ON TABLE identity_audit.audit_log IS
'Registro inmutable de eventos semánticos de auditoría generados explícitamente por NestJS.';


COMMENT ON COLUMN identity_audit.audit_log.action IS
'Código semántico del evento, por ejemplo AUTH_LOGIN_SUCCESS, HOME_CREATED o DEVICE_CONTROL_ON.';


COMMENT ON COLUMN identity_audit.audit_log.metadata IS
'Contexto mínimo sanitizado del evento. Nunca contiene contraseñas, hashes, JWT, tokens originales, credenciales MQTT ni secretos.';