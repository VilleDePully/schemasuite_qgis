CREATE TABLE IF NOT EXISTS mapped.precision
(
    id serial NOT NULL,
    id_precision smallint,
    value_fr character varying(40) COLLATE pg_catalog."default",
    CONSTRAINT precision_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE mapped.precision
    OWNER to postgres;

GRANT REFERENCES, SELECT, TRIGGER ON TABLE mapped.precision TO grp_schemasuite_r;

GRANT ALL ON TABLE mapped.precision TO postgres;

INSERT INTO mapped.precision (id_state, value_fr) VALUES
(0,	'Inconnue'),
(1,	'Imprécis'),
(2,	'Précis')
;