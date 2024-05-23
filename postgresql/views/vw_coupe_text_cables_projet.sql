DROP VIEW IF EXISTS export.vw_coupe_text_cables_projet;

CREATE VIEW export.vw_coupe_text_cables_projet AS
SELECT
	ctfv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	ctfv.id_ctfv as id_ctfv,
	ctfv.libelle_ctfv as libelle,
	ctfv.idprj_ctfv as idprj,
	degrees(ST_Azimuth(ST_StartPoint(ctfv.the_geom), ST_EndPoint(ctfv.the_geom))) as orientation,
	ctfv.texttype_ctfv as texttype,
	ctfv.idobr_ctfv as idobr,
	ctfv.echelle_ctfv as echelle,
	ST_Force2D(ST_StartPoint(ctfv.the_geom))::geometry('Point',2056) as the_geom
FROM
	dbo.coupetextfeatureversion_ctfv ctfv
WHERE
    texttype_ctfv = 2
AND idprj_ctfv != 1;