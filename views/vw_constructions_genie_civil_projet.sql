DROP VIEW IF EXISTS sigip.vw_constructions_genie_civil_projet;

CREATE OR REPLACE VIEW sigip.vw_constructions_genie_civil_projet AS

SELECT
    enfv.id_enfv as id_enfv,
	enfv.libelle_enfv as libelle,
	enfv.classcode_enfv as classe,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	enfv.the_geom::geometry('PolygonZ',2056) as geom_polygon,
	st_centroid(ST_Force2D(enfv.the_geom))::geometry('Point',2056) as geom_centroid
	
FROM dbo.externalnoeudfeatureversion_enfv enfv
LEFT JOIN dbo.projet_prj prj ON prj.id_prj = enfv.idprj_enfv
WHERE id_prj != 1;