SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Author:		Popescu Adrian
-- Create date: 11.10.2022
-- Mod. date: 01.12.2023 - Set a name to the transaction + correct delete of CoupeTextFeature_CTF
-- Description:	Script for deleting network object
-- =============================================
ALTER PROCEDURE [dbo].[SP_DeleteNetworkObject]
	@NetworkObjectVersionRootId integer
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION [SP_DeleteNetworkObject];
	BEGIN TRY
		DELETE FROM Connexion_CNX WHERE IdBRA_CNX = @NetworkObjectVersionRootId OR IdOBR_CNX = @NetworkObjectVersionRootId;
		DELETE FROM Composition_CMP WHERE IdParent_CMP = @NetworkObjectVersionRootId OR IdEnfant_CMP = @NetworkObjectVersionRootId;
		DELETE FROM ContenuSchema_CSH WHERE IdOBR_CSH = @NetworkObjectVersionRootId;
		DELETE FROM SchemaVersion_SCHV WHERE IdOBR_SCHV = @NetworkObjectVersionRootId;
		DELETE FROM Schema_SCH WHERE IdOBR_SCH = @NetworkObjectVersionRootId;
		DELETE FROM Schema_SCH WHERE NOT EXISTS (SELECT * FROM SchemaVersion_SCHV WHERE IdSCH_SCHV = Id_SCH);

		DELETE FROM TraceFeatureVersion_TRAV WHERE IdOBR_TRAV = @NetworkObjectVersionRootId;
		DELETE FROM TraceFeature_TRA WHERE NOT EXISTS (SELECT * FROM TraceFeatureVersion_TRAV WHERE IdTRA_TRAV = Id_TRA);
		DELETE FROM NoeudFeatureVersion_NDFV WHERE IdOBR_NDFV = @NetworkObjectVersionRootId;
		DELETE FROM NoeudFeature_NDF WHERE NOT EXISTS (SELECT * FROM NoeudFeatureVersion_NDFV WHERE IdNDF_NDFV = Id_NDF);
		DELETE FROM NoeudConnectionPointFeatureVersion_NPFV WHERE IdOBR_NPFV = @NetworkObjectVersionRootId;
		DELETE FROM NoeudConnectionPointFeature_NPF WHERE NOT EXISTS (SELECT * FROM NoeudConnectionPointFeatureVersion_NPFV WHERE IdNPF_NPFV = Id_NPF);
		DELETE FROM BrancheFeatureVersion_BRFV WHERE IdOBR_BRFV = @NetworkObjectVersionRootId;
		DELETE FROM BrancheFeature_BRF WHERE NOT EXISTS (SELECT * FROM BrancheFeatureVersion_BRFV WHERE IdBRF_BRFV = Id_BRF);
		DELETE FROM ConduiteFeatureVersion_COFV WHERE IdOBR_COFV = @NetworkObjectVersionRootId;
		DELETE FROM ConduiteFeature_COF WHERE NOT EXISTS (SELECT * FROM ConduiteFeatureVersion_COFV WHERE IdCOF_COFV = Id_COF);


		DELETE LinkVersionTable
		       FROM CoupeLinkFeatureVersion_KYFV LinkVersionTable
		       JOIN CoupeLinkFeature_KYF LinkRootTable ON LinkRootTable.Id_KYF = LinkVersionTable.IdKYF_KYFV
			   JOIN CoupeFeatureVersion_CUPV CoupeVersionTable ON CoupeVersionTable.IdCUP_CUPV = LinkRootTable.IdCUP_KYF
			  WHERE CoupeVersionTable.IdOBR_CUPV = @NetworkObjectVersionRootId

	    DELETE LinkVersionTable
		       FROM CoupeLinkFeatureVersion_KYFV LinkVersionTable
		       JOIN CoupeLinkFeature_KYF LinkRootTable ON LinkRootTable.Id_KYF = LinkVersionTable.IdKYF_KYFV
			   JOIN CoupeTextFeatureVersion_CTFV TextVersionTable ON TextVersionTable.IdCTF_CTFV = LinkRootTable.IdCTF_KYF
			  WHERE TextVersionTable.IdOBR_CTFV = @NetworkObjectVersionRootId
		DELETE FROM CoupeLinkFeature_KYF WHERE NOT EXISTS (SELECT * FROM CoupeLinkFeatureVersion_KYFV WHERE IdKYF_KYFV = Id_KYF);

    
    
    DELETE FROM CoupeTextFeatureVersion_CTFV WHERE IdOBR_CTFV = @NetworkObjectVersionRootId;
		DELETE FROM CoupeTextFeature_CTF WHERE NOT EXISTS (SELECT * FROM CoupeTextFeatureVersion_CTFV WHERE IdCTF_CTFV = id_CTF);
		DELETE FROM CoupeFeatureVersion_CUPV WHERE IdOBR_CUPV = @NetworkObjectVersionRootId;
		DELETE FROM CoupeFeature_CUP WHERE NOT EXISTS (SELECT * FROM CoupeFeatureVersion_CUPV WHERE IdCUP_CUPV = Id_CUP);
    
    -- Si tracé --> supprimer aussi les éléments de coupes internes 
    IF EXISTS(SELECT id_OBR FROM ObjetReseau_OBR inner join NObjetReseauClasse_ORC on idORC_OBR = id_ORC WHERE code_ORC = 'TRC' And id_OBR = @NetworkObjectVersionRootId)
    BEGIN
      DELETE FROM dbo.CoupeTextFeatureVersion_CTFV
      WHERE IdCTF_CTFV in 
      (
        SELECT id_CTF FROM dbo.CoupeTextFeature_CTF where IdCUP_CTF in 
          (
            SELECT c.Id_CUP 
            FROM CoupeFeatureVersion_CUPV cv inner join 
              CoupeFeature_CUP c on c.Id_CUP = cv.IdCUP_CUPV
            WHERE 
              c.CoupeTraceRacineGuid_CUP not in (SELECT cc.guid_CUP FROM CoupeFeature_CUP cc)
          )
      )

      DELETE FROM dbo.CoupeTextFeature_CTF 
      WHERE IdCUP_CTF in 
      (
        SELECT c.Id_CUP FROM CoupeFeatureVersion_CUPV cv inner join CoupeFeature_CUP c on c.Id_CUP = cv.IdCUP_CUPV 
        WHERE 
        c.CoupeTraceRacineGuid_CUP not in (SELECT cc.guid_CUP FROM CoupeFeature_CUP cc)
      )

      DELETE FROM CoupeFeatureVersion_CUPV
      WHERE Id_CUPV in (
      SELECT cv.Id_CUPV 
      FROM CoupeFeatureVersion_CUPV cv inner join CoupeFeature_CUP c on c.Id_CUP = cv.IdCUP_CUPV
      WHERE 
        c.CoupeTraceRacineGuid_CUP not in (SELECT cc.guid_CUP FROM CoupeFeature_CUP cc)
      )

      DELETE FROM CoupeFeature_CUP
      WHERE CoupeTraceRacineGuid_CUP not in (SELECT cc.guid_CUP FROM CoupeFeature_CUP cc)
    END
    
		DELETE FROM ObjetReseauVersion_OBRV WHERE IdOBR_OBRV = @NetworkObjectVersionRootId;
		DELETE FROM ObjetReseau_OBR WHERE NOT EXISTS (SELECT * FROM ObjetReseauVersion_OBRV WHERE IdOBR_OBRV = Id_OBR);
		
    COMMIT TRANSACTION [SP_DeleteNetworkObject];
	
  END TRY
	BEGIN CATCH
		DECLARE @error int,
				@message varchar(4000),
				@xstate int;

		SELECT
		  @error = ERROR_NUMBER(),
		  @message = ERROR_MESSAGE(),
		  @xstate = XACT_STATE();
		  PRINT 'An error occured while deleting network object ' + @message;
		ROLLBACK TRANSACTION [SP_DeleteNetworkObject];
	END CATCH
