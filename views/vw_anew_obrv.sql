DROP VIEW IF EXISTS export.vw__new_obrv;

CREATE OR REPLACE VIEW export.vw__new_obrv AS

SELECT 	objetreseauversion_obrv.idobr_obrv as idobr_obrv, 
		count(*) > 1 as existant

FROM dbo.objetreseauversion_obrv

GROUP BY objetreseauversion_obrv.idobr_obrv

HAVING count(*) > 1;