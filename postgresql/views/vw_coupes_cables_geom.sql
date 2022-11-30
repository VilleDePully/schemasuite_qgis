DROP VIEW IF EXISTS export.vw_coupes_cables_geom;

CREATE OR REPLACE VIEW export.vw_coupes_cables_geom AS

 SELECT cupv.idobr_cupv AS id_obr,
    ST_MULTI(ST_UNION(ST_Force2D(cupv.the_geom)::geometry(Polygon,2056))) AS geom_multi_polygon
   FROM dbo.coupefeatureversion_cupv cupv
  WHERE cupv.coupetype_cupv = 4 AND cupv.idprj_cupv = 1
  GROUP BY cupv.idobr_cupv;