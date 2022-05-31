DROP VIEW IF EXISTS export.vw_traces;

CREATE OR REPLACE VIEW export.vw_traces
 AS
 SELECT
    obrv.id_obrv as id_obrv,
    obrv.idobr_obrv as id_obr,
    obrv.modele_obrv AS modele,
    obrv.code_obrv AS code,
    obrv.nom_obrv as nom,
    obrv.racineguid_obrv as guid_racine,
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
    obrv.observation_obrv as observation,
    obrv.creationdate_obrv AS date_creation,
    obrv.modificationdate_obrv AS date_modification,
    ST_FORCE2D(trav.the_geom)::Geometry('LineString', 2056) as the_geom

   FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.tracefeatureversion_trav trav ON trav.idobr_trav = obrv.idobr_obrv
     LEFT JOIN dbo.trace_trc trc ON trc.id_obrv = obrv.id_obrv
     LEFT JOIN mapped.precision prc ON prc.id_prec = trc.precision_trc
     LEFT JOIN dbo.netat_eta eta ON eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.netatentretien_ete ete ON ete.id_ete = obrv.idetatentretien_obrv
     LEFT JOIN dbo.nproprietetype_ete prt ON prt.id_prt = obrv.idproprietetype_obrv
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
     LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
     LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos

   WHERE obrv.idorc_obrv = 1 
    AND obrv.idprj_obrv = 1 
    AND trav.idprj_trav = 1;
