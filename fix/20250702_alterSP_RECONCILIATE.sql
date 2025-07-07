SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[SP_RECONCILIATE]
    @projectId integer
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @saisieProject integer
DECLARE @saisieProjectGuid uniqueidentifier
DECLARE @baseProject integer
DECLARE @projectName varchar(100)

DECLARE @CREATED integer = 0
DECLARE @DEFAULT integer = 1
DECLARE @DELETED integer = 2



DECLARE project_cursor CURSOR FOR
    SELECT Id_PRJ, 
           IdPRJ_PRJ,
           Guid_PRJ,
           Nom_PRJ
      FROM Projet_PRJ 
     WHERE IdPRJ_PRJ IS NOT NULL
           AND Id_PRJ = @projectId;
           


OPEN project_cursor;
FETCH NEXT FROM project_cursor INTO @saisieProject, @baseProject, @saisieProjectGuid, @projectName;

WHILE @@FETCH_STATUS = 0
BEGIN
BEGIN TRY
BEGIN TRANSACTION
PRINT ''
PRINT ''
PRINT ''

PRINT '================================================================================================================== '
PRINT 'Reconciling project ' + @projectName + ' ' + CONVERT(varchar(100), @saisieProject)
PRINT '================================================================================================================== '


PRINT ''
PRINT ''
PRINT 'Moving schema events....'

SET ANSI_WARNINGS OFF;

UPDATE EV
   SET EV.AggregateId = OffsetBySchema.BaseGuid,
       EV.Version = COALESCE(EV.Version,0) + IIF(OffsetBySchema.Offset < 0, 0, OffsetBySchema.Offset)
FROM
(
      SELECT Saisie.Guid_SCHV SaisieGuid,
             BaseSCHV.Guid_SCHV BaseGuid,
             Saisie.MinSaisieVersion MinSaisieVersion,
             MAX(Version) MaxBaseVersion,
             MAX(Version_FSC) FileVersion,
             ISNULL(MAX(Version) + 1, ISNULL(MAX(Version_FSC) + 1, 0)) - Saisie.MinSaisieVersion Offset
        FROM
           (
              SELECT SaisieSCHV.IdSCH_SCHV,
                     SaisieSCHV.Guid_SCHV,
                     ISNULL(MIN(Version), 0) MinSaisieVersion
                FROM SchemaVersion_SCHV SaisieSCHV
                JOIN Events.Events ON AggregateId = SaisieSCHV.Guid_SCHV
               WHERE SaisieSCHV.IdPRJ_SCHV = @saisieProject AND
                     SaisieSCHV.State_SCHV != @DELETED
            GROUP BY SaisieSCHV.IdSCH_SCHV, SaisieSCHV.Guid_SCHV
           ) AS Saisie
        JOIN SchemaVersion_SCHV BaseSCHV ON BaseSCHV.IdSCH_SCHV = Saisie.IdSCH_SCHV AND BaseSCHV.IdPRJ_SCHV = @baseProject
        LEFT JOIN FichierSchema_FSC ON Id_FSC = IdFSC_SCHV
        LEFT JOIN Events.Events ON AggregateId = BaseSCHV.Guid_SCHV
        GROUP BY Saisie.Guid_SCHV, 
                 Saisie.MinSaisieVersion,
                 BaseSCHV.Guid_SCHV
) AS OffsetBySchema
JOIN Events.Events EV ON AggregateId = SaisieGuid

SET ANSI_WARNINGS ON;

PRINT ''
PRINT ''
PRINT 'Deleting schema content ...'
/*DELETE CONTENT*/
DELETE CSH
  FROM ContenuSchema_CSH SaisieCSH
  JOIN SchemaVersion_SCHV SaisieSCHV ON SaisieSCHV.Id_SCHV = IdSCH_CSH AND SaisieSCHV.IdPRJ_SCHV = @saisieProject
  JOIN SchemaVersion_SCHV BaseSCHV ON BaseSCHV.IdSCH_SCHV = SaisieSCHV.IdSCH_SCHV AND BaseSCHV.IdPRJ_SCHV = @baseProject
  JOIN ContenuSchema_CSH CSH ON CSH.IdSCH_CSH = BaseSCHV.Id_SCHV AND  CSH.GraphItemId_CSH = SaisieCSH.GraphItemId_CSH
 WHERE SaisieCSH.State_CSH = @DELETED

PRINT ''
PRINT ''
PRINT 'Updating schema content ...'
 /*UPDATE*/
 UPDATE CSH
    SET CSH.IdOBR_CSH = SaisieCSH.IdOBR_CSH,
        CSH.ParentGraphItemId_CSH = SaisieCSH.ParentGraphItemId_CSH,
        CSH.PosX_CSH = SaisieCSH.PosX_CSH,
        CSH.PosY_CSH = SaisieCSH.PosY_CSH,
        CSH.State_CSH = 0/*DEFAULT CONTENT STATE*/
  FROM ContenuSchema_CSH SaisieCSH
  JOIN SchemaVersion_SCHV SaisieSCHV ON SaisieSCHV.Id_SCHV = IdSCH_CSH AND SaisieSCHV.IdPRJ_SCHV = @saisieProject
  JOIN SchemaVersion_SCHV BaseSCHV ON BaseSCHV.IdSCH_SCHV = SaisieSCHV.IdSCH_SCHV AND BaseSCHV.IdPRJ_SCHV = @baseProject
  JOIN ContenuSchema_CSH CSH ON CSH.IdSCH_CSH = BaseSCHV.Id_SCHV AND  CSH.GraphItemId_CSH = SaisieCSH.GraphItemId_CSH
 WHERE SaisieCSH.State_CSH != @DELETED

