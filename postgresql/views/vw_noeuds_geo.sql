DROP VIEW IF EXISTS export.vw_noeuds_geo;

CREATE OR REPLACE VIEW export.vw_noeuds_geo AS

SELECT
	enfv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	enfv.id_enfv as id_enfv,
	enfv.libelle_enfv as libelle,
	--Attributs spécifiques
	--Annexes
	--Geometry
	enfv.the_geom as geom_point
	
FROM dbo.externalnoeudfeatureversion_enfv enfv
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = enfv.idprj_enfv

WHERE enfv.idprj_enfv = 1; -- noeuds geo

