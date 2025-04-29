
-- SefaMajQuotidienSSe

-- Corriger les noms des schémas en fonction des noms des noeuds
update schv
  set Nom_SCHV = obrv.Nom_OBRV
FROM 
  SchemaVersion_SCHV schv inner join 
    ObjetReseauVersion_OBRV obrv on schv.IdOBR_SCHV = obrv.IdOBR_OBRV And schv.IdPRJ_SCHV = obrv.IdPRJ_OBRV
Where 
  --schv.IdTSC_SCHV in (select id_TSC from NTypeSchema_TSC where Code_TSC = 'ELECOrtInt') And
  obrv.Nom_OBRV is not null And
  obrv.Nom_OBRV <> schv.Nom_SCHV And
  Len (obrv.Nom_OBRV) > 2
GO

-- Corriger données pour la topologie:
-- 1. Mettre la tension BT sur les composants EP avec connexion sur câble BT
UPDATE 
  composantVersion_COPV 
SET  
  IdNIV_COPV = (SELECT niv.id_NIV FROM dbo.NNiveauTension_NIV niv Where niv.Code_NIV = 'BT')
WHERE 
  Id_OBRV in (SELECT obrv.id_OBRV 
              FROM objetreseauVersion_OBRV obrv 
              WHERE obrv.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null)     
                And obrv.IdOBR_OBRV in 
                    (
                      SELECT distinct cop.id_COP
                                  FROM 
                                    connexion_CNX cnx INNER JOIN
                                      dbo.V_Topo_Elec_Branche bra on bra.id_BRA = cnx.IdBRA_CNX inner join 
                                        dbo.V_Topo_Elec_Composant cop on cnx.IdOBR_CNX = cop.id_COP
                                  WHERE
                                    cop.code_ORC = 'PCX' And
                                    cop.Code_NIV = 'EP'
                                    And bra.Code_NIV = 'BT'
                    )
              )
GO

-- 2. Mettre la tension BT sur les câbles internes connecté à un composant BT
UPDATE 
  BrancheVersion_BRAV 
SET
  IdNIV_BRAV = (SELECT niv.id_NIV FROM dbo.NNiveauTension_NIV niv Where niv.Code_NIV = 'BT')
WHERE 
  IdNIV_BRAV Is null And
  Id_OBRV in 
  (SELECT obrv.id_OBRV FROM 
    objetreseauVersion_OBRV obrv WHERE obrv.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null) 
    And obrv.IdOBR_OBRV in 
        (SELECT bra.id_BRA
            FROM 
              connexion_CNX cnx INNER JOIN
                dbo.V_Topo_Elec_Branche bra on bra.id_BRA = cnx.IdBRA_CNX inner join dbo.V_Topo_Elec_Composant cop on cnx.IdOBR_CNX = cop.id_COP
            WHERE
              cop.Code_NIV = 'BT'
              And bra.Code_ORC = 'BRVI'
              AND bra.code_NIV is null)
   )
GO

--3. Mettre la tension MT sur les câbles internes connecté à un composant MT
UPDATE 
  BrancheVersion_BRAV 
SET
  IdNIV_BRAV = (SELECT niv.id_NIV FROM dbo.NNiveauTension_NIV niv Where niv.Code_NIV = 'MT')
WHERE 
  IdNIV_BRAV Is null And
  Id_OBRV in 
  (SELECT obrv.id_OBRV FROM 
    objetreseauVersion_OBRV obrv WHERE obrv.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null) 
    And obrv.IdOBR_OBRV in 
        (SELECT bra.id_BRA
            FROM 
              connexion_CNX cnx INNER JOIN
                dbo.V_Topo_Elec_Branche bra on bra.id_BRA = cnx.IdBRA_CNX inner join dbo.V_Topo_Elec_Composant cop on cnx.IdOBR_CNX = cop.id_COP
            WHERE
              cop.Code_NIV = 'MT'
              And bra.Code_ORC = 'BRVI'
              AND bra.code_NIV is null)
   )
GO

-- 4. Corriger le flux sur composants "non" manoeuvrables 
UPDATE copv
SET copv.EtatFlux_COPV = 1
FROM
  dbo.ComposantVersion_COPV copv inner join 
    dbo.ObjetReseauVersion_OBRV obrv ON OBRV.Id_OBRV = COPV.Id_OBRV inner join
      dbo.NObjetReseauClasse_ORC orc ON ORC.Id_ORC = OBRV.IdORC_OBRV
WHERE 
  obrv.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null) 
  And copv.EtatFlux_COPV != 1 
  And orc.Code_ORC in ('BARRE','BORNE','CEL','EPROD','PCX','TRF')
GO

EXEC dbo.PRC_Topology 
GO

-- SELECT * FROM [dbo].[V_ELEC_Noeud_Non_Alimente]