PRINT ''
PRINT ''
PRINT 'Creating schema content ...'
/*INSERT*/
 INSERT 
   INTO ContenuSchema_CSH (IdSCH_CSH, IdOBR_CSH, GraphItemId_CSH, State_CSH, ParentGraphItemId_CSH, PosX_CSH, PosY_CSH)
 SELECT BaseSCHV.Id_SCHV,
        SaisieCSH.IdOBR_CSH,
        SaisieCSH.GraphItemId_CSH,
        0,/*DEFAULT CONTENT STATE*/
        SaisieCSH.ParentGraphItemId_CSH,
        SaisieCSH.PosX_CSH,
        SaisieCSH.PosY_CSH
  FROM ContenuSchema_CSH SaisieCSH
  JOIN SchemaVersion_SCHV SaisieSCHV ON SaisieSCHV.Id_SCHV = IdSCH_CSH AND SaisieSCHV.IdPRJ_SCHV = @saisieProject
  JOIN SchemaVersion_SCHV BaseSCHV ON BaseSCHV.IdSCH_SCHV = SaisieSCHV.IdSCH_SCHV AND BaseSCHV.IdPRJ_SCHV = @baseProject
  LEFT JOIN ContenuSchema_CSH CSH ON CSH.IdSCH_CSH = BaseSCHV.Id_SCHV AND  CSH.GraphItemId_CSH = SaisieCSH.GraphItemId_CSH
 WHERE SaisieCSH.State_CSH != @DELETED AND CSH.Id_CSH IS NULL

/*========================================================= RECONCILIATE SCHEMA ========================================================= */

PRINT ''
PRINT ''
PRINT 'Deleting schema versions...';
DELETE SCHV
  FROM SchemaVersion_SCHV SaisieSCHV
  JOIN SchemaVersion_SCHV SCHV ON SCHV.IdSCH_SCHV = SaisieSCHV.IdSCH_SCHV
 WHERE SaisieSCHV.IdPRJ_SCHV = @saisieProject AND 
       SaisieSCHV.State_SCHV = @DELETED;

/*As schemas will always have a base version, the base version will be updated instead of being replaced*/

PRINT ''
PRINT ''
PRINT 'Creating/Updating schema versions...'
UPDATE SchemaVersion_SCHV 
   SET Nom_SCHV = Src.Nom_SCHV,
       Description_SCHV = Src.Description_SCHV,
       Tag_SCHV = Src.Tag_SCHV,
       CreationDate_SCHV = Src.CreationDate_SCHV,
       CreationUtilisateur_SCHV = Src.CreationUtilisateur_SCHV,
       ModificationDate_SCHV = Src.ModificationDate_SCHV,
       ModificationUtilisateur_SCHV = Src.ModificationUtilisateur_SCHV,
       State_SCHV = 1 -- Default    
   FROM (
       SELECT IdSCH_SCHV,
              Nom_SCHV,
              Description_SCHV,
              Tag_SCHV,
              CreationDate_SCHV,
              CreationUtilisateur_SCHV,
              ModificationDate_SCHV,
              ModificationUtilisateur_SCHV
         FROM SchemaVersion_SCHV 
        WHERE IdPRJ_SCHV = @saisieProject AND State_SCHV < 2) Src 
   INNER JOIN SchemaVersion_SCHV Trgt ON Src.IdSCH_SCHV = Trgt.IdSCH_SCHV
        WHERE IdPRJ_SCHV = @baseProject;

PRINT ''
PRINT ''
PRINT '[COH] Deleting schema versions for deleted network object versions...'
DELETE SCHV
  FROM SchemaVersion_SCHV SCHV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_SCHV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE IdOBR_SCHV IS NOT NULL

PRINT ''
PRINT ''
PRINT '[COH] Deleting schema versions for versionless network object versions...'
DELETE SCHV
  FROM SchemaVersion_SCHV SCHV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_SCHV
 WHERE SCHV.IdOBR_SCHV IS NOT NULL AND Id_OBRV IS NULL



PRINT ''
PRINT ''
PRINT 'Deleting schema version roots...'
DELETE SCH
  FROM Schema_SCH SCH
  LEFT JOIN SchemaVersion_SCHV ON IdSCH_SCHV = Id_SCH
 WHERE Id_SCHV IS NULL



/* ========================================================= RECONCILIATE FEATURES ========================================================= */

PRINT ''
PRINT ''
PRINT 'Reconciliating branche features'

DELETE FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [IdPRJ_BRFV] = @baseProject AND RacineGuid_BRFV IN (SELECT RacineGuid_BRFV FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [IdPRJ_BRFV] = @saisieProject);
DELETE FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [IdPRJ_BRFV] = @saisieProject AND [State_BRFV] = 2;
UPDATE [dbo].[BrancheFeatureVersion_BRFV] SET [IdPRJ_BRFV] = @baseProject WHERE [IdPRJ_BRFV] = @saisieProject;
PRINT ''
PRINT ''
PRINT '[COH] Deleting branche feature versions for deleted network object versions...'
DELETE BRFV
  FROM BrancheFeatureVersion_BRFV BRFV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_BRFV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_BRFV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting branche feature versions for versionless network object versions...'
DELETE BRFV
  FROM BrancheFeatureVersion_BRFV BRFV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_BRFV
 WHERE Id_OBRV IS NULL AND State_BRFV != @DELETED

PRINT ''
PRINT ''
PRINT 'Deleting branche feature version versionless roots...'
DELETE FROM [dbo].[BrancheFeature_BRF] WHERE (SELECT COUNT(*) FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [RacineGuid_BRFV] = [Guid_BRF]) = 0;

PRINT ''
PRINT ''
PRINT 'Reconciliating branche schema features'

DELETE FROM [dbo].[BrancheSchemaFeatureVersion_BSFV] WHERE [IdPRJ_BSFV] = @baseProject AND RacineGuid_BSFV IN (SELECT RacineGuid_BSFV FROM [dbo].[BrancheSchemaFeatureVersion_BSFV] WHERE [IdPRJ_BSFV] = @saisieProject);
DELETE FROM [dbo].[BrancheSchemaFeatureVersion_BSFV] WHERE [IdPRJ_BSFV] = @saisieProject AND [State_BSFV] = 2;
UPDATE [dbo].[BrancheSchemaFeatureVersion_BSFV] SET [IdPRJ_BSFV] = @baseProject WHERE [IdPRJ_BSFV] = @saisieProject;


