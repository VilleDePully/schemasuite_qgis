UPDATE Composition_CMP
SET RacineGuid_CMP = CAST(HASHBYTES('MD5', CAST(RacineGuid_CMP AS VARBINARY(16))) AS uniqueidentifier),
    Guid_CMP = NEWID()

UPDATE Connexion_CNX
SET RacineGuid_CNX =CAST(HASHBYTES('MD5', CAST(RacineGuid_CNX AS VARBINARY(16))) AS uniqueidentifier),
    Guid_CNX = NEWID()

UPDATE ObjetReseau_OBR
   SET Guid_OBR = NEWID();
UPDATE OBRV
   SET OBRV.RacineGuid_OBRV = OBR.Guid_OBR,
       OBRV.Guid_OBRV = NEWID()
  FROM ObjetReseauVersion_OBRV OBRV
  JOIN ObjetReseau_OBR OBR ON OBR.Id_OBR = OBRV.IdOBR_OBRV
UPDATE Schema_SCH
   SET Guid_SCH = NEWID();
UPDATE SCHV
   SET SCHV.RacineGuid_SCHV = SCH.Guid_SCH,
       SCHV.Guid_SCHV = NEWID()
  FROM SchemaVersion_SCHV SCHV
  JOIN Schema_SCH SCH ON SCH.Id_SCH = SCHV.IdSCH_SCHV