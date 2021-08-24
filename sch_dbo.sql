
CREATE SCHEMA dbo
    AUTHORIZATION postgres;

GRANT USAGE ON SCHEMA dbo TO grp_schemasuite_r;

GRANT ALL ON SCHEMA dbo TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA dbo
GRANT SELECT, REFERENCES, TRIGGER ON TABLES TO grp_schemasuite_r;