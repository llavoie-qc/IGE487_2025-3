/*
////
-- =========================================================================== A
-- Herbivorie_drop.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : applicable
Résumé : Suppression du contenu (types et tables) du schéma.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Élimination des définitions de domaines, de types, de tables et de procédures à
l’exception des carnets d’observations.

.Notes de mise en oeuvre
a. Aucune.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

--
-- Élimination
--
DROP TABLE ObsDimension CASCADE ;
DROP TABLE ObsFloraison CASCADE ;
DROP TABLE ObsEtat CASCADE ;
DROP TABLE Plant CASCADE ;
DROP TABLE Placette CASCADE ;
DROP TABLE Etat CASCADE ;
DROP TABLE Taux CASCADE ;
DROP TABLE Peuplement CASCADE ;
DROP TABLE Arbre CASCADE ;

DROP DOMAIN Arbre_id CASCADE;
DROP DOMAIN Date_eco CASCADE;
DROP DOMAIN Description CASCADE;
DROP DOMAIN Dim_mm CASCADE;
DROP DOMAIN Etat_id CASCADE;
DROP DOMAIN Plant_id CASCADE;
DROP DOMAIN Parcelle CASCADE;
DROP DOMAIN Peuplement_id CASCADE;
DROP DOMAIN Placette_id CASCADE;
DROP DOMAIN Taux_id CASCADE;
DROP DOMAIN Taux_val CASCADE;

/*
-- =========================================================================== Z
////
.Contributeurs
* (DAL) diane.auberson-lavoie@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-01-30 LL01. Évolution
  - Maintenir le script au fil de l’évolution de Herbivorie_cre.sql

.Tâches réalisées
* 2025-01-26 LL01. Adaptation au standard de programmation de CoFELI.
  - Mise en forme des commentaires externes en AsciiDoc.
* 2017-09-17 LL01. Création
  - Version initiale.

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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_drop.sql
-- =========================================================================== Z
*/
