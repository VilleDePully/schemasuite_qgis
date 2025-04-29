IF EXISTS(SELECT t.object_id FROM sys.tables t where t.[name] = 'zsysTopoParallele_ZAP')
DROP TABLE [dbo].[zsysTopoParallele_ZAP]
GO

CREATE TABLE [dbo].[zsysTopoParallele_ZAP] (
[id_ZAP] int IDENTITY(1, 1) NOT NULL,
[idOBR_ZAP] int NOT NULL,
[idOBRParallele_ZAP] int NULL,
CONSTRAINT [PK_ZAP]
PRIMARY KEY CLUSTERED ([id_ZAP] )
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

ALTER TABLE [dbo].[zsysTopoParallele_ZAP] SET (LOCK_ESCALATION = TABLE);
GO


IF EXISTS(SELECT t.object_id FROM sys.tables t where t.[name] = 'zsysTopoObject_ZTO')
DROP TABLE [dbo].[zsysTopoObject_ZTO]
GO

CREATE TABLE [dbo].[zsysTopoObject_ZTO] (
[id_ZTO] int IDENTITY(1, 1) NOT NULL,
[classeOBJ_ZTO] nvarchar(3) NOT NULL,
[idOBR_ZTO] int NOT NULL,
[idNODAlimMT_ZTO] int NULL,
[idNODAlimBT_ZTO] int NULL,
[idCOPAlimMT_ZTO] int NULL,
[idCOPAlimBT_ZTO] int NULL,
[idTRFAlimBT_ZTO] int NULL,
[idADBTAlim_ZTO] int NULL,
[idCOPMes_ZTO] int NULL,
[niveau_ZTO] int NOT NULL,
[classeParent_ZTO] nvarchar(3) NULL,
[idOBJParent_ZTO] int NULL,
[boucle_ZTO] int NULL,
[kmCableMTamont_ZTO] float NULL DEFAULT(0),
[kmCableBTamont_ZTO] float NULL DEFAULT(0),
[kmLigneMTamont_ZTO] float NULL DEFAULT(0),
[kmLigneBTamont_ZTO] float NULL DEFAULT(0),
[nbStationInter_ZTO] int NOT NULL DEFAULT(0),
[nbArmoireInter_ZTO] int NOT NULL DEFAULT(0),
-- Au retour
[bouclageIndiceBT_ZTO] int NOT NULL DEFAULT(5),
[bouclageIndiceMT_ZTO] int NOT NULL DEFAULT(5),
[kmCableMTaval_ZTO] float NULL DEFAULT(0),
[kmCableBTaval_ZTO] float NULL DEFAULT(0),
[kmLigneMTaval_ZTO] float NULL DEFAULT(0),
[kmLigneBTaval_ZTO] float NULL DEFAULT(0),
[nbClient_ZTO] int NOT NULL DEFAULT(0),
[nbClientDirect_ZTO] int NOT NULL DEFAULT(0),
[nbCoffret_ZTO] int NOT NULL DEFAULT(0),
[nbCoffretDirect_ZTO] int NOT NULL DEFAULT(0),
[nbArmoire_ZTO] int NOT NULL DEFAULT(0),
[nbStation_ZTO] int NOT NULL DEFAULT(0),
[SInst_ZTO] float NOT NULL DEFAULT(0),
[SMesure_ZTO] float NOT NULL DEFAULT(0),
[nbClientSensible_ZTO] int NOT NULL DEFAULT(0),
[nbClientSensible2_ZTO] int NOT NULL DEFAULT(0),
[nbClientSensible3_ZTO] int NOT NULL DEFAULT(0),
[consommationDerAnnnee_ZTO] float NOT NULL DEFAULT(0),
CONSTRAINT [PK_ZTO]
PRIMARY KEY CLUSTERED ([id_ZTO] )
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

ALTER TABLE [dbo].[zsysTopoObject_ZTO] SET (LOCK_ESCALATION = TABLE);
GO


CREATE NONCLUSTERED INDEX [idx_Nonclustered_zsysTopoObject_ZTO_classeOBJ_ZTO_idOBR_ZTO]
ON [dbo].[zsysTopoObject_ZTO]
([classeOBJ_ZTO] , [idOBR_ZTO])
WITH
(
PAD_INDEX = OFF,
FILLFACTOR = 100,
IGNORE_DUP_KEY = OFF,
STATISTICS_NORECOMPUTE = OFF,
ONLINE = OFF,
ALLOW_ROW_LOCKS = ON,
ALLOW_PAGE_LOCKS = ON,
DATA_COMPRESSION = NONE
)
ON [PRIMARY];
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Elec_Branche')
DROP VIEW dbo.V_Topo_Elec_Branche
GO

CREATE VIEW dbo.V_Topo_Elec_Branche
AS
SELECT
  obrv.Id_OBRV, obrv.IdOBR_OBRV as id_BRA, obrv.IdORC_OBRV, bra.IdNIV_BRAV, 
  niv.No_NIV, 
  niv.Code_NIV, 
  orc.Code_ORC, obrv.Nom_OBRV, obrv.Code_OBRV, obrv.ConstructionDate_OBRV, obrv.MiseEnServiceDate_OBRV, obrv.Fictif_OBRV, 
  ISNULL(bra.Longueur_BRAV, bra.LongueurCalcul_BRAV) as Longueur_BRA
FROM 
  dbo.ObjetReseauVersion_OBRV obrv INNER JOIN 
    dbo.BrancheVersion_BRAV bra ON bra.Id_OBRV = obrv.Id_OBRV inner join 
      NObjetReseauClasse_ORC orc on obrv.IdORC_OBRV = orc.Id_ORC left outer join
        dbo.NNiveauTension_NIV niv ON NIV.Id_NIV = bra.IdNIV_BRAV  

WHERE
  obrv.IdPRJ_OBRV in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Elec_Composant')
DROP VIEW dbo.V_Topo_Elec_Composant
GO

CREATE VIEW dbo.V_Topo_Elec_Composant
AS
SELECT
  obrv.Id_OBRV, obrv.IdOBR_OBRV as id_COP, obrv.IdORC_OBRV, 
  case when orc.Code_ORC in ('BARRE', 'PCX', 'BORNE') then 1 else cop.EtatFlux_COPV end as EtatFlux_COPV, 
  cop.DegreManoeuvre_COPV,
  niv.Code_NIV, niv.no_NIV, niv.Id_NIV, 
  cmp.IdParent_CMP as id_NOD, 
  orc.Code_ORC, obrv.Nom_OBRV, obrv.Code_OBRV, obrv.ConstructionDate_OBRV, obrv.MiseEnServiceDate_OBRV, obrv.Modele_OBRV
FROM 
  dbo.ObjetReseauVersion_OBRV obrv INNER JOIN 
    dbo.ComposantVersion_COPV cop ON cop.Id_OBRV = obrv.Id_OBRV inner join 
      dbo.NNiveauTension_NIV niv ON NIV.Id_NIV = cop.IdNIV_COPV inner join 
        Composition_CMP cmp on cmp.IdEnfant_CMP = obrv.IdOBR_OBRV and cmp.IdPRJ_CMP = obrv.IdPRJ_OBRV  inner join 
          NObjetReseauClasse_ORC orc on obrv.IdORC_OBRV = orc.Id_ORC
WHERE
  obrv.IdPRJ_OBRV in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Elec_Noeud')
DROP VIEW dbo.V_Topo_Elec_Noeud
GO

CREATE VIEW dbo.V_Topo_Elec_Noeud
AS
SELECT
  obrv.Id_OBRV, obrv.IdOBR_OBRV as id_NOD, obrv.IdORC_OBRV, obrv.Nom_OBRV, obrv.Code_OBRV, obrv.ConstructionDate_OBRV, obrv.MiseEnServiceDate_OBRV, orc.Code_ORC 
FROM 
  dbo.ObjetReseauVersion_OBRV obrv INNER JOIN 
    dbo.NoeudVersion_NODV nod on nod.Id_OBRV = obrv.Id_OBRV inner join 
      NObjetReseauClasse_ORC orc on obrv.IdORC_OBRV = orc.Id_ORC
WHERE
  obrv.IdPRJ_OBRV in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Elec_DepartPoste')
DROP VIEW dbo.V_Topo_Elec_DepartPoste
GO

CREATE VIEW dbo.V_Topo_Elec_DepartPoste
AS
SELECT
  cop.id_COP, nod.id_NOD, nod.Nom_OBRV as NomPoste, nod.Code_OBRV as CodePoste, cop.Code_OBRV as CodeDepart, cop.Nom_OBRV as NomDepart, cop.EtatFlux_COPV, bra.id_BRA
FROM 
  dbo.V_Topo_Elec_Composant cop INNER JOIN 
    dbo.Connexion_CNX cnx on cop.id_COP = cnx.IdOBR_CNX inner join 
      dbo.V_Topo_Elec_Branche bra on cnx.IdBRA_CNX = bra.id_BRA inner join
        dbo.V_Topo_Elec_Noeud nod on cop.id_NOD = nod.id_NOD
WHERE
  cnx.IdPRJ_CNX in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
  And bra.Code_ORC in ('LIEL', 'CAEL') 
  And nod.code_ORC = 'STHT' 
  And cop.Code_NIV = 'MT'
  
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Elec_DepartStation')
DROP VIEW dbo.V_Topo_Elec_DepartStation
GO

CREATE VIEW dbo.V_Topo_Elec_DepartStation
AS
SELECT
  cop.id_COP, nod.id_NOD, nod.Nom_OBRV as NomPoste, nod.Code_OBRV as CodePoste, cop.Code_OBRV as CodeDepart, cop.Nom_OBRV as NomDepart, cop.EtatFlux_COPV, bra.id_BRA
FROM 
  dbo.V_Topo_Elec_Composant cop INNER JOIN 
    dbo.Connexion_CNX cnx on cop.id_COP = cnx.IdOBR_CNX inner join 
      dbo.V_Topo_Elec_Branche bra on cnx.IdBRA_CNX = bra.id_BRA inner join
        dbo.V_Topo_Elec_Noeud nod on cop.id_NOD = nod.id_NOD
WHERE
  cnx.IdPRJ_CNX in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
  And bra.Code_ORC in ('LIEL', 'CAEL') 
  And nod.code_ORC = 'STMT' 
  And cop.Code_NIV = 'BT'
  
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Elec_TransfoMtBt')
DROP VIEW dbo.V_Topo_Elec_TransfoMtBt
GO

CREATE VIEW dbo.V_Topo_Elec_TransfoMtBt
AS
SELECT
  cop.id_COP, nod.id_NOD, nod.Nom_OBRV as NomStation, nod.Code_OBRV as CodeStation, cop.Code_OBRV as CodeTrf, cop.Nom_OBRV as NomTrf, cop.EtatFlux_COPV
FROM 
  dbo.V_Topo_Elec_Composant cop inner join V_Topo_Elec_Noeud nod on cop.id_NOD = nod.id_NOD
WHERE
  cop.Code_ORC = 'TRF' And
  cop.Code_NIV = 'MT/BT' And
  cop.id_COP in (SELECT idOBR_ZTO FROM zsysTopoObject_ZTO)
GO



IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_Mesure')
DROP VIEW dbo.V_Topo_Mesure
GO

CREATE VIEW dbo.V_Topo_Mesure
AS
SELECT 
  obr.Id_OBR as id_COP,
  mes.IgnorePourCalcul_MES, mes.Valeur_MES, mes.Remarque_MES, mes.IdNMT_MES, mes.DateMesure_MES
FROM Mesure_MES mes inner join ObjetReseau_OBR obr on obr.Guid_OBR = mes.EntityKey_MES
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_Topo_ClientDerive')
DROP VIEW dbo.V_Topo_ClientDerive
GO

CREATE VIEW dbo.V_Topo_ClientDerive
AS
SELECT 
  id_OBR,
  0 as nbClientDerive,
  0 as nbClientSensible,
  0 as nbClientSensible2,
  0 as nbClientSensible3,
  0 as ConsommationDerAnnee
FROM
  ObjetReseau_OBR obr inner join 
    NObjetReseauClasse_ORC orc on obr.IdORC_OBR = orc.Id_ORC
WHERE orc.Code_ORC = 'COBT'
GO

  

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_ELEC_Station_Avec_Point_Alim_MT')
DROP VIEW dbo.V_ELEC_Station_Avec_Point_Alim_MT
GO

CREATE VIEW dbo.V_ELEC_Station_Avec_Point_Alim_MT
AS
SELECT n.Nom_OBRV as NomStation, n.Code_OBRV as CodeStation, dep.NomPoste, dep.CodeDepart, topo.Niveau
FROM
  (SELECT MAX(v.niveau_ZTO) as Niveau,
    v.idCOPAlimMT_ZTO as idDepMT, cop.id_NOD as id_NOD 
  FROM 
    zsysTopoObject_ZTO v inner join V_Topo_Elec_Composant cop on cop.id_COP = v.idOBR_ZTO
  GROUP BY v.idCOPAlimMT_ZTO, cop.id_NOD
  ) topo inner join 
    V_Topo_Elec_Noeud n on n.id_NOD = topo.id_NOD inner join V_Topo_Elec_DepartPoste dep on dep.id_COP = topo.idDepMT 
Where 
  n.Code_ORC = 'STMT'
GO

IF EXISTS(SELECT v.object_id from sys.views v where v.[name] = 'V_ELEC_Noeud_Avec_Point_Alim_MT_Et_BT')
DROP VIEW dbo.V_ELEC_Noeud_Avec_Point_Alim_MT_Et_BT
GO

CREATE VIEW dbo.V_ELEC_Noeud_Avec_Point_Alim_MT_Et_BT
AS
SELECT n.Code_ORC, n.Nom_OBRV as NomNoeud, n.Code_OBRV as CodeNoeud, dep.NomPoste, dep.CodeDepart, trfAlim.NomStation, trfAlim.CodeStation, trfAlim.CodeTrf, trfAlim.NomTrf, topo.Niveau
FROM
  (SELECT z.niveau_ZTO as Niveau, z.idOBR_ZTO as id_NOD, z.idCOPAlimMT_ZTO as idDepMT, z.idTRFAlimBT_ZTO as idTrf FROM zsysTopoObject_ZTO z WHERE z.classeOBJ_ZTO = 'NOD') topo inner join 
    V_Topo_Elec_Noeud n on n.id_NOD = topo.id_NOD inner join 
      V_Topo_Elec_DepartPoste dep on dep.id_COP = topo.idDepMT left outer join 
        V_Topo_Elec_TransfoMtBt trfAlim on trfAlim.id_COP = topo.idTrf
Where 
  n.Code_ORC != 'STHT'
GO

IF EXISTS(SELECT o.[object_id] FROM sys.all_objects o where o.name = 'FCT_TopologyNextCable')
DROP FUNCTION dbo.FCT_TopologyNextCable
GO

CREATE FUNCTION dbo.FCT_TopologyNextCable 
(
  @idCOP int,
  @classeFrom nvarchar(3),
  @idObjFrom int
)
RETURNS @trace_result 
  TABLE (classeObj nvarchar (3), id int, statut int)
AS
BEGIN
  DECLARE @idNiv int, @id int, @classeObj nvarchar (3)

  SELECT @idNiv = Id_NIV FROM V_Topo_Elec_Composant WHERE id_COP = @idCOP
  
  INSERT INTO @trace_result (classeObj, id, statut) VALUES (@classeFrom, @idObjFrom, 1)
  INSERT INTO @trace_result (classeObj, id, statut) VALUES ('COP', @idCOP, 0)
  
  WHILE EXISTS (SELECT id FROM @trace_result WHERE statut = 0)
  BEGIN
    
    DECLARE cursTopo CURSOR LOCAL READ_ONLY FOR
      SELECT classeObj, id
      FROM @trace_result WHERE statut = 0

    OPEN cursTopo
    FETCH NEXT FROM cursTopo INTO @classeObj, @id

    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF @classeObj = 'COP'  
        INSERT INTO @trace_result (classeObj, id, statut)
        SELECT 
          'BRA', cnx.idBRA_CNX, case when bra.Code_ORC != 'BRVI' then 1 else 0 end 
        FROM 
          connexion_CNX cnx inner join 
            dbo.V_Topo_Elec_Branche bra ON bra.id_BRA  = cnx.IdBRA_CNX  
        WHERE     
          cnx.IdOBR_CNX = @id
          AND cnx.IdPRJ_CNX in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
          AND cnx.idBRA_CNX NOT IN (SELECT id FROM @trace_result)
      ELSE
        INSERT INTO @trace_result (classeObj, id, statut)
        SELECT 
          'COP', cnx.idOBR_CNX, 0
        FROM 
          connexion_CNX cnx inner join 
            dbo.V_Topo_Elec_Composant cop ON cop.id_COP  = cnx.IdOBR_CNX  
        WHERE     
          cnx.IdBRA_CNX = @id
          AND cop.Id_NIV = @idNiv
          AND cnx.IdPRJ_CNX in (SELECT Id_PRJ FROM Projet_PRJ Where IdPRJ_PRJ is null and Actif_PRJ != 0)
          AND cnx.idOBR_CNX NOT IN (SELECT id FROM @trace_result)
      
      UPDATE @trace_result 
        SET statut = 1 
      WHERE 
        id = @id

      FETCH NEXT FROM cursTopo INTO @classeObj, @id
    END
    CLOSE cursTopo
    DEALLOCATE cursTopo
  END
  DELETE FROM @trace_result WHERE classeObj = @classeFrom And id = @idObjFrom
  RETURN
END
GO

IF EXISTS(SELECT o.[object_id] FROM sys.all_objects o where o.name = 'FCT_TopologyMT')
DROP FUNCTION dbo.FCT_TopologyMT
GO

CREATE FUNCTION dbo.FCT_TopologyMT 
(
  @idCOP int, 
  @idToBra int,
  @iStopIfExists int = 1
)
RETURNS @trace_result 
  TABLE (classeObj nvarchar (3), id int, statut int, nbStation int, totCable float, totLigne float, statutOuverture int, statutBoucle int, niveau int, classeParent nvarchar (3), idParent int )
AS
BEGIN
  DECLARE @iNiveau int, @id int, @classeObj nvarchar (3), @dTotCable float, @dTotLigne float, @nbStation int

  SET @iNiveau = 1
  
  INSERT INTO @trace_result (classeObj, id, statut, nbStation, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent) 
    VALUES ('COP', @idCOP, 1, 0, 0, 0, 0, 0, @iNiveau, Null, Null)
  SET @iNiveau = 2
  
  INSERT INTO @trace_result (classeObj, id, statut, nbStation, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent)
    SELECT 'BRA', id_BRA, 
      case when @iStopIfExists = 1 then
        case when EXISTS(SELECT zto.idOBR_ZTO FROM zsysTopoObject_ZTO zto where zto.idOBR_ZTO = id_BRA) then 1 else 0 end
      else 0 
      end, 
      0,
      case when bra.Code_ORC = 'CAEL' then ISNULL(bra.Longueur_BRA,0) else 0 end, 
      case when bra.Code_ORC = 'LIEL' then ISNULL(bra.Longueur_BRA,0) else 0 end, 
      0, 
      0, 
      @iNiveau, 
      'COP', 
      @idCop
    FROM 
      V_Topo_Elec_Branche bra Where bra.id_BRA = @idToBra

  WHILE EXISTS (SELECT id FROM @trace_result WHERE statut = 0)
  BEGIN
    
    DECLARE cursTopo CURSOR LOCAL READ_ONLY FOR
      SELECT classeObj, id, nbStation, totCable, totLigne, Niveau
      FROM @trace_result WHERE statut = 0

    OPEN cursTopo
    FETCH NEXT FROM cursTopo INTO @classeObj, @id, @nbStation, @dTotCable, @dTotLigne, @iNiveau

    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF @classeObj = 'BRA'
        INSERT INTO @trace_result (classeObj, id, statut, nbStation, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent)
        SELECT 
          'COP', cnx.idOBR_CNX, 
          case when cop.id_NIV = (SELECT id_NIV FROM NNiveauTension_NIV where Code_NIV  = 'MT/BT') then 1
            else
              case when @iStopIfExists = 1 then
                case when EXISTS(SELECT zto.idOBR_ZTO FROM zsysTopoObject_ZTO zto where zto.idOBR_ZTO = cop.id_COP) 
                  then 1 else 0 end
               
              else 0 
              end
          end,
          @nbStation,
          @dTotCable, @dTotLigne, 
          case when cop.etatFlux_COPV = 1 then 0 else ISNULL(cop.degreManoeuvre_COPV,2) end, 
          case when (EXISTS(SELECT n.id_NOD FROM V_Topo_Elec_Noeud n where n.id_NOD = cop.id_NOD And n.code_ORC in ('STHT', 'GEMT')) or 
                      EXISTS(SELECT id FROM @trace_result WHERE id=cop.id_COP)) then 1 else 0 end,
          @iNiveau+1, 
          @classeObj, 
          @id
        FROM 
          connexion_CNX cnx inner join 
            dbo.V_Topo_Elec_Composant cop ON cop.id_COP  = cnx.IdOBR_CNX 
        WHERE 
          cnx.IdBRA_CNX = @id
          And cnx.idOBR_CNX NOT IN (SELECT id FROM @trace_result WHERE statutOuverture = 0)
          AND cop.id_NIV IN (SELECT id_NIV FROM NNiveauTension_NIV where Code_NIV in ('MT', 'MT/BT'))
      ELSE  
        INSERT INTO @trace_result (classeObj, id, statut, nbStation, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent)
        SELECT 
          'BRA', cnx.idBRA_CNX, 0,
          @nbStation + case when (SELECT n.code_ORC FROM V_Topo_Elec_Noeud n inner join V_Topo_Elec_Composant c on c.id_NOD = n.id_NOD WHERE c.id_COP = @id) = 'STMT' then 1 else 0 end,
          @dTotCable + case when bra.Code_ORC  = 'CAEL' then Isnull(bra.longueur_BRA,0) else 0 end, 
          @dTotLigne + case when bra.Code_ORC  = 'LIEL' then Isnull(bra.longueur_BRA,0) else 0 end, 
          0,
          case when EXISTS(SELECT id FROM @trace_result WHERE classeObj = 'BRA' And id=bra.id_BRA) then 1 else 0 end,
          @iNiveau+1, @classeObj, @id
        FROM 
          connexion_CNX cnx inner join 
            dbo.V_Topo_Elec_Branche bra on cnx.IdBRA_CNX = bra.id_BRA   
        WHERE     
          cnx.idOBR_CNX = @id
          AND cnx.idBRA_CNX NOT IN (SELECT id FROM @trace_result WHERE Niveau = @iNiveau-1)

      UPDATE @trace_result 
        SET statut = 1 
      WHERE 
        (classeObj = @classeObj AND id = @id) Or 
        (statutOuverture != 0) or 
        (statutBoucle != 0)

      FETCH NEXT FROM cursTopo INTO @classeObj, @id, @nbStation, @dTotCable, @dTotLigne, @iNiveau
    END
    CLOSE cursTopo
    DEALLOCATE cursTopo
  END
  RETURN
END
GO

IF EXISTS(SELECT o.[object_id] FROM sys.all_objects o where o.name = 'FCT_TopologyBT')
DROP FUNCTION dbo.FCT_TopologyBT
GO

CREATE FUNCTION dbo.FCT_TopologyBT 
(
  @idCOP int, 
  @idToBra int,
  @iStopIfExists int = 1
)
RETURNS @trace_result 
  TABLE (classeObj nvarchar(3), id int, statut int, nbArmoire int, idADBT int, idCopMesure int, totCable float, totLigne float, statutOuverture int, statutBoucle int, niveau int, classeParent nvarchar(3), idParent int )
AS
BEGIN
  DECLARE @iNiveau int, @id int, @classeObj nvarchar(3), @dTotCable float, @dTotLigne float, @idNodSource int, @nbArmoire int, @idADBT int, @idCopMesure int

  SELECT @idNodSource = id_NOD FROM dbo.V_Topo_Elec_Composant WHERE id_COP = @idCOP
  SET @iNiveau = 1
  
  INSERT INTO @trace_result (classeObj, id, statut, nbArmoire, idADBT, idCopMesure, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent) VALUES ('COP', @idCOP, 1, 0, 0, 0, 0, 0, 0, 0, @iNiveau, Null, Null)
  SET @iNiveau = 2
  
  INSERT INTO @trace_result (classeObj, id, statut, nbArmoire, idADBT, idCopMesure, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent)
    SELECT 'BRA', bra.id_BRA, 
    case when @iStopIfExists = 1 then
      case when EXISTS(SELECT zto.idOBR_ZTO FROM zsysTopoObject_ZTO zto where zto.idOBR_ZTO = id_BRA) 
        then 1 else 0 end
    else 0 end, 
    0,
    0,
    ISNULL((SELECT top 1 mes.id_COP from dbo.V_Topo_Mesure mes WHERE mes.IgnorePourCalcul_MES = 0 And mes.id_COP = @idCOP),0),
    case when bra.code_ORC = 'CAEL' then Isnull(bra.longueur_BRA, 0) else 0 end, 
    case when bra.code_ORC = 'LIEL' then Isnull(bra.longueur_BRA, 0) else 0 end, 
    0, 0, @iNiveau, 'COP', @idCop
    FROM 
      dbo.V_Topo_Elec_Branche bra
    Where 
      bra.id_BRA = @idToBra

  WHILE EXISTS (SELECT id FROM @trace_result WHERE statut = 0)
  BEGIN
    
    DECLARE cursTopo CURSOR LOCAL READ_ONLY FOR
      SELECT classeObj, id, nbArmoire, idADBT, idCopMesure, totCable, totLigne, Niveau
      FROM @trace_result WHERE statut = 0

    OPEN cursTopo
    FETCH NEXT FROM cursTopo INTO @classeObj, @id, @nbArmoire, @idADBT, @idCopMesure, @dTotCable, @dTotLigne, @iNiveau

    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF @classeObj = 'BRA'
        INSERT INTO @trace_result (classeObj, id, statut, nbArmoire, idADBT, idCopMesure, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent)
        SELECT 
          'COP', cnx.idOBR_CNX, 
          case when @iStopIfExists = 1 then
            case when EXISTS(SELECT zto.idOBR_ZTO FROM zsysTopoObject_ZTO zto where zto.idOBR_ZTO = cnx.idOBR_CNX) 
              then 1 else 0 end
          else 0 
          end, 
          @nbArmoire,
          @idADBT,
          @idCopMesure,
          @dTotCable, @dTotLigne, 
          case when cop.etatFlux_COPV = 1 then 0 else ISNULL(cop.degreManoeuvre_COPV,2) end, 
          case when (cop.code_NIV != 'BT') then 1 else 0 end,
          @iNiveau+1, @classeObj, @id
        FROM 
          Connexion_CNX cnx INNER JOIN 
            dbo.V_Topo_Elec_Composant cop on cnx.IdOBR_CNX = cop.id_COP 
        WHERE     
          --cop.etatFlux_COP = 1 AND 
          cnx.idBRA_CNX = @id
          AND cnx.idOBR_CNX NOT IN (SELECT id FROM @trace_result WHERE statutOuverture = 0) --  And Niveau = @iNiveau-1)
          AND cop.code_NIV IN ('BT', 'MT/BT')
          And cop.id_NOD != @idNodSource
          --           AND ncl.code_NCL ! = 'STHT'
      ELSE
        INSERT INTO @trace_result (classeObj, id, statut, nbArmoire, idADBT, idCopMesure, totCable, totLigne, statutOuverture, statutBoucle, niveau, classeParent, idParent)
        SELECT 
          'BRA', cnx.idBRA_CNX, 0, 
          @nbArmoire + case when (SELECT nod.code_ORC FROM dbo.V_Topo_Elec_Noeud nod inner join dbo.V_Topo_Elec_Composant cop  on cop.id_NOD = nod.id_NOD WHERE cop.id_COP = @id) = 'ADBT' then 1 else 0 end,
          ISNULL((SELECT nod.id_NOD FROM dbo.V_Topo_Elec_Noeud nod inner join dbo.V_Topo_Elec_Composant cop  on cop.id_NOD = nod.id_NOD WHERE nod.code_ORC = 'ADBT' And cop.id_COP = @id), @idADBT),
          ISNULL((SELECT top 1 mes.id_COP from dbo.V_Topo_Mesure mes WHERE mes.IgnorePourCalcul_MES  = 0 And mes.id_COP = @id),@idCopMesure),
          @dTotCable + case when bra.code_ORC = 'CAEL' then Isnull(bra.longueur_BRA, 0) else 0 end, 
          @dTotLigne + case when bra.code_ORC = 'LIEL' then Isnull(bra.longueur_BRA, 0) else 0 end, 
          0,
          0, --case when EXISTS(SELECT id FROM @trace_result WHERE classeObj = 'BRA' And id=bra.id_BRA) then 1 else 0 end,
          @iNiveau+1, @classeObj, @id
        FROM 
          Connexion_CNX cnx INNER JOIN 
            dbo.V_Topo_Elec_Branche bra on cnx.IdBRA_CNX = bra.id_BRA
        WHERE     
          cnx.idOBR_CNX = @id
          AND cnx.idBRA_CNX NOT IN (SELECT id FROM @trace_result) -- And Niveau = @iNiveau-1)

      UPDATE @trace_result 
        SET statut = 1 
      WHERE 
        (classeObj = @classeObj AND id = @id) Or 
        (statutOuverture != 0) or 
        (statutBoucle != 0)

      FETCH NEXT FROM cursTopo INTO @classeObj, @id, @nbArmoire, @idADBT, @idCopMesure, @dTotCable, @dTotLigne, @iNiveau
    END
    CLOSE cursTopo
    DEALLOCATE cursTopo
  END
  RETURN
