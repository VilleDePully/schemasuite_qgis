-- Corriger composition: remettre les bornes dans le bon manchon en fonction du PCX qui lui est connecté
WITH liste AS 
(
SELECT  
  borne.idBorne, 
  borne.idParent as idParentBorne, 
  (SELECT n.code_ORC FROM dbo.ObjetReseau_OBR o inner join dbo.NObjetReseauClasse_ORC n ON n.Id_ORC = o.IdORC_OBR WHERE o.id_OBR = borne.idParent) as ClasseParentBorne, 
  pcx.idPcx, 
  pcx.idParent as idParentPCX, 
  (SELECT n.code_ORC FROM dbo.ObjetReseau_OBR o inner join dbo.NObjetReseauClasse_ORC n ON n.Id_ORC = o.IdORC_OBR WHERE o.id_OBR = pcx.idParent) as ClasseParentPCX 
FROM

(
SELECT
  bor.Id_OBR as idBorne, 
  brvi.Id_OBR as idCable,
  (SELECT idParent_CMP FROM dbo.Composition_CMP cmp WHERE idEnfant_CMP = bor.Id_OBR) as idParent  
FROM 
  dbo.ObjetReseau_OBR bor inner join dbo.NObjetReseauClasse_ORC nob ON nob.Id_ORC = bor.IdORC_OBR inner join 
    dbo.Connexion_CNX cnc on cnc.IdOBR_CNX = bor.Id_OBR inner join dbo.ObjetReseau_OBR brvi on brvi.Id_OBR = cnc.IdBRA_CNX inner join 
      dbo.NObjetReseauClasse_ORC nob1 ON nob1.Id_ORC = brvi.IdORC_OBR 
WHERE 
  nob.Code_ORC = 'BORNE' And nob1.Code_ORC = N'BRVI'
)borne inner join
(
SELECT
  bor.Id_OBR as idPcx, 
  brvi.Id_OBR as idCable,
  (SELECT idParent_CMP FROM dbo.Composition_CMP cmp WHERE idEnfant_CMP = bor.Id_OBR) as idParent  
FROM 
  dbo.ObjetReseau_OBR bor inner join dbo.NObjetReseauClasse_ORC nob ON nob.Id_ORC = bor.IdORC_OBR inner join 
    dbo.Connexion_CNX cnc on cnc.IdOBR_CNX = bor.Id_OBR inner join dbo.ObjetReseau_OBR brvi on brvi.Id_OBR = cnc.IdBRA_CNX inner join 
      dbo.NObjetReseauClasse_ORC nob1 ON nob1.Id_ORC = brvi.IdORC_OBR 
WHERE 
  nob.Code_ORC = 'PCX' And nob1.Code_ORC = N'BRVI'
)  
pcx on pcx.idCable = borne.idCable
WHERE
pcx.idParent != borne.idParent
)
UPDATE cmp
  SET cmp.IdParent_CMP = liste.idParentPCX
FROM 
  dbo.Composition_CMP cmp inner join liste on liste.idBorne = cmp.idEnfant_CMP
GO

-- Connexion sur MAEL/COBT erroné: pas de composant interne connecté au câble
DELETE FROM dbo.Connexion_CNX WHERE id_CNX in 
(
SELECT
  con.Id_CNX
FROM 
  dbo.Connexion_CNX con inner join dbo.ObjetReseau_OBR obj ON obj.Id_OBR = con.IdOBR_CNX inner join dbo.NObjetReseauClasse_ORC nob ON nob.Id_ORC = obj.IdORC_OBR
WHERE 
  con.IdPRJ_CNX = 1 And 
  nob.Code_ORC in ('MAEL', 'COBT') And
  -- Pas de connexion sur un enfant du MAEL
  Not Exists
  (
    SELECT c.id_CNX
    FROM 
      dbo.Connexion_CNX c 
    WHERE 
      c.IdBRA_CNX = con.IdBRA_CNX And 
      c.IdPRJ_CNX = con.IdPRJ_CNX And 
      c.IdOBR_CNX in (SELECT com.IdEnfant_CMP from dbo.Composition_CMP com WHERE com.IdParent_CMP = con.IdOBR_CNX)
  )
)
GO

