DROP VIEW IF EXISTS export.vw_coupe_text_cables;

CREATE VIEW export.vw_coupe_text_cables AS
SELECT 
	ctfv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	id_ctfv as id_ctfv,
	libelle_ctfv as libelle,
	idprj_ctfv as idprj,
	degrees(ST_Azimuth(ST_StartPoint(the_geom), ST_EndPoint(the_geom))) as orientation,
	texttype_ctfv as texttype,
	idobr_ctfv as idobr,
	echelle_ctfv as echelle,
	ST_Force2D(ST_StartPoint(the_geom))::geometry('Point',2056) as the_geom
FROM
	dbo.coupetextfeatureversion_ctfv ctfv
WHERE
    texttype_ctfv = 2
AND idprj_ctfv = 1;