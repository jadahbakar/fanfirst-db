-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
CREATE SCHEMA mst;
CREATE SCHEMA prm;
CREATE SCHEMA trx;
CREATE SCHEMA hst;
CREATE SCHEMA sec;
CREATE SCHEMA log;
CREATE SCHEMA utl;
COMMENT ON SCHEMA mst IS 'Master';
COMMENT ON SCHEMA trx IS 'Transaction';
COMMENT ON SCHEMA hst IS 'History';
COMMENT ON SCHEMA sec IS 'Security';
COMMENT ON SCHEMA log IS 'Log';
COMMENT ON SCHEMA utl IS 'Utils';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
DROP SCHEMA mst CASCADE;
DROP SCHEMA prm CASCADE;
DROP SCHEMA trx CASCADE;
DROP SCHEMA hst CASCADE;
DROP SCHEMA sec CASCADE;
DROP SCHEMA log CASCADE;
DROP SCHEMA utl CASCADE;
-- +goose StatementEnd
