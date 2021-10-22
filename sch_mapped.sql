-- SCHEMA: mapped

-- DROP SCHEMA mapped ;

CREATE SCHEMA mapped
    AUTHORIZATION postgres;

GRANT USAGE ON SCHEMA mapped TO grp_schemasuite_r;

GRANT ALL ON SCHEMA mapped TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA mapped
GRANT SELECT, REFERENCES, TRIGGER ON TABLES TO grp_schemasuite_r;