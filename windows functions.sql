----------------------------WINDOWS FUNCTIONS------------------------


--Volume cumulé par utilisateur
--Table concernée : trade
--Objectif : voir le total des quantités exécutées par utilisateur, ligne par ligne.
SELECT 
    t.id_trade,
    t.id_ordre,
    o.id_user,
    t.quantite,
    SUM(t.quantite) OVER (PARTITION BY o.id_user ORDER BY t.date_execution) AS volume_cumule_user
FROM trade t
JOIN ordre o ON t.id_ordre = o.id_ordre
ORDER BY o.id_user, t.date_execution;

--Exemple : Prix moyen pondéré (VWAP) par paire
--Table concernée : trade
--Objectif : calculer le VWAP pour chaque paire de crypto à chaque moment.
SELECT 
    t.id_paire,
    t.date_execution,
    SUM(t.prix * t.quantite) OVER (PARTITION BY t.id_paire ORDER BY t.date_execution) /
    SUM(t.quantite) OVER (PARTITION BY t.id_paire ORDER BY t.date_execution) AS vwap_cumule
FROM trade t
ORDER BY t.id_paire, t.date_execution;

--Exemple : Dernier prix ou valeur d’indicateur
--Table concernée : prix_marche ou statistiques_marche
--Objectif : récupérer le dernier prix ou indicateur pour chaque paire.
SELECT 
    id_paire,
    prix,
    date_maj,
    ROW_NUMBER() OVER (PARTITION BY id_paire ORDER BY date_maj DESC) AS rang
FROM prix_marche
WHERE rang = 1;

--Exemple : Comparer avec la valeur précédente (LAG)
--Table : prix_marche
--Objectif : calculer la variation du prix par rapport au trade précédent
SELECT 
    id_paire,
    prix,
    date_maj,
    LAG(prix) OVER (PARTITION BY id_paire ORDER BY date_maj) AS prix_precedent,
    prix - LAG(prix) OVER (PARTITION BY id_paire ORDER BY date_maj) AS delta_prix
FROM prix_marche;

--Exemple : Classement des utilisateurs par volume
--Table : trade
--Objectif : voir qui a le plus gros volume total par période
SELECT 
    id_user,
    SUM(t.quantite) OVER (PARTITION BY id_user) AS volume_total,
    RANK() OVER (ORDER BY SUM(t.quantite) OVER (PARTITION BY id_user) DESC) AS rang
FROM trade t
JOIN ordre o ON t.id_ordre = o.id_ordre;
