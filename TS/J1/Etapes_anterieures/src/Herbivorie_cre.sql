/*
////
-- =========================================================================== A
-- Herbivorie_cre.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2025-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.3a
Statut : applicable
Résumé : Création modèle logique du schéma Herbivorie.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////
Création du schéma SQL correspondant au modèle logique proposé pour la collecte
des données de terrain du projet Herbivorie dans le document de modélisation [SML].

Pour rappel, l’esquisse initiale du modèle logique est la suivante :

    Etat (etat, description)
      cle {etat};
    Peuplement (peuplement, description)
      cle {peuplement};
    Arbre (arbre, description)
      cle {arbre};
    Taux {tCat, tMin, tMax}
      cle {tCat}
    Placette {placette, peuplement,
      obs_F1, obs_F2, obs_C1, obs_C2, obs_T1, obs_T2,
      graminees, mousses, fougeres,
      arb_P1, arb_P2, arb_P3,
      date, note}
      clé {placette}
      ref {obs_F1} -> Taux {tCat}
      ref {obs_F2} -> Taux {tCat}
      ref {obs_C1} -> Taux {tCat}
      ref {obs_C2} -> Taux {tCat}
      ref {obs_T1} -> Taux {tCat}
      ref {obs_T2} -> Taux {tCat}
      ref {graminees} -> Taux {tCat}
      ref {mousses} -> Taux {tCat}
      ref {fougeres} -> Taux {tCat}
      ref {arb_P1} -> Arbre {arbre}
      ref {arb_P2} -> Arbre {arbre}
      ref {arb_P2} -> Arbre {arbre};
    Plant {id, placette, parcelle, date, note}
      cle {id}
      ref id -> Plant
      ref placette -> Placette;
    Observation {id, largeur, longueur, floraison, etat, date, note}
      clé {id, date}
      ref id -> Plant
      ref etat -> Etat;

.Précisions
 a. Obstruction latérale : prend en compte les obstructions sur une distance de
    10 m, à des hauteurs de 1 et 2 mètres.
 b. Floraison : vrai ssi le plant porte une fleur (qu’elle soit ouverte ou pas)
    ou un fruit ; permet de déterminer si un plant est (potentiellement)
    reproducteur ou pas.
 c. Une parcelle est une subdivision de la placette qui permet de faciliter le
    repérage des plants.
 d. Les conventions relatives aux codes (plants, placettes, parcelles, etc.) sont
    celles qui nous ont été communiquées au 2017-09-17.
 e. On présume qu’aucune donnée n’a été consignée antérieurement au 20 décembre 1582,
    ce qui légitime l’usage exclusif du calendrier grégorien (en vigueur en France
    et en Nouvelle-France depuis cette date).
 f. Pour plus de détails, voir [EPP, SML].

.Notes de mise en oeuvre
 a. Les descriptions ont été arbitrairement limitées à 60 caractères ;
    il conviendrait sans doute d’augmenter cette limite substantiellement.
 b. Les observations sont décomposées en trois tables afin de permettre un
    meilleur traitement des données manquantes.
////
-- =========================================================================== B
*/

--
-- Création du schéma
--
DROP SCHEMA IF EXISTS "Herbivorie" CASCADE ;
CREATE SCHEMA "Herbivorie" ;
SET SCHEMA 'Herbivorie' ;

--
-- Description des placettes
--
CREATE DOMAIN Arbre_id
 -- Code identifiant uniquement une variété d’arbres.
  TEXT
  CHECK (CHAR_LENGTH (VALUE) BETWEEN 1 AND 20);

CREATE DOMAIN Description
 -- Description textuelle consignée par l’observateur.
 -- Typiquement, une définition, une annotation ou un commentaire associé à une observation.
  TEXT
  CHECK (CHAR_LENGTH (VALUE) BETWEEN 1 AND 60);

CREATE TABLE Arbre
 -- Répertoire des variétés d’arbres.
 -- PRÉDICAT : La variété d’arbres identifiée par "arbre" correspond à la description "description".
(
  arbre       Arbre_id    NOT NULL,
  description Description NOT NULL,
  CONSTRAINT Arbre_cc0 PRIMARY KEY (arbre)
);

