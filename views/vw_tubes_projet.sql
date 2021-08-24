DROP VIEW IF EXISTS sigip.vw_tubes_projet;

CREATE OR REPLACE VIEW sigip.vw_tubes_projet AS

SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.nom_obrv as nom,
	eta.libelle_eta as etat,
	ete.libelle_ete as etat_entretien,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	obrv.fictif_obrv as fictif,
	cofv.the_geom::geometry('LineStringZ','2056') as the_geom

FROM dbo.objetreseauversion_obrv obrv
LEFT JOIN dbo.conduitefeatureversion_cofv cofv ON cofv.idobr_cofv = obrv.idobr_obrv
LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
LEFT JOIN dbo.projet_prj prj ON prj.id_prj = cofv.idprj_cofv
WHERE idorc_obrv = 2 AND prj.id_prj <> 1; -- conduites
