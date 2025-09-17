/*
////
-- =========================================================================== A
-- Meteo_req4.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2022-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : en cours de développement
Résumé : Test minimaliste d’importation des carnets météorologiques.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Test minimaliste d’importation des carnets météorologiques dans la base de données.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

-- Vider les tables du contenu des précédents essais
delete from ObsTemperature ;
delete from ObsHumidite ;
delete from ObsPrecipitations ;
delete from ObsVents ;
delete from ObsPression ;
delete from CarnetMeteo ;

-- Ajouter les données au carnet météorologique (remarquons la conversion implicite des données numériques!!!)
insert into CarnetMeteo values
  (10, 14, 18, 24, 0, 'P', 4, 20, 1028, 1030, '2016-05-04', 'départ'),
  (10, 14, 18, 24, null, null, 4, 20, 1028, 1030, '2016-05-05', 'comme hier'),
  (10, 14, 18, 24, null, null, 4, 20, 1028, 1030, '2015-05-05', 'refus d'),
  (10, 65, -2, 24, 10, 'K', 4, 2000, 1028, 2000, '2016-07-05', 'refus m'),
  (12, 15, 24, 30, 1, 'P', 8, 10, 1026, 1028, '2016-05-06', 'fin');

-- Faire l’importation
call Meteo_ELT () ;

-- Fin

/*
-- =========================================================================== Z
////
.Contributeurs
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-01-23 LL01. Enrichier

.Tâches réalisées
* 2022-01-23 LL01. Création.

.Références
* {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
////

.Adresse, droits d’auteur et copyright
  Groupe Metis
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

-- -----------------------------------------------------------------------------
-- fin de {CoFELI}/Exemple/Herbivorie/src/Meteo_req4.sql
-- =========================================================================== Z
*/
