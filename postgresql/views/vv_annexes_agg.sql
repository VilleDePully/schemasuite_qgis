-- Ce fichier a un préfixe différent pour être créé en premier

DROP VIEW IF EXISTS export.vw_annexes_agg;

CREATE OR REPLACE VIEW export.vw_annexes_agg AS

    SELECT 
        idobr_anx AS idobr_objet,
        string_agg(chemin_anx, ' ; '::text) AS annexe_chemins, --gérer un lien qgis + un lien gmf ?
        type_anx AS type_objet
    FROM dbo.annexe_anx
	GROUP BY
		idobr_anx,
        type_anx;
