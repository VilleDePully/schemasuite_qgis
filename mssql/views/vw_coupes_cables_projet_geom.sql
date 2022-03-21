
CREATE VIEW export.vw_coupes_cables_projet_geom AS

 SELECT cupv.idobr_cupv AS id_obr,
	geometry::UnionAggregate(cupv.geometry_cupv) AS geom_multi_polygon
   FROM dbo.coupefeatureversion_cupv cupv
  WHERE cupv.coupetype_cupv = 4 AND cupv.idprj_cupv != 1
  GROUP BY cupv.idobr_cupv;