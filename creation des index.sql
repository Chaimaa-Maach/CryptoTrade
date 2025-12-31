------------ CREATION DES INDEX-------------------


----------------------------------------------------------------------------------
----------------- LES TABLES NORMALES ---------------------------------------
----------------------------------------------------------------------------------

---table utilisateur : ---------------------
-------------------------------------------------
---Index B-tree sur date_inscription
CREATE INDEX idx_utilisateur_date_inscription
ON utilisateur (date_inscription);
---Index PARTIEL sur les utilisateurs 
CREATE INDEX idx_utilisateur_actif
ON utilisateur (id_user)
WHERE statut = 'actif';

---table cryptomonnaie : ---------------------
-------------------------------------------------
---Index partiel sur les cryptos actives
CREATE INDEX idx_crypto_actif
ON cryptomonnaie (id_crypto)
WHERE statut = 'actif';

---table paire_trading : ---------------------
-------------------------------------------------
---Index partiel sur paires actives
CREATE INDEX idx_paire_disponible
ON paire_trading (id_paire)
WHERE statut = 'disponible';
---UNIQUE composite
CREATE UNIQUE INDEX idx_paire_crypto_unique
ON paire_trading (crypto_base, crypto_cotation);

---table portefeuille: ---------------------
-------------------------------------------------
---Index UNIQUE composite
CREATE UNIQUE INDEX idx_portefeuille_user_crypto
ON portefeuille (id_user, id_crypto);
---Index simple sur id_user
CREATE INDEX idx_portefeuille_user
ON portefeuille (id_user);

---table prix_marche: ---------------------
-------------------------------------------------
---Index composite PAIRE + DATE
CREATE INDEX idx_prix_marche_paire_date
ON prix_marche (id_paire, date_maj DESC);

---table statistiques_marche: ---------------------
-------------------------------------------------
---Index composite PAIRE + INDICATEUR + PERIODE
CREATE INDEX idx_stat_marche_lookup
ON statistiques_marche (id_paire, nom_indicateur, periode, date_maj DESC);

---table detection_anomalie: ---------------------
-------------------------------------------------
---Index composite ORDRE + DATE
CREATE INDEX idx_anomalie_ordre_date
ON detection_anomalie (id_ordre, date_detection DESC);
---Index composite TYPE + DATE
CREATE INDEX idx_anomalie_type_date
ON detection_anomalie (type, date_detection DESC);

----------------------------------------------------------------------------------
----------------- LES TABLES PARTITIONNEES ---------------------------------------
----------------------------------------------------------------------------------


-------------------------------------------------
---------table audit_trail: ---------------------
-------------------------------------------------

-----Partition audit_trail_2026_01----------------

-- Index lookup RECORD
CREATE INDEX idx_audit_record_2026_01
ON audit_trail_2026_01 (table_cible, record_id, date_action DESC);
-- Index ACTION + DATE
CREATE INDEX idx_audit_action_date_2026_01
ON audit_trail_2026_01 (action, date_action DESC);
-- Index couvrant
CREATE INDEX idx_audit_cover_2026_01
ON audit_trail_2026_01 (table_cible, record_id, date_action DESC)
INCLUDE (action, id_user);

-----Partition audit_trail_2026_02----------------

-- Index lookup RECORD
CREATE INDEX idx_audit_record_2026_02
ON audit_trail_2026_02 (table_cible, record_id, date_action DESC);
-- Index ACTION + DATE
CREATE INDEX idx_audit_action_date_2026_02
ON audit_trail_2026_02 (action, date_action DESC);
-- Index couvrant
CREATE INDEX idx_audit_cover_2026_02
ON audit_trail_2026_02 (table_cible, record_id, date_action DESC)
INCLUDE (action, id_user);

-----Partition audit_trail_2025_12----------------

-- Index lookup RECORD
CREATE INDEX idx_audit_record_2025_12
ON audit_trail_2025_12 (table_cible, record_id, date_action DESC);
-- Index ACTION + DATE
CREATE INDEX idx_audit_action_date_2025_12
ON audit_trail_2025_12 (action, date_action DESC);
-- Index couvrant
CREATE INDEX idx_audit_cover_2025_12
ON audit_trail_2025_12 (table_cible, record_id, date_action DESC)
INCLUDE (action, id_user);

----------------------------------------------
--------------table trade: ---------------------
-------------------------------------------------

-----Partition trade_2026_01----------------

-- Index composite ORDRE + DATE
CREATE INDEX idx_trade_ordre_date_2026_01
ON trade_2026_01 (id_ordre, date_execution);
-- Index composite PAIRE + DATE
CREATE INDEX idx_trade_paire_date_2026_01
ON trade_2026_01 (id_paire, date_execution);

-----Partition trade_2026_02----------------

-- Index composite ORDRE + DATE
CREATE INDEX idx_trade_ordre_date_2026_02
ON trade_2026_02 (id_ordre, date_execution);
-- Index composite PAIRE + DATE
CREATE INDEX idx_trade_paire_date_2026_02
ON trade_2026_02 (id_paire, date_execution);

-----Partition trade_2025_12----------------

-- Index composite ORDRE + DATE
CREATE INDEX idx_trade_ordre_date_2025_12
ON trade_2025_12 (id_ordre, date_execution);
-- Index composite PAIRE + DATE
CREATE INDEX idx_trade_paire_date_2025_12
ON trade_2025_12 (id_paire, date_execution);
-------------------------------------------------
---------------table ordre: ---------------------
-------------------------------------------------

-----Partition ordre_2026_01----------------

-- Index partiel sur statut
CREATE INDEX idx_ordre_en_attente_2026_01
ON ordre_2026_01 (id_paire, date_creation)
WHERE statut = 'en_attente';
-- Index composite USER + PAIRE + DATE
CREATE INDEX idx_ordre_user_paire_date_2026_01
ON ordre_2026_01 (id_user, id_paire, date_creation DESC);
-- Index simple sur id_paire
CREATE INDEX idx_ordre_paire_2026_01
ON ordre_2026_01 (id_paire);

-----Partition ordre_2026_02----------------

-- Index partiel sur statut
CREATE INDEX idx_ordre_en_attente_2026_02
ON ordre_2026_02 (id_paire, date_creation)
WHERE statut = 'en_attente';
-- Index composite USER + PAIRE + DATE
CREATE INDEX idx_ordre_user_paire_date_2026_02
ON ordre_2026_02 (id_user, id_paire, date_creation DESC);
-- Index simple sur id_paire
CREATE INDEX idx_ordre_paire_2026_02
ON ordre_2026_02 (id_paire);

-----Partition ordre_2025_12----------------

-- Index partiel sur statut
CREATE INDEX idx_ordre_en_attente_2025_12
ON ordre_2025_12 (id_paire, date_creation)
WHERE statut = 'en_attente';
-- Index composite USER + PAIRE + DATE
CREATE INDEX idx_ordre_user_paire_date_2025_12
ON ordre_2025_12 (id_user, id_paire, date_creation DESC);
-- Index simple sur id_paire
CREATE INDEX idx_ordre_paire_2025_12
ON ordre_2025_12 (id_paire);
