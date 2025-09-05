-- TODO 2025-09-04 LL01. Refactorisation de P_etudiante_DM.sql
--  * Personne -> P_etudiante
--  * Revue

CREATE TABLE Personne
(
  matricule  Matricule   NOT NULL,
  nom        Varchar     NOT NULL,
  ddn        Date,
  adresse    Varchar,
  CONSTRAINT Personne_ddn CHECK (ddn >= '1900-01-01'),
  CONSTRAINT Personne_cc0 PRIMARY KEY (matricule)
)
;

insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('12345678', 'Jean', '1900-01-01', 'Saint-Malo'),
  ('23456781', 'Anna', '1920-01-27', 'Douala');

insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('11110000', 'Zara', '1899-12-31', 'Tanger');

insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('11112222', 'Atan', NULL,         'Lévis');

insert into Personne
  (matricule,  nom,    ddn,          adresse)
values
  ('11114444', 'Paul', '2025-09-01', NULL);

select count(*) as "nb. tuples de Personne"
from Personne ;

select count(*) as "nb. tuples de Personne"
from Personne
where ddn >= '1900-01-01' ;

select *
from Personne
order by nom, matricule ;

drop table Personne cascade ;

