/*
============================================================================== A
M1_B.sql
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
-- Définir la mise en oeuvre des routines de l'interface M1_B
-- (une procédure modifiant la table B)
--

set schema 'M1_B' ;

create or replace procedure "Add" (_k "M1"."Cardinal", _v Text)
  external security definer
begin atomic -- DataGrip 2022.2 n'accepte toujours pas la syntaxe des procédures de PostgreSQL 14.
  insert into "M1_pri"."B" values (_k, _v) ;
end ;

/*
============================================================================== Z
M1_B.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_def.sql
============================================================================== Z
*/
