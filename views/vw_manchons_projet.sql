DROP VIEW IF EXISTS export.vw_manchons_projet;

CREATE OR REPLACE VIEW export.vw_manchons_projet AS

SELECT
    obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.nom_obrv as nom,
	eta.libelle_eta as etat,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	ndfv.niveautension_ndf as tension,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	nodv.geoposz_nodv as altitude,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	obrv.fictif_obrv as fictif,
	st_centroid(ST_Force2D(ndfv.the_geom))::geometry('Point',2056) as geom_centroid,
	ST_Force2D(ndfv.the_geom)::geometry('Polygon',2056) as geom_polygon
	
FROM dbo.objetreseauversion_obrv obrv
LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.idobrv_nodv = obrv.id_obrv
LEFT JOIN dbo.noeudfeatureversion_ndfv ndfv ON  ndfv.idobr_ndfv = obrv.idobr_obrv
LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
WHERE obrv.idorc_obrv = 41 and id_prj != 1 and idprj_ndfv != 1; -- manchons