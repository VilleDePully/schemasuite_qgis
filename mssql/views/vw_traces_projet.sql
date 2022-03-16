
CREATE VIEW export.vw_traces_projet
 AS
 SELECT
    obrv.id_obrv,
    obrv.idobr_obrv AS id_obr,
    obrv.modele_obrv AS modele,
    obrv.nom_obrv AS nom,
    trc.hauteur_trc AS hauteur,
    trc.emprise_trc AS emprise,
    ROUND(trav.geometry_trav.STLength(),2) AS longueur_calc,
    --prc.value_fr AS precision,
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
	statut =
	CASE
		WHEN obrv.state_obrv = 0 THEN 'Cree'
		WHEN obrv.state_obrv = 1 THEN 'Modifie'
		WHEN obrv.state_obrv = 2 THEN 'Supprime'
	END,
  trav.geometry_trav as the_geom

   FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.tracefeatureversion_trav trav ON trav.idobr_trav = obrv.idobr_obrv
     LEFT JOIN dbo.trace_trc trc ON trc.id_obrv = obrv.id_obrv
     --LEFT JOIN mapped.precision prc ON prc.id_prec = trc.precision_trc
     LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
     LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
     LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos
     
   WHERE obrv.idorc_obrv = 1 
    AND obrv.idprj_obrv != 1 
    AND trav.idprj_trav != 1;