END
GO

IF EXISTS(SELECT o.[object_id] FROM sys.all_objects o where o.name = 'FCT_TopologyTransfo')
DROP FUNCTION dbo.FCT_TopologyTransfo
GO

CREATE FUNCTION dbo.FCT_TopologyTransfo 
(
  @idTRF INT
)
RETURNS @trace_result 
  TABLE (classeObj nvarchar (3), id int, statut int, statutOuverture int, statutBoucle int, niveau int, classeParent nvarchar (3), idParent int )
AS
BEGIN
  DECLARE @iNiveau int, @id int, @classeObj nvarchar (3), @dTotCable float, @dTotLigne float
  SET @iNiveau = 1
  
  INSERT INTO @trace_result (classeObj, id, statut, statutOuverture, statutBoucle, niveau, classeParent, idParent) VALUES ('COP', @idTRF, 1, 0, 0, @iNiveau, Null, Null)

  INSERT INTO @trace_result (classeObj, id, statut, statutOuverture, statutBoucle, niveau, classeParent, idParent)
    SELECT 
      'BRA', cnx.idBRA_CNX, 0, 0, 0,
      @iNiveau+1, 
      'COP', 
      @idTRF
    FROM 
      connexion_CNX cnx INNER JOIN 
        dbo.V_Topo_Elec_Branche bra on cnx.IdBRA_CNX = bra.id_BRA
    WHERE
      bra.Code_ORC = 'BRVI'
      AND cnx.idOBR_CNX = @idTRF
      AND cnx.idBRA_CNX NOT IN (SELECT id FROM @trace_result)
      AND bra.Code_NIV = 'BT'

  WHILE EXISTS (SELECT id FROM @trace_result WHERE statut = 0)
  BEGIN
    
    DECLARE cursTopo CURSOR LOCAL READ_ONLY FOR
      SELECT classeObj, id, Niveau
      FROM @trace_result WHERE statut = 0

    OPEN cursTopo
    FETCH NEXT FROM cursTopo INTO @classeObj, @id, @iNiveau

    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF @classeObj = 'BRA' 
        INSERT INTO @trace_result (classeObj, id, statut, statutOuverture, statutBoucle, niveau, classeParent, idParent)
        SELECT 
          'COP', cnx.idOBR_CNX, 0, 
          case when cop.etatFlux_COPV = 1 then 0 else ISNULL(cop.degreManoeuvre_COPV,2) end,
          case when EXISTS(SELECT id FROM @trace_result WHERE id = cop.id_COP) then 1 else 0 end,
          @iNiveau+1, @classeObj, @id
        FROM 
          Connexion_CNX cnx inner join 
            dbo.V_Topo_Elec_Composant cop on cnx.IdOBR_CNX = cop.id_COP
        WHERE
          -- cop.etatFlux_COP = 1 AND 
          cnx.idBRA_CNX = @id
          AND cnx.idOBR_CNX NOT IN (SELECT id FROM @trace_result WHERE classeObj = 'COP' And Niveau = @iNiveau-1)
          AND cop.Code_NIV = 'BT'
      ELSE
        INSERT INTO @trace_result (classeObj, id, statut, statutOuverture, statutBoucle, niveau, classeParent, idParent)
        SELECT 
          'BRA', cnx.idBRA_CNX, case when bra.Code_ORC = 'BRVI' then 0 else 1 end, 
          0,
          case when EXISTS(SELECT id FROM @trace_result WHERE id = bra.id_BRA) then 1 else 0 end,
          @iNiveau+1, @classeObj, @id
        FROM 
          Connexion_CNX cnx inner join 
            dbo.V_Topo_Elec_Branche bra on cnx.IdBRA_CNX = bra.id_BRA
        WHERE
          bra.Code_ORC = 'BRVI'
          AND cnx.idOBR_CNX = @id
          AND cnx.idBRA_CNX NOT IN (SELECT id FROM @trace_result WHERE classeObj = 'BRA' And Niveau = @iNiveau-1)
          AND bra.Code_NIV = 'BT'

      UPDATE @trace_result 
        SET statut = 1 
      WHERE 
        (classeObj = @classeObj AND id = @id) Or 
        (statutOuverture != 0) or 
        (statutBoucle != 0)

      FETCH NEXT FROM cursTopo INTO @classeObj, @id, @iNiveau
    END
    CLOSE cursTopo
    DEALLOCATE cursTopo
  END
  RETURN
