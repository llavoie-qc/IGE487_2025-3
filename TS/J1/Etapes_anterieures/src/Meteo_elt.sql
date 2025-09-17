/*
////
-- =========================================================================== A
-- Meteo_elt.sql
-- ---------------------------------------------------------------------------
Activité : IFT187_2022-1
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 17
Responsable : luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : en cours de développement
Résumé : Importation des données d'observations météorologiques.
-- =========================================================================== A
*/

/*
-- =========================================================================== B
////

Création des types, tables et routines requises pour les tâches d’importation
(vérification, conversion et transformation) requises par le mécanisme d’ELT.

Utilisation de la stratégie B et de la tactique 1 décrites dans le document
Herbivorie_ELT_SCL.adoc

Le présent solutionnaire comprend plus de types de mesures (et de mesures)
que ce qui était requis au TP4.

Par contre, le jeu de données esquissé est insuffisant par rapport aux exigences
du TP4.

////
-- =========================================================================== B
*/

--
-- Spécification du schéma
--
SET SCHEMA 'Herbivorie' ;

--
-- == Ajustement du domaine Date_eco
--
-- Afin d’offrir une meilleure validation des données, nous modifions la
-- définition de Date_eco afin de la réduire à une portée plus réaliste.
-- NOTE : ceci n'était pas demandé dans le TP4.
--
alter domain Date_eco drop constraint Date_eco_check ;
alter domain Date_eco add constraint Date_eco_check
  check ((extract(year from value) between 2016 and 2030));

--
-- == Vérification et conversion de Date_eco
--

-- Vérification
create or replace function Date_eco_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
with
  syntaxe as (
    select argument,
      argument similar to '[0-9]{4}-[0-9]{2}-[0-9]{2}' as syntaxe_ok,
      split_part(argument, '-', 1) as annee_p,
      split_part(argument, '-', 2) as mois_p,
      split_part(argument, '-', 3) as jour_p
    ),
  evaluation as (
    select *,
      case when syntaxe_ok then annee_p::int else 1900 end annee,
      case when syntaxe_ok then mois_p::int else 1 end mois,
      case when syntaxe_ok then jour_p::int else 1 end jour
    from syntaxe),
  verification as (
    select *,
      case
      when mois in (1,3,5,7,8,10,12) then jour between 1 and 31
      when mois in (4,6,9,11) then jour between 1 and 30
      when mois = 2 then
        case when annee/4*4 = annee and (annee/100*100 <> annee or annee/400*400 = annee)
        then jour between 1 and 29
        else jour between 1 and 28 end
      else false end as valide
    from evaluation)
select
  syntaxe_ok and valide and (annee between 2016 and 2030) as resultat
from verification
$$;

-- Petit test Date_eco_verif
with
  A (d) as (values ('2021-12-03'), ('2021-02-29'), ('0000-12-31'), ('2015-12-31'), ('2031-01-01'))
select
  d as date , Date_eco_verif(d) as valide
from A ;

-- Conversion
create or replace function Date_eco_conv (argument text)
returns date_eco
language sql as
$$
select to_date(argument, 'yyyy-mm-dd')
$$;

--
-- == Vérification d'entiers compris entre dans un intervalle [min..max] compris dans [-999999..999999]
--

create or replace function Entier_verif (argument text, min integer, max integer)
returns boolean -- vrai SSI valide
language sql as
$$
select
  case
    when argument similar to '(-)?[0-9]{1,6}' then
      cast (argument as integer) between min and max
    else
      false
  end
$$;

--
-- == Vérification et conversion de valeurs de type Temperature
--

-- Verification
create or replace function Temperature_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, -50, 50) ;
$$;

-- Conversion
create or replace function Temperature_conv (argument text)
returns Temperature
language sql as
$$
select CAST (argument AS Temperature)
$$;

--
-- == Vérification et conversion de valeurs de type Humidite
--

-- Verification
create or replace function Humidite_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 0, 100) ;
$$;

-- Conversion
create or replace function Humidite_conv (argument text)
returns Humidite
language sql as
$$
select CAST (argument AS Humidite)
$$;

--
-- == Vérification et conversion de valeurs de type Vitesse
--

-- Verification
create or replace function Vitesse_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 0, 300) ;
$$;

-- Conversion
create or replace function Vitesse_conv (argument text)
returns Vitesse
language sql as
$$
select CAST (argument AS Vitesse)
$$;

--
-- == Vérification et conversion de valeurs de type Pression
--

