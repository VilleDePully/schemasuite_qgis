-- Ce fichier a un préfixe différent pour être créé en premier

DROP VIEW IF EXISTS export.vw_annexes;

CREATE OR REPLACE VIEW export.vw_annexes AS

    SELECT 
        id_anx AS id,
        chemin_anx AS chemin,
        lower(entitykey_anx) AS guid_objet,
        entitytype_anx AS type_objet

    FROM dbo.annexe_anx;

