DROP VIEW IF EXISTS export.vw_coupes_lien_projet;

CREATE VIEW export.vw_coupes_lien_projet AS
SELECT 
    id_kyfv as id_kyfv,
	id_kyfv as id_ctfv,
	libelle_kyfv as libelle,
	idkyf_kyfv as idkyf,
	idprj_kyfv as idprj,
	state_kyfv as etat,
	idsch_kyfv as idsch,
	ST_Force2D(the_geom)::geometry('MultiLineString','2056') as the_geom
FROM
	dbo.coupelinkfeatureversion_kyfv
WHERE
	idprj_kyfv != 1;