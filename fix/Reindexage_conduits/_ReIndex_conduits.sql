DECLARE @TraceVersionRootId integer
DECLARE traces_with_conduits CURSOR LOCAL
   FOR SELECT DISTINCT(Id_OBR)
         FROM Composition_CMP AS CMP
         JOIN ObjetReseau_OBR ON Id_OBR = IdParent_CMP
         JOIN NObjetReseauClasse_ORC ON Id_ORC = IdORC_OBR
        WHERE Code_ORC = 'TRC'

OPEN traces_with_conduits;
FETCH NEXT FROM traces_with_conduits INTO @TraceVersionRootId
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Re-indexing conduits for trace ' + CONVERT(varchar(100), @TraceVersionRootId)
		EXEC SP_ReIndexConduits @TraceVersionRootId
		FETCH NEXT FROM traces_with_conduits INTO @TraceVersionRootId;
	END;
CLOSE traces_with_conduits;
DEALLOCATE traces_with_conduits;
