DROP VIEW IF EXISTS sigip.vw_coupes_elements;

CREATE OR REPLACE VIEW sigip.vw_coupes_elements AS

SELECT
	cupv.id_cupv as id_cupv,
	cupv.idobr_cupv as id_obr,
	cupv.libelle_cupv as libelle,
	cupv.coupetype_cupv as type,
	cupv.echelle_cupv as echelle,
	cupv.codecouleur_cupv as code_couleur,
	cupv.backgroundtype_cupv as background_type,
	cupv.outlinetype_cupv as outline_type,
	cupv.coupelevel_cupv as level,
	cupv.idprj_cupv as projet_id,
	cupv.the_geom::geometry('PolygonZ',2056) as geom_polygon

FROM dbo.coupefeatureversion_cupv cupv