PRINT ''
PRINT ''
PRINT '[COH] Deleting branche schema feature versions for deleted network object versions...'
DELETE BSFV
  FROM BrancheSchemaFeatureVersion_BSFV BSFV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_BSFV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_BSFV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting branche schema feature versions for versionless network object versions...'
DELETE BSFV
  FROM BrancheSchemaFeatureVersion_BSFV BSFV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_BSFV
 WHERE Id_OBRV IS NULL AND State_BSFV != @DELETED

PRINT ''
PRINT ''
PRINT 'Deleting branche schema feature version versionless roots...'
DELETE FROM [dbo].[BrancheSchemaFeature_BSF] WHERE (SELECT COUNT(*) FROM [dbo].[BrancheSchemaFeatureVersion_BSFV] WHERE [RacineGuid_BSFV] = [Guid_BSF]) = 0;

PRINT ''
PRINT ''
PRINT 'Reconciliating cable features'

DELETE FROM [dbo].[CableFeatureVersion_CAFV] WHERE [IdPRJ_CAFV] = @baseProject AND RacineGuid_CAFV IN (SELECT RacineGuid_CAFV FROM [dbo].[CableFeatureVersion_CAFV] WHERE [IdPRJ_CAFV] = @saisieProject);
DELETE FROM [dbo].[CableFeatureVersion_CAFV] WHERE [IdPRJ_CAFV] = @saisieProject AND [State_CAFV] = 2;
UPDATE [dbo].[CableFeatureVersion_CAFV] SET [IdPRJ_CAFV] = @baseProject WHERE [IdPRJ_CAFV] = @saisieProject;
DELETE FROM [dbo].[CableFeature_CAF] WHERE (SELECT COUNT(*) FROM [dbo].[CableFeatureVersion_CAFV] WHERE [RacineGuid_CAFV] = [Guid_CAF]) = 0;

PRINT ''
PRINT ''
PRINT 'Reconciliating conduit features'

DELETE FROM [dbo].[ConduiteFeatureVersion_COFV] WHERE [IdPRJ_COFV] = @baseProject AND RacineGuid_COFV IN (SELECT RacineGuid_COFV FROM [dbo].[ConduiteFeatureVersion_COFV] WHERE [IdPRJ_COFV] = @saisieProject);
DELETE FROM [dbo].[ConduiteFeatureVersion_COFV] WHERE [IdPRJ_COFV] = @saisieProject AND [State_COFV] = 2;
UPDATE [dbo].[ConduiteFeatureVersion_COFV] SET [IdPRJ_COFV] = @baseProject WHERE [IdPRJ_COFV] = @saisieProject;
PRINT ''
PRINT ''
PRINT '[COH] Deleting conduit feature versions for deleted network object versions...'
DELETE COFV
  FROM ConduiteFeatureVersion_COFV COFV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_COFV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_COFV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting conduit feature versions for versionless network object versions...'
DELETE COFV
  FROM ConduiteFeatureVersion_COFV COFV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_COFV
 WHERE Id_OBRV IS NULL AND State_COFV != @DELETED

PRINT ''
PRINT ''
PRINT 'Deleting conduit feature version versionless roots...'
DELETE FROM [dbo].[ConduiteFeature_COF] WHERE (SELECT COUNT(*) FROM [dbo].[ConduiteFeatureVersion_COFV] WHERE [RacineGuid_COFV] = [Guid_COF]) = 0;
PRINT ''
PRINT ''



PRINT 'Reconciliating coupe features'


DELETE FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [IdPRJ_KYFV] = @baseProject AND RacineGuid_KYFV IN (SELECT RacineGuid_KYFV FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [IdPRJ_KYFV] = @saisieProject);
DELETE FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [IdPRJ_KYFV] = @saisieProject AND [State_KYFV] = 2;
DELETE KYFV
  FROM CoupeLinkFeatureVersion_KYFV KYFV
  JOIN CoupeLinkFeature_KYF ON Id_KYF = IdKYF_KYFV
  JOIN CoupeFeatureVersion_CUPV ON IdCUP_CUPV = IdCUP_KYF AND IdPRJ_CUPV = @saisieProject AND State_CUPV = @DELETED
UPDATE [dbo].[CoupeLinkFeatureVersion_KYFV] SET [IdPRJ_KYFV] = @baseProject WHERE [IdPRJ_KYFV] = @saisieProject;
DELETE FROM [dbo].[CoupeLinkFeature_KYF] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [RacineGuid_KYFV] = [Guid_KYF]) = 0;


DELETE OtherCTFV
  FROM CoupeTextFeatureVersion_CTFV SaisieCTFV 
  JOIN CoupeTextFeatureVersion_CTFV OtherCTFV ON OtherCTFV.IdCTF_CTFV = SaisieCTFV.IdCTF_CTFV 
 WHERE SaisieCTFV.IdPRJ_CTFV = @saisieProject
 And OtherCTFV.IdPRJ_CTFV = @baseProject

DELETE 
  FROM CoupeTextFeatureVersion_CTFV
 WHERE IdPRJ_CTFV = @saisieProject AND
       State_CTFV = @DELETED;

DELETE CTFV
  FROM CoupeTextFeatureVersion_CTFV CTFV
  JOIN CoupeTextFeature_CTF ON Id_CTF = IdCTF_CTFV
  JOIN CoupeFeatureVersion_CUPV ON IdCUP_CUPV = IdCUP_CTF AND IdPRJ_CUPV = @saisieProject AND State_CUPV = @DELETED
  
UPDATE [dbo].[CoupeTextFeatureVersion_CTFV] SET [IdPRJ_CTFV] = @baseProject WHERE [IdPRJ_CTFV] = @saisieProject;
DELETE FROM [dbo].[CoupeTextFeature_CTF] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeTextFeatureVersion_CTFV] WHERE [RacineGuid_CTFV] = [Guid_CTF]) = 0;


DELETE FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = @baseProject AND RacineGuid_CUPV IN (SELECT RacineGuid_CUPV FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = @saisieProject);
DELETE FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = @saisieProject AND [State_CUPV] = 2;
UPDATE [dbo].[CoupeFeatureVersion_CUPV] SET [IdPRJ_CUPV] = @baseProject WHERE [IdPRJ_CUPV] = @saisieProject;


