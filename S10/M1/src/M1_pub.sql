/*
============================================================================== A
M1_pub.sql
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

create role "M1" ;
comment on role "M1" is $$
Groupe des utilisateurs pouvant utiliser l'interface commune publique du module M1.
$$;

create schema "M1";
comment on schema "M1" is $$
Schéma dédié à la base commune publique du module M1 utilisé à titre d’exemple
de la gestion des politiques d’accès (GPA).
$$;
grant usage on schema "M1" to "M1" ;

--
-- Base commune publique (un domaine et une fonction immuable).
--

set schema 'M1' ;

create domain "Cardinal" as Bigint check (value >= 0) ;
grant usage on domain "Cardinal" to "M1" ;

create function "f" () returns "Cardinal" immutable return 12;
grant execute on function "f" () to "M1" ;

--
-- Gestion des droits
--

-- NOTE
--  Un gestion individuelle des droits est privilégiée pour le moment.
--  La gestion collective (on all xxx in schema sss) apparait intéressante,
--  mais elle n'est pas disponible pour tous les objets :
--    * disponible :
--      - table, sequence, function, procedure, routine ;
--    * non disponible étrange et ennuyeux :
--      - domain, type ;
--    * non disponible prévisible :
--      - database, foreign data wrapper, foreign server, langage, large object,
--        schema, table space
--  À réviser en fonction de l'expérience et de l'évolution de PostgreSQL
/*
============================================================================== Z
M1_pub.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
