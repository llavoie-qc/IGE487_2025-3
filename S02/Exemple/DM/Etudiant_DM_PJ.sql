-- Etudiant_PJ

create table Etudiant_PJ
(
  matricule  Matricule not null,
  nom        Varchar not null,
  constraint Etudiant_PJ_cc0 primary key (matricule)
)
;

create table Etudiant_PJ_avec_adresse
(
  matricule  Matricule not null,
  adresse    Varchar not null,
  constraint Etudiant_PJ_avec_adresse_cc0 primary key (matricule),
  constraint Etudiant_PJ_avec_adresse_cr0 foreign key (matricule)
    references Etudiant_PJ
)
;

--
-- Relations connexes
--

-- Les étudiants dont les attributs facultatifs sont disponibles
-- (avec l’ensemble des attributs, obligatoires et facultatifs)
create view Etudiant_PJ_complet (matricule, nom, adresse) as
  select matricule, nom, adresse
  from Etudiant_PJ natural join Etudiant_PJ_avec_adresse
;

-- Les étudiants dont l’adresse est inconnue.
-- (avec les seuls attributs obligatoires)
create view Etudiant_PJ_sans_adresse (matricule, nom) as
  select matricule, nom from Etudiant_PJ
  except
  select matricule, nom from Etudiant_PJ_complet
;

-- Table complète équivalente à Etudiant_NULL_adresse
create view Etudiant_PJ_table_NULL (matricule, nom, adresse) as
  select matricule, nom, adresse
  from Etudiant_PJ left join Etudiant_PJ_avec_adresse using (matricule)
;

-- Table complète annotée
-- Potentiellement utile pour l’affichage
create view Etudiant_PJ_table_DM (matricule, nom, adresse) as
  select matricule, nom, coalesce(adresse, '<donnée manquante>') as adressse
  from Etudiant_PJ left join Etudiant_PJ_avec_adresse using (matricule)
;
