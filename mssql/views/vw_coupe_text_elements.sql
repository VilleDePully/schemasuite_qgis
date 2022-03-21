
CREATE VIEW export.vw_coupe_text_elements AS
	SELECT 
		id_ctfv as id_ctfv,
		libelle_ctfv as libelle,
		idctf_ctfv as idctf,
		idprj_ctfv as idprj,
		state_ctfv as etat,
		idsch_ctfv as idsch,
		--degrees(ST_Azimuth(ST_StartPoint(the_geom), ST_EndPoint(the_geom))) as orientation,
		texttype_ctfv as texttype,
		idobr_ctfv as idobr,
		echelle_ctfv as echelle,
		geometry_ctvf as the_geom
	FROM
		dbo.coupetextfeatureversion_ctfv ctfv
	WHERE ctfv.idprj_ctfv = 1;