END
GO

INSERT INTO NEtat_ETA (
   Code_ETA
  ,Libelle_ETA
  ,Couleur_ETA
  ,TexteDeRecherche_ETA
  ,Actif_ETA
  ,Description_ETA
) SELECT 
   '1006' AS Code_ETA               -- Code_ETA - nvarchar(MAX)
  ,'Fictif - A supprimer' AS Libelle_ETA            -- Libelle_ETA - nvarchar(50)
  ,NULL AS Couleur_ETA            -- Couleur_ETA - nvarchar(50)
  ,'Fictif - A supprimer' AS TexteDeRecherche_ETA   -- TexteDeRecherche_ETA - nvarchar(MAX)
  ,-1  AS Actif_ETA               -- Actif_ETA - bit
  ,'Pour noeud fictif à supprimer' AS Description_ETA        -- Description_ETA - nvarchar(50)
WHERE NOT EXISTS(SELECT Id_ETA FROM NEtat_ETA WHERE code_ETA = '1006') 
GO

--IF EXISTS(SELECT t.object_ID FROM sys.tables t WHERE t.name = 'zsysIncludeTKR_ZIK')
--DROP TABLE [dbo].[zsysIncludeTKR_ZIK]
--GO

IF NOT EXISTS(SELECT t.object_ID FROM sys.tables t WHERE t.name = 'zsysIncludeTKR_ZIK')
CREATE TABLE [dbo].[zsysIncludeTKR_ZIK] (
[id_ZIK] int IDENTITY(1, 1) NOT NULL,
[type_ZIK] int NOT NULL DEFAULT (0),
[idOBRParent_ZIK] int NULL,
[idOBREnfant_ZIK] int NULL,
[GEOM_ZIK] geometry NULL
CONSTRAINT [PK_ZIK]
PRIMARY KEY CLUSTERED ([id_ZIK] ASC)
WITH ( PAD_INDEX = OFF,
FILLFACTOR = 100,
IGNORE_DUP_KEY = OFF,
STATISTICS_NORECOMPUTE = OFF,
ALLOW_ROW_LOCKS = ON,
ALLOW_PAGE_LOCKS = ON,
DATA_COMPRESSION = NONE )
 ON [PRIMARY]
) 
ON [PRIMARY]
--WITH (DATA_COMPRESSION = NONE);
GO

