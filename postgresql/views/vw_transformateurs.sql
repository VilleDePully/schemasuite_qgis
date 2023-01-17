DROP VIEW IF EXISTS export.vw_transformateurs;

CREATE OR REPLACE VIEW export.vw_transformateurs AS

SELECT
	obrv.id_obrv as id_obrv,
	obrv.idobr_obrv as id_obr,
	v_obrvl.idparent_cmp as id_parent,
	obrv.modele_obrv AS modele,
	obrv.code_obrv AS code,
	obrv.nom_obrv as nom,
	lower(obrv.racineguid_obrv) as guid_racine,
	eta.libelle_eta as etat_deploiement,
	ete.libelle_ete as etat_entretien,
	prt.libelle_prt as type_propriete,
	obrv.convention_obrv as num_esti,
	obrv.constructiondate_obrv as date_construction,
	obrv.miseenservicedate_obrv as date_mise_en_service,
	obrv.horsservicedate_obrv as date_mise_hors_service,
	obrv.observation_obrv as observation,
	prap.libelle_pra as proprietaire,
	prae.libelle_pra as exploitant,
	praf.libelle_pra as fournisseur,
	obrv.creationdate_obrv AS date_creation,
	obrv.modificationdate_obrv AS date_modification,
	--Attributs spécifiques
	copv.noserie_copv as num_serie,
	copv.noappareil_copv as num_appareil,
	copv.tensionnominal_copv AS tension_nominale,
	copv.etatflux_copv AS etat_flux,
	trf.ucc_trf AS ucc,
	trf.pertefer_trf AS perte_fer,
	trf.pertecuivre_trf AS perte_cuivre,
	trf.typeborne_trf AS type_borne,
	trf.couplage_trf AS couplage,
	trf.posinserateur_trf AS position_inserateur,
	trf.poidstotal_trf AS poids_total,
	trf.courantprimaire_trf AS intensite_primaire,
	trf.courantsecondaire_trf AS intensite_secondaire,
	trf.rapporttension_trf AS rapport_tension,
	trf.isolation_trf AS isolation_trf,
	trf.poidshuile_trf AS poids_huile,
	trf.puissance_trf AS puissance
	--Geometry
	--st_centroid(ST_Force2D(ndfv.the_geom))::geometry('Point',2056) as geom_centroid,
	--ST_Force2D(ndfv.the_geom)::geometry('Polygon',2056) as geom_polygon
	
FROM dbo.v_objetreseauversionliaison v_obrvl
	LEFT JOIN dbo.objetreseauversion_obrv obrv ON v_obrvl.id_obrv = obrv.id_obrv
	--LEFT JOIN dbo.noeudfeatureversion_ndfv ndfv ON  ndfv.idobr_ndfv = v_obrvl.idparent_cmp
	--LEFT JOIN dbo.noeudversion_nodv nodv ON nodv.id_obrv = v_obrvl.idparent_cmp
	LEFT JOIN dbo.netat_eta eta ON  eta.id_eta = obrv.idetat_obrv
	LEFT JOIN dbo.netatentretien_ete ete ON  ete.id_ete = obrv.idetatentretien_obrv
	LEFT JOIN dbo.nproprietetype_prt prt ON  prt.id_prt = obrv.idproprietetype_obrv
	LEFT JOIN dbo.npersonneabstraite_pra prap ON obrv.idproprietairepra_obrv = prap.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra prae ON obrv.idexploitantpra_obrv = prae.id_pra
	LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
	LEFT JOIN dbo.projet_prj prj ON prj.id_prj = obrv.idprj_obrv
	LEFT JOIN dbo.composantversion_copv copv ON copv.id_obrv = obrv.id_obrv 
	LEFT JOIN dbo.transformateur_trf trf ON trf.id_obrv = obrv.id_obrv

WHERE obrv.idorc_obrv IN (41) 
	AND obrv.idprj_obrv = 1
	--AND ndfv.idprj_ndfv = 1 -- Transformateurs
	;
