
DROP VIEW IF EXISTS export.vw_zones_projets;

CREATE OR REPLACE VIEW export.vw_zones_projets AS

SELECT
    zft.id_zft as id_zft,
	zft.label_zft as label_zft,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	CASE 
		WHEN ST_geometrytype(the_geom) = 'ST_Point' 
			THEN ST_Buffer(ST_SetSRID(the_geom,2056),10)
		ELSE ST_ForceCurve(ST_SetSRID(the_geom,2056))
	END geometry_polygon
	
FROM dbo.zonefeature_zft zft
	LEFT JOIN dbo.projet_prj prj ON prj.nom_prj = zft.label_zft
; -- zones de projets