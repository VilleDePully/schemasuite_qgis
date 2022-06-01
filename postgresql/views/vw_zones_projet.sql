
DROP VIEW IF EXISTS export.vw_zones_projets;

CREATE OR REPLACE VIEW export.vw_zones_projets AS

SELECT
	prj.id_prj AS id,
	prj.nom_prj AS nom,
	prj.description_prj AS description,
	prj.etat_prj AS etat,
	CASE
		WHEN prj.etat_prj = 0 THEN 'En travaux'
		WHEN prj.etat_prj = 1 THEN 'A publier'
		WHEN prj.etat_prj = 2 THEN 'A supprimer'
		WHEN prj.etat_prj = 3 THEN 'Temporaire'
	END etat,
	CASE 
		WHEN ST_geometrytype(the_geom) = 'ST_Point' 
			THEN ST_Buffer(ST_SetSRID(the_geom,2056),10)
		ELSE ST_ForceCurve(ST_SetSRID(the_geom,2056))
	END geometry_polygon
	
FROM dbo.zonefeature_zft zft
	LEFT JOIN dbo.projet_prj prj ON prj.nom_prj = zft.label_zft
; -- zones de projets