PRINT ''
PRINT ''
PRINT '[COH] Deleting coupe feature versions for deleted network object versions...'
DELETE CUPV
  FROM CoupeFeatureVersion_CUPV CUPV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_CUPV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_CUPV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting coupe feature versions for versionless network object versions...'
DELETE CUPV
  FROM CoupeFeatureVersion_CUPV CUPV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_CUPV
 WHERE Id_OBRV IS NULL AND State_CUPV != @DELETED

PRINT ''
PRINT ''
PRINT 'Deleting coupe feature version versionless roots...'
DELETE FROM [dbo].[CoupeFeature_CUP] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [RacineGuid_CUPV] = [Guid_CUP]) = 0;


PRINT ''
PRINT ''
PRINT 'Reconciliating external node features'

DELETE FROM [dbo].[ExternalNoeudFeatureVersion_ENFV] WHERE [IdPRJ_ENFV] = @baseProject AND RacineGuid_ENFV IN (SELECT RacineGuid_ENFV FROM [dbo].[ExternalNoeudFeatureVersion_ENFV] WHERE [IdPRJ_ENFV] = @saisieProject);
DELETE FROM [dbo].[ExternalNoeudFeatureVersion_ENFV] WHERE [IdPRJ_ENFV] = @saisieProject AND [State_ENFV] = 2;
UPDATE [dbo].[ExternalNoeudFeatureVersion_ENFV] SET [IdPRJ_ENFV] = @baseProject WHERE [IdPRJ_ENFV] = @saisieProject;
DELETE FROM [dbo].[ExternalNoeudFeature_ENF] WHERE (SELECT COUNT(*) FROM [dbo].[ExternalNoeudFeatureVersion_ENFV] WHERE [RacineGuid_ENFV] = [Guid_ENF]) = 0;

PRINT ''
PRINT ''
PRINT 'Reconciliating graphic features'


DELETE FROM [dbo].[GraphiqueFeatureVersion_GQTV] WHERE [IdPRJ_GQTV] = @baseProject AND RacineGuid_GQTV IN (SELECT RacineGuid_GQTV FROM [dbo].[GraphiqueFeatureVersion_GQTV] WHERE [IdPRJ_GQTV] = @saisieProject);
DELETE FROM [dbo].[GraphiqueFeatureVersion_GQTV] WHERE [IdPRJ_GQTV] = @saisieProject AND [State_GQTV] = 2;
UPDATE [dbo].[GraphiqueFeatureVersion_GQTV] SET [IdPRJ_GQTV] = @baseProject WHERE [IdPRJ_GQTV] = @saisieProject;
DELETE FROM [dbo].[GraphiqueFeature_GQT] WHERE (SELECT COUNT(*) FROM [dbo].[GraphiqueFeatureVersion_GQTV] WHERE [RacineGuid_GQTV] = [Guid_GQT]) = 0;


PRINT ''
PRINT ''
PRINT 'Reconciliating link features'

DELETE FROM [dbo].[LinkFeatureVersion_LYFV] WHERE [IdPRJ_LYFV] = @baseProject AND RacineGuid_LYFV IN (SELECT RacineGuid_LYFV FROM [dbo].[LinkFeatureVersion_LYFV] WHERE [IdPRJ_LYFV] = @saisieProject);
DELETE FROM [dbo].[LinkFeatureVersion_LYFV] WHERE [IdPRJ_LYFV] = @saisieProject AND [State_LYFV] = 2;
UPDATE [dbo].[LinkFeatureVersion_LYFV] SET [IdPRJ_LYFV] = @baseProject WHERE [IdPRJ_LYFV] = @saisieProject;
DELETE FROM [dbo].[LinkFeature_LYF] WHERE (SELECT COUNT(*) FROM [dbo].[LinkFeatureVersion_LYFV] WHERE [RacineGuid_LYFV] = [Guid_LYF]) = 0;

PRINT ''
PRINT ''
PRINT 'Reconciliating node features'


DELETE FROM [dbo].[NoeudConnectionPointFeatureVersion_NPFV] WHERE [IdPRJ_NPFV] = @baseProject AND RacineGuid_NPFV IN (SELECT RacineGuid_NPFV FROM [dbo].[NoeudConnectionPointFeatureVersion_NPFV] WHERE [IdPRJ_NPFV] = @saisieProject);
DELETE FROM [dbo].[NoeudConnectionPointFeatureVersion_NPFV] WHERE [IdPRJ_NPFV] = @saisieProject AND [State_NPFV] = 2;
UPDATE [dbo].[NoeudConnectionPointFeatureVersion_NPFV] SET [IdPRJ_NPFV] = @baseProject WHERE [IdPRJ_NPFV] = @saisieProject;
PRINT ''
PRINT ''
PRINT '[COH] Deleting node connection point feature versions for deleted network object versions...'
DELETE NPFV
  FROM NoeudConnectionPointFeatureVersion_NPFV NPFV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_NPFV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_NPFV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting node connection point feature versions for versionless network object versions...'
DELETE NPFV
  FROM NoeudConnectionPointFeatureVersion_NPFV NPFV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_NPFV
 WHERE Id_OBRV IS NULL AND State_NPFV != @DELETED
PRINT ''
PRINT ''
PRINT 'Deleting versionless node connection point feature version roots...'
DELETE FROM [dbo].[NoeudConnectionPointFeature_NPF] WHERE (SELECT COUNT(*) FROM [dbo].[NoeudConnectionPointFeatureVersion_NPFV] WHERE [RacineGuid_NPFV] = [Guid_NPF]) = 0;


