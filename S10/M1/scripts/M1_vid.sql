/*
============================================================================== A
M1_vid.sql
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
-- Retrait de tous les tuples de toutes les tables.
--

set schema 'M1_pri' ;
delete from "A" ;
delete from "B" ;
delete from "C" ;

/*
============================================================================== Z
M1_vid.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