CREATE DOMAIN Peuplement_id
 -- Code identifiant uniquement un peuplement végétal de parcelle.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{4}');

CREATE TABLE Peuplement
 -- Répertoire des types de peuplement végétal d’une parcelle.
 -- PRÉDICAT : Le type de peuplement identifié par "peup" correspond à la description "description".
(
  peup        Peuplement_id NOT NULL,
  description Description   NOT NULL,
  CONSTRAINT Peuplement_cc0 PRIMARY KEY (peup)
);

CREATE DOMAIN Taux_val
 -- Valeur correspondant à la proportion d’une couverture à un centième près.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 100);

CREATE DOMAIN Taux_id
 -- Code identifiant uniquement un intervalle de couverture communément appelé «taux».
 -- Ces codes sont utilisés notamment lors de la mesure de l’obstruction latérale de la surface au sol.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{1}');

CREATE TABLE Taux
 -- Répertoire des codes de couverture communément appelés «taux».
 -- PRÉDICAT : Le code de couverture identifié par "tCat" correspond à l’intervalle
 --   de couverture [tMin..tMax].
 -- NOTE : Le choix d’une représentation discrète pour Taux_val a conduit
 --   naturellement à définir le taux de la catégorie tCat par un intervalle
 --   fermé-fermé [compris entre tMin (inclusivement) et tMax (inclusivement)].
 -- CONTRAINTE : Compacité sur [0..100]
 --   Il ne doit y avoir aucun recoupement entre les intervalles associés
 --   aux codes définis et l’union des intervalles définis doit couvrir la totalité
 --   du spectre 0..100.
 -- TODO 2025-01-29 LL01. Mettre en oeuvre la contrainte de compacité.
(
  tCat Taux_id  NOT NULL,
  tMin Taux_val NOT NULL,
  tMax Taux_val NOT NULL,
  CONSTRAINT Taux_cc0 PRIMARY KEY (tCat),
  CONSTRAINT Taux_inter CHECK (tMin <= tMax)
);

CREATE DOMAIN Placette_id
 -- Code identifiant uniquement une placette.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z][0-9]');

CREATE DOMAIN Date_eco
 -- Date d’une observation écologique.
  DATE
  CHECK (VALUE >= '1582-12-20');

CREATE TABLE Placette
 -- Description de la placette
 -- PRÉDICAT : La placette identifiée par "plac" a été caractérisée grâce aux observations
 --   faites en date du "date" et consignées grâce aux autres attributs décrits ci-après.
(
  plac      Placette_id   NOT NULL, -- désignation de la placette
  peup      Peuplement_id NOT NULL, -- type de peuplement de la placette
  obs_F1    Taux_id       NOT NULL, -- taux d’obstruction latérale feuillue moyenne à 1 m de hauteur
  obs_F2    Taux_id       NOT NULL, -- taux d’obstruction latérale feuillue moyenne à 2 m de hauteur
  obs_C1    Taux_id       NOT NULL, -- taux d’obstruction latérale coniférienne moyenne à 1 m de hauteur
  obs_C2    Taux_id       NOT NULL, -- taux d’obstruction latérale coniférienne moyenne à 2 m de hauteur
  obs_T1    Taux_id       NOT NULL, -- taux d’obstruction latérale totale moyenne à 1 m de hauteur
  obs_T2    Taux_id       NOT NULL, -- taux d’obstruction latérale totale moyenne à 2 m de hauteur
  graminees Taux_id       NOT NULL, -- taux d’occupation au sol des graminées dans la placette
  mousses   Taux_id       NOT NULL, -- taux d’occupation au sol des mousses dans la placette
  fougeres  Taux_id       NOT NULL, -- taux d’occupation au sol des fougères dans la placette
  arb_P1    Arbre_id      NOT NULL, -- arbre dominant de la placette (1er rang)
  arb_P2    Arbre_id      NOT NULL, -- arbre dominant de la placette (2e rang)
  arb_P3    Arbre_id      NOT NULL, -- arbre dominant de la placette (3e rang)
  date      Date_eco      NOT NULL, -- date à laquelle la description a été établie
  CONSTRAINT Placette_cc0 PRIMARY KEY (plac),
  CONSTRAINT Placette_cr_pe FOREIGN KEY (peup) REFERENCES Peuplement (peup),
  CONSTRAINT Placette_cr_f1 FOREIGN KEY (obs_F1) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_f2 FOREIGN KEY (obs_F2) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_c1 FOREIGN KEY (obs_C1) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_c2 FOREIGN KEY (obs_C2) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_t1 FOREIGN KEY (obs_T1) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_t2 FOREIGN KEY (obs_T2) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_gr FOREIGN KEY (graminees) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_mo FOREIGN KEY (mousses) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_fo FOREIGN KEY (fougeres) REFERENCES Taux (tCat),
  CONSTRAINT Placette_cr_p1 FOREIGN KEY (arb_P1) REFERENCES Arbre (arbre),
  CONSTRAINT Placette_cr_p2 FOREIGN KEY (arb_P2) REFERENCES Arbre (arbre),
  CONSTRAINT Placette_cr_p3 FOREIGN KEY (arb_P3) REFERENCES Arbre (arbre)
 -- NOTE : Comment vérifier que obs_T1.tMin >= obs_F1.tMin + obs_C1.tMin ?
 -- NOTE : Comment vérifier que obs_T2.tMin >= obs_F2.tMin + obs_C2.tMin ?
 -- NOTE : Que faudrait-il faire pour les tMax ?
 -- NOTE : Que faudrait-il suggérer aux collègues écologistes ?
 -- NOTE : Quels outils pourrions-nous leur fournir ?
);