ALTER TABLE [dbo].[zsysIncludeTKR_ZIK] SET (LOCK_ESCALATION = TABLE);
GO

IF EXISTS(SELECT v.[object_id] FROM SYS.VIEWS v WHERE v.name = 'V_ParentTKR')
DROP VIEW dbo.V_ParentTKR
GO

CREATE VIEW dbo.V_ParentTKR
AS
SELECT DISTINCT
  idOBRParent_ZIK, idOBREnfant_ZIK
FROM 
  dbo.zsysIncludeTKR_ZIK z
WHERE 
  type_ZIK = 0 And
  idOBRParent_ZIK not in (SELECT idOBREnfant_ZIK FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = 0)
GO

IF NOT EXISTS(SELECT t.object_id from sys.tables t Where t.name = 'zzzTmpAction_ZAC')
CREATE TABLE [dbo].[zzzTmpAction_ZAC] (
[id_ZAC] int IDENTITY(1, 1) NOT NULL,
[etape_ZAC] int NULL,
[action_ZAC] nvarchar(4000) NULL,
[idOBR_ZAC] int NULL,
CONSTRAINT [PK_ZAC]
PRIMARY KEY CLUSTERED ([id_ZAC])
WITH ( PAD_INDEX = OFF,
FILLFACTOR = 100,
IGNORE_DUP_KEY = OFF,
STATISTICS_NORECOMPUTE = OFF,
ALLOW_ROW_LOCKS = ON,
ALLOW_PAGE_LOCKS = ON,
DATA_COMPRESSION = NONE )
 ON [PRIMARY]
)
ON [PRIMARY];
GO

IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'fn_GetIncludesNodes')
DROP FUNCTION dbo.fn_GetIncludesNodes 
GO

