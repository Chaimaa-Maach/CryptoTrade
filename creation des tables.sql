----------------- CREATION DES TABLES AVEC CONTRAINTES ET PARTITIONNEMENT ---------------------

---table utilisateur : ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.utilisateur CASCADE;

CREATE  TABLE IF NOT EXISTS public.utilisateur
(
    id_user BIGINT GENERATED ALWAYS AS IDENTITY,
    nom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    date_inscription TIMESTAMPTZ NOT NULL DEFAULT now(),
    statut VARCHAR(20) NOT NULL,
    -- Clé primaire
    CONSTRAINT utilisateur_pkey 
        PRIMARY KEY (id_user),
    -- Email unique
    CONSTRAINT utilisateur_email_unique 
        UNIQUE (email),
    -- Validation basique du format email
    CONSTRAINT utilisateur_email_check 
        CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    -- Statut limité aux valeurs autorisées
    CONSTRAINT utilisateur_statut_check 
        CHECK (statut IN ('actif', 'inactif')),
    -- Date d’inscription cohérente
    CONSTRAINT utilisateur_date_inscription_check
        CHECK (date_inscription <= now())
);

---table cryptomonnaie : ---------------------
-------------------------------------------------

DROP TABLE IF EXISTS public.cryptomonnaie CASCADE;

CREATE TABLE IF NOT EXISTS public.cryptomonnaie
(
    id_crypto BIGINT GENERATED ALWAYS AS IDENTITY,
    nom VARCHAR(50) NOT NULL,    
    symbole VARCHAR(20) NOT NULL,    
    date_creation TIMESTAMPTZ NOT NULL DEFAULT now(),    
    statut VARCHAR(20) NOT NULL,    
    -- Clé primaire
    CONSTRAINT cryptomonnaie_pkey PRIMARY KEY (id_crypto),    
    -- Nom unique
    CONSTRAINT cryptomonnaie_nom_unique UNIQUE (nom),    
    -- Symbole unique
    CONSTRAINT cryptomonnaie_symbole_unique UNIQUE (symbole),    
    -- Statut limité aux valeurs autorisées
    CONSTRAINT cryptomonnaie_statut_check CHECK (statut IN ('actif', 'desactive')),    
    -- Cohérence temporelle
    CONSTRAINT cryptomonnaie_date_creation_check CHECK (date_creation <= now())
);

---table paire_trading : ---------------------
-------------------------------------------------

DROP TABLE IF EXISTS public.paire_trading CASCADE;

CREATE TABLE IF NOT EXISTS public.paire_trading
(
    id_paire BIGINT GENERATED ALWAYS AS IDENTITY,   
    crypto_base VARCHAR(20) NOT NULL,    
    crypto_cotation VARCHAR(20) NOT NULL,    
    statut VARCHAR(20) NOT NULL,    
    date_ouverture TIMESTAMPTZ NOT NULL DEFAULT now(),    
    -- Clé primaire
    CONSTRAINT paire_trading_pkey PRIMARY KEY (id_paire),    
    -- Statut limité aux valeurs autorisées
    CONSTRAINT paire_trading_statut_check CHECK (statut IN ('disponible', 'indisponible')),    
    -- Crypto base différente de crypto cotation
    CONSTRAINT paire_trading_diff_crypto_check CHECK (crypto_base <> crypto_cotation),    
    -- Optionnel : combinaison base/cotation unique
    CONSTRAINT paire_trading_unique_pair UNIQUE (crypto_base, crypto_cotation),    
    -- Optionnel : date cohérente
    CONSTRAINT paire_trading_date_ouverture_check CHECK (date_ouverture <= now())
);

---table portefeuille: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.portefeuille CASCADE;

