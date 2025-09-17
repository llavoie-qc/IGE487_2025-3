/*
////
-- =========================================================================== A
-- Herbivorie_req3.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.2.0c
Statut : solutionnaire préliminaire
Résumé : Groupe de requêtes applicables au schéma Herbivorie.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Quelques requêtes de groupement, de quantification et d'ordonnancement.

.Notes de mise en oeuvre
a.  aucune.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

-- X01.
-- Calculer le nombre de plants par placette.
-- Donner le peuplement et l’identifiant de la placette puis le nombre de plants.
-- Trier selon le peuplement, puis l’identifiant.
-- -- v1
WITH N as (
    SELECT placette, count (*) AS nombre_de_plants
    FROM Plant
    GROUP BY placette
    )
SELECT peup, placette, nombre_de_plants
FROM N JOIN Placette ON (placette = plac)
ORDER BY peup, placette
;
-- -- v2
SELECT peup, placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (placette = plac)
GROUP BY placette, peup
ORDER BY peup, placette
;
-- -- v3
SELECT MAX(peup), placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (placette = plac)
GROUP BY placette
ORDER BY MAX(peup), placette
;

-- X02.
-- Sur la base de la date d’observation, calculer le tableau du nombre d’observations par mois.
-- Présenter le résultat de façon appropriée.
-- CLARIFICATION
--  * Placette vs Obs_XXX
--  * donnée d’observation vs date

-- X02A.
-- Interprétation une observation, multiples actions de mesure

-- -- v1a
WITH Observation AS (
    SELECT DISTINCT id, date
    FROM ObsDimension
  UNION DISTINCT
    SELECT DISTINCT id, date
    FROM ObsEtat
  UNION DISTINCT
    SELECT DISTINCT id, date
    FROM ObsFloraison )
SELECT
  EXTRACT (YEAR FROM date)  AS annee,
  EXTRACT (MONTH FROM date) AS mois,
  COUNT (*)                 AS nb_obs_par_mois
FROM Observation
GROUP BY EXTRACT (YEAR FROM date), EXTRACT (MONTH FROM date)
ORDER BY annee, mois
;
-- -- v1b
WITH Observation AS (
    SELECT DISTINCT id, date
    FROM ObsDimension
  UNION DISTINCT
    SELECT DISTINCT id, date
    FROM ObsEtat
  UNION DISTINCT
    SELECT DISTINCT id, date
    FROM ObsFloraison )
SELECT
  EXTRACT (YEAR FROM date)  AS annee,
  EXTRACT (MONTH FROM date) AS mois,
  COUNT (*)                 AS nb_obs_par_mois
FROM Observation
GROUP BY annee, mois
ORDER BY annee, mois
;

-- -- v2
CREATE VIEW Observation AS
    SELECT DISTINCT id, date
    FROM ObsDimension
  UNION DISTINCT
    SELECT DISTINCT id, date
    FROM ObsEtat
  UNION DISTINCT
    SELECT DISTINCT id, date
    FROM ObsFloraison
;

SELECT
  EXTRACT (YEAR FROM date)  AS annee,
  EXTRACT (MONTH FROM date) AS mois,
  COUNT (*)                 AS nb_obs_par_mois
FROM Observation
GROUP BY EXTRACT (YEAR FROM date), EXTRACT (MONTH FROM date)
ORDER BY annee, mois
;

-- X02B.
-- Interprétation une action de mesure, une observation


-- Pour la suite du solutionnaire, nous retiendrons l'interprétation X02A
-- où une observation identifiée par le plant et la date.


-- X03.
-- Quel est le mois comportant le plus d’observations ?
-- Présenter le résultat de façon appropriée.
-- -- v1
WITH NbObs AS
(
    SELECT
      EXTRACT (YEAR FROM date)  AS annee,
      EXTRACT (MONTH FROM date) AS mois,
      COUNT (*)                 AS nb_obs_par_mois
    FROM Observation
    GROUP BY EXTRACT (YEAR FROM date), EXTRACT (MONTH FROM date)
)
SELECT
  annee, mois, nb_obs_par_mois
FROM NbObs
WHERE nb_obs_par_mois = (SELECT MAX (nb_obs_par_mois) FROM NbObs)
;
-- -- v2
SELECT
  EXTRACT (YEAR FROM date)  AS annee,
  EXTRACT (MONTH FROM date) AS mois,
  COUNT (*)                 AS nb_obs_par_mois
FROM Observation
GROUP BY EXTRACT (YEAR FROM date), EXTRACT (MONTH FROM date)
ORDER BY nb_obs_par_mois DESC
LIMIT 1
;


-- X04.
-- Quels sont les plants dont l’état n’a jamais été observé ?
-- Présenter le résultat de façon appropriée.
-- -- v1
  SELECT id
  FROM plant
EXCEPT
  SELECT id
  FROM obsetat
ORDER BY id
;
-- -- v2
SELECT id
FROM plant
WHERE id NOT IN (SELECT id FROM obsetat)
ORDER BY id
;
-- -- v3
SELECT id
FROM plant
WHERE NOT EXISTS
  (
    SELECT id
    FROM obsetat
    WHERE plant.id = obsetat.id
  )
ORDER BY id
;
-- -- v4
SELECT id
FROM plant LEFT JOIN obsetat USING (id)
WHERE etat IS NULL
ORDER BY id
;


-- X05.
-- Quels sont les plants ayant plus de trois observations de dimension et dont
-- la largeur est toujours plus grande que la longueur ?
-- Présenter le résultat de façon appropriée.
-- -- v1
WITH
X05A AS -- Plants ayant plus de trois observations
  (
    SELECT id
    FROM ObsDimension
    GROUP BY id
    HAVING COUNT (*) > 3
  ),
X05B AS -- Plants dont la largeur est plus petite ou égale que la longueur
  (
    SELECT id
    FROM ObsDimension NATURAL JOIN X05A
    WHERE (largeur <= longueur)
  )
SELECT * FROM X05A
EXCEPT
SELECT * FROM X05B
;
-- -- v2
WITH
X05A AS -- Plants ayant plus de trois observations
  (
    SELECT id
    FROM ObsDimension
    GROUP BY id
    HAVING COUNT (*) > 3
  )
SELECT DISTINCT id
FROM ObsDimension AS ObsDim1 NATURAL JOIN X05A
WHERE NOT EXISTS
  (
    SELECT id
    FROM ObsDimension AS ObsDim2 NATURAL JOIN X05A
    WHERE (ObsDim1.id = ObsDim2.id) AND (ObsDim2.largeur <= ObsDim2.longueur)
  )
;


-- X06.
-- Quelles sont les parcelles (d’une placette) dont tous les plants ont été observés trois fois ?
-- Présenter le résultat de façon appropriée.

-- X06.a : OK... mais O(#Observation + #Plant^2)
WITH Obs AS
  (
    SELECT id, COUNT(*) AS nbObs
    FROM Observation
    GROUP BY id
  ),
R AS
  (
    SELECT DISTINCT placette, parcelle
    FROM Plant AS p1 NATURAL JOIN Obs
    WHERE NOT EXISTS
      (
        SELECT parcelle, id
        FROM Plant AS p2 NATURAL JOIN Obs
        WHERE p1.placette = p2.placette
          AND p1.parcelle = p2.parcelle
          AND nbObs <> 3
      )
  )
SELECT * FROM R
ORDER BY placette, parcelle
;

-- X06b. OK... mais O(#Observation + #Plant*(#Emplacement+1))
WITH
Obs AS -- Le nombre d'observations par plant
  (
    SELECT id, COUNT (*) AS nbObs
    FROM Observation
    GROUP BY id
  ),
Emplacement AS -- Rappel : les parcelles sont uniques au sein d'une placette, pas globalement
  (
    SELECT DISTINCT placette, parcelle
    FROM Plant
  ),
R AS -- Il suffit d'examiner les emplacements entre eux (la somme des carrés est inférieure au carré de la somme)
  (
    SELECT placette, parcelle
    FROM Emplacement AS E1
    WHERE NOT EXISTS
      (
        SELECT id
        FROM Emplacement AS E2 NATURAL JOIN Plant NATURAL JOIN Obs
        WHERE (E1.placette = E2.placette) AND (E1.parcelle = E2.parcelle) AND (nbObs <> 3)
      )
  )
SELECT placette, parcelle, count(*) AS nbPlants
FROM R NATURAL JOIN Plant
GROUP BY placette, parcelle
ORDER BY placette, parcelle;

-- X06c. OK... peut-on faire mieux ?
WITH
Obs AS -- Le nombre d'observations par plant
  (
    SELECT id, COUNT (*) AS nbObs
    FROM Observation
    GROUP BY id
  ),
Emplacement AS -- Rappel : les parcelles sont uniques au sein d'une placette, pas globalement
  (
    SELECT DISTINCT placette, parcelle
    FROM Plant
  )
SELECT placette, parcelle, count(*) AS nbPlants
FROM Emplacement NATURAL JOIN Plant NATURAL JOIN Obs
GROUP BY placette, parcelle
HAVING MIN(nbObs) = 3 AND MAX(nbObs) = 3
ORDER BY placette, parcelle
;


-- X07.
-- Déterminer les plants dont le nombre d’observations est supérieur à un écart-type
-- au-dessus de la moyenne du nombre d’observations par plant.
-- Présenter le résultat de façon appropriée.
WITH
Obs AS
  (
    SELECT id, COUNT (*) AS nbObs
    FROM Observation
    GROUP BY id
  ),
Seuil AS
  (
    SELECT AVG (nbObs) + STDDEV (nbObs) AS seuil
    FROM Obs
  )
SELECT *
FROM Obs
WHERE nbObs > (SELECT seuil FROM Seuil)
ORDER BY nbObs DESC, id ASC
;


-- X08.
-- Quelles sont les trois paires de parcelles dont le nombre de fleurs est le plus proche ?
-- Pour chacune des paires, donner les deux dénombrements.
-- Présenter le résultat de façon appropriée.
WITH
Emplacement AS -- Rappel : les parcelles sont uniques au sein d’une placette, pas globalement
  (
    SELECT placette, parcelle, COUNT (id) as nbPlants
    FROM Plant
    GROUP BY placette, parcelle
  )
SELECT E1.placette, E1.parcelle, E1.nbPlants, E2.placette, E2.parcelle, E2.nbPlants
FROM Emplacement AS E1 CROSS JOIN Emplacement AS E2
WHERE E1.placette < E2.placette
ORDER BY abs(E1.nbPlants-E2.nbPlants), E1.placette, E1.parcelle, E2.placette, E2.parcelle
LIMIT 3
-- En pratique, la réponse, bien que correcte, n’est guère satisfaisante
-- puisqu’il y a plusieurs parcelles qui ont le même nombre de fleurs.
-- Que pourriez-vous suggérer de plus utile ?

/*
-- =========================================================================== Z
////
.Contributeurs
* (CK01) christina.khnaisser@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* ...

.Tâches réalisées
* 2025-02-05 LL01. Revue sommaire
  - Coquilles et ponctuation.
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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_req3.sql
-- =========================================================================== Z
*/
