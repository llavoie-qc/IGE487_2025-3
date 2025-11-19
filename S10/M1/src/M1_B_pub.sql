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

create role "M1_B" ;
comment on role "M1_B" is $$
Groupe des utilisateurs pouvant utiliser les entités du module M1 assujetties à
la politique d’accès B.
$$;

create schema "M1_B" ;
comment on schema "M1_B" is $$
Interface programmatique (API) du module M1 assujettie à la politique d’accès B.
$$;
grant "M1" to "M1_B" ;
grant usage on schema "M1_B" to "M1_B" ;

-- Si on implante les profils associés au politiques de gestion d’accès,
-- il suffit d'octroyer le rôle M1_B au profil approprié, par exemple :
-- grant "M1_B" to "GPA_B" ;

--
-- Définir la signature des routines de l'interface M1_B
-- (une procédure consultant modifiant la table B)
--

set schema 'M1_B' ;

create procedure "Add" (_k "M1"."Cardinal", _v Text)
begin atomic -- DataGrip n'accepte toujours pas la syntaxe des procédures de PostgreSQL
  -- corps bidon
end ;
grant execute on procedure "Add" ("M1"."Cardinal", Text) to "M1_B" ;

/*
============================================================================== Z
M1_B.sql
------------------------------------------------------------------------------ Z
Contributeurs, droits, copyright, licences... : voir M1_ini.sql
============================================================================== Z
*/
