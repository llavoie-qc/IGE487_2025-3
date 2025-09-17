/*
////
-- =========================================================================== A
-- Herbivorie_req4.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.2.0a
Statut : Solutionnaire préliminaire
Résumé : Mise en oeuvre d’une vue unifiée des données météorologiques.
-- =========================================================================== A
*/

/*
////

-- =========================================================================== B
Mise en oeuvre des demandes de modifications Y3, Y4, Y5
(vue unifiée des données météorologiques).

.Notes de mise en oeuvre
a.  aucune.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

--
-- Y3.
-- Définir une vue donnant les conditions météorologiques complètes hors précipitation.
-- Maintenir les mêmes identifiants d’attributs qu’en Y1 (voir Meteo_cre.sql).
-- Clarification :
--   Que signifie complète ?
--   Que faire si, pour une date donnée, certaines mesures sont absentes ?
--   Toutes les mesures doivent être présentes pour qu'un tuple soit retenu.
--
CREATE VIEW Meteo_HP
(
  date      ,   -- date de la prise de donnée
  note      ,   -- note supplémentaire à propos des conditions du jour
  temp_min  ,   -- la température minimale,
  temp_max  ,   -- la température maximale,
  hum_min   ,   -- le taux d’humidité absolue minimal (en pourcentage),
  hum_max   ,   -- le taux d’humidité absolue maximal (en pourcentage),
  vent_min  ,   -- la vitesse minimale des vents (en km/h),
  vent_max  ,   -- la vitesse maximale des vents (en km/h),
  pres_min  ,   -- la pression atmosphérique minimale (en hPa),
  pres_max      -- la pression atmosphérique maximale (en hPa),
) AS
  SELECT *
    FROM ObsTemperature
      NATURAL JOIN ObsHumidite
      NATURAL JOIN ObsVents
      NATURAL JOIN ObsPression
;

--
-- Y4.
-- Retirer les données météorologiques du 17 au 19 juin si la température minimale
-- rapportée est en deçà de 4 C (le capteur était défectueux).
-- Utiliser l’instruction DELETE.
-- Clarification :
--    Seules les données de températures doivent être détruites.
--    Seule l'année 2016 est concernée.
--
DELETE FROM ObsTemperature
WHERE (date BETWEEN '2016-06-17' AND '2016-06-17') AND  (temp_min < 4)
;

--
-- Y5.
-- Augmenter les températures rapportées de 10 % entre le 20 et 30 juin
-- (le capteur était mal calibré).
-- Utiliser l’instruction UPDATE.
-- Clarification :
--    Seule l'année 2016 est concernée.
--    L'augmentation est relative à la valeur absolue de la temperature.
--
UPDATE ObsTemperature
SET temp_min = temp_min + 0.1* abs(temp_min), temp_max = temp_max + 0.1* abs(temp_max)
WHERE (date BETWEEN '2016-06-20' AND '2016-06-30')
;

/*
-- =========================================================================== Z
////
.Contributeurs :
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

.Adresse, droits d'auteur et copyright :
  Groupe Metis
  Département d'informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

-- -----------------------------------------------------------------------------
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_req4.sql
-- =========================================================================== Z
*/
