/*
============================================================================== A
M1_pri.sql
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

create schema "M1_pri";
comment on schema "M1_pri" is $$
Schéma dédié à la partie privée (hors API) du module M1 utilisé à titre d’exemple
de la gestion des politiques d’accès (GPA).
$$;

--
-- Base commune privée (trois tables).
--

set schema 'M1_pri' ;

create table "A" ("k" "M1"."Cardinal", "v" Text, primary key ("k"));
create table "B" ("k" "M1"."Cardinal", "v" Text, primary key ("k"));
create table "C" ("k" "M1"."Cardinal", "v" Text, primary key ("k"));

--
-- La partie M1_ext (pouvant utiliser les routines de M1_A et M1_B)
-- peut être ajoutée immédiatement ci-après
--

-- exemple à compléter

/*
============================================================================== Z
M1_pri.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
