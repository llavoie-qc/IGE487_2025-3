/*
============================================================================== A
M1_ind.sql
------------------------------------------------------------------------------ A
Produit : M1
Résumé : Module utilisé à titre d’exemple de la gestion des politiques d’accès (GPA).
Projet : Metis_GPA_2022-2
Responsable : luc.lavoie@usherbrooke.ca
Version : 2022-07-15
Statut : en cours de développement
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 14
============================================================================== A
*/

--
-- Indéfinition (drop) du module M1.
--

drop schema if exists "M1" cascade;
drop schema if exists "M1_A" cascade;
drop schema if exists "M1_B" cascade;
drop schema if exists "M1_pri" cascade;

drop role if exists "M1" ;
drop role if exists "M1_A" ;
drop role if exists "M1_B" ;

/*
============================================================================== Z
M1_ind.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
