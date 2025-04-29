DROP PROCEDURE IF EXISTS SP_ReIndexConduits


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Popescu Adrian
-- Create date: 01.02.2023
-- Description:	Procedure for recalculating conduit indexes in a trace
-- =============================================
CREATE PROCEDURE SP_ReIndexConduits
    @TraceVersionRootId integer
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BaseProjectId integer = (SELECT MAX(Id_PRJ) FROM ObjetReseauVersion_OBRV JOIN Projet_PRJ ON Id_PRJ = IdPRJ_OBRV WHERE IdOBR_OBRV = @TraceVersionRootId AND IdPRJ_PRJ IS NULL)
    DECLARE @ProjectId integer = IIF (@BaseProjectId IS NULL, (SELECT MAX(IdPRJ_OBRV) FROM ObjetReseauVersion_OBRV WHERE IdOBR_OBRV = @TraceVersionRootId), @BaseProjectId)

   

    
 
    UPDATE CompositionsToIndex
       SET Index_CMP = IndexUpdate.UpdatedIndex
     FROM Composition_CMP CompositionsToIndex
     JOIN
     (
     SELECT Id_CMP AS ComposantVersionRootId,
            ((ROW_NUMBER() OVER (ORDER BY (CMP.Y_CMP - (SELECT  MAX(IIF(Diametre_BRAV IS NULL, 0.1, Diametre_BRAV / 1000)) FROM ObjetReseauVersion_OBRV JOIN BrancheVersion_BRAV ON BrancheVersion_BRAV.Id_OBRV = ObjetReseauVersion_OBRV.Id_OBRV 	WHERE IdOBR_OBRV = Id_OBR)) DESC, CMP.X_CMP)) - 1)  AS UpdatedIndex
       FROM Composition_CMP AS CMP
       JOIN ObjetReseau_OBR ON Id_OBR = IdEnfant_CMP
       JOIN NObjetReseauClasse_ORC ON Id_ORC = IdORC_OBR
      WHERE IdParent_CMP = @TraceVersionRootId AND
	        Code_ORC = 'CON' AND
            CMP.X_CMP IS NOT NULL AND 
            CMP.Y_CMP IS NOT NULL AND
            CMP.IdPRJ_CMP = @ProjectId    
     ) as IndexUpdate ON IndexUpdate.ComposantVersionRootId = CompositionsToIndex.Id_CMP

     UPDATE CompositionsInProject
        SET CompositionsInProject.Index_CMP = CompositionsInBaseProject.Index_CMP
       FROM Composition_CMP CompositionsInProject
       JOIN Composition_CMP CompositionsInBaseProject ON CompositionsInBaseProject.RacineGuid_CMP = CompositionsInProject.RacineGuid_CMP AND CompositionsInBaseProject.IdPRJ_CMP = @BaseProjectId
      WHERE CompositionsInProject.IdPRJ_CMP != @BaseProjectId AND CompositionsInProject.IdParent_CMP = @TraceVersionRootId
END
GO