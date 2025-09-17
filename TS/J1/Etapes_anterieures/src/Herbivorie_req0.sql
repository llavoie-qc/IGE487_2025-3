/*
////
-- =========================================================================== A
-- Herbivorie_req0.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.2.0b
Statut : en cours de développement
Résumé : Groupe de requêtes applicables au schéma Herbivorie.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Ébauche de quelques requêtes simples

.Notes de mise en oeuvre
a. à compléter.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

-- R01.
-- Quels sont les plants ayant (eu) des feuilles dont les deux dimensions sont
-- supérieures à 150 mm ?
-- Donner l’étiquette (id) de chaque plant.
SELECT DISTINCT id
FROM ObsDimension
WHERE (longueur > 150) AND (largeur > 150)
;

-- R02.
-- Même requête qu’en R01.
-- Donner l’étiquette, la placette et la parcelle de chaque plant.


-- R03.
-- La troisième lettre et le premier chiffre de l’étiquette du plant doivent
-- normalement coïncider avec le code de la placette où est localisé le plant.
-- Quelles sont les exceptions ?
-- Donner l’étiquette, la placette et la parcelle de chaque exception.


-- R04.
-- Combien de plants y a-t-il dans la placette A1 ?
-- CLARIFICATION
-- Il faut dénombrer le nombre de plants distincts.


-- R05.
-- Combien de plants ont une obstruction latérale totale à 2 m de plus de 75% ?
-- Donner le nombre de plants.


-- R06.
-- R06.	Quels sont les plants localisés dans des placettes ayant une couverture
-- de mousses au sol d’au moins 50 % et qui ont été observés entre le 10 et le 17 juillet 2017 ?
-- Donner l’étiquette, la placette et la parcelle de chaque plant.


-- R07.
-- Quelles sont les placettes qui ont un plus grand taux d’obstruction latérale
-- totale à 2 m que les placettes qui ont un taux de couverture de mousse au sol
-- de moins de 50% ?
-- Donner le code de la placette et ses taux d’obstruction.


-- R08.
-- Soit k, la plus grande largeur de feuille parmi les plants dont la floraison
-- est antérieure au 18 mai 2017.
-- Quels sont les plants qui ne sont pas en floraison au 30 juin et dont la largeur
-- de feuilles est plus grande que k ?
-- Donner l’étiquette, la placette et la parcelle de chaque plant.


-- R09.
-- Quels sont les plants dont la largeur de la feuille a dépassé 100 mm avant
-- le 15 juin 2017, mais dont la floraison est postérieure au 2 juillet 2017 ?
-- Donner l’étiquette, la placette et la parcelle de chaque plant.


-- R10.
-- Deux plants sont semblables s’ils ont eu leur floraison initiale
-- à moins de 5 jours de distance et si le produit de leur longueur par leur largeur
-- diffère de moins de 10%.
-- Combien de plants semblables chacun des plants d’une parcelle donnée a-t-il
-- au sein de cette même parcelle ?
-- Pour chaque plant de la parcelle, donner l’étiquette, la placette, la parcelle,
-- la date de floraison initiale, le produit de la longueur par la largeur de feuille
-- et le nombre de plants semblables.

/*
-- =========================================================================== Z
////
.Contributeurs :
* (CK01) christina.khnaisser@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées :
* ...

.Tâches réalisées :
* 2017-09-24 LL01. Création
  - Version initiale.

.Références
* [EPP] {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
* [SML] {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_SML.pdf
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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_req0.sql
-- =========================================================================== Z
*/