--
-- Description des plants recensés dans les placettes
--
CREATE DOMAIN Plant_id
 -- Code identifiant uniquement un plant de trille.
  TEXT
  CHECK (VALUE SIMILAR TO 'MM[A-C][0-9]{4}');

CREATE DOMAIN Parcelle
 -- La parcelle est une subdivision de la placette.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 99);

CREATE TABLE Plant
 -- Répertoire des plants de trille et de leur emplacement.
 -- PRÉDICAT : Le plant "id" a été identifié dans la parcelle "parcelle" de la
 --   placette "placette" en date du "date".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id    NOT NULL, -- identifiant unique de chaque trille
  placette Placette_id NOT NULL, -- placette dans laquelle est le trille
  parcelle Parcelle    NOT NULL, -- parcelle dans laquelle se trouve le trille
  date     Date_eco    NOT NULL, -- date de la prise de données
  note     TEXT        NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT Plant_cc0 PRIMARY KEY (id),
  CONSTRAINT Plant_cr0 FOREIGN KEY (placette) REFERENCES Placette (plac)
);

CREATE DOMAIN Dim_mm
 -- Dimension d’une feuille de trille exprimée en millimètre.
  INTEGER
  CHECK (VALUE BETWEEN 1 AND 999);

CREATE TABLE ObsDimension
 -- Répertoire des observations de dimension de plants de trille.
 -- PRÉDICAT : Il a été observé en date du "date" que le plan "id" possédait une feuille
 --   de dimension "longueur" par "largeur".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  longueur Dim_mm   NOT NULL, -- longueur d’une des feuilles d’un trille, en mm
  largeur  Dim_mm   NOT NULL, -- largeur d’une des feuilles d’un trille, en mm
  date     Date_eco NOT NULL, -- date de l’observation
  note     TEXT     NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsDimension_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsDimension_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE TABLE ObsFloraison
 -- Répertoire des observations de floraison de plants de trille.
 -- PRÉDICAT : Il a été observé au jour "date" que le plan "id" possédait une fleur (ou non).
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  fleur    BOOLEAN  NOT NULL, -- présence de fleur
  date     Date_eco NOT NULL, -- date de l’observation
  note     TEXT     NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsFloraison_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsFloraison_cr0 FOREIGN KEY (id) REFERENCES Plant (id)
);

CREATE DOMAIN Etat_id
 -- Code identifiant uniquement un état d’un plant.
 -- NOTE : La définition est identique à celle de Peuplement_id.
 --   C’est une coïncidence, pas une conséquence d’une assertion commune.
 --   Il est donc important de les distinguer en regard de l'évolutivité.
  TEXT
  CHECK (VALUE SIMILAR TO '[A-Z]{1}');

