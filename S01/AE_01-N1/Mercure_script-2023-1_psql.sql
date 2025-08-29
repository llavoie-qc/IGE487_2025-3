/*
-- =========================================================================== A
Projet : Enseignement/Bases de données
Segment : Exemples/Mercure
Composant : Mercure_script-2023-1.sql
Encodage : UTF-8 sans BOM, fin de ligne Unix (LF)
Responsable : Luc.Lavoie@USherbrooke.ca
Statut : en développement
-- =========================================================================== A
*/

/*
Requêtes diverses relatives au schéma Mercure.

Contexte
Le gouvernement du Québec désire assurer la traçabilité de certains produits sensibles
sur son territoire. Pour ce faire, il a mis en place un mécanisme de déclaration
des transactions portant sur ces produits et instauré un registre des organisations
habilitées à effectuer ces transactions.

Note de mise en oeuvre :
Des préfixes sont placés devant les commandes d’écriture permettant de produire
un solutionnaire lorsque le fichier est exécuté sous forme de script.
Par exemple,
  - « prompt » sous SQL*Plus (Oracle),
  - « \qecho » sous psql (PostgreSQL),
  - « -- xox » lorsque le script ne doit pas être produit.
Bien que disponible au sein de nombreuses consoles d’exécution, une telle
commande ne fait pas partie du langage SQL normalisé et n’est donc pas
transportable. Pour cette raison, elle est donc utilisée sous une forme
volontairement restreinte.
*/

/*
== Spécification du format de date pour pallier à un éventuel format implicite
== non standard.

-- Oracle
-- ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd';
*/
-- PostgreSQL, ISO
-- rien à faire

/*
== Rediriger la sortie sur la console

-- Oracle
-- rien à faire
*/
-- PostgreSQL
\o

/*
== Référencer le bon schéma

-- Oracle
-- SET USER 'Mercure'
*/
-- PostgreSQL, ISO
DROP SCHEMA IF EXISTS "Mercure" CASCADE ;
CREATE SCHEMA "Mercure" ;
SET SCHEMA 'Mercure' ;

/*
== Début du script à proprement parler
*/

CREATE DOMAIN Produit_code AS
  Text CHECK (length(VALUE)=3);
CREATE DOMAIN Montant AS
  NUMERIC(12,2) CHECK (VALUE >= 0);

CREATE TABLE Produit
-- Le produit «id» est désigné par le nom «nom», est de type «type», de marque «marque»
-- et dont le cout «cout» est donné en dollars canadiens (CAD).
-- Le cout est ici un cout unitaire moyen de référence auquel on peut comparer le
-- prix effectif consenti lors d’une transaction donnée.
(
  id        Produit_code  NOT NULL,
  nom       VARCHAR(20)   NOT NULL,
  type      VARCHAR(20)   NOT NULL,
  marque    VARCHAR(20)   NOT NULL,
  cout      Montant       NOT NULL,
  CONSTRAINT Produit_cc0 PRIMARY KEY (id)
);

CREATE DOMAIN Org_code AS
  Text CHECK (length(VALUE)=3);

CREATE TABLE Organisation
-- L’organisation «id» est enregistrée; elle porte le nom «nom», a son siège social dans
-- la ville «ville» et offre des services de type «type».
(
  id        Org_code    NOT NULL,
  nom       VARCHAR(20) NOT NULL,
  ville     VARCHAR(60) NOT NULL,
  type      VARCHAR(20) NOT NULL,
  CONSTRAINT Organisation_cc0 PRIMARY KEY (id),
  CONSTRAINT Organisation_cc1 UNIQUE (nom,ville)
);

