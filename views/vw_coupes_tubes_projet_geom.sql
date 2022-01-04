DROP MATERIALIZED VIEW IF EXISTS export.vw_coupes_tubes_projet_geom;

CREATE MATERIALIZED VIEW IF NOT EXISTS export.vw_coupes_tubes_projet_geom
TABLESPACE pg_default
AS
 SELECT cupv.idobr_cupv AS id_obr,
    st_union(cupv.the_geom::geometry(Polygon,2056)) AS geom_multi_polygon
   FROM dbo.coupefeatureversion_cupv cupv
  WHERE cupv.coupetype_cupv = 2 AND cupv.idprj_cupv != 1
  GROUP BY cupv.idobr_cupv
WITH DATA;