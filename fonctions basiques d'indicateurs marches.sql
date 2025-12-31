------------------IMPLEMENTATION DES FONCTIONS BASIQUES POUR CALCULER LES INDICATEURS MARCHES------------------

----Volume total sur une période pour une paire: table trade
CREATE OR REPLACE FUNCTION calcul_volume_total(p_id_paire BIGINT, p_date_debut TIMESTAMP, p_date_fin TIMESTAMP)
RETURNS NUMERIC AS $$
DECLARE
    v_volume NUMERIC;
BEGIN
    SELECT SUM(quantite)
    INTO v_volume
    FROM trade
    WHERE id_paire = p_id_paire
      AND date_execution BETWEEN p_date_debut AND p_date_fin;

    RETURN COALESCE(v_volume, 0);
END;
$$ LANGUAGE plpgsql;

---Prix moyen sur une période pour une paire : table prix_marche
CREATE OR REPLACE FUNCTION prix_moyen(p_id_paire BIGINT, p_date_debut TIMESTAMP, p_date_fin TIMESTAMP)
RETURNS NUMERIC AS $$
DECLARE
    v_prix_moyen NUMERIC;
BEGIN
    SELECT AVG(prix)
    INTO v_prix_moyen
    FROM prix_marche
    WHERE id_paire = p_id_paire
      AND date_maj BETWEEN p_date_debut AND p_date_fin;

    RETURN COALESCE(v_prix_moyen, 0);
END;
$$ LANGUAGE plpgsql;

---Mise à jour de la quantité exécutée d’un ordre table ordre
CREATE OR REPLACE FUNCTION update_ordre_quantite(p_id_ordre BIGINT)
RETURNS VOID AS $$
DECLARE
    v_quantite_executee BIGINT;
BEGIN
    
    SELECT COALESCE(SUM(quantite), 0)
    INTO v_quantite_executee
    FROM trade
    WHERE id_ordre = p_id_ordre;


    UPDATE ordre
    SET quantite = quantite - v_quantite_executee
    WHERE id_ordre = p_id_ordre;
END;
$$ LANGUAGE plpgsql;

---VWAP = ∑(prix×quantite)∑(quantite) : table trade
CREATE OR REPLACE FUNCTION calcul_vwap(p_id_paire BIGINT,p_date_debut TIMESTAMPTZ,p_date_fin TIMESTAMPTZ)
RETURNS NUMERIC AS $$
DECLARE
    v_vwap NUMERIC;
BEGIN
    SELECT
        CASE
            WHEN SUM(quantite) = 0 THEN NULL
            ELSE SUM(prix * quantite) / SUM(quantite)
        END
    INTO v_vwap
    FROM trade
    WHERE id_paire = p_id_paire
      AND date_execution BETWEEN p_date_debut AND p_date_fin;

    RETURN v_vwap;
END;
$$ LANGUAGE plpgsql;
 
---Volatilité = écart-type des prix : table trade
CREATE OR REPLACE FUNCTION calcul_volatilite(p_id_paire BIGINT,p_periode INTEGER DEFAULT 30)
RETURNS NUMERIC(10,6)
LANGUAGE plpgsql
AS $$
DECLARE
    v_volatilite NUMERIC;
BEGIN
    WITH rendements AS (
        SELECT
            LN(prix / LAG(prix) OVER (ORDER BY date_maj)) AS rendement
        FROM prix_marche
        WHERE id_paire = p_id_paire
        ORDER BY date_maj DESC
        LIMIT p_periode + 1
    )
    SELECT
        STDDEV(rendement)
    INTO v_volatilite
    FROM rendements
    WHERE rendement IS NOT NULL;

    RETURN ROUND(v_volatilite, 6);
END;
$$;

---RSI :
----
--**gain = max(prix_t - prix_t-1, 0)
--**loss = max(prix_t-1 - prix_t, 0)
--**RS = avg(gain) / avg(loss)
--**RSI = 100 - (100 / (1 + RS))
-----
CREATE OR REPLACE FUNCTION calcul_rsi(
    p_id_paire BIGINT,
    p_periode INTEGER DEFAULT 14
)
RETURNS NUMERIC(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_avg_gain NUMERIC;
    v_avg_loss NUMERIC;
    v_rsi NUMERIC;
BEGIN
    WITH prix_diff AS (
        SELECT
            prix - LAG(prix) OVER (ORDER BY date_maj) AS diff
        FROM prix_marche
        WHERE id_paire = p_id_paire
        ORDER BY date_maj DESC
        LIMIT p_periode + 1
    ),
    gains_losses AS (
        SELECT
            CASE WHEN diff > 0 THEN diff ELSE 0 END AS gain,
            CASE WHEN diff < 0 THEN ABS(diff) ELSE 0 END AS loss
        FROM prix_diff
        WHERE diff IS NOT NULL
    )
    SELECT
        AVG(gain),
        AVG(loss)
    INTO v_avg_gain, v_avg_loss
    FROM gains_losses;

    IF v_avg_loss = 0 THEN
        RETURN 100;
    END IF;

    v_rsi := 100 - (100 / (1 + (v_avg_gain / v_avg_loss)));

    RETURN ROUND(v_rsi, 2);
END;
$$;