END
GO

IF EXISTS(SELECT o.[object_id] FROM sys.all_objects o where o.name = 'PRC_Topology')
DROP PROCEDURE dbo.PRC_Topology
GO

CREATE PROCEDURE dbo.PRC_Topology
AS
BEGIN
  DECLARE @idPST int, @idDEP int, @idBRA int, @idPER int, @idTRF int, @idDES int, @idSTA int, @dTotCable float, @dTotLigne float, @nbStation int, @iNiveauPrec int, @iMaxLevel int, @iCurLevel int, @myNextObj int
  DECLARE @dFact float, @dUnom float, @dSNomTot float, @dTension float, @dMesure float
  
  TRUNCATE TABLE zsysTopoObject_ZTO
  TRUNCATE TABLE zsysTopoParallele_ZAP
  IF EXISTS(SELECT id_NOD FROM dbo.V_Topo_Elec_DepartPoste dep)
  BEGIN
    DECLARE cursDepMT CURSOR LOCAL READ_ONLY FOR SELECT id_NOD, id_COP, id_BRA FROM dbo.V_Topo_Elec_DepartPoste dep
    OPEN cursDepMT
    FETCH NEXT FROM cursDepMT INTO @idPST, @idDEP, @idBRA
    WHILE @@FETCH_STATUS = 0
    BEGIN
      
      -- Tester Départ MT en //
      IF EXISTS(SELECT idOBR_ZTO FROM zsysTopoObject_ZTO WHERE idOBR_ZTO = @idBRA And classeObj_ZTO = 'BRA' And idCOPAlimMT_ZTO is not Null)
        INSERT INTO zsysTopoParallele_ZAP (idOBR_ZAP, idOBRParallele_ZAP) 
        SELECT @idDEP, idCOPAlimMT_ZTO
        FROM zsysTopoObject_ZTO WHERE classeOBJ_ZTO = 'BRA' And idOBR_ZTO = @idBRA
      ELSE
      
        INSERT INTO zsysTopoObject_ZTO ( classeOBJ_ZTO, idOBR_ZTO, idNODAlimMT_ZTO, idCOPAlimMT_ZTO, niveau_ZTO, classeParent_ZTO, idOBJParent_ZTO, boucle_ZTO, bouclageIndiceMT_ZTO, nbStationInter_ZTO, kmCableMTamont_ZTO, kmLigneMTamont_ZTO)
        SELECT v.classeObj, v.id, @idPST, @idDEP, niveau, classeParent, idParent, statutBoucle, statutOuverture, nbStation, totCable/1000.0, totLigne/1000.0 
        FROM 
          dbo.FCT_TopologyMT (@idDEP, @idBRA, DEFAULT) v
        WHERE
          (statutOuverture > 0) or
          NOT EXISTS(SELECT idOBR_ZTO FROM zsysTopoObject_ZTO WHERE  classeOBJ_ZTO=v.classeObj And idOBR_ZTO = v.id)
      
      FETCH NEXT FROM cursDepMT INTO @idPST, @idDEP, @idBRA
    END    
    CLOSE cursDepMT
    DEALLOCATE cursDepMT
  -- Traitement des transfos
    DECLARE cursTrf CURSOR LOCAL READ_ONLY FOR 
    SELECT id_COP, idNODAlimMT_ZTO, idCOPAlimMT_ZTO, nbStationInter_ZTO, kmCableMTamont_ZTO, kmLigneMTamont_ZTO, niveau_ZTO
    FROM 
      dbo.V_Topo_Elec_Composant cop INNER JOIN 
      (SELECT * FROM zsysTopoObject_ZTO Where  classeOBJ_ZTO = 'COP')ali on ali.idOBR_ZTO = cop.id_COP
    WHERE cop.etatFlux_COPV = 1 And cop.Code_ORC = 'TRF'
  END
  ELSE
    -- Traitement des transfos
    DECLARE cursTrf CURSOR LOCAL READ_ONLY FOR 
    SELECT id_COP, Null, Null, 0, 0, 0, 0
    FROM 
      dbo.V_Topo_Elec_Composant cop 
    WHERE cop.etatFlux_COPV = 1 And cop.Code_ORC = 'TRF'
  
  OPEN cursTrf
  FETCH NEXT FROM cursTrf INTO @idTRF, @idPST,  @idDEP, @nbStation, @dTotCable, @dTotLigne, @iNiveauPrec
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @myNextObj = Null
    
    SELECT @myNextObj = id_BRA
    FROM 
      connexion_CNX cnx INNER JOIN dbo.V_Topo_Elec_Branche bra on bra.id_BRA = cnx.IdBRA_CNX
    WHERE
      cnx.idOBR_CNX = @idTRF
      AND cnx.idBRA_CNX IN (SELECT idOBR_ZTO FROM zsysTopoObject_ZTO WHERE idTRFAlimBT_ZTO is not Null)
      AND bra.code_NIV = 'BT'
   
    -- Tester trf en //
    IF @myNextObj is Not null
      INSERT INTO zsysTopoParallele_ZAP (idOBR_ZAP, idOBRParallele_ZAP) 
      SELECT @idTRF, idTRFAlimBT_ZTO
      FROM zsysTopoObject_ZTO WHERE idOBR_ZTO = @myNextObj
    ELSE
      INSERT INTO zsysTopoObject_ZTO ( classeOBJ_ZTO, idOBR_ZTO, idNODAlimMT_ZTO, idCOPAlimMT_ZTO, idTRFAlimBT_ZTO, niveau_ZTO, classeParent_ZTO, idOBJParent_ZTO, boucle_ZTO, bouclageIndiceBT_ZTO, nbStationInter_ZTO, kmCableMTamont_ZTO, kmLigneMTamont_ZTO)
      SELECT v.classeObj, v.id, @idPST, @idDEP, @idTRF, @iNiveauPrec+v.niveau-1, v.classeParent, v.idParent, v.statutBoucle, v.statutOuverture, @nbStation, @dTotCable, @dTotLigne
      FROM dbo.FCT_TopologyTransfo (@idTRF) v 
      WHERE 
        (v.statutOuverture > 0) or
        (v.statutBoucle = 0  And NOT EXISTS(SELECT idOBR_ZTO FROM zsysTopoObject_ZTO WHERE idOBR_ZTO = v.id))
    
    FETCH NEXT FROM cursTrf INTO @idTRF, @idPST,  @idDEP, @nbStation, @dTotCable, @dTotLigne, @iNiveauPrec
  END
  CLOSE cursTrf
  DEALLOCATE cursTrf
  
  -- Traitements de la partie BT
  DECLARE cursDepBT CURSOR LOCAL READ_ONLY STATIC FOR
  SELECT DISTINCT 
    id_NOD, id_COP, id_BRA
  FROM 
    V_Topo_Elec_DepartStation
  WHERE   
    etatFlux_COPV = 1 And
    id_COP in (select idOBR_ZTO from zsysTopoObject_ZTO WHERE classeOBJ_ZTO = 'COP' And idTRFAlimBT_ZTO is NOT NULL And idCOPAlimBT_ZTO is null) 
  
  OPEN cursDepBT
  FETCH NEXT FROM cursDepBT INTO @idSTA, @idDES, @idBRA
  WHILE @@FETCH_STATUS = 0
  BEGIN

    
    SELECT TOP 1 @idTRF = idTRFAlimBT_ZTO, @idPST = idNODAlimMT_ZTO,  @idDEP = idCOPAlimMT_ZTO, @nbStation = nbStationInter_ZTO, @dTotCable = kmCableMTamont_ZTO, @dTotLigne = kmLigneMTamont_ZTO, @iNiveauPrec = niveau_ZTO 
    FROM zsysTopoObject_ZTO WHERE classeOBJ_ZTO = 'COP' and idOBR_ZTO = @idDES

    -- Tester Départ BT en //
    IF EXISTS(SELECT idOBR_ZTO FROM zsysTopoObject_ZTO WHERE idOBR_ZTO = @idBRA And classeObj_ZTO = 'BRA' And idCOPAlimBT_ZTO is not Null)
      INSERT INTO zsysTopoParallele_ZAP (idOBR_ZAP, idOBRParallele_ZAP) 
      SELECT @idDES, idCOPAlimBT_ZTO
      FROM 
        zsysTopoObject_ZTO WHERE classeOBJ_ZTO = 'BRA' And idOBR_ZTO = @idBRA
    ELSE
      INSERT INTO zsysTopoObject_ZTO (classeOBJ_ZTO, idOBR_ZTO, idNODAlimMT_ZTO, idCOPAlimMT_ZTO, idTRFAlimBT_ZTO, idNODAlimBT_ZTO, idCOPAlimBT_ZTO, niveau_ZTO, classeParent_ZTO, idOBJParent_ZTO, boucle_ZTO, bouclageIndiceBT_ZTO, nbStationInter_ZTO, nbArmoireInter_ZTO, idCOPMes_ZTO, idADBTAlim_ZTO, kmCableMTamont_ZTO, kmLigneMTamont_ZTO, kmCableBTamont_ZTO, kmLigneBTamont_ZTO)
      SELECT 
        v.classeObj, v.id, @idPST, @idDEP, @idTRF, @idSTA, @idDES, @iNiveauPrec+v.niveau-1, classeParent, idParent, statutBoucle, statutOuverture, @nbStation, nbArmoire, idCopMesure, idADBT, @dTotCable, @dTotLigne, totCable/1000, totLigne/1000
      FROM 
        dbo.FCT_TopologyBT (@idDES, @idBRA, DEFAULT) v
      WHERE 
        (v.statutOuverture > 0) or
        NOT EXISTS(SELECT idOBR_ZTO FROM zsysTopoObject_ZTO WHERE idOBR_ZTO = v.id)

    FETCH NEXT FROM cursDepBT INTO @idSTA, @idDES, @idBRA
  END
  CLOSE cursDepBT
  DEALLOCATE cursDepBT
  -- Eléments calculés sur les coffrets: nombres, consommation dernier année, clients + sensibles 
 
  UPDATE ZTO 
    SET nbClient_ZTO = ISNULL((select cli.nbClientDerive from dbo.V_Topo_ClientDerive cli where cli.id_OBR = cop.id_NOD),0),
