DROP VIEW IF EXISTS export.vw_traces;

CREATE OR REPLACE VIEW export.vw_traces
 AS
 SELECT
    obrv.id_obrv as id_obrv,
    obrv.idobr_obrv AS id_obr,
    obrv.modele_obrv AS modele,
    obrv.nom_obrv AS nom,
    trc.hauteur_trc AS hauteur,
    trc.emprise_trc AS emprise,
    ROUND(ST_LENGTH(trav.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
    prc.value AS precision,
    acc.libelle_acc AS accessibilite,
    pos.libelle_pos AS mode_pose,
    eta.libelle_eta as etat,
    obrv.constructiondate_obrv as date_construction,
    obrv.miseenservicedate_obrv as date_mise_en_service,
    obrv.fictif_obrv as fictif,
    ST_FORCE2D(trav.the_geom)::Geometry('LineString', 2056) as the_geom

   FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.tracefeatureversion_trav trav ON trav.idobr_trav = obrv.idobr_obrv
     LEFT JOIN dbo.trace_trc trc ON trc.id_obrv = obrv.id_obrv
     LEFT JOIN mapped.precision prc ON prc.id_prec = trc.precision_trc
     LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = trav.idprj_trav
     LEFT JOIN dbo.accessibilite_acc acc ON trc.idacc_trc = acc.id_acc
     LEFT JOIN dbo.modepose_pos pos ON trc.idpos_trc = pos.id_pos
   WHERE obrv.idorc_obrv = 1 AND obrv.idprj_obrv = 1 AND trav.idprj_trav = 1;