DELETE FROM [dbo].[NoeudFeatureVersion_NDFV] WHERE [IdPRJ_NDFV] = @baseProject AND RacineGuid_NDFV IN (SELECT RacineGuid_NDFV FROM [dbo].[NoeudFeatureVersion_NDFV] WHERE [IdPRJ_NDFV] = @saisieProject);
DELETE FROM [dbo].[NoeudFeatureVersion_NDFV] WHERE [IdPRJ_NDFV] = @saisieProject AND [State_NDFV] = 2;
UPDATE [dbo].[NoeudFeatureVersion_NDFV] SET [IdPRJ_NDFV] = @baseProject WHERE [IdPRJ_NDFV] = @saisieProject;
PRINT ''
PRINT ''
PRINT '[COH] Deleting node feature versions for deleted network object versions...'
DELETE NDFV
  FROM NoeudFeatureVersion_NDFV NDFV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_NDFV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_NDFV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting node feature versions for versionless network object versions...'
DELETE NDFV
  FROM NoeudFeatureVersion_NDFV NDFV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_NDFV
 WHERE Id_OBRV IS NULL AND State_NDFV != @DELETED
PRINT ''
PRINT ''
PRINT 'Deleting versionless node feature version roots...'
DELETE FROM [dbo].[NoeudFeature_NDF] WHERE (SELECT COUNT(*) FROM [dbo].[NoeudFeatureVersion_NDFV] WHERE [RacineGuid_NDFV] = [Guid_NDF]) = 0;



PRINT ''
PRINT ''
PRINT 'Reconciliating text features'

DELETE FROM [dbo].[TextFeatureVersion_TXTV] WHERE [IdPRJ_TXTV] = @baseProject AND RacineGuid_TXTV IN (SELECT RacineGuid_TXTV FROM [dbo].[TextFeatureVersion_TXTV] WHERE [IdPRJ_TXTV] = @saisieProject);
DELETE FROM [dbo].[TextFeatureVersion_TXTV] WHERE [IdPRJ_TXTV] = @saisieProject AND [State_TXTV] = 2;
UPDATE [dbo].[TextFeatureVersion_TXTV] SET [IdPRJ_TXTV] = @baseProject WHERE [IdPRJ_TXTV] = @saisieProject;
DELETE FROM [dbo].[TextFeature_TXT] WHERE (SELECT COUNT(*) FROM [dbo].[TextFeatureVersion_TXTV] WHERE [RacineGuid_TXTV] = [Guid_TXT]) = 0;

PRINT ''
PRINT ''
PRINT 'Reconciliating trace features'

DELETE FROM [dbo].[TraceFeatureVersion_TRAV] WHERE [IdPRJ_TRAV] = @baseProject AND RacineGuid_TRAV IN (SELECT RacineGuid_TRAV FROM [dbo].[TraceFeatureVersion_TRAV] WHERE [IdPRJ_TRAV] = @saisieProject);
DELETE FROM [dbo].[TraceFeatureVersion_TRAV] WHERE [IdPRJ_TRAV] = @saisieProject AND [State_TRAV] = 2;
UPDATE [dbo].[TraceFeatureVersion_TRAV] SET [IdPRJ_TRAV] = @baseProject WHERE [IdPRJ_TRAV] = @saisieProject;
PRINT ''
PRINT ''
PRINT '[COH] Deleting trace feature versions for deleted network object versions...'
DELETE TRAV
  FROM TraceFeatureVersion_TRAV TRAV
  JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_TRAV AND IdPRJ_OBRV = @saisieProject AND State_OBRV = @DELETED
 WHERE State_TRAV != @DELETED

PRINT ''
PRINT ''
PRINT '[COH]  Deleting trace feature versions for versionless network object versions...'
DELETE TRAV
  FROM TraceFeatureVersion_TRAV TRAV
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = IdOBR_TRAV
 WHERE Id_OBRV IS NULL AND State_TRAV != @DELETED
PRINT ''
PRINT ''
PRINT 'Deleting versionless trace feature version roots...'
DELETE FROM [dbo].[TraceFeature_TRA] WHERE (SELECT COUNT(*) FROM [dbo].[TraceFeatureVersion_TRAV] WHERE [RacineGuid_TRAV] = [Guid_TRA]) = 0;




PRINT ''
PRINT ''
PRINT 'Reconciliating zone distribution features'

DELETE FROM [dbo].[ZoneDistributionFeatureVersion_ZOFV] WHERE [IdPRJ_ZOFV] = @baseProject AND RacineGuid_ZOFV IN (SELECT RacineGuid_ZOFV FROM [dbo].[ZoneDistributionFeatureVersion_ZOFV] WHERE [IdPRJ_ZOFV] = @saisieProject);
DELETE FROM [dbo].[ZoneDistributionFeatureVersion_ZOFV] WHERE [IdPRJ_ZOFV] = @saisieProject AND [State_ZOFV] = 2;
UPDATE [dbo].[ZoneDistributionFeatureVersion_ZOFV] SET [IdPRJ_ZOFV] = @baseProject WHERE [IdPRJ_ZOFV] = @saisieProject;
DELETE FROM [dbo].[ZoneDistributionFeature_ZOF] WHERE (SELECT COUNT(*) FROM [dbo].[ZoneDistributionFeatureVersion_ZOFV] WHERE [RacineGuid_ZOFV] = [Guid_ZOF]) = 0;


PRINT ''
PRINT ''
PRINT '[COH] Delete compositions for versionless children...'

DELETE CMP
FROM ObjetReseau_OBR
LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = Id_OBR
JOIN Composition_CMP CMP ON IdEnfant_CMP = Id_OBR
WHERE Id_OBRV IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Delete compositions for versionless parents...'

DELETE CMP
FROM ObjetReseau_OBR
LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = Id_OBR
JOIN Composition_CMP CMP ON IdParent_CMP = Id_OBR
WHERE Id_OBRV IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Insert missing composition versions in deleted state for the case where a parent is deleted'

