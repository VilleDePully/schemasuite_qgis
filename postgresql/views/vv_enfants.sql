-- Ce fichier a un préfixe différent pour être créé en premier

DROP VIEW IF EXISTS export.vw_enfants;

CREATE OR REPLACE VIEW export.vw_enfants AS

    SELECT IdParent_CMP as id_parent,
        COUNT(*) as nombre_enfants
    FROM dbo.V_ObjetReseauVersionLiaison
    WHERE IdParent_CMP IS NOT NULL
    GROUP BY IdParent_CMP