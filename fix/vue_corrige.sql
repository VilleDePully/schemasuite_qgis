CREATE OR REPLACE VIEW export.vw_coffrets
AS 
SELECT obrv.id_obrv,
    obrv.idobr_obrv AS id_obr,
    obrv.modele_obrv AS modele,
    obrv.code_obrv AS code,
    obrv.nom_obrv AS nom,
    lower(obrv.racineguid_obrv) AS guid_racine,
    eta.libelle_eta AS etat_deploiement,
    ete.libelle_ete AS etat_entretien,
    prt.libelle_prt AS type_propriete,
    obrv.convention_obrv AS num_esti,
    obrv.constructiondate_obrv AS date_construction,
    obrv.miseenservicedate_obrv AS date_mise_en_service,
    obrv.observation_obrv AS observation,
    ndfv.niveautension_ndf AS tension,
    prap.libelle_pra AS proprietaire,
    prae.libelle_pra AS exploitant,
    praf.libelle_pra AS fournisseur,
    nodv.geoposz_nodv AS altitude,
    nodv.acces_nodv AS acces,
    nodv.emplacement_nodv AS emplacement,
    nodv.typeconstruction_nodv AS type_construction,
    nodv.remarquecontrole_nodv AS remarque_controle,
    nodv.datedecontrole_nodv AS date_controle,
    obrv.creationdate_obrv AS date_creation,
    obrv.modificationdate_obrv AS date_modification,
    cof.impendance_cof AS impedance,
    cof.icc_cof AS icc,
    gco.nom_gco AS genre,
    cof.avecderivation_cof AS avec_derivation,
    cof.typecsgeneral_cof AS type_cs_general,
    cof.nombrefusible_cof AS nombre_fusibles,
    cof.intensitetaxe_cof AS intensite_taxe,
    cof.intensiteinstalle_cof AS intensite_installee,
    cof.intensitemax_cof AS intensite_max,
    cof.intensiteproduction_cof AS intensite_production,
    cof.nopolice_cof AS no_police,
    cof.pmaxfeg_cof AS puissance_max_feg,
    cof.resisolation_cof AS resistance_isolation,
    -- Alimentation station
     zto.idNODAlimBT_ZTO as id_station_alim,
     (SELECT nom_OBRV FROM ObjetReseauVersion_OBRV sta where sta.IdPRJ_OBRV = 1 And sta.IdOBR_OBRV = zto.idNODAlimBT_ZTO) as nom_station_alim,
     -- Alimentation armoire
     case when zto.idADBTAlim_ZTO = 0 then Null Else zto.idADBTAlim_ZTO end as id_armoire_alim,
     case when zto.idADBTAlim_ZTO = 0 then Null Else (SELECT nom_OBRV FROM ObjetReseauVersion_OBRV sta where sta.IdPRJ_OBRV = 1 And sta.IdOBR_OBRV = zto.idADBTAlim_ZTO) end as nom_armoire_alim,
    st_centroid(st_force2d(ndfv.the_geom))::geometry(Point,2056) AS geom_centroid,
    st_force2d(ndfv.the_geom)::geometry(Polygon,2056) AS geom_polygon
   FROM dbo.v_objetreseauversionliaison v_obrvl
     LEFT JOIN dbo.objetreseauversion_obrv obrv ON v_obrvl.id_obrv = obrv.id_obrv
     LEFT JOIN dbo.noeudfeatureversion_ndfv ndfv ON ndfv.idobr_ndfv = v_obrvl.idparent_cmp
     LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.id_obrv = v_obrvl.id_obrv
     LEFT JOIN dbo.netat_eta eta ON eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.netatentretien_ete ete ON ete.id_ete = obrv.idetatentretien_obrv
     LEFT JOIN dbo.nproprietetype_prt prt ON prt.id_prt = obrv.idproprietetype_obrv
     LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
     LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
     LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
     LEFT JOIN dbo.coffretintroduction_cof cof ON v_obrvl.id_obrv = cof.id_obrv
     LEFT JOIN dbo.ngenrecoffret_gco gco ON cof.idgco_cof = gco.id_gco
     LEFT JOIN dbo.zsysTopoObject_ZTO zto on zto.idOBR_ZTO = obrv.IdOBR_OBRV
     LEFT 
  WHERE obrv.idorc_obrv = 14 AND obrv.idprj_obrv = 1 AND ndfv.idprj_ndfv = 1;