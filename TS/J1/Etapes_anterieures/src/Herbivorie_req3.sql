/*
////
-- =========================================================================== A
-- Herbivorie_req3.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.2.1a
Statut : Solutionnaire préliminaire
Résumé : Groupe de requêtes applicables au schéma Herbivorie.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Quelques requêtes de groupement, de quantification et d'ordonnancement.

.Notes de mise en oeuvre
a. aucune.

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

-- Lesquelles de ces variantes sont
--   * exactes (valides, cohérentes et efficaces) ?
--   * complètes ?
--   * efficientes ?
--   * évolutives ?
--   * claires et concises ?

-- X01.V1 Approche «diviser pour régner»
WITH N as (
    SELECT placette, count (*) AS nb
    FROM Plant
    GROUP BY placette
    )
SELECT Placette.peup as peuplement, Placette.plac as placette, N.nb as nombre_de_plants
FROM N JOIN Placette ON (N.placette = Placette.plac)
ORDER BY peuplement, placette
;
-- X01.V2 Intégration de la V1
SELECT Placette.peup as peuplement, Placette.plac as placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (Plant.placette = Placette.plac)
GROUP BY Placette.peup, placette.plac
ORDER BY peuplement, placette
;
-- X01.V3 Simplification de V2
-- L’attribut Placette.peup étant en dépendance fonctionnelle de Placette.plac,
-- sa valeur est donc identique pour tous les tuples du groupe.
-- Il est alors disponible sans l’intermédiaire d’une fonction d’agrégation
SELECT Placette.peup as peuplement, Placette.plac as placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (Plant.placette = Placette.plac)
GROUP BY Placette.plac
ORDER BY peuplement, placette
;
-- X01.V4 Adaptation de la V3 pour SGBD dotés de la fonction any_value
-- Lorsque le SGBD n’induit pas les dépendances fonctionnelles, il fournit parfois
-- une fonction d’agrégation (any_value) pour pallier cette insuffisance
SELECT any_value (Placette.peup) as peuplement, Placette.plac as placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (Plant.placette = Placette.plac)
GROUP BY Placette.plac
ORDER BY peuplement, placette
;
-- X01.V5 Adaptation de la V3 pour SGBD minimalistes
-- En dernier recours, il est possible d’utiliser une autre fonction agrégation
-- standard, tel que MIN ou MAX
SELECT MAX(Placette.peup) as peuplement, Placette.plac as placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (Plant.placette = Placette.plac)
GROUP BY Placette.plac
ORDER BY peuplement, placette
;
/*
-- Finalement, la déduction de la dépendance fonctionnelle peut souvent
-- être déficiente, comme illustré ici en PostgreSQL v13, 14, 15, 17...
SELECT Placette.peup as peuplement, Plant.placette as placette, count (*) AS nombre_de_plants
FROM Plant JOIN Placette ON (Plant.placette = Placette.plac)
GROUP BY Plant.placette
ORDER BY peuplement, placette ;
** [42803] ERROR: column "placette.peup" must appear in the GROUP BY clause or be used in an aggregate function
** Position : 8
-- PostgresQL ne prend pas en compte qu'en vertu de l’égalité
--   « ON (Plant.placette = Placette.plac) »
-- l’utilisation de Plant.placette est équivalente à celle de Placette.plac dans
-- ce contexte.
*/


-- X02.
-- Sur la base de la date d’observation, calculer le tableau du nombre d’observations par mois.
-- Présenter le résultat de façon appropriée.
-- X02.V1
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
-- X02.V2
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

-- non standard, mais tellement plus évolutif et clair !
SELECT
  EXTRACT (YEAR FROM date)  AS annee,
  EXTRACT (MONTH FROM date) AS mois,
  COUNT (*)                 AS nb_obs_par_mois
FROM Observation
GROUP BY annee, mois
ORDER BY annee, mois
;

-- X03.
-- Quel est le mois comportant le plus d’observations ?
-- Présenter le résultat de façon appropriée.
-- V1
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
-- V2
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
-- V1
  SELECT id
  FROM plant
EXCEPT
  SELECT id
  FROM obsetat
ORDER BY id
;
-- V2
SELECT id
FROM plant
WHERE id NOT IN (SELECT id FROM obsetat)
ORDER BY id
;
-- V3
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
-- V4
SELECT id
FROM plant LEFT JOIN obsetat USING (id)
WHERE etat IS NULL
ORDER BY id
;


-- X05.
-- Quels sont les plants ayant plus de trois observations de dimension et dont
-- la largeur est toujours plus grande que la longueur ?
-- Présenter le résultat de façon appropriée.
-- V1
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
-- V2
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

-- X06.a : OK... mais complexité dans O(#Observation + #Plant^2)
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

-- X06b. OK... mais complexité dans O(#Observation + #Plant*(#Emplacement+1))
WITH
Obs AS -- Le nombre d'observations par plant
  (
    SELECT id, COUNT (*) AS nbObs
    FROM Observation
    GROUP BY id
  ),
Emplacement AS -- Rappel : les parcelles sont uniques au sein d’une placette, pas globalement
  (
    SELECT DISTINCT placette, parcelle
    FROM Plant
  ),
R AS -- Il suffit d’examiner les emplacements entre eux (la somme des carrés est inférieure au carré de la somme)
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
Obs AS -- Le nombre d’observations par plant
  (
    SELECT id, COUNT (*) AS nbObs
    FROM Observation
    GROUP BY id
  ),
Emplacement AS -- Rappel : les parcelles sont uniques au sein d’une placette, pas globalement
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
Emplacement AS -- Rappel : les parcelles sont uniques au sein d'une placette, pas globalement
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
-- En pratique, la réponse, bien que correcte, n’est guère satisfaisante puisqu’il y a
-- plusieurs parcelles qui ont le même nombre de fleurs. Que pourriez-vous suggérer de plus utile ?

/*
-- =========================================================================== Z
////
.Contributeurs
* (CK01) christina.khnaisser@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2025-02-10 LL01. Revoir commentaires et notes de mise en oeuvre
  - Ajouter tous les paragraphes de CLARIFICATION
  - Revoir la numérotation des versions
  - Donner les critères de sélection des versions

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