CREATE TABLE Etat
 -- Répertoire des états d’un plant.
 -- PRÉDICAT : L’état d’un plant identifié par "etat" correspond à la description "description".
(
  etat        Etat_id     NOT NULL,
  description Description NOT NULL,
  CONSTRAINT Etat_cc0 PRIMARY KEY (etat)
);

CREATE TABLE ObsEtat
 -- Répertoire des observations d’état de plants de trille.
 -- PRÉDICAT : Il a été observé au jour "date" que le plant "id" était dans l’état "etat".
 --   À cette occasion, l’observateur a consigné le commentaire "note".
(
  id       Plant_id NOT NULL, -- identifiant unique de chaque trille
  etat     Etat_id  NOT NULL, -- état du plant
  date     Date_eco NOT NULL, -- date de l’observation
  note     TEXT     NOT NULL, -- note supplémentaire à propos du trille
  CONSTRAINT ObsEtat_cc0 PRIMARY KEY (id, date),
  CONSTRAINT ObsEtat_cr0 FOREIGN KEY (id) REFERENCES Plant (id),
  CONSTRAINT ObsEtat_cr1 FOREIGN KEY (etat) REFERENCES Etat (etat)
);

/*
-- =========================================================================== Z
////
.Contributeurs
* (DAL) diane.auberson-lavoie@usherbrooke.ca
* (LL01) luc.lavoie@usherbrooke.ca

.TODO 2025-05-07 LL01. La fusion de Herbivorie.def et Herbivorie.cred était-elle justifiée ?
* Revoir les différents modèles de modularisation.
* Évaluer l'impact pédagogique.

.Tâches projetées
* 2022-01-23 LL01. Compléter le schéma
  - Décomposer et temporaliser les observations relatives aux placettes
    (obstruction latérale, couverture au sol, espèces dominantes, etc.).
* 2017-09-19 LL01. Compléter le schéma
  - Compléter les contraintes, en particulier :
    *** la date d’observation d’un plan ne peut être antérieure à son identification ;
    *** la date d’identification d’un plant ne peut être antérieure à celui de sa placette ;
    *** les obstructions latérales observées d’une placette doivent être cohérentes ;
    *** les couvertures au sol observées d’une placette doivent être cohérentes.
* 2017-09-18 LL01. Renommer plus rigoureusement les concepts utilisés par le schéma
  - Plusieurs identificateurs sont inappropriés en regard des concepts véhiculés.
  - Certaines abréviations prêtent à confusion.
  - La constitution d’un dictionnaire de données et l’utilisation d’une terminologie
    rigoureuse sont fortement recommandées.
  - Entre autres exemples : obs -> obstruction latérale, taux -> pourcentage,
    arb -> variété d’arbres, peup, plac, etc.

.Tâches réalisées
* 2025-02-03 LL01. Fusion des fichiers Herbivorie_def et Herbivorie_cre.
  - Pour mettre en évidence commentaire initial et simplifier la création.
* 2025-01-26 LL01. Adaptation au standard de programmation de CoFELI.
  - Mise en forme des commentaires externes en AsciiDoc.
* 2022-01-23 LL01. Épurer le schéma.
  - Déplacer les commentaires généraux dans Herbivorie_def.
  - Déplacer le carnet dans Herbi-ELT_def.
  - Remplacer les textes statiques (CHAR) par des textes dynamiques (TEXT).
  - Adapter les contraintes en conséquence.
  - Compléter certains prédicats.
  - Enrichir certains commentaires.
  - Capitaliser les types prédéfinis.
  - Corriger diverses coquilles.
* 2017-09-20 LL01. Compléter le schéma.
  - Décomposer Placette afin de permettre l’annulabilité de certaines colonnes.
  - Ne mettre que des attributs TEXT dans Carnet et parfaire les validations.
  - Introduire la table Arbre et les clés référentielles appropriées.
* 2017-09-17 LL01. Création
  - Création du schéma de base.
  - Validation minimale du carnet d’observations (voir test0).
  - Importation des observations intègres (voir ini).

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
-- fin de {CoFELI}/Exemple/Herbivorie/src/Herbivorie_cre.sql
-- =========================================================================== Z
*/