CREATE FUNCTION dbo.fn_GetIncludesNodes 
( 
  @idOBR int,
  @dDist float = -1
)
RETURNS @trace_result TABLE (id INT) 
AS
BEGIN
  DECLARE @geom geometry, @idPrj int
  SELECT top 1 @idPrj = id_PRJ FROM dbo.Projet_PRJ WHERE IdPRJ_PRJ Is null ORDER BY Id_PRJ
  
  SELECT @geom = ISNULL(t.GEOM_ZIK, n.Geometry_NDFV) FROM dbo.NoeudFeatureVersion_NDFV n left outer join (SELECT idOBREnfant_ZIK, GEOM_ZIK FROM zsysIncludeTKR_ZIK WHERE type_ZIK = -1) t on n.IdOBR_NDFV = t.idOBREnfant_ZIK  Where n.IdSCH_NDFV = 1 And n.IdOBR_NDFV = @idOBR And n.IdPRJ_NDFV = @idPrj
  IF @geom is not null
  BEGIN
    INSERT INTO @trace_result (id) 
      SELECT n.IdOBR_NPFV FROM 
        dbo.NoeudConnectionPointFeatureVersion_NPFV n 
      WHERE 
        n.IdSCH_NPFV = 1 And 
        n.IdOBR_NPFV != @idOBR And n.IdPRJ_NPFV = @idPrj And 
        @geom.STContains (n.Geometry_NPFV) != 0 And 
        n.IdOBR_NPFV not in (SELECT opr.IdOBR_OBRV FROM dbo.ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))
    IF @dDist>0
      INSERT INTO @trace_result (id) 
        SELECT n.IdOBR_NPFV FROM 
          dbo.NoeudConnectionPointFeatureVersion_NPFV n 
        WHERE 
          n.IdSCH_NPFV = 1 And
          n.IdOBR_NPFV != @idOBR And n.IdPRJ_NPFV = @idPrj And 
          @geom.STDistance (n.Geometry_NPFV) < @dDist And 
          n.IdOBR_NPFV not in (SELECT opr.IdOBR_OBRV FROM dbo.ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null)) And
          n.IdOBR_NPFV not in (SELECT id from @trace_result)
  END
  RETURN
END
GO


--SELECT * FROM dbo.fn_GetIncludesNodes(41099,0.05);
--SELECT * FROM dbo.fn_GetIncludesNodes(42143,0.1)

IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'sp_ExecuteCleanAction')
DROP PROCEDURE dbo.sp_ExecuteCleanAction 
GO

CREATE PROCEDURE dbo.sp_ExecuteCleanAction
(
  @strSQL nvarchar(max), 
  @idOBRRef int
)
AS
BEGIN
  DECLARE @idOthObr int, @iEtape int
  SELECT @iEtape = MAX(etape_ZAC)+1 FROM zzzTmpAction_ZAC
  IF @iEtape is null 
    SET @iEtape = 1 
  
  IF @idOBRRef < 0
    EXECUTE sp_executeSQL @strSQL
  ELSE
  BEGIN
    INSERT INTO zzzTmpAction_ZAC (etape_ZAC, action_ZAC, idOBR_ZAC) VALUES (@iEtape, @strSQL ,@idOthObr)
    SET @iEtape = @iEtape + 1
    INSERT INTO zzzTmpAction_ZAC (etape_ZAC, action_ZAC, idOBR_ZAC) VALUES (@iEtape, 'GO', @idOthObr)
  END
END
GO


IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'sp_MoveZFLIntoGraphicPoint')
DROP PROCEDURE dbo.sp_MoveZFLIntoGraphicPoint 
GO

CREATE PROCEDURE dbo.sp_MoveZFLIntoGraphicPoint
(
  @idOBRRef int
)
AS
BEGIN
  DECLARE @guid uniqueidentifier, @idOb int
  
  SET @guid = NewId()
  INSERT INTO GraphiqueFeature_GQT (Guid_GQT) SELECT @guid AS Guid_GQT 
  SELECT @idOb = id_GQT FROM GraphiqueFeature_GQT WHERE Guid_GQT = @guid
  
  INSERT INTO GraphiqueFeatureVersion_GQTV (
     Libelle_GQTV
    ,Geometry_GQTV
    ,IdGQT_GQTV
    ,IdPRJ_GQTV
    ,Guid_GQTV
    ,RacineGuid_GQTV
    ,State_GQTV
    ,IdSCH_GQTV
    ,Type_GQTV
  ) SELECT 
     ng.Libelle_NPFV AS Libelle_GQTV           -- Libelle_GQTV - nvarchar(MAX)
    ,ng.Geometry_NPFV AS Geometry_GQTV          -- Geometry_GQTV - geometry
    ,@idOb   AS IdGQT_GQTV              -- IdGQT_GQTV - int
    ,ng.IdPRJ_NPFV   AS IdPRJ_GQTV              -- IdPRJ_GQTV - int
    ,newid() AS Guid_GQTV           -- Guid_GQTV - uniqueidentifier
    ,@guid AS RacineGuid_GQTV     -- RacineGuid_GQTV - uniqueidentifier
    ,0   AS State_GQTV              -- State_GQTV - int
    ,1   AS IdSCH_GQTV              -- IdSCH_GQTV - int
    ,1   AS Type_GQTV               -- Type_GQTV - int
  FROM
     NoeudConnectionPointFeatureVersion_NPFV ng inner join ObjetReseauVersion_OBRV ob on ng.IdOBR_NPFV = ob.IdOBR_OBRV And ob.IdPRJ_OBRV = ng.IdPRJ_NPFV
  WHERE ng.IdSCH_NPFV = 1 And ng.IdOBR_NPFV = @idOBRRef   
