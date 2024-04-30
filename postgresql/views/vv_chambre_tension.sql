--Cette vue calcule la tension du point de connexion present dans la chambre
--TODO : prendre la plus haute tension présente HT>MT>BT>EP>CFA

DROP VIEW IF EXISTS export.vv_chambre_tension;

CREATE OR REPLACE VIEW export.vv_chambre_tension AS

SELECT
    obrv.id_obrv as id_obrv,
	min(niv.code_niv) as niveau_tension
	
FROM dbo.objetreseauversion_obrv obrv
	LEFT JOIN (
		SELECT *
		FROM dbo.v_objetreseauversionliaison v_obrvl
		WHERE v_obrvl.nomclasse_orc= 'PointConnexion') v_obrvl_pdc 
		ON  v_obrvl_pdc.idparent_cmp = obrv.idobr_obrv
	LEFT JOIN dbo.composantversion_copv copv ON copv.id_obrv = v_obrvl_pdc.id_obrv
	LEFT JOIN dbo.nniveautension_niv niv ON niv.id_niv = copv.idniv_copv
	
WHERE obrv.idorc_obrv IN (46,80)
	AND v_obrvl_pdc.id_obrv IS NOT NULL
GROUP by obrv.id_obrv