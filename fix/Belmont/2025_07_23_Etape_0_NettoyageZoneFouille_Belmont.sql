DELETE FROM NObjetReseauClasse_ORC 
WHERE EXISTS(SELECT c.id_ORC from NObjetReseauClasse_ORC c WHERE c.Code_ORC = NObjetReseauClasse_ORC.Code_ORC And c.Id_ORC<NObjetReseauClasse_ORC.Id_ORC)
GO

-- Effacer tous les tracés vides de moins de 1m
BEGIN
  DECLARE @idObj int
  
  DECLARE curSTrc CURSOR LOCAL READ_ONLY STATIC FOR
    SELECT Obj.IdOBR_OBRV FROM dbo.ObjetReseauVersion_OBRV Obj inner join dbo.TraceFeatureVersion_TRAV Tra on Tra.IdPRJ_TRAV = Obj.IdPRJ_OBRV And Tra.IdOBR_TRAV = Obj.IdOBR_OBRV
    WHERE Tra.Geometry_TRAV.STLength() < 1 And NOT EXISTS(SELECT idEnfant_CMP FROM dbo.Composition_CMP Com WHERE Com.IdParent_CMP = obj.IdOBR_OBRV And Com.IdPRJ_CMP = Obj.IdPRJ_OBRV)
  
  OPEN curSTrc
  FETCH NEXT FROM curSTrc INTO @idObj
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC SP_DeleteNetworkObject @idObj
    FETCH NEXT FROM curSTrc INTO @idObj
  END
  CLOSE curSTrc
  DEALLOCATE curSTrc
END
GO

  

TRUNCATE TABLE zsysIncludeTKR_ZIK
GO

-- Armoire/station/Chambre dans Armoire/station/Chambre
BEGIN
  DECLARE @gRoom geometry, @idR int
  DECLARE cursG CURSOR LOCAL READ_ONLY
  FOR 
    SELECT n.IdOBR_NDFV, n.Geometry_NDFV
    FROM 
      dbo.NoeudFeatureVersion_NDFV n inner join 
        dbo.ObjetReseauVersion_OBRV obr ON OBR.IdOBR_OBRV = n.IdOBR_NDFV And n.IdPRJ_NDFV = obr.IdPRJ_OBRV inner join 
          dbo.NObjetReseauClasse_ORC orc on orc.Id_ORC = obr.IdORC_OBRV
    WHERE 
      n.IdSCH_NDFV = 1 And
      orc.Code_ORC in ('STMT', 'ADBT', 'TKR') And 
      (obr.IdEtat_OBRV is null Or obr.IdEtat_OBRV not in (SELECT id_ETA FROM NEtat_ETA WHERE Code_ETA = '1006')) And
      n.IdPRJ_NDFV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is null) And
      -- pas dans un projet
      obr.IdOBR_OBRV not in (SELECT IdOBR_OBRV FROM ObjetReseauVersion_OBRV WHERE IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))
    
  OPEN cursG
  FETCH NEXT FROM cursG INTO @idR, @gRoom
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO zsysIncludeTKR_ZIK (idOBRParent_ZIK,idOBREnfant_ZIK) 
    SELECT @idR, n.IdOBR_NDFV 
      FROM NoeudFeatureVersion_NDFV n inner join 
        dbo.ObjetReseauVersion_OBRV obr ON OBR.IdOBR_OBRV = n.IdOBR_NDFV and obr.IdPRJ_OBRV = n.IdPRJ_NDFV inner join 
          NObjetReseauClasse_ORC orc on orc.Id_ORC = obr.IdORC_OBRV
    WHERE 
      n.IdSCH_NDFV = 1 And
      n.IdOBR_NDFV != @idR And
      orc.Code_ORC in ('STMT', 'ADBT', 'TKR') And 
      (obr.IdEtat_OBRV is null or obr.IdEtat_OBRV not in (SELECT id_ETA FROM NEtat_ETA WHERE Code_ETA = '1006')) And
      n.IdPRJ_NDFV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is null) And
      @gRoom.STContains(Geometry_NDFV) != 0 And
      -- pas dans un projet
      obr.IdOBR_OBRV not in (SELECT opr.IdOBR_OBRV FROM ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))

    FETCH NEXT FROM cursG INTO @idR, @gRoom
  END
  
  CLOSE cursG
  DEALLOCATE cursG
END
GO

