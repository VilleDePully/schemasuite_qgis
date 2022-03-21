--File is named with _z extension to be run last with FME

CREATE VIEW export.vw_coupes_tubes_projet

AS 
  SELECT
    obrv.id_obrv as id_obrv,
    obrv.idobr_obrv as id_obr,
    obrv.modele_obrv AS modele,
    obrv.nom_obrv as nom,
    ROUND(cofv.geometry_cofv.STLength(),2) AS longueur_calc,
    eta.libelle_eta as etat,
    ete.libelle_ete as etat_entretien,
    obrv.constructiondate_obrv as date_construction,
    obrv.miseenservicedate_obrv as date_mise_en_service,
    obrv.observation_obrv as remarque,
    prap.libelle_pra as proprietaire,
    prae.libelle_pra as exploitant,
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
    coupes_tubes.geom_multi_polygon as geom_multi_polygon
    --ST_MULTI(ST_UNION(ST_BUFFER(cofv.the_geom::Geometry('LineStringZ', 2056),0.1),
    --  ST_Force2D(coupes_tubes.geom_multi_polygon)))::geometry('MultiPolygon',2056) as geom_complex
    --(cofv.the_geom)::geometry(LineStringZ,2056) AS the_geom
	
   FROM dbo.objetreseauversion_obrv obrv
     LEFT JOIN dbo.conduitefeatureversion_cofv cofv ON cofv.idobr_cofv = obrv.idobr_obrv
     LEFT JOIN dbo.netat_eta eta ON eta.id_eta = obrv.idetat_obrv
     LEFT JOIN dbo.netatentretien_ete ete ON ete.id_ete = obrv.idetatentretien_obrv
     LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
     LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
     LEFT JOIN dbo.projet_prj prj ON prj.id_prj = cofv.idprj_cofv
     INNER JOIN export.vw_coupes_tubes_projet_geom coupes_tubes ON coupes_tubes.id_obr = obrv.idobr_obrv

  	WHERE obrv.idorc_obrv = 2 
      AND obrv.idprj_obrv != 1 
      AND cofv.idprj_cofv != 1
  ;

