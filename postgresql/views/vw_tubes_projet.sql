DROP VIEW IF EXISTS export.vw_tubes_projet;

CREATE OR REPLACE VIEW export.vw_tubes_projet AS

SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.code_obrv AS code,
	obrv.nom_obrv as nom,
	obrv.racineguid_obrv as guid_racine,
	ROUND(ST_LENGTH(cofv.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
    eta.libelle_eta as etat_deploiement,
    ete.libelle_ete as etat_entretien,
    prt.libelle_prt as type_propriete,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.observation_obrv as remarque,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	praf.libelle_pra as fournisseur,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	obrv.creationdate_obrv AS date_creation,
	obrv.modificationdate_obrv AS date_modification,
	enf.nombre_enfants AS nombre_cables,
	CASE
		WHEN obrv.state_obrv = 0 THEN 'Cree'
		WHEN obrv.state_obrv = 1 THEN 'Modifie'
		WHEN obrv.state_obrv = 2 THEN 'Supprime'
	END statut,
	--Geometry
	ST_FORCE2D(cofv.the_geom)::geometry('LineString','2056') as the_geom

FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN dbo.conduitefeatureversion_cofv cofv ON cofv.idobr_cofv = obrv.idobr_obrv
    LEFT JOIN dbo.netat_eta eta ON eta.id_eta = obrv.idetat_obrv
    LEFT JOIN dbo.netatentretien_ete ete ON ete.id_ete = obrv.idetatentretien_obrv
    LEFT JOIN dbo.nproprietetype_prt prt ON prt.id_prt = obrv.idproprietetype_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = cofv.idprj_cofv
	LEFT JOIN export.vw_enfants enf ON enf.id_parent = obrv.idobr_obrv
	
WHERE obrv.idorc_obrv = 2 
	AND obrv.idprj_obrv != 1 
	AND cofv.idprj_cofv != 1; -- conduites
