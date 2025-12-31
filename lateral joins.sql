--------------------- LATERAL JOINS -------------------------------

--Exemple : Objectif : Pour chaque utilisateur et chaque paire de trading, récupérer :
--**Le nombre de trades effectués
--**Le volume total (quantité totale des trades)
--**Le dernier prix du trade

SELECT 
    o.id_user,
    o.id_paire,
    stats.nb_trades,
    stats.total_volume,
    last_trade.prix AS dernier_prix,
    last_trade.date_execution
FROM (
    SELECT DISTINCT id_user, id_paire
    FROM ordre
) o
-- statistiques cumulées
JOIN LATERAL (
    SELECT 
        COUNT(t.id_trade) AS nb_trades,
        COALESCE(SUM(t.quantite), 0) AS total_volume
    FROM ordre o2
    JOIN trade t ON t.id_ordre = o2.id_ordre
    WHERE o2.id_user = o.id_user
      AND o2.id_paire = o.id_paire
) stats ON true
-- dernier trade
JOIN LATERAL (
    SELECT t.prix, t.date_execution
    FROM ordre o3
    JOIN trade t ON t.id_ordre = o3.id_ordre
    WHERE o3.id_user = o.id_user
      AND o3.id_paire = o.id_paire
    ORDER BY t.date_execution DESC
    LIMIT 1
) last_trade ON true;