INSERT INTO Composition_CMP (
            IdParent_CMP,
            IdEnfant_CMP,
            Guid_CMP,
            RacineGuid_CMP,
            IdPRJ_CMP,
            State_CMP,
            CreationDate_CMP,
            CreationUtilisateur_CMP,
            ModificationDate_CMP,
            ModificationUtilisateur_CMP,
            Index_CMP)
     SELECT ReseauCMP.IdParent_CMP,
            ReseauCMP.IdEnfant_CMP,
            NEWID(),
            ReseauCMP.RacineGuid_CMP,
            @saisieProject,
            @DELETED,
            SYSDATETIME(),
            'COH',
            SYSDATETIME(),
            'COH',
            ReseauCMP.Index_CMP
       FROM ObjetReseauVersion_OBRV
       JOIN Composition_CMP ReseauCMP ON ReseauCMP.IdParent_CMP = IdOBR_OBRV AND ReseauCMP.IdPRJ_CMP = @baseProject
  LEFT JOIN Composition_CMP ProjectCMP ON ProjectCMP.RacineGuid_CMP = ReseauCMP.RacineGuid_CMP AND ProjectCMP.IdPRJ_CMP = @saisieProject
      WHERE State_OBRV = @DELETED AND
            IdPRJ_OBRV = @saisieProject AND
            ProjectCMP.Id_CMP IS NULL
PRINT ''
PRINT ''
PRINT '[COH] Set composition versions to deleted for the case where a parent is deleted'
     UPDATE ProjectCMP
        SET State_CMP = @DELETED
       FROM ObjetReseauVersion_OBRV
       JOIN Composition_CMP ProjectCMP ON ProjectCMP.IdParent_CMP = IdOBR_OBRV AND ProjectCMP.IdPRJ_CMP = @saisieProject
      WHERE State_OBRV = @DELETED AND
            State_CMP != @DELETED AND
            IdPRJ_OBRV = @saisieProject



PRINT ''
PRINT ''
PRINT '[COH] Insert missing composition versions in deleted state for the case where a child is deleted'
INSERT INTO Composition_CMP (
            IdParent_CMP,
            IdEnfant_CMP,
            Guid_CMP,
            RacineGuid_CMP,
            IdPRJ_CMP,
            State_CMP,
            CreationDate_CMP,
            CreationUtilisateur_CMP,
            ModificationDate_CMP,
            ModificationUtilisateur_CMP,
            Index_CMP)
     SELECT ReseauCMP.IdParent_CMP,
            ReseauCMP.IdEnfant_CMP,
            NEWID(),
            ReseauCMP.RacineGuid_CMP,
            @saisieProject,
            @DELETED,
            SYSDATETIME(),
            'COH',
            SYSDATETIME(),
            'COH',
            ReseauCMP.Index_CMP
       FROM ObjetReseauVersion_OBRV
       JOIN Composition_CMP ReseauCMP ON ReseauCMP.IdEnfant_CMP = IdOBR_OBRV AND ReseauCMP.IdPRJ_CMP = @baseProject
  LEFT JOIN Composition_CMP ProjectCMP ON ProjectCMP.RacineGuid_CMP = ReseauCMP.RacineGuid_CMP AND ProjectCMP.IdPRJ_CMP = @saisieProject
      WHERE State_OBRV = @DELETED AND
            IdPRJ_OBRV = @saisieProject AND
            ProjectCMP.Id_CMP IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Set composition versions to deleted for the case where a child is deleted'
     UPDATE ProjectCMP
        SET State_CMP = @DELETED
       FROM ObjetReseauVersion_OBRV
       JOIN Composition_CMP ProjectCMP ON ProjectCMP.IdEnfant_CMP = IdOBR_OBRV AND ProjectCMP.IdPRJ_CMP = @saisieProject
      WHERE State_OBRV = @DELETED AND
            State_CMP != @DELETED AND
            IdPRJ_OBRV = @saisieProject


PRINT ''
PRINT ''
PRINT 'Delete all base project compositions that have been modified in the project'
DELETE BaseCMP 
  FROM Composition_CMP SaisieCMP
  JOIN Composition_CMP BaseCMP  ON BaseCMP.RacineGuid_CMP = SaisieCMP.RacineGuid_CMP AND BaseCMP.IdPRJ_CMP = @baseProject
 WHERE SaisieCMP.IdPRJ_CMP = @saisieProject

PRINT ''
PRINT ''
PRINT 'Delete all compositions with deleted state'
DELETE FROM Composition_CMP 
      WHERE IdPRJ_CMP = @saisieProject AND State_CMP = @DELETED;

PRINT ''
PRINT ''
PRINT 'Set project for all the modified connections'
UPDATE Composition_CMP 
   SET IdPRJ_CMP = @baseProject,
       State_CMP = @DEFAULT
 WHERE IdPRJ_CMP = @saisieProject;




/* ========================================================= RECONCILIATE CONNECTIONS ========================================================= */

PRINT ''
PRINT ''
PRINT '[COH] Delete connections for versionless nodes or composants'
DELETE CNX
FROM ObjetReseau_OBR
LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = Id_OBR
JOIN Connexion_CNX CNX ON IdOBR_CNX = Id_OBR
WHERE Id_OBRV IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Delete connections for versionless branches'
DELETE CNX
FROM ObjetReseau_OBR
LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = Id_OBR
JOIN Connexion_CNX CNX ON IdBRA_CNX = Id_OBR
WHERE Id_OBRV IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Insert missing connection versions in deleted state for the case where a branche is deleted'
INSERT INTO Connexion_CNX (
            IdOBR_CNX,
            IdBRA_CNX,
            Ordre_CNX,
            Guid_CNX,
            RacineGuid_CNX,
            IdPRJ_CNX,
            State_CNX,
            CreationDate,
            CreationUtilisateur,
            ModificationDate,
            ModificationUtilisateur,
            Direction_CNX,
            TypeConnexion_CNX)
     SELECT ReseauCNX.IdOBR_CNX,
            ReseauCNX.IdBRA_CNX,
            ReseauCNX.Ordre_CNX,
            NEWID(),
            ReseauCNX.RacineGuid_CNX,
            @saisieProject,
            @DELETED,
            SYSDATETIME(),
            'COH',
            SYSDATETIME(),
            'COH',
            ReseauCNX.Direction_CNX,
            ReseauCNX.TypeConnexion_CNX 
       FROM ObjetReseauVersion_OBRV
       JOIN Connexion_CNX ReseauCNX ON ReseauCNX.IdBRA_CNX = IdOBR_OBRV AND ReseauCNX.IdPRJ_CNX = @baseProject
  LEFT JOIN Connexion_CNX ProjectCNX ON ProjectCNX.RacineGuid_CNX = ReseauCNX.RacineGuid_CNX AND ProjectCNX.IdPRJ_CNX = @saisieProject
      WHERE State_OBRV = @DELETED AND
            IdPRJ_OBRV = @saisieProject AND
            ReseauCNX.Id_CNX IS NOT NULL AND
            ProjectCNX.Id_CNX IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Set connection versions to deleted for the case when a branche is deleted'
     UPDATE ProjectCNX
        SET State_CNX = @DELETED
       FROM ObjetReseauVersion_OBRV
       JOIN Connexion_CNX ProjectCNX ON ProjectCNX.IdBRA_CNX = IdOBR_OBRV AND ProjectCNX.IdPRJ_CNX = @saisieProject
  LEFT JOIN Connexion_CNX ReseauCNX ON ReseauCNX.RacineGuid_CNX = ProjectCNX.RacineGuid_CNX AND ReseauCNX.IdPRJ_CNX = @baseProject
      WHERE State_OBRV = @DELETED AND
            IdPRJ_OBRV = @saisieProject AND
            ReseauCNX.Id_CNX IS NULL AND
            ProjectCNX.State_CNX != @DELETED