CREATE TABLE Transaction
-- L’organisation «acheteur» a acquis auprès de l’organisation «vendeur» un nombre
-- «quantité» de produit «produit» au prix unitaire de «prix» en date du «date»;
-- le prix est donné en CAD.
-- La valeur totale d’un achat est donnée par quantite*prix.
(
  acheteur  Org_code      NOT NULL,
  vendeur   Org_code      NOT NULL,
  produit   Produit_code  NOT NULL,
  date      DATE          NOT NULL,
  quantite  NUMERIC(9)    NOT NULL,
  prix      Montant       NOT NULL,
  CONSTRAINT Transaction_cc0 PRIMARY KEY (acheteur,vendeur,produit,date),
  CONSTRAINT Transaction_ce1 FOREIGN KEY (acheteur) REFERENCES Organisation (id),
  CONSTRAINT Transaction_ce2 FOREIGN KEY (vendeur) REFERENCES Organisation (id),
  CONSTRAINT Transaction_ce3 FOREIGN KEY (produit) REFERENCES Produit (id)
);

INSERT INTO Produit
  (id,    nom,         type,           marque,   cout)
VALUES
  ('P31', 'Câble #1',  'Électricité',  'IOCT',     10),
  ('P32', 'Câble #2',  'Électricité',  'IOCT',     20),
  ('P33', 'Câble #3',  'Électricité',  '3ITC',     50),
  ('P34', 'Tôle',      'Toiture',      'Rano',     80),
  ('P35', 'Gouttière', 'Toiture',      'Rano',     30),
  ('P36', 'Circuit-A', 'Électronique', '3ITC',     10),
  ('P37', 'Circuit-B', 'Électronique', 'Ducharme', 20),
  ('P38', 'Circuit-C', 'Électronique', 'Ducharme', 40);

INSERT INTO Organisation
  (id,    nom,                ville,           type)
VALUES
  ('ABC', 'Société ABC',      'Montréal',      'Manufacturier'),
  ('DEF', 'Compagnie DEF',    'Victoriaville', 'Assembleur'),
  ('GHI', 'Entreprises GHI',  'Québec',        'Manufacturier'),
  ('JKL', 'Jos, Karl & Lou',  'Montréal',      'Grossiste'),
  ('MNO', 'Marie Normandeau', 'Sherbrooke',    'Detaillant'),
  ('PQR', 'PQR SARL',         'Sherbrooke',    'Utilisateur'),
  ('STU', 'Compagnie STU',    'Montréal',      'Transformateur'),
  ('VWX', 'Entreprises VWX',  'Drummondville', 'Assembleur');

INSERT INTO Transaction
  (acheteur, vendeur, produit, date, quantite, prix)
VALUES
  ('GHI', 'DEF', 'P38', DATE '2006-12-01', 500, 80),
  ('JKL', 'GHI', 'P32', DATE '2006-12-02', 400, 40),
  ('VWX', 'JKL', 'P31', DATE '2006-12-03', 100, 90),
  ('MNO', 'JKL', 'P32', DATE '2006-12-04', 200, 30),
  ('VWX', 'ABC', 'P36', DATE '2006-12-07',  25, 10),
  ('PQR', 'DEF', 'P37', DATE '2006-12-08',  50, 40),
  ('JKL', 'ABC', 'P36', DATE '2006-12-09',  25, 20),
  ('JKL', 'ABC', 'P37', DATE '2006-12-09',  50, 30);

/*
== Rediriger la sortie dans un fichier

-- Oracle
-- ???
*/
-- PostgreSQL
\o Mercure_script-2023-1.txt

-- début du solutionnaire
\qecho "*** DÉBUT DU SOLUTIONNAIRE Mercure_script-2023-1.sql (" `date -Iseconds` ")" ;
-- xox
\qecho "--- =================================================================" ;
\qecho "    Données" ;
\qecho "--- =================================================================" ;
-- xox

\qecho "Produit"
SELECT *  FROM Produit;

\qecho "Organisation"
SELECT *  FROM Organisation;

\qecho "Transaction"
SELECT *  FROM Transaction;

-- xox
\qecho "--- =================================================================" ;
\qecho "    Q2" ;
\qecho "--- =================================================================" ;
-- xox