END
GO

IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'fn_PointTable')
DROP FUNCTION dbo.fn_PointTable 
GO

CREATE FUNCTION dbo.fn_PointTable
(
  @geom geometry
)
RETURNS @table_Result TABLE (geom geometry)
AS
BEGIN
  DECLARE @iPt int
  set @iPt = 1
  WHILE @iPt < @geom.STNumPoints()
  BEGIN
    INSERT INTO @table_Result (geom) SELECT @geom.STPointN(@iPt)
    SET @iPt = @iPt + 1
  END
  RETURN
END
GO

IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'sp_MoveTkrPointIntoGraphicPoint')
DROP PROCEDURE dbo.sp_MoveTkrPointIntoGraphicPoint 
GO

CREATE PROCEDURE dbo.sp_MoveTkrPointIntoGraphicPoint
(
  @idOBRRef int
)
AS
BEGIN
  DECLARE @guid uniqueidentifier, @idOb int, @geom geometry, @iPt int, @cbPt int, @iStep int
  -- Step 1: create geographic node
  
  SET @guid = NewId()
  INSERT INTO ExternalNoeudFeature_ENF (Guid_ENF)  SELECT @guid AS Guid_ENF 
  SELECT @idOb = id_ENF FROM ExternalNoeudFeature_ENF WHERE Guid_ENF = @guid
  INSERT INTO ExternalNoeudFeatureVersion_ENFV (
     Libelle_ENFV
    ,Geometry_ENFV
    ,IdENF_ENFV
    ,IdPRJ_ENFV
    ,Guid_ENFV
    ,RacineGuid_ENFV
    ,State_ENFV
    ,IdSCH_ENFV
    ,ClassCode_ENFV
  ) SELECT 
     Nom_OBRV AS Libelle_ENFV           -- Libelle_ENFV - nvarchar(MAX)
    ,Geometry_NDFV AS Geometry_ENFV          -- Geometry_ENFV - geometry
    ,@idOb   AS IdENF_ENFV              -- IdENF_ENFV - int
    ,IdPRJ_OBRV   AS IdPRJ_ENFV              -- IdPRJ_ENFV - int
    ,newid() AS Guid_ENFV           -- Guid_ENFV - uniqueidentifier
    ,@guid AS RacineGuid_ENFV     -- RacineGuid_ENFV - uniqueidentifier
    ,0   AS State_ENFV              -- State_ENFV - int
    ,1   AS IdSCH_ENFV              -- IdSCH_ENFV - int
    ,N'TKR' AS ClassCode_ENFV          -- ClassCode_ENFV - nvarchar(5)
  FROM
    NoeudFeatureVersion_NDFV ng inner join 
      ObjetReseauVersion_OBRV ob on ng.IdOBR_NDFV = ob.IdOBR_OBRV And ob.IdPRJ_OBRV = ng.IdPRJ_NDFV
  WHERE 
    ng.IdSCH_NDFV = 1 And ng.IdOBR_NDFV = @idOBRRef 

  -- Step 2: create geopoint for each points of polygon  
  SELECT @geom = Geometry_NDFV FROM NoeudFeatureVersion_NDFV WHERE IdOBR_NDFV = @idOBRRef
  SET @cbPt = @geom.STNumPoints()
  SET @iStep = case when @cbPt > 50 then 5 when @cbPt > 40 then 4 when @cbPt > 30 then 3 when @cbPt > 20 then 2 else  1 end
  SET @iPt = 1
  WHILE @iPt < @geom.STNumPoints()
  BEGIN
    SET @guid = NewId()
    INSERT INTO GraphiqueFeature_GQT (Guid_GQT) SELECT @guid AS Guid_GQT 
    SELECT @idOb = id_GQT FROM GraphiqueFeature_GQT WHERE Guid_GQT = @guid
    
    INSERT INTO GraphiqueFeatureVersion_GQTV (
       Libelle_GQTV
      ,Geometry_GQTV
      ,IdGQT_GQTV
      ,IdPRJ_GQTV
      ,Guid_GQTV
      ,RacineGuid_GQTV
      ,State_GQTV
      ,IdSCH_GQTV
      ,Type_GQTV
    ) SELECT 
       ISNULL(ng.Libelle_NPFV,'C') + '-' + LTRIM(STR(@iPt))  AS Libelle_GQTV           -- Libelle_GQTV - nvarchar(MAX)
      ,@geom.STPointN(@iPt) AS Geometry_GQTV          -- Geometry_GQTV - geometry
      ,@idOb   AS IdGQT_GQTV              -- IdGQT_GQTV - int
      ,ng.IdPRJ_NPFV   AS IdPRJ_GQTV              -- IdPRJ_GQTV - int
      ,newid() AS Guid_GQTV           -- Guid_GQTV - uniqueidentifier
      ,@guid AS RacineGuid_GQTV     -- RacineGuid_GQTV - uniqueidentifier
      ,0   AS State_GQTV              -- State_GQTV - int
      ,1   AS IdSCH_GQTV              -- IdSCH_GQTV - int
      ,1   AS Type_GQTV               -- Type_GQTV - int
    FROM
      dbo.NoeudConnectionPointFeatureVersion_NPFV ng inner join 
        dbo.ObjetReseauVersion_OBRV ob on ng.IdOBR_NPFV = ob.IdOBR_OBRV And ob.IdPRJ_OBRV = ng.IdPRJ_NPFV
    WHERE 
      ng.IdSCH_NPFV = 1 And 
      ng.IdOBR_NPFV = @idOBRRef   
    SET @iPt = @iPt + @iStep
  END
