CREATE TABLE IF NOT EXISTS mapped.state
(
    id serial NOT NULL,
    id_state smallint,
    value_fr character varying(40) COLLATE pg_catalog."default",
    CONSTRAINT state_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE mapped.state
    OWNER to postgres;

GRANT REFERENCES, SELECT, TRIGGER ON TABLE mapped.state TO grp_schemasuite_r;

GRANT ALL ON TABLE mapped.state TO postgres;


INSERT INTO mapped.state (id_state, value_fr) VALUES
(0,	'Modifié'),
(1,	'Créé'),
(2,	'Supprimé')
;