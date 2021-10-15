-- SCHEMA: export

-- DROP SCHEMA export ;

CREATE SCHEMA export
    AUTHORIZATION postgres;

GRANT USAGE ON SCHEMA export TO grp_schemasuite_r;

GRANT ALL ON SCHEMA export TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA export
GRANT SELECT, REFERENCES, TRIGGER ON TABLES TO grp_schemasuite_r;