-- inserer les connexions sur MAEL/COBT (entre borne et TKR/MSN)
INSERT INTO dbo.Connexion_CNX (
   TypeConnexion_CNX
  ,Direction_CNX
  ,IdBRA_CNX
  ,IdOBR_CNX
  ,Ordre_CNX
  ,RacineGuid_CNX
  ,IdPRJ_CNX
  ,State_CNX
  ,Guid_CNX
  ,CreationDate
  ,CreationUtilisateur
  ,ModificationUtilisateur
) 
SELECT 
  1 as TypeConnexion_CNX, 
  cnx.Direction_CNX, 
  cnx.IdBRA_CNX, 
  (SELECT p.idParent_CMP from dbo.Composition_CMP p WHERE p.IdEnfant_CMP = cnx.IdOBR_CNX and p.IdPRJ_CMP = 1) as idOBR_CNX,
  case when cnx.Ordre_CNX < 0 then 
    cnx.Ordre_CNX + ( ( SELECT TOP 1 c.ordre_CNX 
      FROM dbo.Connexion_CNX c 
      WHERE c.idBRA_CNX = cnx.IdBRA_CNX And c.Ordre_CNX > cnx.Ordre_CNX order by c.Ordre_CNX)-cnx.Ordre_CNX)/2
     
  else 
    cnx.Ordre_CNX - (cnx.Ordre_CNX - ( SELECT TOP 1 c.ordre_CNX 
      FROM dbo.Connexion_CNX c 
      WHERE c.idBRA_CNX = cnx.IdBRA_CNX And c.Ordre_CNX < cnx.Ordre_CNX order by c.Ordre_CNX DESC))/2
  end Ordre_CNX,
  NewId() as RacineGuid,
  cnx.IdPRJ_CNX,
  cnx.State_CNX,
  NewId() as Guid,
  GetDate(),
  'NEWIS',
  'MAEL'

FROM 
  dbo.Connexion_CNX cnx inner join 
    dbo.ObjetReseau_OBR obj on cnx.IdBRA_CNX = obj.Id_OBR inner join 
      dbo.NObjetReseauClasse_ORC nob ON nob.Id_ORC = obj.IdORC_OBR 
WHERE 
  cnx.IdPRJ_CNX = 1 And
  nob.Code_ORC in ('LIEL', 'CAEL') And
  cnx.IdOBR_CNX in 
  (
    SELECT bor.id_OBR
    FROM 
      dbo.Connexion_CNX cc inner join 
        dbo.ObjetReseau_OBR bor ON cc.IdOBR_CNX = bor.Id_OBR INNER JOIN 
          dbo.NObjetReseauClasse_ORC clb ON clb.Id_ORC = bor.IdORC_OBR inner join
            dbo.ObjetReseau_OBR cca on cc.IdBRA_CNX = cca.Id_OBR inner join 
              dbo.NObjetReseauClasse_ORC ccanob ON ccanob.Id_ORC = cca.IdORC_OBR
    WHERE
      ccanob.Code_ORC in ('LIEL', 'CAEL') and
      clb.Code_ORC = 'BORNE' And
      cc.idPRJ_CNX = 1 And
      Not Exists
      (
        SELECT c.id_CNX
        FROM 
          dbo.Connexion_CNX c  
        WHERE 
          c.IdBRA_CNX = cc.IdBRA_CNX And 
          c.IdPRJ_CNX = cc.IdPRJ_CNX And 
          c.IdOBR_CNX in (SELECT com.IdParent_CMP from dbo.Composition_CMP com WHERE com.IdEnfant_CMP = bor.id_OBR)
      )
  )
GO

-- Requêtes de travail

-- Liste des connexions sur un ensemble de branches

/*
SELECT 
  IdBRA_CNX,cnx.TypeConnexion_CNX, cnx.Direction_CNX, cnx.IdOBR_CNX, cnx.Ordre_CNX, nob.Code_ORC
FROM 
  dbo.Connexion_CNX cnx inner join dbo.ObjetReseau_OBR obj on cnx.IdOBR_CNX = obj.Id_OBR inner join dbo.NObjetReseauClasse_ORC nob ON nob.Id_ORC = obj.IdORC_OBR 
--WHERE cnx.idOBR_CNX = 252444
WHERE cnx.IdBRA_CNX in (252445,252446)
ORDER by cnx.IdBRA_CNX, cnx.Ordre_CNX
GO
*/
