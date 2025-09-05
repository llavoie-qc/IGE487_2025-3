/*
-- =========================================================================== A
-- Composant Evaluation_ins-inv.sql
-- -----------------------------------------------------------------------------
Activité : IFT187
Trimestre : 2020-3
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 11.9
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.0e
Statut : en vigueur
-- =========================================================================== A
*/

/*
-- =========================================================================== B
Exemples de données INVALIDES pour le schéma Evaluation.
Pour plus d’information, voir Evaluation_cre.sql et le module BD012 [mod].
-- =========================================================================== B
*/

--
-- TypeEvaluation : données INVALIDES
--
INSERT INTO TypeEvaluation VALUES
  ('tev', 'trois lettres - ECHEC ATTENDU');
INSERT INTO TypeEvaluation VALUES
  ('i8', 'chiffres refusés - ECHEC ATTENDU');

--
-- Activite : données INVALIDES
--
INSERT INTO Activite VALUES
    ('IG8401', 'Gestion de projets - sigle mal formé');
INSERT INTO Activite VALUES
    ('GMQ1N3', 'Géopositionnement - sigle mal formé');

--
-- Etudiant : données INVALIDES
--
INSERT INTO Etudiant VALUES
    ('A0132', 'Sergeï', 'Chandler - matricule mal formé');
INSERT INTO Etudiant VALUES
    ('10132', 'Paul', 'Montréal - matricule mal formé');

--
-- Resultat : données INVALIDES
--
INSERT INTO Resultat VALUES
    ('99912354', 'XX', 'IFT159', '20123', 52); -- type d’évaluation inconnu
INSERT INTO Resultat VALUES
    ('99912354', 'FI', 'IFT159', '19003', 52); -- année antérieure à 1927
INSERT INTO Resultat VALUES
    ('99912354', 'FI', 'IFT159', '20124', 52); -- il n'y a pas de 4e trimestre
INSERT INTO Resultat VALUES
    ('99912354', 'FI', 'IFT159', '20123', 101); -- note au delà de 100

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
  [CC BY-4.0 (http://creativecommons.org/licenses/by/4.0)]

Tâches projetées :
NIL

Tâches réalisées :
2013-09-03 (LL01) : Création de cas de tests minimaux
  * un test par contrainte

Références :
[mod] http://info.usherbrooke.ca/llavoie/enseignement/Modules/

-- -----------------------------------------------------------------------------
-- fin de Evaluation_ins-inv.sql
-- =========================================================================== Z
*/
