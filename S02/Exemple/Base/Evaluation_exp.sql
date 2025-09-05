create or replace function Resultat_m
  (_matricule Matricule)
  returns Integer
return 1;

/*TEST*/select Resultat_m
/*TEST*/  ('15113150');
/*TEST*/select Resultat_m
/*TEST*/  (CAST('15113150' AS Matricule));

create or replace function Resultat_t
  (_trimestre Trimestre)
  returns Integer
return 2;

/*TEST*/select Resultat_t
/*TEST*/  (20133);
/*TEST*/select Resultat_t
/*TEST*/  (CAST(20133 AS Trimestre));

create or replace function Resultat_ms
  (_matricule Matricule, _activite SigleCours, _trimestre Trimestre)
  returns Integer
return 3;

/*TEST*/select Resultat_ms
/*TEST*/  ('15113150', 'IFT187');
/*TEST*/select Resultat_ms
/*TEST*/  (CAST('15113150' AS Matricule), CAST('IFT187' AS SigleCours));

create or replace function Resultat_3
  (_matricule Matricule, _activite SigleCours, _trimestre Trimestre)
  returns Integer
return 3;

/*TEST*/select Resultat_3
/*TEST*/  ('15113150', 'IFT187', 20133);
/*TEST*/select Resultat_3
/*TEST*/  (CAST('15113150' AS Matricule), CAST('IFT187' AS SigleCours), CAST(20133 AS Trimestre));