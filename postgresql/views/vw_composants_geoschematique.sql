DROP VIEW IF EXISTS export.vw_composants_geoschematique;

CREATE OR REPLACE VIEW export.vw_composants_geoschematique AS

SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	orc.libelle_orc as type_orc,
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
	--npfv.niveautension_npfv as tension_acceptee,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	praf.libelle_pra as fournisseur,
	obrv.creationdate_obrv AS date_creation,
	obrv.modificationdate_obrv AS date_modification,
	--Composants
	copv.etatflux_copv AS etat_flux,
	--Niveau de tension
	niv.code_niv as tension,
	--Attributs spécifiques
	--Annexes
	--anx_agg.annexe_chemins as annexes,
	--Geometry
	npfv.the_geom as geom_point_geoschematique
	
FROM dbo.v_objetreseauversionliaison v_obrvl
	LEFT JOIN dbo.objetreseauversion_obrv obrv ON v_obrvl.id_obrv = obrv.id_obrv
	LEFT JOIN dbo.nobjetreseauclasse_orc orc ON orc.id_orc = obrv.idorc_obrv
	-- lien vers le noeud de l'objet parent (armoire)
	--LEFT JOIN (
	--	SELECT *
	--	FROM dbo.noeudfeatureversion_ndfv ndfv1
	--	WHERE ndfv1.idprj_ndfv = 1
	--	AND ndfv1.idsch_ndfv = 1) ndfv ON  ndfv.idobr_ndfv = v_obrvl.idparent_cmp
	LEFT JOIN (
		SELECT * 
		FROM dbo.noeudconnectionpointfeatureversion_npfv npfv1
		WHERE npfv1.idprj_npfv = 1
		AND npfv1.idsch_npfv != 1
	) npfv ON npfv.idobr_npfv = obrv.idobr_obrv
	LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.id_obrv = v_obrvl.id_obrv
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
	LEFT JOIN dbo.nproprietetype_prt prt ON  prt.id_prt = obrv.idproprietetype_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
	LEFT JOIN dbo.composantversion_copv copv ON copv.id_obrv = obrv.idobr_obrv
	LEFT JOIN dbo.nniveautension_niv niv ON niv.id_niv = copv.idniv_copv
	LEFT JOIN export.vw_annexes_agg anx_agg ON anx_agg.guid_objet = lower(obrv.racineguid_obrv)

WHERE obrv.idorc_obrv IN (29,30,38) 
	AND obrv.idprj_obrv = 1
	AND npfv.the_geom IS NOT NULL; -- discjoncteur, fusible et sectionneur
