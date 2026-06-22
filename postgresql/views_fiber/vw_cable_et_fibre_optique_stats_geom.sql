-- DROP VIEW export.vw_cable_et_fibre_optique_stats_geom;

CREATE OR REPLACE VIEW export.vw_cable_et_fibre_optique_stats_geom
 AS
 SELECT brfv.idobr_brfv AS id_cableoptique,
    st_force2d(brfv.the_geom)::geometry(LineString,2056) AS the_geom,
    tot.total_fibres,
    etat.label_etats,
    srv.label_services
   FROM dbo.branchefeatureversion_brfv brfv
     LEFT JOIN ( SELECT v.id_cableoptique,
            count(*) AS total_fibres
           FROM export.vw_cable_et_fibre_optique v
          GROUP BY v.id_cableoptique) tot ON tot.id_cableoptique = brfv.idobr_brfv
     LEFT JOIN ( SELECT e.id_cableoptique,
            string_agg(((e.etatfibre::text || ' - '::text) || e.nb) || ' fibres'::text, '
'::text ORDER BY e.nb DESC) AS label_etats
           FROM ( SELECT v.id_cableoptique,
                    v.etatfibre,
                    count(*) AS nb
                   FROM export.vw_cable_et_fibre_optique v
                  GROUP BY v.id_cableoptique, v.etatfibre) e
          GROUP BY e.id_cableoptique) etat ON etat.id_cableoptique = brfv.idobr_brfv
     LEFT JOIN ( SELECT s.id_cableoptique,
            string_agg(((s.service::text || ' - '::text) || s.nb) || ' fibres'::text, '
'::text ORDER BY s.nb DESC) AS label_services
           FROM ( SELECT v.id_cableoptique,
                    COALESCE(v.service, 'vide'::character varying) AS service,
                    count(*) AS nb
                   FROM export.vw_cable_et_fibre_optique v
                  GROUP BY v.id_cableoptique, (COALESCE(v.service, 'vide'::character varying))) s
          GROUP BY s.id_cableoptique) srv ON srv.id_cableoptique = brfv.idobr_brfv
  WHERE brfv.idprj_brfv = 67;