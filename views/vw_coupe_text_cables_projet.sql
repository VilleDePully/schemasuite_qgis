DROP VIEW IF EXISTS sigip.vw_coupe_text_cables_projet;

CREATE VIEW sigip.vw_coupe_text_cables_projet AS
SELECT
	id_ctfv as id_ctfv,
	libelle_ctfv as libelle,
	idprj_ctfv as idprj,
	angle_ctfv as orientation,
	texttype_ctfv as texttype,
	idobr_ctfv as idobr,
	echelle_ctfv as echelle,
	ST_Force2D(the_geom)::geometry('Point',2056) as the_geom
FROM
	dbo.coupetextfeatureversion_ctfv
WHERE
    texttype_ctfv = 2
AND idprj_ctfv <> 1;