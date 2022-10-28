
/* OLD
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

OLD */
/************ NEW****************************/

ALTER TABLE dbo.branchefeatureversion_brfv ALTER COLUMN the_geom SET DATA TYPE geometry(LineStringZ, 2056);
ALTER TABLE dbo.brancheschemafeatureversion_bsfv ALTER COLUMN the_geom SET DATA TYPE geometry(LineString, 2056);
ALTER TABLE dbo.conduitefeatureversion_cofv ALTER COLUMN the_geom SET DATA TYPE geometry(LineStringZ, 2056);
ALTER TABLE dbo.coupefeatureversion_cupv ALTER COLUMN the_geom SET DATA TYPE geometry(Polygon, 2056);
UPDATE dbo.coupelinkfeatureversion_kyfv  SET the_geom = ST_MULTI(the_geom);
ALTER TABLE dbo.coupelinkfeatureversion_kyfv ALTER COLUMN the_geom SET DATA TYPE geometry(MultiLineString, 2056);
ALTER TABLE dbo.coupetextfeatureversion_ctfv ALTER COLUMN the_geom SET DATA TYPE geometry(LineString, 2056);
ALTER TABLE dbo.externalnoeudfeatureversion_enfv ALTER COLUMN the_geom SET DATA TYPE geometry(Polygon, 2056);
ALTER TABLE dbo.graphiquefeatureversion_gqtv ALTER COLUMN the_geom SET DATA TYPE geometry(Point, 2056);
ALTER TABLE dbo.noeudconnectionpointfeatureversion_npfv ALTER COLUMN the_geom SET DATA TYPE geometry(Point, 2056);
ALTER TABLE dbo.noeudfeatureversion_ndfv ALTER COLUMN the_geom SET DATA TYPE geometry(Polygon, 2056);
ALTER TABLE dbo.tracefeatureversion_trav ALTER COLUMN the_geom SET DATA TYPE geometry(LineString, 2056);
