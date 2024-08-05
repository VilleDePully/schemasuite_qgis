DROP VIEW IF EXISTS export.vw_coupes_traces_projet;

CREATE OR REPLACE VIEW export.vw_coupes_traces_projet AS

 SELECT 
    obrv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
    obrv.id_obrv as id_obrv,
    obrv.idobr_obrv as id_obr,
    obrv.modele_obrv AS modele,
    obrv.code_obrv AS code,
    obrv.nom_obrv as nom,
  	obrv.nomcalcul_obrv as nom_calcule,
  	obrv.infobulle_obrv as infobulle,
    lower(obrv.racineguid_obrv) as guid_racine,
    trc.hauteur_trc AS hauteur,
    trc.emprise_trc AS emprise,
    ROUND(ST_LENGTH(trav.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
    prc.value_fr AS precision,
    acc.libelle_acc AS accessibilite,
    pos.libelle_pos AS mode_pose,
    eta.libelle_eta as etat_deploiement,
    ete.libelle_ete as etat_entretien,
    prt.libelle_prt as type_propriete,
    obrv.constructiondate_obrv as date_construction,
    obrv.miseenservicedate_obrv as date_mise_en_service,
    obrv.horsservicedate_obrv as date_mise_hors_service,
    obrv.observation_obrv as observation,
    --Projet
    prj.id_prj AS projet_id,
    prj.nom_prj AS projet_nom,
    prj.description_prj AS projet_description,
    prj.etat_prj AS projet_etat,
    obrv.creationdate_obrv AS date_creation,
    obrv.modificationdate_obrv AS date_modification,
    enf.nombre_enfants AS nombre_tubes,
	CASE
		WHEN obrv.state_obrv = 0 THEN 'Cree'
		WHEN obrv.state_obrv = 1 THEN 'Modifie'
		WHEN obrv.state_obrv = 2 THEN 'Supprime'
	END statut,
  --Geometry
    coupes_traces.geom_multi_polygon as geom_multi_polygon
    --ST_MULTI(ST_UNION(ST_BUFFER(trav.the_geom::Geometry('LineStringZ', 2056),0.1)
    --  ,ST_Force2D(coupes_traces.geom_multi_polygon)))::geometry('MultiPolygon',2056) as geom_complex

  FROM dbo.objetreseauversion_obrv obrv
    LEFT JOIN (
      SELECT *
      FROM dbo.tracefeatureversion_trav trav1
      WHERE trav1.idprj_trav != 1
      AND trav1.idsch_trav = 1
    ) trav ON trav.idobr_trav = obrv.idobr_obrv
    LEFT JOIN dbo.trace_trc trc ON trc.id_obrv = obrv.id_obrv
    LEFT JOIN mapped.precision prc ON prc.id_prec = trc.precision_trc
    LEFT JOIN dbo.netat_eta eta ON eta.id_eta = obrv.idetat_obrv
    LEFT JOIN dbo.netatentretien_ete ete ON ete.id_ete = obrv.idetatentretien_obrv
    LEFT JOIN dbo.nproprietetype_prt prt ON prt.id_prt = obrv.idproprietetype_obrv
    LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
    LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
    LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos
    LEFT JOIN export.vw_enfants enf ON enf.id_parent = obrv.idobr_obrv
    INNER JOIN export.vw_coupes_traces_projet_geom coupes_traces ON coupes_traces.id_obr = obrv.idobr_obrv

  WHERE obrv.idorc_obrv = 1 
    AND obrv.idprj_obrv != 1;