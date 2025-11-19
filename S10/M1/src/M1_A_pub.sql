/*
============================================================================== A
M1_A_pub.sql
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

create role "M1_A" ;
comment on role "M1_A" is $$
Groupe des utilisateurs pouvant utiliser les entités du module M1 assujetties à
la politique d’accès A.
$$;

create schema "M1_A" ;
comment on schema "M1_A" is $$
Interface programmatique (API) du module M1 assujettie à la politique d’accès A.
$$;
grant "M1" to "M1_A" ;
grant usage on schema "M1_A" to "M1_A" ;

-- Si on implante les profils associés au politiques de gestion d’accès,
-- il suffit d'octroyer le rôle M1_A au profil approprié, par exemple :
-- grant "M1_A" to "GPA_A" ;

--
-- Définir la signature des routines de l'interface M1_A
-- (une fonction consultant la table A)
--

set schema 'M1_A' ;

create function "nb" (_seuil "M1"."Cardinal") returns "M1"."Cardinal"
  volatile
return
  0 ; -- corps bidon
grant execute on function "nb" ("M1"."Cardinal") to "M1_A" ;

/*
============================================================================== Z
M1_A_pub.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