\qecho "--- ................................................................." ;
\qecho "2.1 Déterminer les produits de marque 3ITC." ;
\qecho "    Donner l’identifiant (id) du produit et son nom." ;
-- xox
SELECT DISTINCT id, nom
FROM Produit
WHERE marque = '3ITC'
;

\qecho "--- ................................................................." ;
\qecho "2.2 Dénombrer les acheteurs distincts de chaque produit acheté (dans Transaction)."
\qecho "    Donner l’identifiant (id) du produit et le nombre d’acheteurs." ;
-- xox
SELECT produit, COUNT(DISTINCT acheteur)
FROM Transaction
GROUP BY produit
;

/*
\qecho "--- ................................................................." ;
\qecho "2.3 Dénombrer les acheteurs distincts de chaque produit documenté (dans Produit)."
\qecho "    Donner l’identifiant (id) du produit et le nombre d’acheteurs." ;
-- xox
-- Ne pas utiliser "produit" dans le select, car il pourrait être nul; utiliser "id".
SELECT id, COUNT(DISTINCT acheteur)
FROM Produit LEFT JOIN Transaction ON (id=produit)
GROUP BY id
;
*/

\qecho "--- ................................................................." ;
\qecho "2.3 Donner le prix moyen pondéré (PMD) de chaque produit vendu."
\qecho "    Calculer la moyenne en pondérant le prix par la quantité vendue à ce prix."
\qecho "    Donner l’identifiant, le nom du produit et le PMD." ;
SELECT id, MAX(nom) AS n, SUM(quantite*prix)/SUM(quantite) AS m
FROM Produit JOIN Transaction ON (id=produit)
GROUP BY id
;

\qecho "--- ................................................................." ;
\qecho "2.4 Déterminer organisations qui sont acheteurs et vendeurs." ;
\qecho "    Donner l’identifiant de l’organisation."
-- xox
\qecho ".v0 - correcte";
SELECT DISTINCT A.acheteur
FROM Transaction as A JOIN Transaction AS B ON (A.acheteur=B.vendeur)
;
\qecho ".v1 - correcte";
WITH
  A AS (SELECT DISTINCT acheteur FROM Transaction),
  V AS (SELECT DISTINCT vendeur FROM Transaction)
SELECT acheteur FROM A WHERE A.acheteur IN (SELECT * FROM V)
;

\qecho "--- ................................................................." ;
\qecho "2.5 Déterminer les organisations qui n’achètent qu’un seul produit." ;
\qecho "    Donner l’identifiant de l’organisation, son nom et sa ville."
-- xox
WITH
  A AS
      (SELECT acheteur AS id
      FROM Transaction
      GROUP BY acheteur
      HAVING COUNT(DISTINCT produit) = 1)
SELECT DISTINCT id, nom, ville
FROM Organisation JOIN A USING (id)
;

\qecho "--- ................................................................." ;
\qecho "2.6 Déterminer les acheteurs n’ayant jamais acheté d’un vendeur de Montréal." ;
\qecho "    Donner l’identifiant (id) de l’organisation et son nom." ;
-- xox
WITH
  X AS (SELECT DISTINCT acheteur AS id FROM Transaction)
SELECT  A.id, A.nom
FROM    Organisation AS A JOIN X USING (id)
WHERE   NOT EXISTS
        ( SELECT  1
          FROM    Organisation AS V join Transaction AS T ON (V.id=T.vendeur)
          WHERE   (A.id=T.acheteur) AND (V.ville='Montréal')
        )
;

\qecho "--- ................................................................." ;
\qecho "2.7 Déterminer les produits ayant été achetés par plus d’un type d’organisations." ;
\qecho "    Donner l’identifiant (id) du produit." ;
-- xox
SELECT produit
FROM Produit, Transaction, Organisation
WHERE (Produit.id=Transaction.produit) AND (Organisation.id=Transaction.acheteur)
GROUP BY produit
HAVING COUNT(DISTINCT Organisation.type) > 1
;

