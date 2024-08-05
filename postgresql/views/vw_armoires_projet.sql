DROP VIEW IF EXISTS export.vw_armoires_projet;

CREATE OR REPLACE VIEW export.vw_armoires_projet AS

SELECT
	obrv.id as id, -- Necessary to ease postgreSQL primary keys attribution through FME
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.code_obrv AS code,
	obrv.nom_obrv as nom,
	obrv.infobulle_obrv as infobulle,
	lower(obrv.racineguid_obrv) as guid_racine,
	eta.libelle_eta as etat_deploiement,
	ete.libelle_ete as etat_entretien,
	prt.libelle_prt	as type_propriete,
	obrv.convention_obrv as num_esti,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.horsservicedate_obrv as date_mise_hors_service,
	obrv.observation_obrv as observation,
	ndfv.niveautension_ndf as tension,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	praf.libelle_pra as fournisseur,
	nodv.geoposz_nodv as altitude,
	nodv.acces_nodv as acces,
	nodv.emplacement_nodv as emplacement,
	nodv.typeconstruction_nodv as type_construction,
	nodv.remarquecontrole_nodv as remarque_controle,
	nodv.datedecontrole_nodv as date_controle,
	--Projet
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
	--Annexes
	anx_agg.annexe_chemins as annexes,
	--Geometry
	npfv.the_geom as geom_point,
	--st_centroid(ST_Force2D(ndfv.the_geom))::geometry('Point',2056) as geom_centroid,
	ndfv.the_geom as geom_polygon
	--ST_Force2D(ndfv.the_geom)::geometry('Polygon',2056) as geom_polygon
	
FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.id_obrv = obrv.id_obrv
	LEFT JOIN (
		SELECT *
		FROM dbo.noeudfeatureversion_ndfv ndfv1
		WHERE ndfv1.idprj_ndfv != 1
		AND ndfv1.idsch_ndfv = 1) ndfv ON  ndfv.idobr_ndfv = obrv.idobr_obrv
	LEFT JOIN (
		SELECT * 
		FROM dbo.noeudconnectionpointfeatureversion_npfv npfv1
		WHERE npfv1.idprj_npfv != 1
		AND npfv1.idsch_npfv = 1
	) npfv ON npfv.idobr_npfv = obrv.idobr_obrv
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
	LEFT JOIN dbo.nproprietetype_prt prt ON  prt.id_prt = obrv.idproprietetype_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
	LEFT JOIN dbo.armoireelectrique_arm arm ON arm.id_obrv = nodv.id_obrv
	LEFT JOIN export.vw_annexes_agg anx_agg ON anx_agg.guid_objet = lower(obrv.racineguid_obrv)
	
WHERE obrv.idorc_obrv = 8
	AND obrv.idprj_obrv != 1;