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

Liste des objets exportés actuellement

 - armoires
 - armoires_projet
 - cables
 - cables_projet
 - candelabres
 - candelabres_projet
 - chambres
 - chambres_projet
 - coffrets
 - coffrets_projet
 - constructions_genie_civil
 - constructions_genie_civil_projet
 - coupe_text_cables
 - coupe_text_cables_projet
 - coupe_text_elements
 - coupe_text_num_tubes
 - coupe_text_num_tubes_projet
 - coupe_text_troncon
 - coupe_text_troncon_projet
 - coupe_text_tubes
 - coupe_text_tubes_projet
 - coupes_cables
 - coupes_cables_geom
 - coupes_cables_projet
 - coupes_cables_projet_geom
 - coupes_traces
 - coupes_traces_geom
 - coupes_traces_projet
 - coupes_traces_projet_geom
 - coupes_tubes
 - coupes_tubes_geom
 - coupes_tubes_projet
 - coupes_tubes_projet_geom
 - elements_production_projet
 - elements_production
 - manchons
 - manchons_projet
 - stations
 - traces
 - traces_projet
 - tubes
 - tubes_projet
 - zones_fouille
 - zones_fouille_projet
 - zones_projets

![Exemple de rendu : cadastre électrique](images/qgis/Cadastre_electrique.png?raw=true "Exemple de rendu : cadastre électrique")