CREATE TABLE IF NOT EXISTS public.portefeuille
(
    id_portfolio BIGINT GENERATED ALWAYS AS IDENTITY,    
    solde_total NUMERIC(20,2) NOT NULL,    
    solde_bloque NUMERIC(20,2) NOT NULL,    
    date_maj TIMESTAMPTZ NOT NULL DEFAULT now(),   
    id_user BIGINT NOT NULL,    
    id_crypto BIGINT NOT NULL,    
    -- Clé primaire
    CONSTRAINT portefeuille_pkey PRIMARY KEY (id_portfolio),    
    -- Solde total positif
    CONSTRAINT portefeuille_solde_total_check CHECK (solde_total >= 0),    
    -- Solde bloqué positif
    CONSTRAINT portefeuille_solde_bloque_check CHECK (solde_bloque >= 0),    
    -- Solde bloqué inférieur ou égal au total
    CONSTRAINT portefeuille_solde_bloque_total_check CHECK (solde_bloque <= solde_total),    
    -- Optionnel : date cohérente
    CONSTRAINT portefeuille_date_maj_check CHECK (date_maj <= now()),   
    -- Clé étrangère vers utilisateur
    CONSTRAINT portefeuille_user_fk FOREIGN KEY (id_user)
        REFERENCES public.utilisateur (id_user),    
    -- Clé étrangère vers cryptomonnaie
    CONSTRAINT portefeuille_crypto_fk FOREIGN KEY (id_crypto)
        REFERENCES public.cryptomonnaie (id_crypto)
);


---table ordre: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.ordre CASCADE;

CREATE TABLE IF NOT EXISTS public.ordre
(
    id_ordre BIGINT GENERATED ALWAYS AS IDENTITY,    
    type_ordre VARCHAR(15) NOT NULL,   
    mode_execution VARCHAR(20) NOT NULL,    
    quantite BIGINT NOT NULL,    
    prix NUMERIC(20,2) NOT NULL,    
    statut VARCHAR(30) NOT NULL,    
    date_creation TIMESTAMPTZ NOT NULL DEFAULT now(),    
    id_user BIGINT NOT NULL,    
    id_paire BIGINT NOT NULL,    
    -- Clé primaire
    CONSTRAINT ordre_pkey PRIMARY KEY (id_ordre, date_creation),    
    -- Type d'ordre limité
    CONSTRAINT ordre_type_check CHECK (type_ordre IN ('achat', 'vente')),    
    -- Mode d'exécution limité
    CONSTRAINT ordre_mode_execution_check CHECK (mode_execution IN ('market', 'limit')),   
    -- Quantité positive ou nulle
    CONSTRAINT ordre_quantite_check CHECK (quantite >= 0),    
    -- Prix positif pour les ordres limit
    CONSTRAINT ordre_prix_check CHECK ((mode_execution = 'limit' AND prix > 0) OR mode_execution = 'market'),    
    -- Statut limité
    CONSTRAINT ordre_statut_check CHECK (statut IN ('en attente', 'execute', 'annule')),    
    -- Date cohérente
    CONSTRAINT ordre_date_creation_check CHECK (date_creation <= now())   
)PARTITION BY RANGE (date_creation);

---table trade: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.trade CASCADE;

CREATE TABLE IF NOT EXISTS public.trade
(
    id_trade BIGINT GENERATED ALWAYS AS IDENTITY,   
    prix NUMERIC(20,2) NOT NULL,    
    quantite BIGINT NOT NULL,    
    date_execution TIMESTAMPTZ NOT NULL DEFAULT now(),    
    id_ordre BIGINT NOT NULL,    
    id_paire BIGINT NOT NULL,    
    -- Clé primaire
    CONSTRAINT trade_pkey PRIMARY KEY (id_trade, date_execution),    
    -- Prix positif
    CONSTRAINT trade_prix_check CHECK (prix > 0),   
    -- Quantité positive ou nulle
    CONSTRAINT trade_quantite_check CHECK (quantite >= 0),   
    -- Date d’exécution cohérente
    CONSTRAINT trade_date_execution_check CHECK (date_execution <= now())    
)PARTITION BY RANGE (date_execution);




---table prix_marche: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.prix_marche CASCADE;

