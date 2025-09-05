/*
-- =========================================================================== A
-- Composant Evaluation_ins-val.sql
-- -----------------------------------------------------------------------------
Activité : IFT187
Trimestre : 2018-3
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.3 à 10.5
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.0c
Statut : en vigueur
-- =========================================================================== A
*/

/*
-- =========================================================================== B
Exemples de données valides pour le schéma Evaluation.
Pour plus d’information, voir Evaluation_cre.sql et le module BD012 [mod].

Les colles du prof
(a) Une des directives de BD190 n'a pas été suivie. Laquelle ? Quelle peut en
    être la conséquence ?
-- =========================================================================== B
*/

--
-- TypeEvaluation : données valides
--
INSERT INTO TypeEvaluation VALUES
  ('FI', 'Examen final');
INSERT INTO TypeEvaluation VALUES
  ('IN', 'Examen intra');
INSERT INTO TypeEvaluation VALUES
  ('TP', 'Travail pratique');
INSERT INTO TypeEvaluation VALUES
  ('PR', 'Projet');
--
-- Activite : données valides
--
INSERT INTO Activite VALUES
  ('IFT159', 'Analyse et programmation');
INSERT INTO Activite VALUES
  ('IFT187', 'Éléments de bases de données');
INSERT INTO Activite VALUES
  ('IMN117', 'Acquisition des médias numériques');
INSERT INTO Activite VALUES
  ('IGE401', 'Gestion de projets');
INSERT INTO Activite VALUES
  ('GMQ103', 'Géopositionnement');
--
-- Etudiant : données invalides
--
INSERT INTO Etudiant VALUES
  ('15113150', 'Paul', 'ᐳᕕᕐᓂᑐᖅ');
INSERT INTO Etudiant VALUES
  ('15112354', 'Éliane', 'Blanc-Sablon');
INSERT INTO Etudiant VALUES
  ('15113870', 'Mohamed', 'Tadoussac');
INSERT INTO Etudiant VALUES
  ('15110132', 'Sergeï', 'Chandler');
--
-- Resultat : données valides
--
INSERT INTO Resultat VALUES
  ('15113150', 'TP', 'IFT187', '20133', 80);
INSERT INTO Resultat VALUES
  ('15112354', 'FI', 'IFT187', '20123', 78);
INSERT INTO Resultat VALUES
  ('15113150', 'TP', 'IFT159', '20133', 75);
INSERT INTO Resultat VALUES
  ('15112354', 'FI', 'GMQ103', '20123', 85);
INSERT INTO Resultat VALUES
  ('15110132', 'IN', 'IMN117', '20123', 90);
INSERT INTO Resultat VALUES
  ('15110132', 'IN', 'IFT187', '20133', 45);
INSERT INTO Resultat VALUES
  ('15112354', 'FI', 'IFT159', '20123', 52);

/*
-- =========================================================================== Z
Contributeurs :
  (CK01) christina.khnaisser@usherbrooke.ca,
  (LL01) luc.lavoie@usherbrooke.ca

Adresse, droits d’auteur et copyright :
  Groupe Metis
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC BY-4.0 (http://creativecommons.org/licenses/by-/4.0)]

Tâches projetées :
NIL

Tâches réalisées :
2013-09-03 (LL01) : Initialisation
  * Insertion des données de l’exemple fourni dans BD012.

Références :
[mod] http://info.usherbrooke.ca/llavoie/enseignement/Modules/
-- -----------------------------------------------------------------------------
-- fin de Evaluation_ins-val.sql
-- =========================================================================== Z
*/
