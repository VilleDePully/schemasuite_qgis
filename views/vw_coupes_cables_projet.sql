DROP VIEW IF EXISTS export.vw_coupes_cables_projet;

CREATE OR REPLACE VIEW export.vw_coupes_cables_projet AS

SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.nom_obrv as nom,
	eta.libelle_eta as etat,
	ete.libelle_ete as etat_entretien,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	brfv.niveautension_brfv as tension,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	prj.id_prj AS projet_id,
	prj.nom_prj AS projet_nom,
	prj.description_prj AS projet_description,
	prj.etat_prj AS projet_etat,
	obrv.fictif_obrv as fictif,
    ST_Multi(ST_Force2D(coupes_cables.geom_multi_polygon))::geometry('MultiPolygon',2056) as geom_multi_polygon
	
FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN dbo.branchefeatureversion_brfv brfv ON brfv.idobr_brfv = obrv.idobr_obrv
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = brfv.idprj_brfv
     INNER JOIN (
	 	SELECT cupv.idobr_cupv AS id_obr,
			st_union((cupv.the_geom)::geometry(PolygonZ,2056)) AS geom_multi_polygon
   		FROM dbo.coupefeatureversion_cupv cupv
  		WHERE cupv.coupetype_cupv = 4
		AND cupv.idprj_cupv <> 1
  		GROUP BY cupv.idobr_cupv) coupes_cables
		ON coupes_cables.id_obr = obrv.idobr_obrv
		
WHERE idorc_obrv = 18  and id_prj <> 1;