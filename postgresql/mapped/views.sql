DROP VIEW IF EXISTS mapped.vw_noeuds CASCADE;

CREATE VIEW mapped.vw_noeuds as
	SELECT * FROM mapped.e_dic_tb2_schemasuite
	WHERE classe_tb2 = 'EW_KNOTEN'
	ORDER BY idobr_schemasuite ASC;

DROP VIEW IF EXISTS mapped.vw_traces CASCADE;

CREATE VIEW mapped.vw_traces as
	SELECT * FROM mapped.e_dic_tb2_schemasuite
	WHERE classe_tb2 = 'EW_TRASSEABS'
	ORDER BY idobr_schemasuite ASC;

DROP VIEW IF EXISTS mapped.vw_tubes CASCADE;

CREATE VIEW mapped.vw_tubes as
	SELECT * FROM mapped.e_dic_tb2_schemasuite
	WHERE classe_tb2 = 'EW_TRAEGER'
	ORDER BY idobr_schemasuite ASC;

DROP VIEW IF EXISTS mapped.vw_cables CASCADE;

CREATE VIEW mapped.vw_cables as
	SELECT * FROM mapped.e_dic_tb2_schemasuite
	WHERE classe_tb2 = 'EW_LEITUNGSABS'
	ORDER BY idobr_schemasuite ASC;