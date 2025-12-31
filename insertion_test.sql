------------------------ INSERTION --------------------------------

--**Insérer les cryptomonnaies
INSERT INTO cryptomonnaie(nom, symbole, date_creation, statut)
VALUES 
('Bitcoin', 'BTC', now() - INTERVAL '1000 days', 'actif'),
('Ethereum', 'ETH', now() - INTERVAL '900 days', 'actif'),
('Cardano', 'ADA', now() - INTERVAL '800 days', 'actif');


--**Insérer les utilisateurs
INSERT INTO utilisateur(nom, email, statut)
SELECT 
    'User_' || gs AS nom,
    'user'|| gs || '@example.com' AS email,
    CASE WHEN gs % 2 = 0 THEN 'actif' ELSE 'inactif' END AS statut
FROM generate_series(1, 10) gs;

--**Insérer les portefeuilles
INSERT INTO portefeuille(id_user, id_crypto, solde_total, solde_bloque)
SELECT u.id_user, c.id_crypto,
       (1000 + random()*9000)::NUMERIC(20,2),
       (random()*1000)::NUMERIC(20,2)
FROM utilisateur u
CROSS JOIN cryptomonnaie c;

--**Insérer les paires de trading
INSERT INTO paire_trading(crypto_base , crypto_cotation, statut, date_ouverture)
SELECT c1.symbole, c2.symbole,
       'disponible',
       now() - (random()*100)::INT * INTERVAL '1 day'
FROM cryptomonnaie c1
CROSS JOIN cryptomonnaie c2
WHERE c1.symbole <> c2.symbole;

--**Insérer les ordres
INSERT INTO ordre(type_ordre, mode_execution, quantite, prix, statut, date_creation, id_user, id_paire)
SELECT 
    CASE WHEN random() < 0.5 THEN 'achat' ELSE 'vente' END,
    CASE WHEN random() < 0.5 THEN 'market' ELSE 'limit' END,
    (random()*10+1)::BIGINT,
    (random()*50000+1000)::NUMERIC(20,2),
    'en attente',
	now() - (random()*30)::INT * INTERVAL '1 day',
    u.id_user,
    p.id_paire
FROM utilisateur u
CROSS JOIN paire_trading p
LIMIT 50;

--**Insérer les trades
INSERT INTO trade(id_ordre, id_paire, quantite, prix, date_execution)
SELECT 
    o.id_ordre,
    o.id_paire,
    LEAST(o.quantite, (random()*5+1)::BIGINT),
    o.prix * (0.95 + random()*0.1),
    -- S'assurer que la date reste dans le passé et dans la partition
    LEAST(
        o.date_creation + (random()*2)::INT * INTERVAL '1 hour',
        now()
    )
FROM ordre o
WHERE o.statut = 'en attente'
  AND o.date_creation >= '2025-12-30'  -- pour correspondre à la partition trade_2026_01
  AND o.date_creation < '2026-01-30'  -- fin du range
LIMIT 50;

--**Inserer prix_marche
INSERT INTO prix_marche(prix, volume, date_maj, id_paire)
SELECT
    (random() * 50000 + 1000)::NUMERIC(20,2),  -- prix > 0
    (random() * 100 + 1)::NUMERIC(20,2),       -- volume > 0
    LEAST(now() - (random()*30)::INT * INTERVAL '1 day', now()),  -- date passée <= now()
    p.id_paire
FROM paire_trading p
LIMIT 50;


--**Inserer audit_trail
INSERT INTO audit_trail(table_cible, record_id, action, date_action, details, id_user)
SELECT
    'ordre',
    o.id_ordre,
    CASE WHEN random() < 0.33 THEN 'INSERT'
         WHEN random() < 0.66 THEN 'UPDATE'
         ELSE 'DELETE' END,
    LEAST(now() - (random()*30)::INT * INTERVAL '1 day', now()),
    'Insertion test',
    u.id_user
FROM ordre o
CROSS JOIN utilisateur u
LIMIT 50;

--**Inserer detection_anomalie
INSERT INTO detection_anomalie(type, date_detection, commentaire, id_ordre, id_user)
SELECT
    CASE WHEN random() < 0.5 THEN 'volume anormal' ELSE 'prix anormal' END,
    LEAST(now() - (random()*30)::INT * INTERVAL '1 day', now()),
    'Test détection',
    o.id_ordre,
    u.id_user
FROM ordre o
CROSS JOIN utilisateur u
LIMIT 30;