PRINT ''
PRINT ''
PRINT '[COH] Insert missing connection versions in deleted state for the case where a node or composant is deleted'
INSERT INTO Connexion_CNX (
            IdOBR_CNX,
            IdBRA_CNX,
            Ordre_CNX,
            Guid_CNX,
            RacineGuid_CNX,
            IdPRJ_CNX,
            State_CNX,
            CreationDate,
            CreationUtilisateur,
            ModificationDate,
            ModificationUtilisateur,
            Direction_CNX,
            TypeConnexion_CNX)
     SELECT ReseauCNX.IdOBR_CNX,
            ReseauCNX.IdBRA_CNX,
            ReseauCNX.Ordre_CNX,
            NEWID(),
            ReseauCNX.RacineGuid_CNX,
            @saisieProject,
            @DELETED,
            SYSDATETIME(),
            'COH',
            SYSDATETIME(),
            'COH',
            ReseauCNX.Direction_CNX,
            ReseauCNX.TypeConnexion_CNX 
       FROM ObjetReseauVersion_OBRV
       JOIN Connexion_CNX ReseauCNX ON ReseauCNX.IdOBR_CNX = IdOBR_OBRV AND ReseauCNX.IdPRJ_CNX = @baseProject
  LEFT JOIN Connexion_CNX ProjectCNX ON ProjectCNX.RacineGuid_CNX = ReseauCNX.RacineGuid_CNX AND ProjectCNX.IdPRJ_CNX = @saisieProject
      WHERE State_OBRV = @DELETED AND
            IdPRJ_OBRV = @saisieProject AND
            ReseauCNX.Id_CNX IS NOT NULL AND
            ProjectCNX.Id_CNX IS NULL

PRINT ''
PRINT ''
PRINT '[COH] Set connection versions to deleted for the case where a object is deleted'
     UPDATE ProjectCNX
        SET State_CNX = @DELETED
       FROM ObjetReseauVersion_OBRV
       JOIN Connexion_CNX ProjectCNX ON ProjectCNX.IdOBR_CNX = IdOBR_OBRV AND ProjectCNX.IdPRJ_CNX = @saisieProject
  LEFT JOIN Connexion_CNX ReseauCNX ON ReseauCNX.RacineGuid_CNX = ProjectCNX.RacineGuid_CNX AND ReseauCNX.IdPRJ_CNX = @baseProject
      WHERE State_OBRV = @DELETED AND
            IdPRJ_OBRV = @saisieProject AND
            ReseauCNX.Id_CNX IS NULL AND
            ProjectCNX.State_CNX != @DELETED


PRINT ''
PRINT ''
PRINT 'Delete all base project connections that have been modified in the saisie project'
DELETE BaseCNX 
  FROM Connexion_CNX SaisieCNX
  JOIN Connexion_CNX BaseCNX  ON BaseCNX.RacineGuid_CNX = SaisieCNX.RacineGuid_CNX AND BaseCNX.IdPRJ_CNX = @baseProject
 WHERE SaisieCNX.IdPRJ_CNX = @saisieProject

PRINT ''
PRINT ''
PRINT 'Delete all connections with deleted state'
DELETE FROM Connexion_CNX
      WHERE IdPRJ_CNX = @saisieProject AND 
            State_CNX = @DELETED;

PRINT ''
PRINT ''
PRINT 'Set project for all the modified connections'
UPDATE Connexion_CNX 
   SET IdPRJ_CNX = @baseProject, 
       State_CNX = @DEFAULT
 WHERE IdPRJ_CNX = @saisieProject;


/* ========================================================= RECONCILIATE ANNEXES ========================================================= */

PRINT ''
PRINT ''
PRINT 'Delete all base project annexes that have been modified in the saisie project'
DELETE BaseANX 
  FROM Annexe_ANX SaisieANX
  JOIN Annexe_ANX BaseANX  ON BaseANX.IdRacine_ANX = SaisieANX.IdRacine_ANX AND BaseANX.IdPRJ_ANX = @baseProject
 WHERE SaisieANX.IdPRJ_ANX = @saisieProject

PRINT ''
PRINT ''
PRINT 'Delete all annexes with deleted state'
DELETE FROM Annexe_ANX
      WHERE IdPRJ_ANX = @saisieProject AND 
            State_ANX = @DELETED;

PRINT ''
PRINT ''
PRINT 'Set project for all the created / modified annexes'
UPDATE Annexe_ANX 
   SET IdPRJ_ANX = @baseProject, 
       State_ANX = @DEFAULT
 WHERE IdPRJ_ANX = @saisieProject;


/* ========================================================= RECONCILIATE LINKS ========================================================= */

