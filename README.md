# [WIP] Projet de visualisation des données du réseau électrique sur QGIS ou pour export vers un géoportail

Ensemble de scripts et de ressources pour faciliter la visualisation et l'exploitation de données électriques saisies dans le logiciel SchemaSuite sur QGIS.

Ces scripts et ressources sont mises à disposition sans garantie ni support et sont actuellement uniquement conçus pour les besoins de la Ville de Pully.

Contenu des dossiers : (séparation postgreSQL et MSSQL en cours)

 - Mapped : tables nécessaires au mapping d'attributs
 - views : vues d'export pour la visualisation sur QGIS ou l'export vers un géoportail

 A venir :
 - Projet QGIS de base?
 - FME utilisés (copie 1:1 + réapplication des scripts .sql)?

## Fonctionnement :

1. La structure de base de données MSSQL est copiée en 1:1 vers postgis (schéma dbo)

2. Les schémas et tables nécessaires sont créés.

3. Les vues d'exports sont créées.

Certaines vues ont été transformées en vues matérialisées pour une meilleure performance.

Ceci est du Work In Progress (WIP) 

![Exemple de rendu : cadastre électrique](images/qgis/Cadastre_electrique.png?raw=true "Exemple de rendu : cadastre électrique")
