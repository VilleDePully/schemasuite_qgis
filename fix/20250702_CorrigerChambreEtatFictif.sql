
 BEGIN
  DECLARE @parts TABLE (
      idOBR INT,
      newGeom geometry
  );
  
  INSERT INTO @parts(idObr, newGeom)
  SELECT
    Obj.IdOBR_OBRV,
    geometry::STGeomFromText 
      ('POLYGON((' + 
        LTRIM(STR(Noe.Geometry_NPFV.STX - cos(PI()/4) * 0.2,15,3)) + ' ' + LTRIM(STR(Noe.Geometry_NPFV.STY,15,3)) + ', ' +
        LTRIM(STR(Noe.Geometry_NPFV.STX,15,3)) + ' ' + LTRIM(STR(Noe.Geometry_NPFV.STY + 0.2 * sin(PI()/4),15,3)) + ', ' +
        LTRIM(STR(Noe.Geometry_NPFV.STX + cos(PI()/4) * 0.2,15,3)) + ' ' + LTRIM(STR(Noe.Geometry_NPFV.STY,15,3)) + ', ' +
        LTRIM(STR(Noe.Geometry_NPFV.STX ,15,3)) + ' ' + LTRIM(STR(Noe.Geometry_NPFV.STY - 0.2 * sin(PI()/4),15,3)) + ', ' +
        LTRIM(STR(Noe.Geometry_NPFV.STX - cos(PI()/4) * 0.2,15,3)) + ' ' + LTRIM(STR(Noe.Geometry_NPFV.STY,15,3)) + '))', 2056)
  FROM 
    dbo.ObjetReseauVersion_OBRV Obj inner join 
      dbo.NEtat_ETA NEt on Obj.IdEtat_OBRV = NEt.Id_ETA inner join
        dbo.NoeudConnectionPointFeatureVersion_NPFV Noe on Obj.IdOBR_OBRV = Noe.IdOBR_NPFV and Obj.IdPRJ_OBRV = Noe.IdPRJ_NPFV inner join 
          dbo.Chambre_TKR Cha on Obj.Id_OBRV = Cha.Id_OBRV
  WHERE
    Obj.Modele_OBRV is null And
    ((Cha.Hauteur_TKR is null and Cha.Largeur_TKR is null) or
     (abs(Cha.Hauteur_TKR-1) <= 0.001 and Abs(Cha.Largeur_TKR-1) <= 0.001)) And
    NEt.Libelle_ETA = N'Fictif'
    And Obj.IdPRJ_OBRV = 1   
  
  UPDATE noe
    SET noe.Geometry_NDFV = p.newGeom
  FROM
    dbo.NoeudFeatureVersion_NDFV noe inner join @parts p on p.idObr = noe.idOBR_NDFV
  
  UPDATE dbo.ObjetReseauVersion_OBRV
    SET modele_OBRV = 'Chambre fictive', guid_ORM = (SELECT mo.guid_ORM FROM dbo.ObjetReseauModele_ORM mo WHERE mo.Nom_ORM = 'Chambre fictive')
  WHERE IdOBR_OBRV in (SELECT idObr FROM @parts)
  
  UPDATE dbo.Chambre_TKR
    set Hauteur_TKR = 0.2, Largeur_TKR = 0.2
  WHERE Id_OBRV in (SELECT obj.id_OBRV FROM dbo.ObjetReseauVersion_OBRV Obj WHERE Obj.IdOBR_OBRV in (SELECT idObr FROM @parts))

END
GO