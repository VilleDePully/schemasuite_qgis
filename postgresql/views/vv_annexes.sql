-- Ce fichier a un préfixe différent pour être créé en premier

DROP VIEW IF EXISTS export.vw_annexes;

CREATE OR REPLACE VIEW export.vw_annexes AS

    SELECT 
        id_anx AS id,
        chemin_anx AS chemin,
        idobr_anx AS idobr_objet,
        type_anx AS type_objet

    FROM dbo.annexe_anx;

