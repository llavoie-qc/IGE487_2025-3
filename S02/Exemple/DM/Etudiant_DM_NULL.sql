-- Etudiant_NULL

create table Etudiant_NULL_adresse
(
  matricule  Matricule not null,
  nom        Varchar not null,
  adresse    Varchar null,
  constraint Etudiant_NULL_adresse_cc0 primary key (matricule)
)
;

--
-- Relations connexes
--

-- Les étudiants dont les attributs facultatifs sont disponibles
-- (avec l’ensemble des attributs, obligatoires et facultatifs)
create view Etudiant_NULL_complet (matricule, nom, adresse) as
  select matricule, nom, adresse
  from Etudiant_NULL_adresse where adresse is not null
;

-- Les étudiants dont l’adresse est inconnue.
-- (avec les seuls attributs obligatoires)
create view Etudiant_NULL_sans_adresse (matricule, nom) as
  select matricule, nom
  from Etudiant_NULL_adresse where adresse is null
;

-- Table complète annotée
-- Potentiellement utile pour l’affichage
create view Etudiant_NULL_table_DM (matricule, nom, adresse) as
  select matricule, nom, coalesce(adresse, '<donnée manquante>') as adressse
  from Etudiant_NULL_adresse
;