PRINT ''
PRINT ''
PRINT 'Delete all base project links that have been modified in the saisie project'
DELETE BaseLEK 
  FROM LienExterne_LEK SaisieLEK
  JOIN LienExterne_LEK BaseLEK  ON BaseLEK.IdRacine_LEK = SaisieLEK.IdRacine_LEK AND BaseLEK.IdPRJ_LEK = @baseProject
 WHERE SaisieLEK.IdPRJ_LEK = @saisieProject

PRINT ''
PRINT ''
PRINT 'Delete all links with deleted state'
DELETE FROM LienExterne_LEK
      WHERE IdPRJ_LEK = @saisieProject AND 
            State_LEK = @DELETED;

PRINT ''
PRINT ''
PRINT 'Set project for all the created / modified links'
UPDATE LienExterne_LEK 
   SET IdPRJ_LEK = @baseProject, 
       State_LEK = @DEFAULT
 WHERE IdPRJ_LEK = @saisieProject;


 /* ========================================================= RECONCILIATE MESURES  ========================================================= */

PRINT ''
PRINT ''
PRINT 'Delete all base project measures that have been modified in the saisie project'
DELETE BaseMOR 
  FROM MesureObjetReseau_MOR SaisieMOR
  JOIN MesureObjetReseau_MOR BaseMOR  ON BaseMOR.IdRacine_MOR = SaisieMOR.IdRacine_MOR AND BaseMOR.IdPRJ_MOR = @baseProject
 WHERE SaisieMOR.IdPRJ_MOR = @saisieProject

PRINT ''
PRINT ''
PRINT 'Delete all measures with deleted state'
DELETE FROM MesureObjetReseau_MOR
      WHERE IdPRJ_MOR = @saisieProject AND 
            State_MOR = @DELETED;

PRINT ''
PRINT ''
PRINT 'Set project for all the created / modified measures'
UPDATE MesureObjetReseau_MOR 
   SET IdPRJ_MOR = @baseProject, 
       State_MOR = @DEFAULT
 WHERE IdPRJ_MOR = @saisieProject;


/* ========================================================= RECONCILIATE NETWORK OBJECTS ========================================================= */

PRINT ''
PRINT ''
PRINT 'Deleting network object base versions that have been modified...'
DELETE BaseOBRV 
  FROM ObjetReseauVersion_OBRV SaisieOBRV
  JOIN ObjetReseauVersion_OBRV BaseOBRV  ON BaseOBRV.IdOBR_OBRV = SaisieOBRV.IdOBR_OBRV AND BaseOBRV.IdPRJ_OBRV = @baseProject
 WHERE SaisieOBRV.IdPRJ_OBRV = @saisieProject

PRINT ''
PRINT ''
PRINT 'Deleting network object versions...'
DELETE FROM ObjetReseauVersion_OBRV
      WHERE IdPRJ_OBRV = @saisieProject AND 
            State_OBRV = @DELETED;

PRINT ''
PRINT ''
PRINT 'Updating project for modified network object versions...'
UPDATE ObjetReseauVersion_OBRV 
   SET IdPRJ_OBRV = @baseProject 
 WHERE IdPRJ_OBRV = @saisieProject;


PRINT ''
PRINT ''
PRINT 'Updating class on the network object version root...'
UPDATE OBR
   SET OBR.IdORC_OBR = VersionTable.IdORC_OBRV
  FROM ObjetReseau_OBR AS OBR
  JOIN ObjetReseauVersion_OBRV AS VersionTable ON OBR.Id_OBR = VersionTable.IdOBR_OBRV AND VersionTable.IdPRJ_OBRV =  @baseProject
 WHERE OBR.IdORC_OBR != VersionTable.IdORC_OBRV;


PRINT ''
PRINT ''
PRINT 'Deleting versionless network object roots...'
DELETE OBR
  FROM ObjetReseau_OBR OBR
  LEFT JOIN ObjetReseauVersion_OBRV ON IdOBR_OBRV = Id_OBR
 WHERE Id_OBRV IS NULL


PRINT ''
PRINT ''
PRINT 'Creating archived project...'
/*=========================================================ARCHIVE PROJECT=========================================================*/
INSERT INTO ProjetArchive_PJA
            (Guid_PJA, 
             GuidParent_PJA,
             Nom_PJA,
             NomParent_PJA,
             Description_PJA,
             DateCreation_PJA,
             UtilisateurCreation_PJA,
             TypeAction_PJA)
SELECT saisiePrj.Guid_PRJ, 
       basePrj.Guid_PRJ, 
       saisiePrj.Nom_PRJ, 
       basePrj.Nom_PRJ, 
       saisiePrj.Description_PRJ, 
       CURRENT_TIMESTAMP, 
       saisiePrj.CreationUtilisateur_PRJ, 
       0
  FROM Projet_PRJ saisiePrj 
  JOIN Projet_PRJ basePrj ON saisiePrj.IdPRJ_PRJ = basePrj.Id_PRJ 
  WHERE saisiePrj.Id_PRJ = @saisieProject; 
/*=========================================================DELETE PROJECT=========================================================*/

PRINT ''
PRINT ''
PRINT 'Deleting project...'
DELETE FROM [dbo].[Projet_PRJ] WHERE Id_PRJ = @saisieProject;


/*=========================================================ZONE FEATURE CLEANUP========================================================*/
PRINT ''
PRINT ''
PRINT 'Cleanup zone features'

DELETE ZFT
FROM ZoneFeature_ZFT ZFT
LEFT JOIN Projet_PRJ ON Guid_PRJ = Guid_ZFT
WHERE Id_PRJ IS NULL



PRINT 'Project '+ @projectName + ' reconciled'
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION; -- Rollback on error

    PRINT ''
    PRINT ''
    PRINT ERROR_MESSAGE()
    PRINT 'Project ' + @projectName + ' failed to be reconciled' 
END CATCH

FETCH NEXT FROM project_cursor INTO @saisieProject, @baseProject, @saisieProjectGuid, @projectName;
END;

CLOSE project_cursor;
DEALLOCATE project_cursor;
END;

GO