\qecho "--- ................................................................." ;
\qecho "2.8 Déterminer l’organisation ayant le plus de partenaires commerciaux différents (acheteurs ou vendeurs)." ;
\qecho "    Donner l’identifiant (id) de l’organisation et le nombre de partenaires." ;
-- xox
WITH
  P AS
    (
      SELECT acheteur AS p1, vendeur AS p2 FROM Transaction
      UNION
      SELECT vendeur AS p1, acheteur AS p2 FROM Transaction
    ),
  C AS
    (SELECT p1, COUNT(DISTINCT p2) AS nbPartenaires FROM P GROUP BY p1)
SELECT p1, nbPartenaires
FROM C
WHERE nbPartenaires = (SELECT MAX(nbPartenaires) FROM C)
;

-- xox
\qecho "--- =================================================================" ;
\qecho "    Q3" ;
\qecho "--- =================================================================" ;
-- xox

\qecho "--- ................................................................." ;
\qecho "3.1 Quels sont les types de produits ayant engendré des achats dépassant 2000 CAD ?" ;
\qecho "    Donner le type de produit." ;
-- xox
SELECT DISTINCT Produit.type
FROM Organisation
  JOIN Transaction ON (Organisation.id=Transaction.acheteur)
  JOIN Produit ON (Transaction.produit=Produit.id)
WHERE Transaction.quantite*Transaction.prix > 2000.00
;

\qecho "--- ................................................................." ;
\qecho "3.2 Quelle est la valeur totale des achats du mois de décembre 2016 ?" ;
\qecho "    Donner la valeur." ;
-- xox
SELECT SUM(quantite*prix) AS val_totale
FROM Transaction
WHERE date BETWEEN '2016-12-01' AND '2016-12-31'
;

\qecho "--- ................................................................." ;
\qecho "3.3 Quelle est valeur totale des achats de chaque organisation ?" ;
\qecho "    Donner l’identifiant (id) de l’organisation et la valeur totale;" ;
\qecho "    indiquer 0 si une organisation n’a pas fait d’achats." ;
-- xox
-- v1
with
  Acheteurs as (
    SELECT acheteur as id, SUM(quantite*prix) AS val_totale
    FROM Transaction
    GROUP BY id
    ),
  NonAcheteurs as (
    SELECT id FROM Organisation
    EXCEPT
    SELECT id FROM Acheteurs
    )
SELECT id, val_totale FROM Acheteurs
UNION
SELECT id, 0 as val_totale FROM NonAcheteurs
ORDER BY id -- le tri n’est pas requis
;

-- v2
SELECT id, coalesce(SUM(quantite*prix),0) AS val_totale
FROM Organisation LEFT JOIN Transaction ON (id=acheteur)
GROUP BY id
ORDER BY id -- le tri n’est pas requis
;

\qecho "--- ................................................................." ;
\qecho "3.4 Les acheteurs dont la valeur totale des achats dépasse 20 000 CAD." ;
\qecho "    Donner l’identifiant et la valeur totale des achats de chacun." ;
-- xox
SELECT acheteur, SUM(quantite*prix) AS val_totale
FROM Transaction
GROUP BY acheteur
HAVING SUM(quantite*prix) > 20000
;

\qecho "--- ................................................................." ;
\qecho "3.5 Majorer de 10% le cout des produits achetés uniquement par des" ;
\qecho "    manufacturiers" ;
-- xox
UPDATE Produit
SET cout = 1.10 * cout
WHERE id IN (SELECT produit FROM Transaction)
  AND NOT EXISTS (
    SELECT DISTINCT A.id
    FROM Organisation A, Transaction
    WHERE (A.id=Transaction.acheteur)
      AND (Produit.id=Transaction.produit)
      AND (A.type <> 'Manufacturier')
  );
