CREATE TABLE Personne
-- La personne identifiée par le matricule «matricule» est nommée «nom»,
-- est née le «ddn» au lieu dit «adresse».
(
  matricule  Matricule   NOT NULL,
  nom        Varchar     NOT NULL,
  ddn        Date,
  adresse    Varchar,
  CONSTRAINT Personne_ddn CHECK (ddn >= '1900-01-01'),
  CONSTRAINT Personne_cc0 PRIMARY KEY (matricule)
)
;

-- Valeurs légitimes
insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('12345678', 'Jean', '1900-01-01', 'Saint-Malo'),
  ('23456781', 'Anna', '1920-01-27', 'Douala');

-- Valeur non légitime
insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('11110000', 'Zara', '1899-12-31', 'Tanger');

-- Valeur légitime
insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('11112222', 'Atan', NULL,         'Lévis');

-- Valeur légitime
insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('11114444', 'Paul', '2025-09-01', NULL);

-- Dénombrement
select count(*) as "nb. tuples de Personne"
from Personne ;

select count(*) as "nb. tuples de Personne"
from Personne
where ddn >= '1900-01-01' ;

-- Illustration de la propriété du tiers exclu.
-- A - Quels sont les tuples retenus ?
select *
from Personne
where (ddn >= '1900-01-01')
order by nom, matricule ;

-- B - Quels sont les tuples non retenus ?
select *
from Personne
where not (ddn >= '1900-01-01')
order by nom, matricule ;

-- Conclusion : Il y a donc des tuples qui ne sont ni retenus, ni non retenus !

drop table Personne cascade ;

-- TODO 2025-09-04 LL01. Refactorisation de P_etudiante_DM.sql
--  * Personne -> P_etudiante
--  * Annotations en Discipulus
--  * Revue
