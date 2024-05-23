DROP VIEW IF EXISTS export.vw_points_geo_projet;

CREATE OR REPLACE VIEW export.vw_points_geo_projet AS

SELECT
	gqtv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	gqtv.id_gqtv as id_gqtv,
	gqtv.libelle_gqtv as libelle,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	--Attributs spécifiques
	--Annexes
	--Geometry
	gqtv.the_geom as geom_point
	
FROM dbo.graphiquefeatureversion_gqtv gqtv
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = gqtv.idprj_gqtv

WHERE gqtv.idprj_gqtv != 1; -- points geo

