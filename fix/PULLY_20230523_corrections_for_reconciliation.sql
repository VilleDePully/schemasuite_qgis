 DELETE FROM Composition_CMP WHERE RacineGuid_CMP IN (
 SELECT RacineGuid_CMP
  FROM ObjetReseauVersion_OBRV
  JOIN Projet_PRJ ON Id_PRJ = IdPRJ_OBRV
  JOIN Composition_CMP CMP ON IdParent_CMP = IdOBR_OBRV AND IdPRJ_CMP IN (Id_PRJ, IdPRJ_PRJ)
   WHERE State_OBRV = 2
  GROUP BY RacineGuid_CMP
   HAVING SUM(State_CMP) < 2
   )

    DELETE FROM Composition_CMP WHERE RacineGuid_CMP IN (
 SELECT RacineGuid_CMP
  FROM ObjetReseauVersion_OBRV
  JOIN Projet_PRJ ON Id_PRJ = IdPRJ_OBRV
  JOIN Composition_CMP CMP ON IdEnfant_CMP = IdOBR_OBRV AND IdPRJ_CMP IN (Id_PRJ, IdPRJ_PRJ)
   WHERE State_OBRV = 2
  GROUP BY RacineGuid_CMP
   HAVING SUM(State_CMP) < 2
   )

 DELETE FROM Connexion_CNX WHERE RacineGuid_CNX IN (
 SELECT RacineGuid_CNX
  FROM ObjetReseauVersion_OBRV
  JOIN Projet_PRJ ON Id_PRJ = IdPRJ_OBRV
  JOIN Connexion_CNX CNX ON IdBRA_CNX = IdOBR_OBRV AND IdPRJ_CNX IN (Id_PRJ, IdPRJ_PRJ)
   WHERE State_OBRV = 2
  GROUP BY RacineGuid_CNX
   HAVING SUM(State_CNX) < 2
   )
 
 DELETE FROM Connexion_CNX WHERE RacineGuid_CNX IN (
 SELECT RacineGuid_CNX
  FROM ObjetReseauVersion_OBRV
  JOIN Projet_PRJ ON Id_PRJ = IdPRJ_OBRV
  JOIN Connexion_CNX CNX ON IdOBR_CNX = IdOBR_OBRV AND IdPRJ_CNX IN (Id_PRJ, IdPRJ_PRJ)
   WHERE State_OBRV = 2
  GROUP BY RacineGuid_CNX
   HAVING SUM(State_CNX) < 2
   )
