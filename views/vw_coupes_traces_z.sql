DROP MATERIALIZED VIEW IF EXISTS export.vw_coupes_traces;

CREATE MATERIALIZED VIEW IF NOT EXISTS export.vw_coupes_traces 
TABLESPACE pg_default
AS
 SELECT 
    obrv.id_obrv,
    obrv.idobr_obrv AS id_obr,
    obrv.modele_obrv AS modele,
    obrv.nom_obrv AS nom,
    trc.hauteur_trc AS hauteur,
    trc.emprise_trc AS emprise,
    ROUND(ST_LENGTH(trav.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
    trc.precision_trc AS precision,
    acc.libelle_acc AS accessibilite,
    pos.libelle_pos AS mode_pose,
    eta.libelle_eta as etat,
    obrv.constructiondate_obrv as date_construction,
    obrv.miseenservicedate_obrv as date_mise_en_service,
    obrv.observation_obrv as remarque,
    obrv.creationdate_obrv AS date_creation,
	 obrv.modificationdate_obrv AS date_modification,
    ST_Multi(ST_Force2D(coupes_traces.geom_multi_polygon))::geometry('MultiPolygon',2056) as geom_multi_polygon
    --ST_MULTI(ST_UNION(ST_BUFFER(trav.the_geom::Geometry('LineStringZ', 2056),0.1)
    --  ,ST_Force2D(coupes_traces.geom_multi_polygon)))::geometry('MultiPolygon',2056) as geom_complex

  FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.tracefeatureversion_trav trav ON trav.idobr_trav = obrv.idobr_obrv
     LEFT JOIN dbo.trace_trc trc ON trc.id_obrv = obrv.id_obrv
     LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
     LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
     LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos
     INNER JOIN export.vw_coupes_traces_geom coupes_traces ON coupes_traces.id_obr = obrv.idobr_obrv
		
  WHERE obrv.idorc_obrv = 1 
   AND obrv.idprj_obrv = 1 
   AND trav.idprj_trav = 1
WITH DATA;