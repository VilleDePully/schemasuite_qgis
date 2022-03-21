DROP MATERIALIZED VIEW IF EXISTS export.vw_coupes_traces_projet;

CREATE MATERIALIZED VIEW IF NOT EXISTS export.vw_coupes_traces_projet 
TABLESPACE pg_default
AS
 SELECT 
   obrv.id_obrv as id_obrv,
    obrv.idobr_obrv AS id_obr,
    obrv.modele_obrv AS modele,
    obrv.nom_obrv AS nom,
    trc.hauteur_trc AS hauteur,
    trc.emprise_trc AS emprise,
    ROUND(ST_LENGTH(trav.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
    prc.value_fr AS precision,
    acc.libelle_acc AS accessibilite,
    pos.libelle_pos AS mode_pose,
    eta.libelle_eta as etat,
    obrv.constructiondate_obrv as date_construction,
    obrv.miseenservicedate_obrv as date_mise_en_service,
    obrv.observation_obrv as remarque,
    prj.id_prj AS projet_id,
    prj.nom_prj AS projet_nom,
    prj.description_prj AS projet_description,
    prj.etat_prj AS projet_etat,
    obrv.creationdate_obrv AS date_creation,
	  obrv.modificationdate_obrv AS date_modification,
	CASE
		WHEN obrv.state_obrv = 0 THEN 'Cree'
		WHEN obrv.state_obrv = 1 THEN 'Modifie'
		WHEN obrv.state_obrv = 2 THEN 'Supprime'
	END statut,
    coupes_traces.geom_multi_polygon as geom_multi_polygon
    --ST_MULTI(ST_UNION(ST_BUFFER(trav.the_geom::Geometry('LineStringZ', 2056),0.1)
    --  ,ST_Force2D(coupes_traces.geom_multi_polygon)))::geometry('MultiPolygon',2056) as geom_complex

  FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.tracefeatureversion_trav trav ON trav.idobr_trav = obrv.idobr_obrv
     LEFT JOIN dbo.trace_trc trc ON trc.id_obrv = obrv.id_obrv
     LEFT JOIN mapped.precision prc ON prc.id_prec = trc.precision_trc
     LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
     LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
     LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos
     INNER JOIN export.vw_coupes_traces_projet_geom coupes_traces ON coupes_traces.id_obr = obrv.idobr_obrv

  WHERE obrv.idorc_obrv = 1 
    AND obrv.idprj_obrv != 1 
    AND trav.idprj_trav != 1
  WITH DATA;