CREATE TABLE IF NOT EXISTS public.prix_marche
(
    id_prixMarche BIGINT GENERATED ALWAYS AS IDENTITY,    
    prix NUMERIC(20,2) NOT NULL,    
    volume NUMERIC(50,2) NOT NULL,    
    date_maj TIMESTAMPTZ NOT NULL DEFAULT now(),    
    id_paire BIGINT NOT NULL,    
    -- Clé primaire
    CONSTRAINT prix_marche_pkey PRIMARY KEY (id_prixMarche),    
    -- Prix positif
    CONSTRAINT prix_marche_prix_check CHECK (prix > 0),    
    -- Volume positif
    CONSTRAINT prix_marche_volume_check CHECK (volume > 0),    
    -- Date cohérente
    CONSTRAINT prix_marche_date_maj_check CHECK (date_maj <= now()),    
    -- Clé étrangère vers paire_trading
    CONSTRAINT prix_marche_paire_fk FOREIGN KEY (id_paire)
        REFERENCES public.paire_trading (id_paire)
);
---table statistiques_marche: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.statistiques_marche CASCADE;

CREATE TABLE IF NOT EXISTS public.statistiques_marche
(
    id_stat_marche BIGINT GENERATED ALWAYS AS IDENTITY,    
    nom_indicateur VARCHAR(50) NOT NULL,    
    valeur_indicateur VARCHAR(50) NOT NULL,    
    periode INTERVAL NOT NULL,    
    date_maj TIMESTAMPTZ NOT NULL DEFAULT now(),    
    id_paire BIGINT NOT NULL,    
    -- Clé primaire
    CONSTRAINT statistiques_marche_pkey PRIMARY KEY (id_stat_marche),    
    -- Période cohérente (> 0)
    CONSTRAINT statistiques_marche_periode_check CHECK (periode > '0 second'),    
    -- Date cohérente
    CONSTRAINT statistiques_marche_date_maj_check CHECK (date_maj <= now()),    
    -- Unicité par indicateur / paire / période
    CONSTRAINT statistiques_marche_unique_indicateur UNIQUE (id_paire, nom_indicateur, periode),    
    -- Clé étrangère vers paire_trading
    CONSTRAINT statistiques_marche_paire_fk FOREIGN KEY (id_paire)
        REFERENCES public.paire_trading (id_paire)
);

---table detection_anomalie: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.detection_anomalie CASCADE;

CREATE TABLE IF NOT EXISTS public.detection_anomalie
(
    id_anomalie BIGINT GENERATED ALWAYS AS IDENTITY,    
    type VARCHAR(50) NOT NULL,    
    date_detection TIMESTAMPTZ NOT NULL DEFAULT now(),    
    commentaire TEXT,    
    id_ordre BIGINT NOT NULL,   
    id_user BIGINT NOT NULL,   
    -- Clé primaire
    CONSTRAINT detection_anomalie_pkey PRIMARY KEY (id_anomalie),    
    -- Date cohérente
    CONSTRAINT detection_anomalie_date_check CHECK (date_detection <= now()),       
    -- Clé étrangère vers utilisateur
    CONSTRAINT detection_anomalie_user_fk FOREIGN KEY (id_user)
        REFERENCES public.utilisateur (id_user)
);

---table audit_trail: ---------------------
-------------------------------------------------
DROP TABLE IF EXISTS public.audit_trail CASCADE;

CREATE TABLE IF NOT EXISTS public.audit_trail
(
    id_audit BIGINT GENERATED ALWAYS AS IDENTITY,    
    table_cible VARCHAR(50) NOT NULL,    
    record_id BIGINT NOT NULL,    
    action VARCHAR(50) NOT NULL,    
    date_action TIMESTAMPTZ NOT NULL DEFAULT now(),    
    details TEXT,    
    id_user BIGINT NOT NULL,    
    -- Clé primaire
    CONSTRAINT audit_trail_pkey PRIMARY KEY (id_audit, date_action),    
    -- Action cohérente
    CONSTRAINT audit_trail_action_check CHECK (action IN ('INSERT','UPDATE','DELETE')),    
    -- Date cohérente
    CONSTRAINT audit_trail_date_check CHECK (date_action <= now())  
)PARTITION BY RANGE (date_action);




