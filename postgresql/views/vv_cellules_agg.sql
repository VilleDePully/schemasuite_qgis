-- Ce fichier a un préfixe différent pour être créé en premier

DROP VIEW IF EXISTS export.vw_cellules_agg;

CREATE OR REPLACE VIEW export.vw_cellules_agg AS

SELECT
	v_obrvl.idparent_cmp as id_parent,
	string_agg('('||coalesce(copv.noserie_copv,'-')||' / '||coalesce(obrv.modele_obrv,'-')||' / '||coalesce(praf.libelle_pra,'-')||')', ' ; '::text) AS cellule_infos	-- ! gestion valeurs nulles
	
FROM dbo.v_objetreseauversionliaison v_obrvl
	LEFT JOIN dbo.objetreseauversion_obrv obrv ON v_obrvl.id_obrv = obrv.id_obrv
	LEFT JOIN dbo.npersonneabstraite_pra praf ON obrv.idfournisseurpra_obrv = praf.id_pra
	LEFT JOIN dbo.composantversion_copv copv ON copv.id_obrv = obrv.id_obrv

WHERE obrv.idorc_obrv IN (26) 
	AND obrv.idprj_obrv = 1
	--AND ndfv.idprj_ndfv = 1 -- Transformateurs
GROUP BY
	v_obrvl.idparent_cmp;
