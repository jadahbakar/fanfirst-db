-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';
CREATE SEQUENCE utl.global_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;

SELECT setval('utl.global_id_sequence', 1, true);

CREATE OR REPLACE FUNCTION utl.generate_id(OUT result BIGINT)
  RETURNS BIGINT AS $BODY$
DECLARE
    our_epoch bigint := 1747357478000;
    seq_id bigint;
    now_millis bigint;
    shard_id int := 1;
BEGIN
    SELECT nextval('utl.global_id_sequence') % 1024 INTO seq_id;
    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (shard_id << 10);
    result := result | (seq_id);
END;
$BODY$
  LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';
DROP FUNCTION IF EXISTS utl.generate_id(OUT result BIGINT) CASCADE;
DROP SEQUENCE IF EXISTS utl.global_id_sequence;
-- +goose StatementEnd
