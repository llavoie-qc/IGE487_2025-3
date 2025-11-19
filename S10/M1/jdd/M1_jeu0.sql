/*
============================================================================== A
M1_jeu0.sql
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
-- Jeu très réduits aux fins de tests éléments en cours de développement.
--

set schema 'M1_pri' ;
insert into "A" values (1, 'un'), (10,'dix'), (100,'cent') ;
insert into "B" values (1, 'one'), (10,'ten'), (100,'one hundred') ;
insert into "C" values (1, 'un'), (10,'dieci'), (100,'cento') ;

/*
============================================================================== Z
M1_jeu0.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