SELECT * FROM Produit ;

\qecho "--- ................................................................." ;
\qecho "3.6 Supprimer les produits qui n’ont jamais été achetés";
-- xox
DELETE FROM Produit
WHERE NOT EXISTS ( SELECT * FROM Transaction WHERE Produit.id=Transaction.produit );
SELECT * FROM Produit
;

\qecho "--- ................................................................." ;
\qecho "3.7 Les produits dont le cout est supérieur au plus cher des"
\qecho "    produits achetés par JKL" ;
-- Les trois variantes suivantes ne livrent pas le même résultat lorsqu’aucun
-- achat n’a été effectué par JKL. La deuxième est présumément plus efficace,
-- car le maximum est plus facilement factorisable. La bonne réponse est la
-- troisième, en raison de la définition incorrecte de MAX en SQL
-- lorsqu’appliquée à un ensemble vide.
-- Par ailleurs, le prix unitaire (recommandé) est celui de Produit alors que
-- celui de Transaction est le prix effectif.
-- xox
\qecho ".v0 - incorrecte lorsque JKL n’a rien acheté";
SELECT DISTINCT id
FROM Produit
WHERE cout > ALL (SELECT prix FROM Transaction WHERE acheteur = 'JKL')
;
\qecho ".v1 - incorrecte lorsque JKL n’a rien acheté";
SELECT DISTINCT id
FROM Produit
WHERE cout > (SELECT MAX(prix) FROM Transaction WHERE acheteur = 'JKL')
;
\qecho ".v2 - correcte même si JKL n’a rien acheté";
SELECT DISTINCT id
FROM Produit
WHERE cout > COALESCE((SELECT MAX(prix) FROM Transaction WHERE acheteur = 'JKL'),0)
;

\qecho "--- ................................................................." ;
\qecho "3.8 Les organisations qui n’achètent que des produits d’une seule marque." ;
\qecho "    Donner l’identifiant de l’organisation (id)." ;
-- xox
\qecho ".v0 - illustration (comprend toutes les organisations)";
WITH AX AS
  (
  SELECT Transaction.*, marque
  FROM Transaction JOIN Produit ON (produit=Produit.id)
  )
SELECT Organisation.id, AX.produit, AX.marque
FROM Organisation LEFT JOIN AX ON (Organisation.id=acheteur)
ORDER BY Organisation.id, AX.produit
;
\qecho ".v1 - correcte (les organisations qui n’ont rien acheté sont exclues)";
SELECT acheteur
FROM Transaction JOIN Produit ON (produit=id)
GROUP BY acheteur
HAVING COUNT(DISTINCT marque) = 1
;
\qecho ".v2 - correcte (les organisations qui n’ont rien acheté sont incluses)";
WITH AX AS
  (
  SELECT Transaction.*, marque
  FROM Transaction JOIN Produit ON (produit=Produit.id)
  )
SELECT Organisation.id
FROM Organisation LEFT JOIN AX ON (Organisation.id=acheteur)
GROUP BY Organisation.id
HAVING COUNT(DISTINCT marque) <= 1
;

\qecho "--- ................................................................." ;
\qecho "3.9 Les organisations dont la valeur totale des achats est supérieure" ;
\qecho "    à 20% de la valeur totale des achats des autres organisations." ;
-- xox
\qecho ".v0 - correcte" ;
SELECT DISTINCT acheteur
FROM Transaction
WHERE
  (SELECT SUM(prix*quantite) FROM Transaction A WHERE Transaction.acheteur=A.acheteur)
  >
  0.2 * (SELECT SUM(prix*quantite) FROM Transaction A WHERE Transaction.acheteur<>A.acheteur)
;
\qecho ".v1 - correcte" ;
WITH
  Syn AS (SELECT acheteur, SUM(prix*quantite) AS st FROM Transaction GROUP BY acheteur),
  Bud AS (SELECT SUM(st) AS tot FROM Syn)
