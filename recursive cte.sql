--------------------- RECURSIVE CTE -------------------------------
--**détecter anomalies et patterns suspects

WITH RECURSIVE ordre_chain AS (

    -- ① Point de départ : chaque ordre annulé
    SELECT
        o.id_ordre,
        o.id_user,
        o.id_paire,
        o.date_creation,
        1 AS profondeur
    FROM ordre o
    WHERE o.statut = 'annule'

    UNION ALL

    -- ② Ordre annulé suivant du même user + même paire
    SELECT
        o2.id_ordre,
        o2.id_user,
        o2.id_paire,
        o2.date_creation,
        oc.profondeur + 1
    FROM ordre_chain oc
    JOIN ordre o2
        ON o2.id_user = oc.id_user
       AND o2.id_paire = oc.id_paire
       AND o2.statut = 'annule'
       AND o2.date_creation > oc.date_creation
       AND o2.date_creation <= oc.date_creation + INTERVAL '5 minutes'
)

-- ③ Détection de l’anomalie
SELECT
    id_user,
    id_paire,
    MAX(profondeur) AS nb_annulations_consecutives
FROM ordre_chain
GROUP BY id_user, id_paire
HAVING MAX(profondeur) >= 3;
