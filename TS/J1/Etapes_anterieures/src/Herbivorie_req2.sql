/*
////
-- =========================================================================== A
-- Herbivorie_req2.sql
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

Ébauche de quelques requêtes simples

.Notes de mise en oeuvre
a.  On observe que plusieurs requêtes nécessitent une clarification, dont (5, 7, 9, 10).
    Il conviendrait de faire approuver les interprétations suggérées par les
    parties prenantes et de les intégrer dans la documentation.
b.  On observe que certains choix de noms d’attributs ont contribué à complexifier
    certaines requêtes (e.a. : placette.plac versus plant.placette) une refactorisation du
    modèle serait souhaitable.
c.  La table Taux comportent présentent plusieurs aspects indésirables :
    * Il ne s’agit pas de taux quelconques, mais bien de pourcentages.
    * Le principe de catégoriser les taux rend les données difficilement interopérables,
      puisqu’il est très peu vraisemblable que les catégories soient universelles.
      Il eut été préférable que les mesures soient un pourcentage et accompagné d’une marge d’erreur.
    * Le traitement des requêtes reposent parfois sur des a priori non vérifiés
      par des contraintes :
      - les intervalles des catégories de la table doivent former une partition en
        classes d’équivalence de l’intervalle 0..100 ;
      - les codes de catégorie doivent former un intervalle et être ordonnés
        (de plus, l’ordre est contraire à celui des bornes (minimales comme maximales)
        des intervalles de pourcentage associés :
          tcat1.tmin < tcat2.tmin ==> tcat1 > tcat2.
d.  Les données de terrain (jeu0, jeu1, jeu2) ne permettent pas de "bien"
    tester toutes les requêtes. Des fichiers complémentaires doivent être développés
    à cet effet. Le jeu3 en est un exemple.

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
SELECT DISTINCT
  id, placette, parcelle
FROM ObsDimension
  JOIN Plant USING (id)
WHERE (longueur > 150) AND (largeur > 150)
;

-- R03.
-- La troisième lettre et le premier chiffre de l’étiquette du plant doivent
-- normalement coïncider avec le code de la placette où le plant est localisé.
-- Quelles sont les exceptions ?
-- Donner l’étiquette, la placette et la parcelle de chaque exception.
SELECT DISTINCT
  id, placette
FROM Plant
WHERE substr (id, 3, 2) <> placette
;

-- R04.
-- Combien de plants y a-t-il dans la placette A1 ?
-- NOTE 1
--   Les trois requêtes suivantes sont équivalentes puisque l’attribut "id" est
--   une clé de la table "Plant" et que la restriction préserve cette propriété.
--   Chaque ligne se caractérise donc par un "id" distinct, le nombre des "id",
--   des "id" distincts et des lignes est donc forcément le même.

-- R04_v1
SELECT count(distinct id)
FROM Plant
WHERE placette = 'A1'
;

-- R04_v2
SELECT count(id)
FROM Plant
WHERE placette = 'A1'
;

-- R04_v3
SELECT count(*)
FROM Plant
WHERE placette = 'A1'
;

-- R05.
-- Combien de plants ont une obstruction latérale totale à 2 m de plus de 75 % (cible 76 %) ?
-- NOTE 1
--   À moins de faire des hypothèses qui ne sont pas validées par une contrainte,
--   on ne peut présumer des propriétés suivantes sur la table Taux :
--     (a) que les intervalles [tMin..tMax] sont disjoints ;
--     (b) que l’union des intervalles couvrent [0..100] ;
--     (c) que l’ordre des tuples sur tCat est le même que sur tMin (resp. tMax).
--   Conséquemment, toute catégorie dont tMin est supérieur ou égal à la cible
--   doit être retenue (l’appartenance est certaine).
--   Que faire d'un catégorie pour laquelle tMin < cible <= tMax ?
--   En fait, l’appartenance est possible, mais incertaine. Il serait opportun de concevoir
--   une requête séparée et d'en soumettre le résultat au requérant pour qu'il évalue
--   l’impact de son choix de cible.
--   En pratique, il serait préférable que les propriétés de la table Taux soient
--   garanties par des contraintes et que les seules cibles admises soient égales
--   à l’un des tMax.
-- NOTE 2
--   Par ailleurs, compte tenu des données de terrain disponibles, nous abaisserons
--   la cible à 51 %, car aucune placette n'a une obstruction latérale totale à 2 m d'au moins 76 %.
--   Pour tester les deux classes d'appartenance, utiliser une cible de 4 %.
-- CLARIFICATION
--   Combien de plants ont une obstruction latérale totale à 2 m d'au moins 76 % (la cible) ?

-- Appartenance certaine (cible 51 %)
WITH
  CatCibles AS (select tCat from Taux where tMin >= 51)
SELECT count (distinct id)
FROM Plant
  JOIN Placette ON (plac=Placette)
  JOIN Taux ON (obs_T2 = tCat)
WHERE tCat in (select * from CatCibles)
;

-- Appartenance possible, mais incertaine (cible 51 %)
WITH
  CatCibles AS (select tCat from Taux where (tMin < 51) and (51 <= tMax))
SELECT count (distinct id)
FROM Plant
  JOIN Placette ON (plac=Placette)
  JOIN Taux ON (obs_T2 = tCat)
WHERE tCat in (select * from CatCibles)
;

-- R06.
-- Quels sont les plants localisés dans des placettes ayant une couverture de mousses
-- au sol d’au moins 50 % (la cible) et qui ont été observés entre le 10 et le 17 juillet 2017 ?
-- Donner l’étiquette, la placette et la parcelle de chaque plant.
-- NOTE 1
--   On observe le même problème de catégorisation qu'au numéro 5.
--   Nous ferons ici les hypothèses suivantes :
--   * les propriétés de la table Taux sont garanties ;
--   * la cible est un tMin (0, 1, 6, 26, 51, 76).
--   Par ailleurs, compte tenu des données de terrain disponibles, nous abaisserons
--   la cible à 26 %, car aucune placette n'a un taux de couverture de mousse d'au moins 51 %.
-- CLARIFICATION
--   Quels sont les plants localisés dans des placettes ayant une couverture de mousses
--   au sol d’au moins 26 % et qui ont été observés entre le 10 et le 17 juillet 2017 ?
--   Donner l’étiquette, la placette et la parcelle de chaque plant.
WITH
  CatCibles AS
  (
    SELECT tCat FROM Taux WHERE tMin >= 26
  ),
  PlacCibles AS
  (
    SELECT DISTINCT plac
    FROM Placette JOIN CatCibles ON (mousses=CatCibles.tCat)
  ),
  PlantDates AS
  (
    SELECT DISTINCT id FROM ObsDimension WHERE date BETWEEN '2017-07-10' AND '2017-07-17'
    UNION DISTINCT
    SELECT DISTINCT id FROM ObsEtat WHERE date BETWEEN '2017-07-10' AND '2017-07-17'
    UNION DISTINCT
    SELECT DISTINCT id FROM ObsFloraison WHERE date BETWEEN '2017-07-10' AND '2017-07-17'
  )
SELECT id, placette, parcelle
FROM PlantDates
  JOIN Plant USING (id)
  JOIN PlacCibles ON (placette=plac)
;

-- R07.
-- Quelles sont les placettes qui ont un plus grand taux d'obstruction latérale
-- totale à 2 m que les placettes qui ont un taux de couverture de mousse au sol
-- de moins de 50 % (la cible) ?
-- Donner le code de la placette et ses taux d’obstruction.
-- NOTE 1
--   On observe le même problème de catégorisation qu'aux numéros 5 et 6.
--   Nous ferons ici les hypothèses suivantes :
--   * les propriétés de la table Taux sont garanties ;
--   * la cible est un tMin (0, 1, 6, 26, 51, 76).
--   Par ailleurs, compte tenu des données de terrain disponibles, nous abaisserons
--   la cible à 26 % car aucune placette n'a un taux de couverture de mousse d'au moins 51 %.
-- NOTE 2
--   On observe que les codes de catégories de taux de couverture sont en ordre inverse
--   des couvertures elles même, en conséquence si on désire une plus grande couverture,
--   il faut spécifier un plus petit code de couverture.
-- NOTE 3
--   Dans les données de terrain, il n'y a pas de telle placette.
--   Une telle placette (A3) a donc été ajoutée.
-- CLARIFICATION
--   Soit A, l’ensemble des placettes dont tMin(mousse) >= cible ;
--   Soit B, le maximum des obs_T2 des placettes de A ;
--     résultat := les placettes dont obs_T2 < B
WITH
  CatCibles AS
    (SELECT tCat FROM Taux WHERE tMin >= 26),
  B AS
    (SELECT MIN(obs_T2) AS seuil FROM Placette JOIN CatCibles ON mousses=CatCibles.tCat)
SELECT plac, obs_f1, obs_f2, obs_c1, obs_c2, obs_t1, obs_t2
FROM Placette
WHERE obs_T2 < (SELECT seuil FROM B)
;

-- R08.
-- Soit k, la largeur moyenne des feuilles des plants dont la floraison
-- est antérieure au 18 mai 2017.
-- Quels sont les plants qui ne sont pas en floraison au 30 juin et dont la largeur
-- de feuilles est plus grande que k ?
-- Donner l’étiquette, la placette et la parcelle de chaque plant.
-- CLARIFICATION
--   Soit k, la largeur moyenne des feuilles des plants dont la floraison
--   est antérieure au 18 mai 2017.
--   Au 30 juin, quels sont les plants qui ne sont pas en floraison et dont la largeur
--   de feuille est plus grande que k ?
WITH
  Fk AS -- les plants dont la floraison est antérieure au 18 mai 2017
    (SELECT DISTINCT id FROM ObsFloraison WHERE fleur AND date < '2017-05-18'),
  k AS -- la plus  largeur moyenne de feuille parmi Fk
    (SELECT AVG(largeur) AS largeur FROM ObsDimension NATURAL JOIN FK),
  Fg AS -- les plants dont la floraison est antérieure au 30 juin 2017
    (SELECT DISTINCT id FROM ObsFloraison WHERE fleur AND date < '2017-06-30'),
  non_Fg AS -- les plants qui ne sont pas en floraison au 30 juin
    (SELECT id FROM Plant EXCEPT SELECT * FROM Fg)
SELECT DISTINCT id, placette, parcelle
FROM non_Fg NATURAL JOIN Plant NATURAL JOIN ObsDimension
WHERE largeur > (SELECT largeur FROM k)
;

-- R09.
-- Quels sont les plants dont la largeur de la feuille a dépassé 100 mm avant
-- le 15 juin 2017, mais dont la floraison (initiale) est postérieure au 2 juillet 2017 (la cible) ?
-- Donner l’étiquette, la placette et la parcelle de chaque plant.
-- NOTE 1
--  Encore une fois, les données de terrain ne permettent pas d'illustrer de tels cas
--  pour la cible du 2 juillet, par contre il en existe pour la cible du 12 mai,
--  d'où le changement de cible ci-après.

WITH
  D AS (
    SELECT DISTINCT id FROM ObsDimension WHERE largeur > 100 AND date < '2017-06-15'
    ),
  F AS (
      SELECT DISTINCT id
      FROM ObsFloraison
      WHERE fleur AND date > '2017-05-12'
    EXCEPT
      SELECT DISTINCT id
      FROM ObsFloraison
      WHERE fleur AND date <= '2017-05-12'
    )
SELECT id, placette, parcelle
FROM D
  NATURAL JOIN F
  JOIN Plant USING (id)
;

-- R10a.
-- On définit que deux plants sont semblables s’ils ont eu leur floraison initiale
-- à moins de 5 jours de distance et si le produit de leur longueur par leur largeur
-- diffère de moins de 10%.
--
-- Combien de plants semblables chacun des plants d’une parcelle donnée a-t-il
-- au sein de cette même parcelle ?
--
-- Pour chaque plant de la parcelle, donner l’étiquette, la placette, la parcelle,
-- la date de floraison initiale, le produit de la longueur par la largeur de feuille
-- et le nombre de plants semblables.
--
-- Deux plants semblables n’ont pas nécessaire le même de plants semblables...
-- Pourquoi ?
--
-- INTERROGATION
-- Que penser d’une relation de similitude qui, bien que réflexive et commutative,
-- n’est pas transitive ?
--
-- CLARIFICATION
--   1. À quel moment doit-on prendre les largeurs et les longueurs lorsqu’il y a
--      plusieurs observations ? Nous prendrons la surface maximale atteinte.
--   2. Pour que la relation semblable soit symétrique entre deux plants a et b,
--      il faut un dividende identique dans le calcul du 10%.
--      Nous prendrons la surface maximale entre par celle de a et celle de b.

-- =====================================
-- Laissé en exercice !
-- Le R10b peut servir d'inspiration :-)
-- =====================================

-- R10b.
-- Même définition de semblable qu'en R10a.
-- Même clarification qu'en R10a.
--
-- Pour chaque paire de placettes distinctes (a,b), donner le nombre de plants
-- de la placette a ayant au moins un plant semblable dans la placette b
-- (note : par définition tout plant d’une parcelle est semblable à lui-même
-- les paires (a,a) sont donc peu intéressantes !)
--
-- Pour encore plus de plaisir, calculer le pourcentage de plants de la placette a
-- ayant au moins un semblable dans la placette b.
-- :-)

WITH
  Aflor AS -- la date de dernière observation de floraison de chaque plant
  (
    SELECT id, min (date) as date
    FROM ObsFloraison
    WHERE fleur
    GROUP BY id
  ),
  Asurf AS -- la surface maximale atteinte par la plus grande feuille de chaque plant
  (
    SELECT id, max (CAST(largeur AS FLOAT)* longueur) as surface
    FROM ObsDimension
    GROUP BY id
  ),
  A AS -- la date de dernière observation de floraison et la surface maximale de chaque plan
  (
    SELECT *
    FROM Aflor NATURAL JOIN Asurf
  ),
  S AS -- les paires de plants semblables
  (
    SELECT A1.id AS idA, A2.id AS idB
    FROM A AS A1 CROSS JOIN A AS A2
    WHERE A1.id < A2.id
      AND abs (A1.date - A2.date) < 5
      AND (abs (A1.surface - A2.surface)
          / CASE WHEN A1.surface < A2.surface THEN A1.surface ELSE A2.surface END)
          < 0.10
  ),
  Semblables AS -- ajout de la symétrie, sans la diagonale réflexive
  (
    SELECT idA as a, idB as b FROM S
    UNION -- forcément distincts, voir S
    SELECT idB as a, idA as b FROM S
  ),
  P AS  -- pour chaque paire de placettes distinctes (a,b), le nombre de plants de a
        -- ayant au moins un plant semblable dans b
  (
    SELECT PA.placette as pa, PB.placette as pb, count(distinct a) as n
    FROM Semblables JOIN Plant AS PA ON (a=PA.id) JOIN Plant AS PB ON (b=PB.id)
    GROUP BY PA.placette, PB.placette
  ),
  N AS -- le nombre de plants par placette
  (
    SELECT placette, count(*) AS n
    FROM Plant
    GROUP BY placette
  )
SELECT
  N1.placette as placette_a,
  N2.placette as placette_b,
  P.n AS nb_semblables,
  N1.n AS nb_a,
  round(100.0 * P.n / N1.n) AS pourcent
FROM P JOIN N AS N1 ON (N1.placette=P.pa) JOIN N AS N2 ON (N2.placette=P.pb)
ORDER BY N1.placette, N2.placette -- petit ajout facultatif afin de faciliter la consultation
;

-- La colle du prof !
-- Sauriez-vous dire ce qui advient des placettes n’ayant aucun plant ?

/*
-- =========================================================================== Z
////
.Contributeurs :
* (CK01) christina.khnaisser@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées :
* TODO 2025-05-07 LL01. Développer des nouveaux jeux de données intermédiaires
    - Afin de faciliter le développement et l'essai.

.Tâches réalisées :
* 2025-05-07 LL01. Inversion et ajustement aux requêtes R08 et R09.
  - Suivre l’ordre de complexité croissante des requêtes.
  - Commenter les sus-étapes des WITH.
  - Donner plus de sens à la (nouvelle) R09 en définissant k comme la moyenne plutôt que le maximum.
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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_req2.sql
-- =========================================================================== Z
*/