END
GO

IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'sp_ReplaceManhole')
DROP PROCEDURE dbo.sp_ReplaceManhole 
GO

CREATE PROCEDURE dbo.sp_ReplaceManhole
(
  @idOBRToDel int,  
  @idOBRToKeep int, 
  @iBuildGeoPt int
)
AS
BEGIN
  DECLARE @idBra int

  -- Remplacer les composition par @idOBRToKeep
  UPDATE composition_CMP SET IdParent_CMP = @idOBRToKeep WHERE IdParent_CMP = @idOBRToDel
  
  DECLARE cursBra CURSOR LOCAL READ_ONLY FOR
    SELECT DISTINCT idBRA_CNX FROM Connexion_CNX WHERE IdOBR_CNX = @idOBRToDel
  
  OPEN cursBra
  FETCH NEXT FROM cursBra INTO @idBra
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF (SELECT COUNT(id_CNX) FROM Connexion_CNX WHERE IdBRA_CNX = @idBra And IdOBR_CNX = @idOBRToDel) > 1 
      -- Traversant
      IF EXISTS(SELECT id_CNX FROM Connexion_CNX WHERE IdBRA_CNX = @idBra And IdOBR_CNX = @idOBRToKeep)
        -- Suppression des connexions passantes
        DELETE FROM Connexion_CNX WHERE IdBRA_CNX = @idBra And IdOBR_CNX = @idOBRToDel
      ELSE
        UPDATE Connexion_CNX SET IdOBR_CNX = @idOBRToKeep WHERE IdBRA_CNX = @idBra And IdOBR_CNX = @idOBRToDel
    ELSE
    BEGIN
      -- Suppression des éventuels cnx passante sur Keep
      DELETE FROM Connexion_CNX WHERE IdBRA_CNX = @idBra And IdOBR_CNX = @idOBRToKeep
      
      UPDATE Connexion_CNX SET IdOBR_CNX = @idOBRToKeep WHERE IdBRA_CNX = @idBra And IdOBR_CNX = @idOBRToDel
    END
    FETCH NEXT FROM cursBra INTO @idBra
  END
  
  CLOSE cursBra
  DEALLOCATE cursBra
  IF @iBuildGeoPt != 0
    EXEC dbo.sp_MoveTkrPointIntoGraphicPoint @idOBRToDel

  -- Récupérer attributs
  UPDATE ob1
    SET 
      ob1.Nom_OBRV = 
        case when ob1.Nom_OBRV is null then ob2.Nom_OBRV 
        else 
          case when ob2.nom_OBRV is null then ob1.Nom_OBRV 
          else 
            case when ob1.Nom_OBRV != ob2.Nom_OBRV then ob1.Nom_OBRV + '/' + ob2.Nom_OBRV  
            Else ob1.Nom_OBRV
            end
          end 
        end,
      ob1.IdEtat_OBRV = 
        case when ob1.IdEtat_OBRV is null then ob2.IdEtat_OBRV 
        else ob1.IdEtat_OBRV 
        end,
      ob1.Note_OBRV =
        case when ob1.Note_OBRV is null then ob2.Note_OBRV 
        else 
          case when ob2.Note_OBRV is null then ob1.Note_OBRV 
          else 
            case when ob1.Note_OBRV != ob2.Note_OBRV then ob1.Note_OBRV + '/' + ob2.Note_OBRV  
            Else ob1.Note_OBRV
            end
          end 
        end,
       ob1.Observation_OBRV =
        case when ob1.Observation_OBRV is null then ob2.Observation_OBRV 
        else 
          case when ob2.Observation_OBRV is null then ob1.Observation_OBRV 
          else 
            case when ob1.Observation_OBRV != ob2.Observation_OBRV then ob1.Observation_OBRV + '/' + ob2.Observation_OBRV  
            Else ob1.Observation_OBRV
            end
          end 
        end
     
  FROM 
    ObjetReseauVersion_OBRV ob1, 
    ObjetReseauVersion_OBRV ob2
  WHERE ob1.IdOBR_OBRV = @idOBRToKeep And ob2.IdOBR_OBRV = @idOBRToDel
  
  IF @iBuildGeoPt != 0
    UPDATE 
      zsysIncludeTKR_ZIK 
    SET 
      type_ZIK = -1, 
      GEOM_ZIK = (SELECT TOP 1 Geometry_NDFV FROM NoeudFeatureVersion_NDFV WHERE IdOBR_NDFV = @idOBRToDel And IdPRJ_NDFV = 1)
    WHERE idOBRParent_ZIK = @idOBRToDel And idOBREnfant_ZIK = @idOBRToKeep
  
  EXEC dbo.SP_DeleteNetworkObject @idOBRToDel
  
  
