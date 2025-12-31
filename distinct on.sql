--------------------- DISTINCT ON -------------------------------

--Exemple : dernier prix exécuté d’un ordre
SELECT DISTINCT ON (t.id_ordre)
       t.id_ordre,
       t.prix,
       t.date_execution
FROM trade t
ORDER BY t.id_ordre, t.date_execution DESC;

--DISTINCT ON pour obtenir le dernier prix ou état de l’ordre
SELECT DISTINCT ON (o.id_ordre)
       o.id_ordre,
       t.prix AS dernier_prix,
       t.date_execution,
       o.statut
FROM ordre o
JOIN trade t ON t.id_ordre = o.id_ordre
ORDER BY o.id_ordre, t.date_execution DESC;

