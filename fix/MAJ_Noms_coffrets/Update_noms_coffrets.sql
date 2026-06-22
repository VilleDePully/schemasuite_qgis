UPDATE cof
  SET cof.Nom_OBRV  = msn.Nom_OBRV
FROM 
  dbo.ObjetReseauVersion_OBRV cof INNER JOIN 
  dbo.NObjetReseauClasse_ORC nob ON nob.Id_ORC = cof.IdORC_OBRV INNER JOIN 
  dbo.Composition_CMP cmp on cmp.IdEnfant_CMP = cof.IdOBR_OBRV AND cmp.IdPRJ_CMP = cof.IdPRJ_OBRV INNER JOIN  
  dbo.ObjetReseauVersion_OBRV msn on cmp.IdParent_CMP = msn.IdOBR_OBRV AND cmp.IdPRJ_CMP = msn.IdPRJ_OBRV INNER JOIN 
  dbo.NObjetReseauClasse_ORC nobM ON nobM.Id_ORC = msn.IdORC_OBRV
WHERE 
  nob.Code_ORC = 'COBT'          
  AND (cof.Nom_OBRV IS NULL OR (cof.Nom_OBRV != msn.Nom_OBRV))