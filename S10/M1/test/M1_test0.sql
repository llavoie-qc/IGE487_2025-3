/*
============================================================================== A
M1_test0.sql
------------------------------------------------------------------------------ A
Produit : M1
Résumé : Module utilisé à titre d'exemple de la gestion de politique d'accès (GPA).
Projet : Metis_GPA_2022-2
Responsable : Luc.Lavoie@USherbrooke.ca
Version : 2022-07-15
Statut : en cours de développement
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 14
============================================================================== A
*/

--
-- Utilisateurs (rôles avec login) fictifs définis pour les fins du test
--
create role "U0" login password 'U0' ;
create role "U1" login password 'U1' ;
create role "U2" login password 'U2' ;
create role "U3" login password 'U3' ;

--
-- Définir les droits des utilisateurs
--

-- N'accorder aucun droits à U0
-- Rien à faire :-)

-- Accorder les droits de M1_A à U1
grant "M1_A" to "U1" ;

-- Accorder les droits de M1_B à U2
grant "M1_B" to "U2" ;

-- Accorder les droits de M1_A et M1_B à U3
grant "M1_A", "M1_B" to "U3" ;


/*
Tests exécutés (manuellement pour moment ).
*/

-- TODO Vérifier que toute modification des droits de X se percole à Y suite à «grant X to Y».
--      et ce, même lorsque les modifications ont lieu postérieurement au «grant».
--      Si ce n'est pas le cas, il faudra regrouper les «grant» structurels de façon
--      à pouvoir les exécuter après chaque modification à un droit atomique.

-- TODO Vérifier que "M1" peut tout faire !
-- À faire en psql en établissant la connexion avec l'usager M1

-- TODO vérifier les accès de {u0..u3} à {A, B, C, M1_A, M1_B}.
-- À faire en psql en établissant les connexions avec les usagers u0..u3

-- Divers
select "M1_A"."nb" ("M1"."f"()) ;
call "M1_B"."Add" (13, 'thirteen') ;
