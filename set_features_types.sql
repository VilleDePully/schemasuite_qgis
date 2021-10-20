-- Branches câbles et noeuds

ALTER TABLE dbo.tracefeatureversion_trav
ALTER COLUMN the_geom SET DATA TYPE geometry(LineStringZ, 2056);

ALTER TABLE dbo.branchefeatureversion_brfv
ALTER COLUMN the_geom SET DATA TYPE geometry(LineStringZ, 2056);

--ALTER TABLE dbo.cablefeatureversion_cafv
--ALTER COLUMN the_geom SET DATA TYPE geometry(LineStringZ, 2056);

ALTER TABLE dbo.conduitefeatureversion_cofv
ALTER COLUMN the_geom SET DATA TYPE geometry(LineStringZ, 2056);

-- Noeuds et Polygones

ALTER TABLE dbo.noeudfeatureversion_ndfv
ALTER COLUMN the_geom SET DATA TYPE geometry(Polygon, 2056);

ALTER TABLE dbo.externalnoeudfeatureversion_enfv
ALTER COLUMN the_geom SET DATA TYPE geometry(PolygonZ, 2056);

-- Coupes

ALTER TABLE dbo.coupefeatureversion_cupv
ALTER COLUMN the_geom SET DATA TYPE geometry(PolygonZ, 2056);

--ALTER TABLE dbo.coupelinkfeatureversion_kyfv
--ALTER COLUMN the_geom SET DATA TYPE geometry(LineString, 2056);

ALTER TABLE dbo.coupetextfeatureversion_ctfv
ALTER COLUMN the_geom SET DATA TYPE geometry(PointZ, 2056);

