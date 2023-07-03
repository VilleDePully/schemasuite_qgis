-- Ce fichier a un préfixe différent pour être créé en premier

DROP VIEW IF EXISTS export.vw_transformateurs_agg;

CREATE OR REPLACE VIEW export.vw_transformateurs_agg AS

SELECT
	v_obrvl.idparent_cmp as id_parent,
	string_agg('('||coalesce(obrv.modele_obrv,'-')::text||' / '||coalesce(trf.puissance_trf,'0')::text||' / '||coalesce(trf.couplage_trf,'-')::text||')', ' ; '::text) AS transfo_infos
FROM dbo.v_objetreseauversionliaison v_obrvl
	LEFT JOIN dbo.objetreseauversion_obrv obrv ON v_obrvl.id_obrv = obrv.id_obrv
	LEFT JOIN dbo.transformateur_trf trf ON trf.id_obrv = obrv.id_obrv
WHERE obrv.idorc_obrv IN (41) 
	AND obrv.idprj_obrv = 1
GROUP BY
	v_obrvl.idparent_cmp;