
CREATE VIEW export.vw_zones_projets AS

	SELECT
		zft.id_zft as id_zft,
		zft.label_zft as label_zft,
		prj.id_prj AS projet_id,
		prj.nom_prj AS projet_nom,
		prj.description_prj AS projet_description,
		prj.etat_prj AS projet_etat,
		geometry_polygon =
		CASE 
			WHEN geometry_zft.STGeometryType() = 'Point' 
				THEN geometry_zft.STBuffer(10)
			ELSE geometry_zft
		END
		
	FROM dbo.zonefeature_zft zft
		LEFT JOIN dbo.projet_prj prj ON prj.nom_prj = zft.label_zft
	; -- zones de projets