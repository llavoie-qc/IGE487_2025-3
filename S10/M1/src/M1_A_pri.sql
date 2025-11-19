/*
============================================================================== A
M1_A_pri.sql
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
-- Définir la mise en oeuvre des routines de l'interface M1_A
-- (une fonction consultant la table A)
--

set schema 'M1_A' ;
create or replace function "nb" (_seuil "M1"."Cardinal") returns "M1"."Cardinal"
  volatile
  external security definer
return
  (select count (*) from "M1_pri"."A" where "k" > _seuil) ;

/*
============================================================================== Z
M1_A_pri.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
