/*
============================================================================== A
Produit : CoFELI.Exemple.Evaluation
Composant : Evaluation_cre.sql
Responsable : luc.lavoie@usherbrooke.ca
Version : 1.0.0a (2025-05-07)
Statut : applicable
Encodage : UTF-8, sans BOM; fin de ligne simple (LF)
Plateformes : ISO, PostgreSQL...
============================================================================== A
*/

-- Les définitions suivantes sont établies dans le contexte de l’Université de Samarcande (UdeS).

CREATE DOMAIN SigleCours
  -- Un sigle de cours a pour vocation d’identifier uniquement une activité de formation.
  -- Il est composé de trois lettres majuscules suivies de trois chiffres.
  CHAR(6)
  CHECK
  (
    VALUE SIMILAR TO '[A-Z]{3}[0-9]{3}'
  )
;

CREATE DOMAIN Matricule
  -- Un matricule a pour vocation d’identifier uniquement un étudiant.
  -- Il est composé d’exactement huit chiffres.
  CHAR(8)
  CHECK
  (
    VALUE SIMILAR TO '[0-9]{8}'
  )
;

CREATE DOMAIN TypeEval
  -- Un code de type d’évaluation a pour vocation d’identifier uniquement un type d’évaluation.
  -- Il est composé d’exactement deux lettres.
  CHAR(2)
  CHECK
  (
    VALUE SIMILAR TO '[A-Za-z]{2}'
  )
;

CREATE DOMAIN Note
  -- Une note est une mesure d’évaluation d’un travail remis dans le cadre d’une activité de formation.
  -- Elle est représenté un entier compris entre 0 et 100 inclusivement.
  INTEGER
  CHECK (VALUE BETWEEN 0 AND 100)
;

CREATE DOMAIN Trimestre
  -- Les trimestres sont encodés en suffixant le chiffre du trimestre à
  -- une année postérieure à 1927 (année de fondation de l’UdeS).
  -- Chiffre associé au trimestre : hiver -> 1, été -> 2, automne -> 3.
  CHAR(5)
  CHECK
  (
    (VALUE SIMILAR TO '[0-9]{4}[1-3]{1}')
    AND
    (SUBSTR(VALUE , 1, 4) > '1927')
  )
;

CREATE TABLE Activite
(
  sigle      SigleCours  NOT NULL,
  titre      Varchar     NOT NULL,
  CONSTRAINT Activite_cc0 PRIMARY KEY (sigle)
)
;

CREATE TABLE Etudiant
(
  matricule  Matricule   NOT NULL,
  nom        Varchar     NOT NULL,
  adresse    Varchar     NOT NULL,
  CONSTRAINT Etudiant_cc0 PRIMARY KEY (matricule)
)
;

CREATE TABLE TypeEvaluation
(
  code       TypeEval    NOT NULL,
  description Varchar    NOT NULL,
  CONSTRAINT TypeEvaluation_cc0 PRIMARY KEY (code)
)
;

CREATE TABLE Resultat
(
  matricule  Matricule  NOT NULL,
  TE         TypeEval   NOT NULL,
  activite   SigleCours NOT NULL,
  trimestre  Trimestre  NOT NULL,
  note       Note       NOT NULL,
  CONSTRAINT Resultat_cc0 PRIMARY KEY (matricule, activite, TE, trimestre),
  CONSTRAINT Resultat_cr0 FOREIGN KEY (matricule) REFERENCES Etudiant (matricule),
  CONSTRAINT Resultat_cr1 FOREIGN KEY (activite) REFERENCES Activite (sigle),
  CONSTRAINT Resultat_cr2 FOREIGN KEY (TE) REFERENCES TypeEvaluation (code)
)
;

/*
============================================================================== Z
.TODO 2025-05-07 LL01. Compléter la documentation et faire réviser.
  * Documenter le problème.
  * Documenter les prédicats.
  * Documenter l’évolution du composant.
  * Mettre en forme la documentation en accord avec [STD-PROG-SQL].
============================================================================== Z
*/
