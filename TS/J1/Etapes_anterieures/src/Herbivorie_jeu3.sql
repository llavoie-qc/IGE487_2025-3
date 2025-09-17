/*
////
-- =========================================================================== A
-- Herbivorie_jeu3.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.2a
Statut : applicable
Résumé : Jeu de données réaliste de moyenne envergure.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Ce jeu de données au jeu2 qui représente une saisie réaliste de petite envergure
dont les observations d’état ne sont pas encore disponibles. Le présent jeu3
*ajoute* des données fictives au jeu2 afin de faciliter certains tests.

L’initialisation comportera donc quatre parties :

 1. Les données issues du protocole expérimental
      (Etat, Peuplement, Taux, Arbre, Placette).
 2. Les observations recueillies par la suite sur le terrain.
      (Plant, ObsDimension, ObsFloraison, ObsEtat)
    ces dernières doivent être extraites des carnets de terrain.
 3. Ajout d’un plant et de dimensions hors norme.
 4. Ajout d’une placette hors norme et d’un plant mal étiquetté.

Les parties 1 et 2 sont dans le jeu2.
Les parties 3 et 4 sont dans le jeu3.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

--
-- Parties 1 et 2 - Insérer le jeu2 au préalable !
--

--
-- Partie 3
--
INSERT INTO plant (id, placette, parcelle, date, note) VALUES
  ('MMC5985', 'C5', 6, '2017-05-17', '');
INSERT INTO ObsDimension (id, longueur, largeur, date, note) VALUES
  ('MMC5985', 58, 62, '2017-05-08', ''),
  ('MMC5985', 68, 72, '2017-06-08', ''),
  ('MMC5985', 78, 82, '2017-07-08', ''),
  ('MMC5985', 88, 92, '2017-08-08', '');
INSERT INTO ObsDimension (id, longueur, largeur, date, note) VALUES
  ('MMA7092', 168, 120, '2017-07-12', 'Pour 6'),
  ('MMA7093', 180, 140, '2017-07-12', 'Pour 6');

--
-- Partie 4
--
INSERT INTO Plant (id, placette, parcelle, date, note) VALUES
  ('MMA9168', 'A1', 17, '2017-05-12', 'étiquette de plant non conforme à la parcelle');
-- Placette ajouter pour qu'il y ait un cas au no 7
INSERT INTO Placette VALUES
  ('A3', 'ERHE', 'E', 'E', 'F', 'F', 'D', 'A', 'D', 'F', 'C', 'ACESAC', 'FAGGRA', 'BETALL', '2017-07-25');

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
* [] {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_jeu3.sql
-- =========================================================================== Z
*/
