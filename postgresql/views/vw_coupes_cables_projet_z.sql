DROP MATERIALIZED VIEW IF EXISTS export.vw_coupes_cables_projet;

--File is named with _z extension to be run last with FME

CREATE MATERIALIZED VIEW IF NOT EXISTS export.vw_coupes_cables_projet
TABLESPACE pg_default
AS SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	obrv.modele_obrv AS modele,
	obrv.code_obrv AS code,
	obrv.nom_obrv as nom,
	lower(obrv.racineguid_obrv) as guid_racine,
	ROUND(ST_LENGTH(brfv.the_geom)::numeric,2)::numeric(10,2) AS longueur_calc,
	eta.libelle_eta as etat_deploiement,
	ete.libelle_ete as etat_entretien,
	prt.libelle_prt	as type_propriete,
	obrv.convention_obrv as num_esti,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.observation_obrv as observation,
	brfv.niveautension_brfv as tension,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	praf.libelle_pra as fournisseur,
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
	--Attributs spécifiques
	tyc.type_tyc as type_cablage,
	cae.resisolementrs_cae AS resistance_isolation_rs, --L1-L2
	cae.resisolementst_cae AS resistance_isolation_st, --L2-L3
	cae.resisolementrt_cae AS resistance_isolation_rt, --L1-L3
	cae.dtresisolementphasephase_cae AS date_mesure_resistance_isolement_phase_phase,
	cae.resisolementrn_cae AS resistance_isolation_rn, --L1-PE
	cae.resisolementsn_cae AS resistance_isolation_sn, --L2-PE
	cae.resisolementtn_cae AS resistance_isolation_tn, --L3-PE
	cae.dtresisolementphasepe_cae AS date_mesure_resistance_isolement_phase_pe,
	cae.mesdechargepartielle_cae AS mesure_decharges_partielles,
	cae.section_cae AS section,
	cae.sectionaffiche_cae AS section_affichee,
	cae.tensionnominale_cae AS tension_nominale,
	cae.courantadmissible_cae AS courant_admissible,
	cae.courantadm24heures_cae AS courant_admissible_24h,
	cae.reslineique_cae AS resistance_lineique,
	cae.indlineique_cae AS inductance_lineique,
	cae.caplineique_cae AS capacite_lineique,
	case when obrv.idorc_obrv IN (19)  then 1 else 0 end as aerien,
	--Geometry
    coupes_cables.geom_multi_polygon as geom_multi_polygon
    --ST_MULTI(ST_UNION(ST_BUFFER(brfv.the_geom::Geometry('LineStringZ', 2056),0.1),
    --  ST_Force2D(coupes_cables.geom_multi_polygon)))::geometry('MultiPolygon',2056) as geom_complex	

FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN dbo.branchefeatureversion_brfv brfv ON brfv.idobr_brfv = obrv.idobr_obrv
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
	LEFT JOIN dbo.nproprietetype_prt prt ON  prt.id_prt = obrv.idproprietetype_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
	LEFT JOIN dbo.cableelectrique_cae cae ON cae.id_obrv = obrv.id_obrv
	LEFT JOIN dbo.ntypecablage_tyc tyc ON cae.idtyc_cae = tyc.id_tyc
    INNER JOIN export.vw_coupes_cables_projet_geom coupes_cables ON coupes_cables.id_obr = obrv.idobr_obrv
		
WHERE obrv.idorc_obrv IN (4,18,19) 
	AND obrv.idprj_obrv != 1 
	AND brfv.idprj_brfv != 1
WITH DATA;