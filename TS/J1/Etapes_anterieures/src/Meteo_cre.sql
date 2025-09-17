/*
////
-- =========================================================================== A
-- Meteo_cre.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : base de développement
Résumé : Ajout des tables d’observations météorologiques..
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Création du schéma correspondant à la collecte de données du sous-projet Meteo
du projet Herbivorie (voir [ddv]).

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

CREATE DOMAIN Temperature
  -- Température plausible de l'air ambiant dans le sud du Québec (en Celsius)
  SMALLINT
  CHECK (VALUE BETWEEN -50 AND 50);

CREATE TABLE ObsTemperature
  -- Répertoire des observations de température.
  -- PRÉDICAT : Il a été observé en date du "date" que la variation de la température
  --            était comprise entre "temp_min" et "temp_max".
  --            À cette occasion, l’observateur a consigné le commentaire "note".
(
  date      Date_eco NOT NULL,
  temp_min  Temperature NOT NULL,
  temp_max  Temperature NOT NULL,
  note      TEXT NOT NULL,
  CONSTRAINT ObsTemperature_cc0 PRIMARY KEY (date)
);

CREATE DOMAIN Humidite
  -- Taux d’humidité absolue de l'air ambiant (en pourcentage)
  SMALLINT
  CHECK (VALUE BETWEEN 0 AND 100);

CREATE TABLE ObsHumidite
  -- Répertoire des observations de taux d'humidité.
  -- PRÉDICAT : Il a été observé en date du "date" que la variation de l'humidité absolue
  --            était comprise entre "hum_min" et "hum_max".
(
  date      Date_eco NOT NULL,
  hum_min   Humidite NOT NULL,
  hum_max   Humidite NOT NULL,
  CONSTRAINT ObsHumidite_cc0 PRIMARY KEY (date)
);

CREATE DOMAIN Vitesse
  -- Vitesse des vents (en km/h)
  SMALLINT
  CHECK (VALUE BETWEEN 0 AND 300);

CREATE TABLE ObsVents
  -- Répertoire des observations de vitesse des vents.
  -- PRÉDICAT : Il a été observé en date du "date" que la variation de la vitesse des vents
  --            était comprise entre "vent_min" et "vent_max".
(
  date      Date_eco NOT NULL,
  vent_min  Vitesse NOT NULL,
  vent_max  Vitesse NOT NULL,
  CONSTRAINT ObsVents_cc0 PRIMARY KEY (date)
);

CREATE DOMAIN Pression
  -- Pression atmosphérique (en hPa)
  SMALLINT
  CHECK (VALUE BETWEEN 900 AND 1100);

CREATE TABLE ObsPression
  -- Répertoire des observations de vitesse de pression atmosphérique.
  -- PRÉDICAT : Il a été observé en date du "date" que la variation de la pression atmosphérique
  --            était comprise entre "vent_min" et "vent_max".
(
  date      Date_eco NOT NULL,
  pres_min  Pression NOT NULL,
  pres_max  Pression NOT NULL,
  CONSTRAINT ObsPression_cc0 PRIMARY KEY (date)
);

CREATE DOMAIN HNP
  -- Hauteur normée de précipitations (en mm)
  SMALLINT
  CHECK (VALUE BETWEEN 0 AND 500);

CREATE DOMAIN Code_P
  -- Code de type de précipitations
  CHAR(1)
  CHECK (VALUE BETWEEN 'A' AND 'Z');

CREATE TABLE TypePrecipitations
  -- Répertoire des type de  précipitation.
(
  code      Code_P NOT NULL,
  libelle   TEXT NOT NULL,
  CONSTRAINT TypePrecipitations_cc0 PRIMARY KEY (code)
);

INSERT INTO TypePrecipitations (code, libelle) VALUES ('G', 'Grêle') ;
INSERT INTO TypePrecipitations (code, libelle) VALUES ('N', 'Neige') ;
INSERT INTO TypePrecipitations (code, libelle) VALUES ('P', 'Pluie') ;

CREATE TABLE ObsPrecipitations
  -- Répertoire des observations de l'envergure des précipitations.
  -- PRÉDICAT : Il a été observé en date du "date" que la hauteur normée totale des précipitations
  --            de type "prec_nat" était de "prec_tot".
(
  date      Date_eco NOT NULL,
  prec_tot  HNP NOT NULL,
  prec_nat  Code_P NOT NULL,
  CONSTRAINT ObsPrecipitations_cc0 PRIMARY KEY (date, prec_nat)
);

CREATE TABLE CarnetMeteo
  -- Carnet de terrain contenant les données brutes des observations météorologiques.
  -- La table est utilisée afin de vérifier les données en vue de leur insertion
  -- dans le modèle de données.
(
  temp_min  text,   -- la température minimale,
  temp_max  text,   -- la température maximale,
  hum_min   text,   -- le taux d’humidité absolue minimal (en pourcentage),
  hum_max   text,   -- le taux d’humidité absolue maximal (en pourcentage),
  prec_tot  text,   -- les précipitations totales (en mm),
  prec_nat  text,   -- la nature des précipitations (un texte codifié, voir Code_P et TypePrecipitations),
  vent_min  text,   -- la vitesse minimale des vents (en km/h),
  vent_max  text,   -- la vitesse maximale des vents (en km/h),
  pres_min  text,   -- la pression atmosphérique minimale (en hPa),
  pres_max  text,   -- la pression atmosphérique maximale (en hPa),
  date      text,   -- date de la prise de données
  -- JJ     text,   -- jour julien de la prise de données ; inutilisé dans le présent contexte
  note      text    -- note supplémentaire à propos des conditions du jour
);


/*
-- =========================================================================== Z
////
.Contributeurs
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-02-10 LL01. Généraliser.
  - Introduire les concepts d’unité de mesure, de type de mesure, etc.
  - Introduire un mécanisme paramétrable de vérification générale des mesures.
  - Rendre le tout évolutif.
* 2022-01-23 LL01. Compléter le schéma.
  - Mieux documenter conjointement Herbivorie et Meteo.
  - Affiner le mécanisme d’ELT.
  - Développer des jeux de données.

.Tâches réalisées
* 2022-01-17 LL01. Création.
  - Création du schéma de base.
  - Validation minimale du carnet d’observations (voir test0).
  - Importation des observations intègres (voir ini).

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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Meteo_cre.sql
-- =========================================================================== Z
*/