END
GO

IF EXISTS(SELECT fn.object_id FROM sys.all_objects fn WHERE fn.name = 'sp_CleanManhole')
DROP PROCEDURE dbo.sp_CleanManhole 
GO

CREATE PROCEDURE dbo.sp_CleanManhole
(
  @idOBRRef int,  @dDist float
)
AS
BEGIN
  DECLARE @idOthObr int, @iEtape int, @strSQL nvarchar(max)

  SELECT @iEtape = MAX(etape_ZAC)+1 FROM zzzTmpAction_ZAC
  
  IF @iEtape is null 
    SET @iEtape = 1 
  
  -- Supprimer les tracés internes
  DECLARE cursTra CURSOR LOCAL READ_ONLY FOR    
    SELECT id_OBR
    FROM 
      dbo.ObjetReseau_OBR tr inner join 
        dbo.NObjetReseauClasse_ORC orc on orc.Id_ORC = tr.IdORC_OBR 
    WHERE 
      orc.Code_ORC = 'TRC' And
      tr.id_OBR in (SELECT idBRA_CNX from dbo.Connexion_CNX WHERE idPRJ_CNX = 1 And (IdOBR_CNX = @idOBRRef or IdOBR_CNX in (select Id FROM dbo.fn_GetIncludesNodes(@idOBRRef, @dDist)))) And
      tr.Id_OBR not in (SELECT opr.IdOBR_OBRV FROM dbo.ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))
  OPEN cursTra
  FETCH NEXT FROM cursTra INTO @idOthObr
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF NOT EXISTS(SELECT id_CNX FROM dbo.Connexion_CNX WHERE idPRJ_CNX = 1 And IdBRA_CNX = @idOthObr And IdOBR_CNX not in (SELECT @idOBRRef UNION SELECT id FROM dbo.fn_GetIncludesNodes(@idOBRRef, @dDist)))
    BEGIN
      -- Le tracé n'a pas d'extrémité à l'extérieur de la zone ---> on peut le supprimer
      SET @strSQL = 'EXEC dbo.SP_DeleteNetworkObject ' + LTRIM(STR(@idOthObr))
      EXEC sp_ExecuteCleanAction @strSQL, -1 -- @idOthObr
    END
    FETCH NEXT FROM cursTra INTO @idOthObr
  END
  CLOSE cursTra
  DEALLOCATE cursTra
  
  -- Vérifier les connexions des objets conduits, câbles sur la ZFL -> il doit exister au moins une extrémité exterieur aux ZFL traités
  DECLARE cursTra CURSOR LOCAL READ_ONLY FOR    
    SELECT id_OBR
    FROM 
      dbo.ObjetReseau_OBR tr inner join 
        dbo.NObjetReseauClasse_ORC orc on orc.Id_ORC = tr.IdORC_OBR 
    WHERE 
      orc.Code_ORC != 'TRC' And
      id_OBR in (SELECT idBRA_CNX from dbo.Connexion_CNX WHERE IdOBR_CNX = @idOBRRef or IdOBR_CNX in (select Id FROM dbo.fn_GetIncludesNodes(@idOBRRef,@dDist)))
  OPEN cursTra
  FETCH NEXT FROM cursTra INTO @idOthObr
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF NOT EXISTS(SELECT id_CNX FROM dbo.Connexion_CNX WHERE state_CNX != 2 And IdBRA_CNX = @idOthObr And IdOBR_CNX not in (SELECT @idOBRRef UNION SELECT id FROM dbo.fn_GetIncludesNodes(@idOBRRef,@dDist)))
    -- On marque les ZFL
      UPDATE ObjetReseauVersion_OBRV Set NoImmo_OBRV = 'KEEP' WHERE IdORC_OBRV = 3 And IdOBR_OBRV in (SELECT idOBR_CNX FROM dbo.Connexion_CNX WHERE idPRJ_CNX = 1 And IdBRA_CNX = @idOthObr)
    FETCH NEXT FROM cursTra INTO @idOthObr
  END
  CLOSE cursTra
  DEALLOCATE cursTra
  
  DECLARE cursObj CURSOR LOCAL READ_ONLY FOR
    SELECT inc.ID
      FROM 
        dbo.fn_GetIncludesNodes(@idOBRRef, @dDist) inc inner join dbo.ObjetReseauVersion_OBRV obr on inc.id = obr.IdOBR_OBRV inner join dbo.NObjetReseauClasse_ORC orc on obr.IdORC_OBRV = orc.Id_ORC 
      WHERE 
        obr.IdOBR_OBRV != @idOBRRef And
        obr.idPRJ_OBRV = 1 And
