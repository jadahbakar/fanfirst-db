-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
CREATE TABLE sec.role (
    role_id INTEGER,
    role_status INTEGER DEFAULT 1,
    role_name TEXT,
    PRIMARY KEY(role_id)
);

COMMENT ON TABLE sec.role IS 'Role';
COMMENT ON COLUMN sec.role.role_id IS 'Id';
COMMENT ON COLUMN sec.role.role_status IS 'Status';
COMMENT ON COLUMN sec.role.role_name IS 'Name';


INSERT INTO sec.role (role_id, role_name)VALUES 
(0,'Administrator'),
(1,'BOD'),
(2,'Supervisor'),
(3,'Assessor'),
(4,'Operator'),
(5,'Participant');


CREATE OR REPLACE FUNCTION sec.role_get_all()
  RETURNS TABLE(role json) AS $BODY$
BEGIN
RETURN QUERY
  SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) FROM  
	(
    SELECT role_id, role_name 
    FROM sec.role 
    WHERE role_status = 1 ORDER BY role_id
  ) t;
END;
$BODY$
  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION sec.role_get_by_id(param INTEGER)
  RETURNS TABLE(role json) AS
$BODY$
BEGIN
  RETURN QUERY	
   SELECT COALESCE(row_to_json(t), '{}'::json) FROM  
	  (
		SELECT role_id, role_name
		FROM sec.role 
		WHERE role_status = 1 AND role_id = param
    ) t;
END;
$BODY$
  LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
DROP FUNCTION IF EXISTS sec.role_get_all();
DROP FUNCTION IF EXISTS sec.role_get_by_id(param INTEGER);
DROP TABLE IF EXISTS sec.role CASCADE;
-- +goose StatementEnd
