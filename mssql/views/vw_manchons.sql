
CREATE VIEW export.vw_manchons AS

SELECT 
    obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.nom_obrv as nom,
	eta.libelle_eta as etat,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.observation_obrv as remarque,
	--ndfv.niveautension_ndf as tension, NULL pour les chambres
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	nodv.geoposz_nodv as altitude,
	nodv.acces_nodv as acces,
	v_obrvl.idparent_cmp as id_obr_parent,
	ndfv.libelle_ndfv as libelle_parent,
	obrv.creationdate_obrv AS date_creation,
	obrv.modificationdate_obrv AS date_modification,
	ndfv.geometry_ndfv.STCentroid() as geom_centroid,
	ndfv.geometry_ndfv as geom_polygon

FROM dbo.v_objetreseauversionliaison v_obrvl
	LEFT JOIN dbo.objetreseauversion_obrv obrv ON v_obrvl.id_obrv = obrv.id_obrv
	LEFT JOIN dbo.noeudfeatureversion_ndfv ndfv ON  ndfv.idobr_ndfv = v_obrvl.idparent_cmp
	LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.id_obrv = v_obrvl.idparent_cmp
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv

WHERE obrv.idorc_obrv = 13 
	AND obrv.idprj_obrv = 1 
	AND ndfv.idprj_ndfv = 1; -- manchons