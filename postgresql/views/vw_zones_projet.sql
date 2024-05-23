
DROP VIEW IF EXISTS export.vw_zones_projets;

CREATE OR REPLACE VIEW export.vw_zones_projets AS

SELECT
	zft.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS description,
	CASE
		WHEN prj.etat_prj = 0 THEN 'En travaux'
		WHEN prj.etat_prj = 1 THEN 'A publier'
		WHEN prj.etat_prj = 2 THEN 'A supprimer'
		WHEN prj.etat_prj = 3 THEN 'Temporaire'
	END etat,
	--Geometry
	CASE 
		WHEN ST_geometrytype(the_geom) = 'ST_Point' 
			THEN ST_Buffer(ST_SetSRID(the_geom,2056),10)
		ELSE ST_ForceCurve(ST_SetSRID(the_geom,2056))
	END geometry_polygon
	
FROM dbo.zonefeature_zft zft
	LEFT JOIN dbo.projet_prj prj ON prj.nom_prj = zft.label_zft
; -- zones de projets