SELECT acheteur
FROM Syn
WHERE st > 0.2 * ((SELECT * FROM Bud)-st)
;


-- xox
\qecho "--- =================================================================" ;
\qecho "    Q4" ;
\qecho "--- =================================================================" ;
-- xox

\qecho "--- ................................................................." ;
\qecho "Écrire une fonction SQL qui retourne le prix maximal payé pour un produit." ;
-- xox

\qecho ".v0 - correcte" ;
create or replace function prix_max (p Produit_code) returns Montant
language sql as $$
  select Max(prix) from Transaction where produit=p;
$$;

\qecho ".v1 - correcte" ;
create or replace function prix_max (p Produit_code) returns Montant
return (
  select Max(prix) from Transaction where produit=p
  );

-- select prix_max('P32') ;

\qecho ".v2 - généralisation" ;
create or replace function t_prix_max () returns table (p Produit_code, m Montant)
begin atomic
  select produit, Max(prix) from Transaction group by produit;
end;


-- fin du solutionnaire
-- xox
\qecho "*** FIN DU SOLUTIONNAIRE Mercure_script-2023-1.sql (" `date -Iseconds` ")"

-- libération du fichier
\o

/*
-- =========================================================================== Z
Contributeurs :
  (LL01) Luc.Lavoie@USherbrooke.ca

Adresse, droits d’auteur et copyright :
  Μῆτις Ἀκαδήμεια
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  [CC-BY-NC-3.0 (http://creativecommons.org/licenses/by-nc/3.0)]
  http://info.usherbrooke.ca/llavoie/Metis

Tâches projetées :
NIL

Tâches réalisées :
2022-11-30 (LL01) _v141a : Modification pour l’examen IFT187 (2023-1)
  * Donner un nouveau contexte, plus général (traçage des produits sensibles).
  * Clarifier les prédicats des tables.
  * Renommer Achat -> Transaction.
2017-10-01 (LL01) _v140a : Modification pour l’examen IFT187 (2017-3)
  * retrait des références aux métaux, nouvelle répartition et
  * modification des requêtes.
2016-10-23 (LL01) _v130a : Simplification pour l’examen IFT187 (2016-3)
  * retrait de l’impression de la requête (faire imprimer le fichier)
  * ajout ou simplification de variantes.
2016-10-04 (LL01) _v120a : Adaptation pour l’examen IFT187 (2016-3)
  * Variation des questions et prédicats.
2015-09-28 (LL01) _v112a : Adaptation pour l’examen IFT187 (2015-3)
  * Correction de coquilles, reformulation de certains prédicats.
2015-02-28 (LL01) _v111b : Adaptation pour l’examen IFT187 (2015-1)
  * Correction de coquilles, reformulation de certains prédicats.
2014-02-20 (LL01) _v111a : Adaptation pour l’examen IFT187 (2014-1)
  * Correction de coquilles, ajout d’une illustration dans [l].
2013-08-27 (LL01) _v110a : Adaptation pour l’examen  IFT187 (2013-3)
  * Ajout de variantes
  * Changement de nom pour les tables Organisation et Produit
2006-12-09 (LL01) _v100a : Création.
  * Exemple pour le cours IFT 187 au Maroc
  * Inspiré d’une nouvelle publiée par le journal Al Watan.

Références :
[Date1997]
    DATE, C. J. ; DARWEN, H.
    "A guide to the SQL standard"
    4th ed., Addison-Wesley Inc., 1997.
    ISBN 0-201-96426-0
[Date2012]
    DATE, C. J. ;
    "SQL and the relationnal theory"
    2nd ed., O'Reilly, 2012.
    ISBN 978-1-449-31640-2

-- -----------------------------------------------------------------------------
-- fin de Enseignement/Exemples/Mercure/Mercure_script-2023-1.sql
-- =========================================================================== Z
*/
