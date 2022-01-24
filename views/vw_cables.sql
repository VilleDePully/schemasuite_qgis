DROP VIEW IF EXISTS export.vw_cables;

CREATE OR REPLACE VIEW export.vw_cables AS

SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.nom_obrv as nom,
	ROUND(ST_LENGTH(brfv.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
	eta.libelle_eta as etat,
	ete.libelle_ete as etat_entretien,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.observation_obrv as remarque,
	brfv.niveautension_brfv as tension,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	ST_FORCE2D(brfv.the_geom)::geometry('LineString','2056') as the_geom

FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN dbo.branchefeatureversion_brfv brfv ON brfv.idobr_brfv = obrv.idobr_obrv
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
WHERE obrv.idorc_obrv IN (4,18)  AND obrv.idprj_obrv = 1 AND brfv.idprj_brfv = 1; -- cable générique, electrique