-- Traiter les armoires "doubles": l'armoire intérieure est conservée
-- On traite les cas ou la forme est "sensiblement" la même 
--   Une seule chambre intérieure
--   Forme avec nombre de points semblable: polygone simple ou cercle
--   On élimine les cas ou la chambre interne est une "fausse" zone de fouille (<15% de la surface de la grande)
--   

BEGIN
  DECLARE @idTkrToDel int, @idTkrToKeep int
  DECLARE cursTkr CURSOR LOCAL READ_ONLY FOR
    SELECT v.idOBRParent_ZIK, v.idOBREnfant_ZIK
    FROM
    (
    SELECT 
      zik.idOBRParent_ZIK, 
      (SELECT n.Geometry_NDFV.STNumPoints() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBRParent_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as NbPointPolygonParent,
      (SELECT n.Geometry_NDFV.STArea() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBRParent_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as AreaParent,
      zik.idOBREnfant_ZIK,
      (SELECT n.Geometry_NDFV.STNumPoints() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBREnfant_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as NbPointPolygonEnfant,
      (SELECT n.Geometry_NDFV.STArea() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBREnfant_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as AreaEnfant
    FROM 
      zsysIncludeTKR_ZIK zik inner join 
        ObjetReseauVersion_OBRV par on zik.idOBRParent_ZIK = par.IdOBR_OBRV inner join 
          ObjetReseauVersion_OBRV enf on zik.idOBREnfant_ZIK = enf.idOBR_OBRV
    WHERE 
      enf.idPRJ_OBRV = par.IdPRJ_OBRV And
      par.IdORC_OBRV = enf.IdORC_OBRV 
      And zik.idOBRParent_ZIK in 
      ( SELECT z.idOBRParent_ZIK FROM zsysIncludeTKR_ZIK z GROUP BY z.idOBRParent_ZIK HAVING COUNT(*) = 1)
    ) v  
    WHERE 
      ((v.NbPointPolygonParent > 10 And v.NbPointPolygonEnfant > 10) or
       (v.NbPointPolygonParent <= 10 And v.NbPointPolygonEnfant <= 10))  
      And 100*AreaEnfant/AreaParent > 15 
      And idOBREnfant_ZIK not in 
      (
    SELECT v.idOBRParent_ZIK
    FROM
    (
    SELECT 
      zik.idOBRParent_ZIK, 
      (SELECT n.Geometry_NDFV.STNumPoints() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBRParent_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as NbPointPolygonParent,
      (SELECT n.Geometry_NDFV.STArea() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBRParent_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as AreaParent,
      zik.idOBREnfant_ZIK,
      (SELECT n.Geometry_NDFV.STNumPoints() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBREnfant_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as NbPointPolygonEnfant,
      (SELECT n.Geometry_NDFV.STArea() FROM NoeudFeatureVersion_NDFV n WHERE n.IdSCH_NDFV = 1 And n.IdOBR_NDFV =  zik.idOBREnfant_ZIK And n.IdPRJ_NDFV = par.IdPRJ_OBRV) as AreaEnfant
    FROM 
      zsysIncludeTKR_ZIK zik inner join 
        ObjetReseauVersion_OBRV par on zik.idOBRParent_ZIK = par.IdOBR_OBRV inner join 
          ObjetReseauVersion_OBRV enf on zik.idOBREnfant_ZIK = enf.idOBR_OBRV
    WHERE 
      enf.idPRJ_OBRV = par.IdPRJ_OBRV And
      par.IdORC_OBRV = enf.IdORC_OBRV 
      And zik.idOBRParent_ZIK in 
      ( SELECT z.idOBRParent_ZIK FROM zsysIncludeTKR_ZIK z GROUP BY z.idOBRParent_ZIK HAVING COUNT(*) = 1)
    ) v  
    WHERE 
      ((v.NbPointPolygonParent > 10 And v.NbPointPolygonEnfant > 10) or
       (v.NbPointPolygonParent <= 10 And v.NbPointPolygonEnfant <= 10))  
      And 100*AreaEnfant/AreaParent > 15
    )
  OPEN cursTkr
  FETCH NEXT FROM cursTkr INTO @idTkrToDel, @idTkrToKeep
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC dbo.sp_ReplaceManhole @idTkrToDel, @idTkrToKeep, 1
    FETCH NEXT FROM cursTkr INTO @idTkrToDel, @idTkrToKeep
  END
  CLOSE cursTkr
  DEALLOCATE cursTkr
END
GO

--SELECT * FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = -1

-- ZFL inclus TKR
BEGIN
  DECLARE @gRoom geometry, @idR int
  DECLARE cursG CURSOR LOCAL READ_ONLY
  FOR 
    SELECT n.IdOBR_NDFV, ISNULL(v.GEOM_ZIK, n.Geometry_NDFV)
    FROM 
      dbo.NoeudFeatureVersion_NDFV n inner join 
        dbo.ObjetReseauVersion_OBRV obr ON OBR.IdOBR_OBRV = n.IdOBR_NDFV and obr.IdPRJ_OBRV = n.IdPRJ_NDFV inner join 
          dbo.NObjetReseauClasse_ORC orc on orc.Id_ORC = obr.IdORC_OBRV left outer join 
            (SELECT idOBREnfant_ZIK, GEOM_ZIK FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = -1)v on obr.IdOBR_OBRV = v.idOBREnfant_ZIK
    WHERE 
      n.IdSCH_NDFV = 1 And
      orc.Code_ORC in ('STMT', 'ADBT', 'TKR') And 
      (obr.IdEtat_OBRV is null or obr.IdEtat_OBRV not in (SELECT id_ETA FROM NEtat_ETA WHERE Code_ETA = '1006')) And
      n.IdPRJ_NDFV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is null) And
      n.IdOBR_NDFV not in (SELECT idOBREnfant_ZIK FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = 0) And
      obr.IdOBR_OBRV not in (SELECT opr.IdOBR_OBRV FROM ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))

  
  OPEN cursG
  FETCH NEXT FROM cursG INTO @idR, @gRoom
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO zsysIncludeTKR_ZIK (idOBRParent_ZIK,idOBREnfant_ZIK, type_ZIK) 
    SELECT @idR, n.IdOBR_NPFV, 1
      FROM NoeudConnectionPointFeatureVersion_NPFV n inner join 
        dbo.ObjetReseauVersion_OBRV obr ON OBR.IdOBR_OBRV = n.IdOBR_NPFV And n.IdPRJ_NPFV = obr.IdPRJ_OBRV inner join 
          NObjetReseauClasse_ORC orc on orc.Id_ORC = obr.IdORC_OBRV
    WHERE 
      n.IdSCH_NPFV = 1 And
      n.IdOBR_NPFV != @idR And
--      (orc.Code_ORC = 'ZFL' or (orc.Code_ORC = 'TKR' And obr.IdEtat_OBRV = (SELECT id_ETA FROM NEtat_ETA Where Libelle_ETA = 'Fictif')))  And 
      (orc.Code_ORC = 'ZFL' or (orc.Code_ORC = 'TKR' And obr.IdEtat_OBRV in (SELECT id_ETA FROM NEtat_ETA WHERE Code_ETA = '1006'))) And 
      n.IdPRJ_NPFV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is null) And
      @gRoom.STContains(Geometry_NPFV) != 0 And
      obr.IdOBR_OBRV not in (SELECT opr.IdOBR_OBRV FROM ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))
    FETCH NEXT FROM cursG INTO @idR, @gRoom
  END
  
  CLOSE cursG
  DEALLOCATE cursG
END
GO

-- TODO / FROM there Etape 1 - Tester sur toutes les chambres concernées (uniquement "inclus" dans la chambre)
BEGIN
  DECLARE @idTKR int

  TRUNCATE TABLE zzzTmpAction_ZAC
  
  DECLARE cursTkr CURSOR LOCAL READ_ONLY FOR
    SELECT  DISTINCT
      idObrParent_ZIK
    FROM 
      dbo.zsysIncludeTKR_ZIK z
    Where z.type_ZIK = 1 And
      -- on ne prend que les chambres contentant des ZFL qui ne sont pas incluse dans une autre chambre   
      idOBREnfant_ZIK in (SELECT idOBREnfant_ZIK FROM zsysIncludeTKR_ZIK WHERE type_ZIK = 1 GROUP BY idOBREnfant_ZIK HAVING COUNT(*) = 1)
  OPEN cursTkr
  FETCH NEXT FROM cursTkr INTO @idTkr
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC dbo.sp_CleanManhole @idTKR, -1
    FETCH NEXT FROM cursTkr INTO @idTkr
  END
  CLOSE cursTkr
  DEALLOCATE cursTkr
END
GO


DELETE FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = 1
GO


-- Phase 2 / Inclus et Proche
BEGIN
  DECLARE @gRoom geometry, @idR int
  DECLARE cursG CURSOR LOCAL READ_ONLY
  FOR 
    SELECT n.IdOBR_NDFV , ISNULL(v.GEOM_ZIK, n.Geometry_NDFV)
    FROM 
      dbo.NoeudFeatureVersion_NDFV n inner join 
        dbo.ObjetReseauVersion_OBRV obr ON OBR.IdOBR_OBRV = n.IdOBR_NDFV and obr.IdPRJ_OBRV = n.IdPRJ_NDFV inner join 
          dbo.NObjetReseauClasse_ORC orc on orc.Id_ORC = obr.IdORC_OBRV left outer join 
            (SELECT idOBREnfant_ZIK, GEOM_ZIK FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = -1)v on obr.IdOBR_OBRV = v.idOBREnfant_ZIK
    WHERE 
      n.IdSCH_NDFV = 1 And
      orc.Code_ORC in ('STMT', 'ADBT', 'TKR') And 
      (obr.IdEtat_OBRV is null or obr.IdEtat_OBRV not in (SELECT id_ETA FROM NEtat_ETA WHERE Code_ETA = '1006')) And
      n.IdPRJ_NDFV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is null) And
      n.IdOBR_NDFV not in (SELECT idOBREnfant_ZIK FROM dbo.zsysIncludeTKR_ZIK WHERE type_ZIK = 0) And
      obr.IdOBR_OBRV not in (SELECT opr.IdOBR_OBRV FROM ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))

  
  OPEN cursG
  FETCH NEXT FROM cursG INTO @idR, @gRoom
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO zsysIncludeTKR_ZIK (idOBRParent_ZIK,idOBREnfant_ZIK, type_ZIK) 
    SELECT @idR, n.IdOBR_NPFV, 1
      FROM NoeudConnectionPointFeatureVersion_NPFV n inner join 
        dbo.ObjetReseauVersion_OBRV obr ON OBR.IdOBR_OBRV = n.IdOBR_NPFV And n.IdPRJ_NPFV = obr.IdPRJ_OBRV inner join 
          NObjetReseauClasse_ORC orc on orc.Id_ORC = obr.IdORC_OBRV
    WHERE 
      n.IdSCH_NPFV = 1 And
      n.IdOBR_NPFV != @idR And
--      (orc.Code_ORC = 'ZFL' or (orc.Code_ORC = 'TKR' And obr.IdEtat_OBRV = (SELECT id_ETA FROM NEtat_ETA Where Libelle_ETA = 'Fictif')))  And 
      (orc.Code_ORC = 'ZFL' or (orc.Code_ORC = 'TKR' And obr.IdEtat_OBRV in (SELECT id_ETA FROM NEtat_ETA WHERE Code_ETA = '1006'))) And 
      n.IdPRJ_NPFV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is null) And
