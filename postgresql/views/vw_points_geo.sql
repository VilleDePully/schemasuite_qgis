DROP VIEW IF EXISTS export.vw_points_geo;

CREATE OR REPLACE VIEW export.vw_points_geo AS

SELECT
	gqtv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	gqtv.id_gqtv as id_gqtv,
	gqtv.libelle_gqtv as libelle,
	--Attributs spécifiques
	--Annexes
	--Geometry
	gqtv.the_geom as geom_point
	
FROM dbo.graphiquefeatureversion_gqtv gqtv

WHERE gqtv.idprj_gqtv = 1; -- points geo

