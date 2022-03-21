
CREATE VIEW export.vw_coupe_text_troncon AS
	SELECT 
		id_ctfv as id_ctfv,
		libelle_ctfv as libelle,
		idprj_ctfv as idprj,
		--degrees(ST_Azimuth(ST_StartPoint(the_geom), ST_EndPoint(the_geom))) as orientation,
		texttype_ctfv as texttype,
		idobr_ctfv as idobr,
		echelle_ctfv as echelle,
		geometry_ctfv as the_geom
	FROM
		dbo.coupetextfeatureversion_ctfv
	WHERE
		texttype_ctfv = 4
	AND idprj_ctfv = 1;