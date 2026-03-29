-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
CREATE TABLE sec.user (
    user_id BIGINT DEFAULT utl.generate_id() PRIMARY KEY,
    user_status INTEGER DEFAULT 1,
    -- user_role INTEGER,
    user_name TEXT,
    user_password TEXT,
    user_email TEXT,
    user_phone TEXT,
    user_is_login BOOLEAN DEFAULT false,
    
    user_user_input BIGINT,
    user_time_input TIMESTAMPTZ,
    user_user_update BIGINT,
    user_time_update TIMESTAMPTZ,
    user_user_delete BIGINT,
    user_time_delete TIMESTAMPTZ,
    user_user_approve BIGINT,
    user_time_approve TIMESTAMPTZ,
);

COMMENT ON TABLE sec.user IS 'User';
COMMENT ON COLUMN sec.user.user_id IS 'Id';
COMMENT ON COLUMN sec.user.user_perusahaan IS 'Id Perusahaan';
COMMENT ON COLUMN sec.user.user_status IS 'Status';
-- COMMENT ON COLUMN sec.user.user_role IS 'Role';
COMMENT ON COLUMN sec.user.user_name IS 'Name';
COMMENT ON COLUMN sec.user.user_password IS 'Password';
COMMENT ON COLUMN sec.user.user_email IS 'Email';
COMMENT ON COLUMN sec.user.user_phone IS 'Phone/WA';
COMMENT ON COLUMN sec.user.user_is_login IS 'Is Login ?';

COMMENT ON COLUMN sec.user.user_user_input IS 'User Input';
COMMENT ON COLUMN sec.user.user_time_input IS 'Time Input';
COMMENT ON COLUMN sec.user.user_user_update IS 'User Update';
COMMENT ON COLUMN sec.user.user_time_update IS 'Time Update';
COMMENT ON COLUMN sec.user.user_user_delete IS 'User Delete';
COMMENT ON COLUMN sec.user.user_time_delete IS 'Time Delete';
COMMENT ON COLUMN sec.user.user_user_approve IS 'User Approve';
COMMENT ON COLUMN sec.user.user_time_approve IS 'Time Approve';


CREATE FUNCTION sec.create_user(role INTEGER, name TEXT, password TEXT, email TEXT, phone TEXT, user_create BIGINT) RETURNS BIGINT AS 
$BODY$
DECLARE 
    id BIGINT;
BEGIN
    INSERT INTO sec.user (user_role, user_name, user_password, user_email, user_phone) 
    VALUES (role, name, crypt(password, gen_salt('bf', 10)), email, phone) RETURNING user_id INTO id;
    EXCEPTION
        WHEN unique_violation THEN id = 0;

RETURN id;
END
$BODY$
LANGUAGE plpgsql;


CREATE FUNCTION sec.update_user(id BIGINT, role INTEGER, name TEXT, email TEXT, phone TEXT) RETURNS INTEGER AS 
$BODY$
DECLARE _updated_rows INTEGER := 0;
BEGIN
    UPDATE sec.user SET user_role = role, user_name = name, user_email = email, user_phone = phone 
    WHERE user_id = id;
    GET DIAGNOSTICS _updated_rows = ROW_COUNT;
    RETURN _updated_rows;
END
$BODY$
LANGUAGE plpgsql;



CREATE FUNCTION sec.reset_password(id BIGINT, passwor TEXT) RETURNS INTEGER AS 
$BODY$
DECLARE _updated_rows INTEGER := 0;
BEGIN
    UPDATE sec.user SET user_password = crypt(password, gen_salt('bf', 10))
    WHERE user_id = id;
    GET DIAGNOSTICS _updated_rows = ROW_COUNT;
    RETURN _updated_rows;
END
$BODY$
LANGUAGE plpgsql;


CREATE FUNCTION sec.login(email TEXT, password TEXT) RETURNS TABLE(data json) AS 
$BODY$
DECLARE 
    r RECORD;
BEGIN
    SELECT user_id, user_status, user_role, user_name, user_phone, user_is_login, role_status, role_name INTO r 
    FROM sec.user 
    INNER JOIN sec.roles ON role_id = user_role 
    WHERE user_email = email AND user_password = crypt(pass, password); 
    
    IF (r.client_status = 1) AND (r.role_status = 1) THEN 
        SELECT log.write_users_log(r.user_id, 'login');
        UPDATE sec.user SET user_is_login = true WHERE user_id = r.user_id;
        RETURN QUERY
            SELECT COALESCE(row_to_json(t), '{}') FROM 
            (
                SELECT
                r.user_id,
                r.user_role,
                r.user_name,
                r.user_phone,
                r.user_email,
                r.role_name
            ) t;
    ELSE 
        RETURN QUERY SELECT '{"result": {"role_status":'||r.role_status||', "user_status":'||r.user_status||', "is_login":'||r.user_is_login||'}}'::json;
    END IF;
END
$BODY$
LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
DROP FUNCTION IF EXISTS sec.create_user(role INTEGER, perusahaan BIGINT, name TEXT, password TEXT, email TEXT, phone TEXT);
DROP FUNCTION IF EXISTS sec.login(email TEXT, password TEXT);
DROP FUNCTION IF EXISTS sec.reset_password(id BIGINT, password);
DROP FUNCTION IF EXISTS sec.update_user(id BIGINT, role INTEGER, name TEXT, email TEXT, phone TEXT);
DROP FUNCTION IF EXISTS sec.create_user(role, name, password, email, phone);
DROP TABLE IF EXISTS sec.user CASCADE;
-- +goose StatementEnd
