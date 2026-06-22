
/*
Sélection des fibres optiques d'un câble optique et de leur état, ainsi que du service associé à chaque fibre optique.
*/

CREATE OR ALTER VIEW [dbo].[vw_cable_et_fibre_optique] as 
SELECT        
  braT.IdParent_CMP AS id_CableOptique, 
  (SELECT Libelle_ETA FROM dbo.NEtat_ETA AS eta WHERE Id_ETA = ob.IdEtat_OBRV) AS EtatFibre,
  (SELECT nse.Nom_SRV FROM dbo.NService_SRV nse WHERE nse.Id_SRV = ob.IdSRV_OBRV ) AS [Service]
FROM            
  dbo.ObjetReseauVersion_OBRV AS cab INNER JOIN
  dbo.Composition_CMP AS braT ON cab.IdOBR_OBRV = braT.IdParent_CMP INNER JOIN
  dbo.Composition_CMP AS tubF ON braT.IdEnfant_CMP = tubF.IdParent_CMP AND braT.IdPRJ_CMP = tubF.IdPRJ_CMP INNER JOIN
  dbo.ObjetReseauVersion_OBRV AS ob ON tubF.IdEnfant_CMP = ob.IdOBR_OBRV AND ob.IdPRJ_OBRV = tubF.IdPRJ_CMP INNER JOIN
  dbo.BrancheVersion_BRAV AS bra ON ob.Id_OBRV = bra.Id_OBRV INNER JOIN
  dbo.FibreOptique_LWF AS fib ON ob.Id_OBRV = fib.Id_OBRV
WHERE
  cab.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null)
  And ob.IdPRJ_OBRV in (SELECT id_PRJ from Projet_PRJ WHERE IdPRJ_PRJ is null)
GO

CREATE OR ALTER VIEW [dbo].[vw_cable_et_fibre_optique_etat]
AS
SELECT 
  ROW_NUMBER( )     
  	OVER( ORDER BY id_CableOptique, cab.Nombre ) as ID,
cab.id_CableOptique, cab.EtatFibre, cab.Nombre, LTRIM(STR(cab.Nombre)) + ' Fibres' as NbFibres, LTRIM(STR(cab.Nombre/cab.NbFibDansCable * 100,3,0)) + '%' as PctFibres
FROM
(
SELECT v.id_CableOptique,  v.EtatFibre, CONVERT(float, v.Nombre) as Nombre, CONVERT(float, (SELECT COUNT(*) FROM vw_cable_et_fibre_optique c WHERE c.id_CableOptique = v.id_CableOptique)) as NbFibDansCable
FROM
  (
    SELECT
      id_CableOptique, EtatFibre, COUNT(*) as Nombre
    FROM 
      [dbo].[vw_cable_et_fibre_optique] 
    group by id_CableOptique, EtatFibre
  )v  
)cab
GO

CREATE OR ALTER VIEW [dbo].[vw_cable_et_fibre_optique_service]
AS
SELECT 
  ROW_NUMBER( )     
  	OVER( ORDER BY id_CableOptique, cab.Nombre ) as ID,
  cab.id_CableOptique, ISNULL(cab.[Service], 'Vide') as [Service], cab.Nombre, LTRIM(STR(cab.Nombre)) + ' Fibres' as NbFibres, LTRIM(STR(cab.Nombre/cab.NbFibDansCable * 100,3,0)) + '%' as PctFibres
FROM
(
SELECT v.id_CableOptique,  v.[Service], CONVERT(float, v.Nombre) as Nombre, CONVERT(float, (SELECT COUNT(*) FROM vw_cable_et_fibre_optique c WHERE c.id_CableOptique = v.id_CableOptique)) as NbFibDansCable
FROM
  (
    SELECT
      id_CableOptique, [Service], COUNT(*) as Nombre
    FROM 
      [dbo].[vw_cable_et_fibre_optique] 
    group by id_CableOptique, [Service]
  )v  
)cab
GO

SELECT * FROM vw_cable_et_fibre_optique_etat ORDER by id_CableOptique, nombre DESC
SELECT * FROM vw_cable_et_fibre_optique_service ORDER by id_CableOptique, nombre DESC