--      nbClientDirect_ZTO = (),
      nbClientSensible_ZTO = ISNULL((select cli.nbClientSensible from dbo.V_Topo_ClientDerive cli where cli.id_OBR = cop.id_NOD),0),
      nbClientSensible2_ZTO = ISNULL((select cli.nbClientSensible2 from dbo.V_Topo_ClientDerive cli where cli.id_OBR = cop.id_NOD),0),
      nbClientSensible3_ZTO = ISNULL((select cli.nbClientSensible3 from dbo.V_Topo_ClientDerive cli where cli.id_OBR = cop.id_NOD),0),
      consommationDerAnnnee_ZTO = ISNULL((select cli.ConsommationDerAnnee from dbo.V_Topo_ClientDerive cli where cli.id_OBR = cop.id_NOD),0)
  FROM 
    zsysTopoObject_ZTO zto inner join dbo.v_topo_Elec_Composant cop on zto.idOBR_ZTO = cop.id_COP  
  WHERE
    zto.classeOBJ_ZTO = 'COP' And
    cop.Code_ORC = 'PCX' and
    cop.id_NOD in  
      (SELECT id_OBR 
        from ObjetReseau_OBR obr inner join NObjetReseauClasse_ORC orc on obr.IdORC_OBR = orc.Id_ORC Where orc.Code_ORC = 'COBT'
      )
  
  
  UPDATE ZTO
    SET 
      SInst_ZTO = ISNULL(trf.puissance_TRF,0),
      SMesure_ZTO = 0 --ISNULL((select top 1 met.puissanceApparente_MET from mesureTransfoMTBT_MET met where met.idCOP_MET = cop.id_COP And (met.ignoreSIFLOW_MET is null or met.ignoreSIFLOW_MET = 0) order by met.dtMesure_MET DESC) ,0)
  FROM 
    zsysTopoObject_ZTO zto inner join 
      dbo.V_Topo_Elec_Composant cop on zto.idOBR_ZTO = cop.id_COP inner join 
        dbo.Transformateur_TRF trf on trf.Id_OBRV = cop.Id_OBRV

    
  UPDATE ZTO
    SET 
      zto.bouclageIndiceBT_ZTO = 5,
      zto.bouclageIndiceMT_ZTO = 5,
      ZTO.kmCableMTaval_ZTO = case when zto.idTRFAlimBT_ZTO is null then case when bra.Code_ORC = 'CAEL' then ISNULL(bra.longueur_BRA, 0)/1000 else 0 end else 0 end,
      ZTO.kmCableBTaval_ZTO = case when zto.idTRFAlimBT_ZTO is not null then case when bra.Code_ORC = 'CAEL' then ISNULL(bra.longueur_BRA, 0)/1000 else 0 end else 0 end,
      ZTO.kmLigneMTaval_ZTO = case when zto.idTRFAlimBT_ZTO is null then case when bra.Code_ORC = 'LIEL' then ISNULL(bra.longueur_BRA, 0)/1000/1000 else 0 end else 0 end,
      ZTO.kmLigneBTaval_ZTO = case when zto.idTRFAlimBT_ZTO is not null then case when bra.Code_ORC = 'LIEL' then ISNULL(bra.longueur_BRA, 0)/1000 else 0 end else 0 end
  FROM 
    zsysTopoObject_ZTO zto inner join 
      dbo.V_Topo_Elec_Branche bra on zto.idOBR_ZTO = bra.id_BRA 
  WHERE 
    bra.Code_ORC in ('CAEL', 'LIEL')   

  UPDATE ZTO
    SET 
      zto.bouclageIndiceBT_ZTO = 5,
      zto.bouclageIndiceMT_ZTO = 5
  FROM 
    zsysTopoObject_ZTO zto inner join 
      dbo.V_Topo_Elec_Composant cop on cop.id_COP = zto.idOBR_ZTO
  WHERE 
    cop.etatFlux_COPV = 1

  SET ANSI_WARNINGS OFF;
  
  UPDATE zto
    SET 
      zto.nbCoffret_ZTO = 
        ISNULL((SELECT COUNT(nod.id_NOD) FROM 
                          zsysTopoObject_ZTO f inner join 
                            dbo.V_Topo_Elec_Composant cop on f.idOBR_ZTO = cop.id_COP inner join 
                              dbo.V_Topo_Elec_Noeud nod on nod.id_NOD = cop.id_NOD
                        where cop.etatFlux_COPV = 1 And f.classeParent_ZTO = zto.classeOBJ_ZTO AND f.idOBJParent_ZTO = zto.idOBR_ZTO and f.classeOBJ_ZTO = 'COP' And nod.code_ORC in ('COBT')), 0),
      zto.nbArmoire_ZTO = 
        ISNULL((SELECT COUNT(nod.id_NOD) FROM 
                          zsysTopoObject_ZTO f inner join 
                            dbo.V_Topo_Elec_Composant cop on f.idOBR_ZTO = cop.id_COP inner join 
                              dbo.V_Topo_Elec_Noeud nod on nod.id_NOD = cop.id_NOD
                        where cop.etatFlux_COPV = 1 And f.classeParent_ZTO = zto.classeOBJ_ZTO AND f.idOBJParent_ZTO = zto.idOBR_ZTO and f.classeOBJ_ZTO = 'COP' And nod.code_ORC in ('ADBT')), 0),
      zto.nbStation_ZTO = 
        ISNULL((SELECT COUNT(nod.id_NOD) FROM 
                          zsysTopoObject_ZTO f inner join 
                            dbo.V_Topo_Elec_Composant cop on f.idOBR_ZTO = cop.id_COP inner join 
                              dbo.V_Topo_Elec_Noeud nod on nod.id_NOD = cop.id_NOD
                        where cop.etatFlux_COPV = 1 And f.classeParent_ZTO = zto.classeOBJ_ZTO AND f.idOBJParent_ZTO = zto.idOBR_ZTO and f.classeOBJ_ZTO = 'COP' And nod.code_ORC in ('STMT')), 0)
  FROM 
    zsysTopoObject_ZTO zto
  WHERE 
     zto.idOBR_ZTO in (SELECT id_BRA from dbo.V_Topo_Elec_Branche Where Code_ORC in ('CAEL', 'LIEL'))

  UPDATE zsysTopoObject_ZTO 
  SET nbClientDirect_ZTO = nbClient_ZTO
    WHERE nbClient_ZTO > 0

  UPDATE zsysTopoObject_ZTO 
  SET nbCoffretDirect_ZTO  = nbCoffret_ZTO
    WHERE nbCoffret_ZTO > 0  

  -- Supprimer les bouclages 'inutiles' (couplage ouvert sans extrémités de câble)
  DELETE FROM zsysTopoObject_ZTO
  WHERE  classeOBJ_ZTO = 'COP' And idOBR_ZTO in 
  (SELECT cop.id_COP FROM 
    zsysTopoObject_ZTO zto inner join 
      dbo.V_Topo_Elec_Composant cop on cop.id_COP = zto.idOBR_ZTO
  WHERE 
    cop.etatFlux_COPV != 1 and 
    (select count(*) FROM dbo.FCT_TopologyNextCable (cop.id_COP, zto.classeParent_ZTO, zto.idOBJParent_ZTO)v inner join dbo.V_Topo_Elec_Branche bra on v.id = bra.id_BRA Where bra.Code_ORC in ('LIEL', 'CAEL') And classeObj = 'BRA') = 0)

  -- Reporter les valeurs vers la source
  SELECT @iMaxLevel = MAX(niveau_ZTO) FROM zsysTopoObject_ZTO
  
  SET @iCurLevel = @iMaxLevel -1
  WHILE @iCurLevel >= 0
  BEGIN
    
    UPDATE ZTO
      SET 
        ZTO.nbCoffret_ZTO = ZTO.nbCoffret_ZTO + ISNULL((SELECT SUM(fils.nbCoffret_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.nbArmoire_ZTO = ZTO.nbArmoire_ZTO + ISNULL((SELECT SUM(fils.nbArmoire_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.nbStation_ZTO = ZTO.nbStation_ZTO + ISNULL((SELECT SUM(fils.nbStation_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.nbClient_ZTO = ZTO.nbClient_ZTO + ISNULL((SELECT SUM(fils.nbClient_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.nbClientSensible_ZTO = ZTO.nbClientSensible_ZTO + ISNULL((SELECT SUM(fils.nbClientSensible_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.nbClientSensible2_ZTO = ZTO.nbClientSensible2_ZTO + ISNULL((SELECT SUM(fils.nbClientSensible2_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.nbClientSensible3_ZTO = ZTO.nbClientSensible3_ZTO + ISNULL((SELECT SUM(fils.nbClientSensible3_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.consommationDerAnnnee_ZTO = ZTO.consommationDerAnnnee_ZTO + ISNULL((SELECT SUM(fils.consommationDerAnnnee_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.SInst_ZTO = ZTO.SInst_ZTO + ISNULL((SELECT SUM(fils.SInst_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.SMesure_ZTO = ZTO.SMesure_ZTO + ISNULL((SELECT SUM(fils.SMesure_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.kmCableMTaval_ZTO = ZTO.kmCableMTaval_ZTO + ISNULL((SELECT SUM(fils.kmCableMTaval_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.kmCableBTaval_ZTO = ZTO.kmCableBTaval_ZTO + ISNULL((SELECT SUM(fils.kmCableBTaval_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.kmLigneMTaval_ZTO = ZTO.kmLigneMTaval_ZTO + ISNULL((SELECT SUM(fils.kmLigneMTaval_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        ZTO.kmLigneBTaval_ZTO = ZTO.kmLigneBTaval_ZTO + ISNULL((SELECT SUM(fils.kmLigneBTaval_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO),0),
        
        zto.bouclageIndiceBT_ZTO = ISNULL((SELECT MIN(bouclageIndiceBT_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO), zto.bouclageIndiceBT_ZTO),
        zto.bouclageIndiceMT_ZTO = ISNULL((SELECT MIN(bouclageIndiceMT_ZTO) FROM zsysTopoObject_ZTO fils WHERE fils.classeParent_ZTO = zto.classeOBJ_ZTO And fils.idOBJParent_ZTO = zto.idOBR_ZTO), zto.bouclageIndiceMT_ZTO)
        
      FROM 
        zsysTopoObject_ZTO zto  
      WHERE zto.niveau_ZTO =  @iCurLevel
    SET @iCurLevel = @iCurLevel-1
  END   
  SET ANSI_WARNINGS ON;
  
  -- Insertion des noeuds électriques
  
  INSERT INTO zsysTopoObject_ZTO (
     classeOBJ_ZTO
    ,idOBR_ZTO
    ,idNODAlimMT_ZTO
    ,idNODAlimBT_ZTO
    ,idCOPAlimMT_ZTO
    ,idCOPAlimBT_ZTO
    ,idTRFAlimBT_ZTO
    ,idADBTAlim_ZTO
    ,idCOPMes_ZTO
    ,niveau_ZTO
    ,classeParent_ZTO
    ,idOBJParent_ZTO
    ,boucle_ZTO
    ,kmCableMTamont_ZTO
    ,kmCableBTamont_ZTO
    ,kmLigneMTamont_ZTO
    ,kmLigneBTamont_ZTO
    ,nbStationInter_ZTO
    ,nbArmoireInter_ZTO
    ,bouclageIndiceBT_ZTO
    ,bouclageIndiceMT_ZTO
    ,kmCableMTaval_ZTO
    ,kmCableBTaval_ZTO
    ,kmLigneMTaval_ZTO
    ,kmLigneBTaval_ZTO
    ,nbClient_ZTO
    ,nbClientDirect_ZTO
    ,nbCoffret_ZTO
    ,nbCoffretDirect_ZTO
    ,nbArmoire_ZTO
    ,nbStation_ZTO
    ,SInst_ZTO
    ,SMesure_ZTO
    ,nbClientSensible_ZTO
    ,nbClientSensible2_ZTO
    ,nbClientSensible3_ZTO
    ,consommationDerAnnnee_ZTO
  ) SELECT
     N'NOD' AS classeOBJ_ZTO           -- classeOBJ_ZTO - nvarchar(3)
    ,c.IdParent_CMP   AS idOBR_ZTO               -- idOBR_ZTO - int
    ,idNODAlimMT_ZTO
    ,idNODAlimBT_ZTO
    ,idCOPAlimMT_ZTO
    ,idCOPAlimBT_ZTO
    ,idTRFAlimBT_ZTO
    ,idADBTAlim_ZTO
    ,idCOPMes_ZTO
    ,niveau_ZTO
    ,classeParent_ZTO
    ,idOBJParent_ZTO
    ,boucle_ZTO
    ,kmCableMTamont_ZTO
    ,kmCableBTamont_ZTO
    ,kmLigneMTamont_ZTO
    ,kmLigneBTamont_ZTO
    ,nbStationInter_ZTO
    ,nbArmoireInter_ZTO
    ,bouclageIndiceBT_ZTO
    ,bouclageIndiceMT_ZTO
    ,kmCableMTaval_ZTO
    ,kmCableBTaval_ZTO
    ,kmLigneMTaval_ZTO
    ,kmLigneBTaval_ZTO
    ,nbClient_ZTO
    ,nbClientDirect_ZTO
    ,nbCoffret_ZTO
    ,nbCoffretDirect_ZTO
    ,nbArmoire_ZTO
    ,nbStation_ZTO
    ,SInst_ZTO
    ,SMesure_ZTO
    ,nbClientSensible_ZTO
    ,nbClientSensible2_ZTO
    ,nbClientSensible3_ZTO
    ,consommationDerAnnnee_ZTO
  FROM zsysTopoObject_ZTO z inner join ObjetReseau_OBR o on z.idOBR_ZTO = o.Id_OBR inner join Composition_CMP c on c.IdEnfant_CMP = o.Id_OBR
  WHERE c.IdPRJ_CMP = 1 And o.IdORC_OBR in (select Id_ORC from NObjetReseauClasse_ORC Where Code_ORC in ('PCX', 'BARRE'))
  
  DELETE 
  FROM zsysTopoObject_ZTO 
  WHERE classeOBJ_ZTO = 'NOD' And EXISTS(SELECT z.id_ZTO FROM zsysTopoObject_ZTO z WHERE z.classeOBJ_ZTO  ='NOD' And z.idOBR_ZTO = zsysTopoObject_ZTO.idOBR_ZTO And z.id_ZTO > zsysTopoObject_ZTO.id_ZTO)
END
GO


CREATE OR ALTER VIEW [dbo].[V_ELEC_Noeud_Non_Alimente]
AS
SELECT DISTINCT
  orc.Code_ORC, orc.Libelle_ORC,
  ob.Code_OBRV, ob.Nom_OBRV, ob.IdOBR_OBRV,
  (SELECT idParent_CMP from Composition_CMP WHERE dbo.Composition_CMP.IdEnfant_CMP = ob.IdOBR_OBRV And idPRJ_CMP = ob.IdPRJ_OBRV) as IdOBR_Geo
FROM 
  NoeudVersion_NODV nod inner join 
    ObjetReseauVersion_OBRV ob on ob.Id_OBRV = nod.Id_OBRV inner join 
      NObjetReseauClasse_ORC orc on orc.Id_ORC = ob.IdORC_OBRV
WHERE 
  orc.Code_ORC not in ('CND', 'TKR', 'PLN', 'ZFL', 'STHT', 'MSN') And
  ob.Nom_OBRV != 'Armoire EP' And
  ob.IdOBR_OBRV in (SELECT c.idOBR_CNX from Connexion_CNX c inner join ObjetReseau_OBR o on c.IdBRA_CNX = o.Id_OBR inner join NObjetReseauClasse_ORC oc on o.IdORC_OBR = oc.Id_ORC where oc.Code_ORC in ('CAEL', N'LIEL')) And
  ob.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null) And 
  ob.IdOBR_OBRV in (
    SELECT cmp.IdParent_CMP as idNod
    FROM 
      ObjetReseau_OBR obr INNER JOIN 
          dbo.NObjetReseauClasse_ORC orc ON ORC.Id_ORC = obr.IdORC_OBR INNER JOIN
            dbo.composition_CMP cmp on cmp.idEnfant_CMP = obr.Id_OBR
    WHERE 
      orc.Code_ORC in ('PCX', 'BARRE') And
      obr.Id_OBR not in (SELECT idOBR_ZTO FROM zsysTopoObject_ZTO)
    )
  And ob.IdOBR_OBRV not in
      (SELECT ob.IdOBR_OBRV
        FROM 
        NoeudVersion_NODV nod inner join 
          ObjetReseauVersion_OBRV ob on ob.Id_OBRV = nod.Id_OBRV
        WHERE 
          ob.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null) And 
          ob.IdOBR_OBRV in 
          (
            SELECT cmp.IdParent_CMP as idNod
            FROM 
              ObjetReseau_OBR obr INNER JOIN 
                  dbo.NObjetReseauClasse_ORC orc ON ORC.Id_ORC = obr.IdORC_OBR INNER JOIN
                    dbo.composition_CMP cmp on cmp.idEnfant_CMP = obr.Id_OBR
            WHERE 
              orc.Code_ORC in ('PCX', 'BARRE') And
              obr.Id_OBR in (SELECT idOBR_ZTO FROM zsysTopoObject_ZTO)
          )
          )
GO


