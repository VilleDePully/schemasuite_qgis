DROP VIEW IF EXISTS export.vw_coupes_traces_projet;

CREATE OR REPLACE VIEW export.vw_coupes_traces_projet AS

 SELECT 
   obrv.id_obrv as id_obrv,
    obrv.idobr_obrv AS id_obr,
    obrv.modele_obrv AS modele,
    obrv.nom_obrv AS nom,
    trc.hauteur_trc AS hauteur,
    trc.emprise_trc AS emprise,
    ST_LENGTH(trav.the_geom) AS longueur_calc,
    trc.precision_trc AS precision,
    acc.libelle_acc AS accessibilite,
    pos.libelle_pos AS mode_pose,
    eta.libelle_eta as etat,
    obrv.constructiondate_obrv as date_construction,
    obrv.miseenservicedate_obrv as date_mise_en_service,
    prj.id_prj AS projet_id,
    prj.nom_prj AS projet_nom,
    prj.description_prj AS projet_description,
    prj.etat_prj AS projet_etat,
    ST_Multi(ST_Force2D(coupes_traces.geom_multi_polygon))::geometry('MultiPolygon',2056) as geom_multi_polygon
	
  FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.tracefeatureversion_trav trav ON trav.idobr_trav = obrv.idobr_obrv
     LEFT JOIN dbo.trace_trc trc ON trc.idbrav_trc = obrv.id_obrv
     LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
     LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
     LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos
     INNER JOIN (
	 	SELECT cupv.idobr_cupv AS id_obr,
			st_union((cupv.the_geom)::geometry(PolygonZ,2056)) AS geom_multi_polygon
   		FROM dbo.coupefeatureversion_cupv cupv
  		WHERE cupv.coupetype_cupv = 1 
      AND cupv.idprj_cupv <> 1
  		GROUP BY cupv.idobr_cupv) coupes_traces
		ON coupes_traces.id_obr = obrv.idobr_obrv
		
  WHERE obrv.idorc_obrv = 1 AND prj.id_prj <> 1;