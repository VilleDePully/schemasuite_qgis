DROP VIEW IF EXISTS sigip.vw_coupe_text_elements;

CREATE VIEW sigip.vw_coupe_text_elements AS
SELECT 
	id_ctfv as id_ctfv,
	libelle_ctfv as libelle,
	idctf_ctfv as idctf,
	idprj_ctfv as idprj,
	state_ctfv as etat,
	idsch_ctfv as idsch,
	angle_ctfv as orientation,
	texttype_ctfv as texttype,
	idobr_ctfv as idobr,
	echelle_ctfv as echelle,
	ST_Force2D(the_geom)::geometry('Point',2056) as the_geom
FROM
	dbo.coupetextfeatureversion_ctfv