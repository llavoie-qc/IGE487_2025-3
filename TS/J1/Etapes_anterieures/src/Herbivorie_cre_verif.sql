
/*
== Validation de la table Taux

Il y a deux approches pour assurer la compacité de la table Taux sur son intervalle
de définition [0..100].

.Par vérification explicite de la compacité
....
create assertion Taux_Compcite as check (Test_Taux_compacite (0,100)) ;
....

.Par construction la table virtuelle (vue) Taux à partir seuils tMin
Par exemple à partir des seuils
....
  ('A', 76),
  ('B', 51),
  ('C', 26),
  ('D', 6),
  ('E', 1),
  ('F', 0)
....

On construit la table (vue) suivante
....
  ('A', 76, 100),
  ('B', 51, 75),
  ('C', 26, 50),
  ('D', 6, 25),
  ('E', 1, 5),
  ('F', 0, 0)
....

.Remarque
La seule contrainte applicable aux codes tCat est leur unicité.
Notamment, lors de leur utilisation, on prendra donc soin de ne pas se reposer
sur leur ordre.
Par exemple, la table suivante est valide :
....
  ('T', 76, 100),
  ('X', 51, 75),
  ('Y', 26, 50),
  ('D', 6, 25),
  ('M', 1, 5),
  ('F', 0, 0)
....


*/

create or replace function Test_Taux_compacite (sMin Taux_val, sMax Taux_val) returns Boolean
  immutable
return
  (select min(tMin) from Taux) = sMin and
  (select max(tMax) from Taux) = sMax and
  not exists (
    select tMin
    from Taux as tr
    where (tr.tMax+1) <> (
      select min(tMin) as x
      from Taux as ts
      where tr.tMin < ts.tMin)
    )
/*
  -- ce qui suit est redondant si les trois conditions précédentes sont vérifiées
  and exists (
    select 1
    from Taux
    where tMax = 100 and tMin = (select max(tMin)from Taux)
    )
*/
;
