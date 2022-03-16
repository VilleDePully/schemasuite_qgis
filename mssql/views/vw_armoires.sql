USE [SCHEMASUITE_PULLY_TEST] -- To be replaced or defined in FME
GO

/****** Object:  Schema [db_owner]    Script Date: 16.03.2022 08:09:21 ******/
--DROP VIEW IF EXISTS export.vw_armoires;

CREATE VIEW export.vw_armoires AS

SELECT
    obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.nom_obrv as nom,
	eta.libelle_eta as etat,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.observation_obrv as remarque,
	ndfv.niveautension_ndf as tension,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	nodv.geoposz_nodv as altitude,
	nodv.acces_nodv as acces,
	obrv.creationdate_obrv AS date_creation,
	obrv.modificationdate_obrv AS date_modification,
	--stcentroid(ndfv.geometry_ndfv) as geom_centroid,
	ndfv.geometry_ndfv as geom_polygon
	
FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.id_obrv = obrv.id_obrv
	LEFT JOIN dbo.noeudfeatureversion_ndfv ndfv ON  ndfv.idobr_ndfv = obrv.idobr_obrv
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
	LEFT JOIN dbo.armoireelectrique_arm arm ON arm.id_obrv = nodv.id_obrv
WHERE obrv.idorc_obrv = 8 
	AND obrv.idprj_obrv = 1 
	AND ndfv.idprj_ndfv = 1;
GO


