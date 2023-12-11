DROP VIEW IF EXISTS export.vw_noeuds_geo_projet;

CREATE OR REPLACE VIEW export.vw_noeuds_geo_projet AS

SELECT
	enfv.id_enfv as id_enfv,
	enfv.libelle_enfv as libelle,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	--Attributs spécifiques
	--Annexes
	--Geometry
	enfv.the_geom as geom_point
	
FROM dbo.externalnoeudfeatureversion_enfv enfv
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = enfv.idprj_enfv

WHERE enfv.idprj_enfv != 1; -- noeuds geo