-- Verification
create or replace function Pression_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 900, 1100) ;
$$;

-- Conversion
create or replace function Pression_conv (argument text)
returns Pression
language sql as
$$
select CAST (argument AS Pression)
$$;

--
-- == Vérification et conversion de valeurs de type HNP
--

-- Verification
create or replace function HNP_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select Entier_verif(argument, 0, 500) ;
$$;

-- Conversion
create or replace function HNP_conv (argument text)
returns HNP
language sql as
$$
select CAST (argument AS HNP)
$$;

--
-- == Vérification et conversion de valeurs de type Code_P
--

-- Verification
create or replace function Code_P_verif (argument text)
returns boolean -- vrai SSI valide
language sql as
$$
select argument in (select code from TypePrecipitations)
$$;

-- Conversion
create or replace function Code_P_conv (argument text)
returns Code_P
language sql as
$$
select CAST (argument AS Code_P)
$$;

--
-- == Définition de la procédure d’importation
--

create or replace procedure Meteo_ELT ()
language plpgsql as
$$
begin

insert into ObsTemperature (date, temp_min, temp_max, note)
  select
    date_eco_conv(date) as date,
    Temperature_conv(temp_min) as temp_min,
    Temperature_conv(temp_max) as temp_max,
    coalesce (note, '') as note
  from CarnetMeteo where
    date_eco_verif(date)
    and Temperature_verif(temp_min)
    and Temperature_verif(temp_max) ;

insert into ObsHumidite (date, hum_min, hum_max)
  select
    date_eco_conv(date) as date,
    Humidite_conv(hum_min) as hum_min,
    Humidite_conv(hum_max) as hum_max
  from CarnetMeteo where
    date_eco_verif(date)
    and Humidite_verif(hum_min)
    and Humidite_verif(hum_max) ;

-- NOTE Il peut paraitre étrange de permettre l'insertion de précipitations nulles.
--      Nous laisserons à nos amis écologistes le soin de les retirer s'il je juge opportun.
--      On remarque par ailleurs qu'on peut mettre chaque jour une mesure de précipitations
--      pour chacun des types de précipitations
insert into ObsPrecipitations (date, prec_tot, prec_nat)
  select
    date_eco_conv(date) as date,
    HNP_conv(prec_tot) as prec_tot,
    Code_p_conv(prec_nat) as prec_nat
  from CarnetMeteo where
    date_eco_verif(date)
    and HNP_verif(prec_tot)
    and Code_p_verif(prec_nat) ;

insert into ObsVents (date, vent_min, vent_max)
  select
    date_eco_conv(date) as date,
    Vitesse_conv(vent_min) as vent_min,
    Vitesse_conv(vent_max) as vent_max
  from CarnetMeteo where
    date_eco_verif(date)
    and Vitesse_verif(vent_min)
    and Vitesse_verif(vent_max) ;

-- NOTE Qu'aurait-il fallu faire si nous avions mis une contrainte exigeant que
--      pres_min <= pres_max ?

insert into ObsPression (date, pres_min, pres_max)
  with T as (
    select
      date_eco_conv(date) as date,
      Pression_conv(pres_min) as pres_min,
      Pression_conv(pres_max) as pres_max
    from CarnetMeteo where
      date_eco_verif(date)
      and Pression_verif(pres_min)
      and Pression_verif(pres_max)
    )
  select * from T where pres_min <= pres_max;

-- NOTE Il serait possible de corriger toutes nos tables pour inclure la contrainte min_max
--      sur le modèle suivant :
--
--      alter table ObsPression add
--        constraint ObsPression_min_max check (pres_min <= pres_max) ;
--
--      et ensuite notre procédure Meteo_ELT à l'avenant :-)

end;
$$;

/*
-- =========================================================================== Z
////
.Contributeurs
* (LL01) luc.lavoie@usherbrooke.ca

.Tâches projetées
* 2022-01-23 LL01. Refactoriser les mesures.

.Tâches réalisées
* 2022-01-23 LL01. Épurer le schéma.
* 2017-09-17 LL01. Création.

.Références
* {CoFELI}/Exemple/Herbivorie/pub/Herbivorie_EPP.pdf
////

.Adresse, droits d’auteur et copyright
  Groupe Metis
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

-- -----------------------------------------------------------------------------
-- fin de {CoFELI}/Exemple/Herbivorie/src/Meteo_elt.sql
-- =========================================================================== Z
*/