-- *************************
      @gRoom.STDistance(Geometry_NPFV) < 0.1 And
-- *************************
      obr.IdOBR_OBRV not in (SELECT opr.IdOBR_OBRV FROM ObjetReseauVersion_OBRV opr WHERE opr.IdPRJ_OBRV in (SELECT id_PRJ FROM Projet_PRJ WHERE IdPRJ_PRJ Is not null))
    FETCH NEXT FROM cursG INTO @idR, @gRoom
  END
  
  CLOSE cursG
  DEALLOCATE cursG
END
GO



-- Etape 2 - Tester sur toutes les chambres proches
BEGIN
  DECLARE @idTKR int

  TRUNCATE TABLE zzzTmpAction_ZAC
  
  DECLARE cursTkr CURSOR LOCAL READ_ONLY FOR
    SELECT  DISTINCT
      idObrParent_ZIK
    FROM 
      dbo.zsysIncludeTKR_ZIK z
    Where z.type_ZIK = 1 And
      -- on ne prend que les chambres contentant des ZFL qui ne sont pas incluse dans une autre chambre   
      idOBREnfant_ZIK in (SELECT idOBREnfant_ZIK FROM zsysIncludeTKR_ZIK WHERE type_ZIK = 1 GROUP BY idOBREnfant_ZIK HAVING COUNT(*) = 1)
  OPEN cursTkr
  FETCH NEXT FROM cursTkr INTO @idTkr
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC dbo.sp_CleanManhole @idTKR, 0.1
    FETCH NEXT FROM cursTkr INTO @idTkr
  END
  CLOSE cursTkr
  DEALLOCATE cursTkr
END
GO



