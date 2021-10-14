DROP VIEW IF EXISTS sigip.vw_constructions_genie_civil;

CREATE OR REPLACE VIEW sigip.vw_constructions_genie_civil AS

SELECT
    enfv.id_enfv as id_enfv,
	enfv.libelle_enfv as libelle,
	enfv.classcode_enfv as classe,
	ST_Force2D(enfv.the_geom)::geometry('Polygon',2056) as geom_polygon,
	st_centroid(ST_Force2D(enfv.the_geom))::geometry('Point',2056) as geom_centroid
	
FROM dbo.externalnoeudfeatureversion_enfv enfv
LEFT JOIN dbo.projet_prj prj ON prj.id_prj = enfv.idprj_enfv
WHERE id_prj = 1;