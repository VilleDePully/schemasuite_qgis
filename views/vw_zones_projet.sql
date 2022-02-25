DROP VIEW IF EXISTS export.vw_zones_projets;

CREATE OR REPLACE VIEW export.vw_zones_projets AS

SELECT
    zft.id_zft as id_zft,
	zft.label_zft as label_zft,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	ST_Force2D(zft.the_geom) as geom_polygon
	
FROM dbo.zonefeature_zft zft
	LEFT JOIN dbo.projet_prj prj ON prj.nom_prj = zft.label_zft
; -- zones de projets