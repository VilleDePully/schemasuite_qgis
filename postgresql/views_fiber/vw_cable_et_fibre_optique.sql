-- DROP VIEW export.vw_cable_et_fibre_optique;

CREATE OR REPLACE VIEW export.vw_cable_et_fibre_optique
 AS
 SELECT brat.idparent_cmp AS id_cableoptique,
    ( SELECT eta.libelle_eta
           FROM dbo.netat_eta eta
          WHERE eta.id_eta = ob.idetat_obrv) AS etatfibre,
    ( SELECT nse.nom_srv
           FROM dbo.nservice_srv nse
          WHERE nse.id_srv = ob.idsrv_obrv) AS service
   FROM dbo.objetreseauversion_obrv cab
     JOIN dbo.composition_cmp brat ON cab.idobr_obrv = brat.idparent_cmp
     JOIN dbo.composition_cmp tubf ON brat.idenfant_cmp = tubf.idparent_cmp AND brat.idprj_cmp = tubf.idprj_cmp
     JOIN dbo.objetreseauversion_obrv ob ON tubf.idenfant_cmp = ob.idobr_obrv AND ob.idprj_obrv = tubf.idprj_cmp
     JOIN dbo.brancheversion_brav bra ON ob.id_obrv = bra.id_obrv
     JOIN dbo.fibreoptique_lwf fib ON ob.id_obrv = fib.id_obrv
  WHERE (cab.idprj_obrv IN ( SELECT projet_prj.id_prj
           FROM dbo.projet_prj
          WHERE projet_prj.idprj_prj IS NULL)) 
  AND (ob.idprj_obrv IN ( SELECT projet_prj.id_prj
           FROM dbo.projet_prj
          WHERE projet_prj.idprj_prj IS NULL));