--        (orc.Code_ORC = 'ZFL' or (orc.Code_ORC = 'TKR' And obr.IdEtat_OBRV = (SELECT id_ETA FROM NEtat_ETA Where Libelle_ETA = 'Fictif'))) And 
        orc.Code_ORC = 'ZFL' And 
        inc.id not in (SELECT idOBR_OBRV FROM ObjetReseauVersion_OBRV WHERE NoImmo_OBRV = 'KEEP') And
        obr.IdOBR_OBRV not in (SELECT opr.IdOBR_OBRV FROM dbo.ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))
  OPEN cursObj
  FETCH NEXT FROM cursObj INTO @idOthObr
  WHILE @@FETCH_STATUS = 0
  BEGIN

    -- Remplacer les connexions par @idOBRREF
    SET @strSQL = 'UPDATE Connexion_CNX SET IdOBR_CNX = ' + LTRIM(STR(@idOBRRef)) + ' WHERE IdOBR_CNX = ' + LTRIM(STR(@idOthObr)) + ' And NOT EXISTS(SELECT c.Id_CNX FROM Connexion_CNX c WHERE c.IdBRA_CNX = Connexion_CNX.IdBRA_CNX And c.IdOBR_CNX = ' + LTRIM(STR(@idOBRRef)) + ')'
    EXEC sp_ExecuteCleanAction @strSQL, -1 -- @idOthObr

    -- Remplacer les composition par @idOBRREF
    SET @strSQL = 'UPDATE composition_CMP SET IdParent_CMP = ' + LTRIM(STR(@idOBRRef)) + ' WHERE IdParent_CMP = ' + LTRIM(STR(@idOthObr))
    EXEC sp_ExecuteCleanAction @strSQL, -1 -- @idOthObr
    
    EXEC dbo.sp_MoveZFLIntoGraphicPoint @idOthObr

    SET @strSQL = 'EXEC dbo.SP_DeleteNetworkObject ' + LTRIM(STR(@idOthObr))
    EXEC sp_ExecuteCleanAction @strSQL, -1 -- @idOthObr

    FETCH NEXT FROM cursObj INTO @idOthObr
  END
  CLOSE cursObj
  DEALLOCATE cursObj
END
GO

