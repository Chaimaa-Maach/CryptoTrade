# CryptoTrade
contraintes des tables PostgreSQL

1️⃣ Table utilisateur

| Colonne   | Contrainte                                           | Type               | Description                            |
| --------- | ---------------------------------------------------- | ------------------ | -------------------------------------- |
| `id_user` | PK                                                   | Clé primaire       | Identifiant unique de l’utilisateur    |
| `email`   | CHECK `~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'` | Vérification regex | Valide le format d’adresse email       |
| `statut`  | CHECK `IN ('actif','desactive')`                     | Vérification       | Limite le statut aux valeurs possibles |
| `nom`     | NOT NULL                                             | Non NULL           | Obligatoire                            |
| `email`   | UNIQUE                                               | Unicité            | Aucun doublon d’email autorisé         |
| `id_user` | PRIMARY KEY                                          | Unique             | Identifiant unique                     |

2️⃣ Table cryptomonnaie

| Colonne         | Contrainte                       | Type         | Description                     |
| --------------- | -------------------------------- | ------------ | ------------------------------- |
| `id_crypto`     | PK                               | Clé primaire | Identifiant unique de la crypto |
| `nom`           | UNIQUE                           | Unicité      | Nom unique de la crypto         |
| `symbole`       | UNIQUE                           | Unicité      | Symbole unique de la crypto     |
| `statut`        | CHECK `IN ('actif','desactive')` | Vérification | Limite le statut                |
| `date_creation` | CHECK `<= now()`                 | Vérification | Empêche les dates futures       |

3️⃣ Table paire_trading

| Colonne                            | Contrainte                               | Type         | Description                      |
| ---------------------------------- | ---------------------------------------- | ------------ | -------------------------------- |
| `id_paire`                         | PK                                       | Clé primaire | Identifiant unique               |
| `crypto_base` et `crypto_cotation` | CHECK `crypto_base <> crypto_cotation`   | Vérification | Base ≠ cotation                  |
| `statut`                           | CHECK `IN ('disponible','indisponible')` | Vérification | Limite le statut                 |
| `crypto_base, crypto_cotation`     | UNIQUE                                   | Unicité      | Une paire unique par combinaison |
| `date_ouverture`                   | CHECK `<= now()`                         | Vérification | Pas de date future               |

4️⃣ Table portefeuille

| Colonne        | Contrainte             | Type                    | Description                        |
| -------------- | ---------------------- | ----------------------- | ---------------------------------- |
| `id_portfolio` | PK                     | Clé primaire            | Identifiant unique du portefeuille |
| `solde_total`  | CHECK `>= 0`           | Vérification            | Solde total positif                |
| `solde_bloque` | CHECK `>= 0`           | Vérification            | Solde bloqué positif               |
| `solde_bloque` | CHECK `<= solde_total` | Vérification            | Bloqué ≤ total                     |
| `date_maj`     | CHECK `<= now()`       | Vérification            | Pas de date future                 |
| `id_user`      | FK                     | Référence utilisateur   | Intégrité référentielle            |
| `id_crypto`    | FK                     | Référence cryptomonnaie | Intégrité référentielle            |

5️⃣ Table ordre

| Colonne          | Contrainte                                                               | Type                        | Description                                     |
| ---------------- | ------------------------------------------------------------------------ | --------------------------- | ----------------------------------------------- |
| `id_ordre`       | PK                                                                       | Clé primaire                | Identifiant unique                              |
| `type_ordre`     | CHECK `IN ('achat','vente')`                                             | Vérification                | Limite le type d’ordre                          |
| `mode_execution` | CHECK `IN ('market','limit')`                                            | Vérification                | Limite le mode d’exécution                      |
| `quantite`       | CHECK `>= 0`                                                             | Vérification                | Quantité non négative                           |
| `prix`           | CHECK `(mode_execution = 'limit' AND prix>0) OR mode_execution='market'` | Vérification conditionnelle | Prix obligatoire pour limit, ignoré pour market |
| `statut`         | CHECK `IN ('en attente','execute','annule')`                             | Vérification                | Limite le statut                                |
| `date_creation`  | CHECK `<= now()`                                                         | Vérification                | Pas de date future                              |
| `id_user`        | FK                                                                       | Référence utilisateur       | Intégrité référentielle                         |
| `id_paire`       | FK                                                                       | Référence paire_trading     | Intégrité référentielle                         |

6️⃣ Table trade

| Colonne          | Contrainte       | Type                    | Description             |
| ---------------- | ---------------- | ----------------------- | ----------------------- |
| `id_trade`       | PK               | Clé primaire            | Identifiant unique      |
| `prix`           | CHECK `> 0`      | Vérification            | Prix positif            |
| `quantite`       | CHECK `>= 0`     | Vérification            | Quantité positive       |
| `date_execution` | CHECK `<= now()` | Vérification            | Pas de date future      |
| `id_ordre`       | FK               | Référence ordre         | Intégrité référentielle |
| `id_paire`       | FK               | Référence paire_trading | Intégrité référentielle |

7️⃣ Table prix_marche

| Colonne         | Contrainte       | Type                    | Description             |
| --------------- | ---------------- | ----------------------- | ----------------------- |
| `id_prixMarche` | PK               | Clé primaire            | Identifiant unique      |
| `prix`          | CHECK `> 0`      | Vérification            | Prix positif            |
| `volume`        | CHECK `> 0`      | Vérification            | Volume positif          |
| `date_maj`      | CHECK `<= now()` | Vérification            | Pas de date future      |
| `id_paire`      | FK               | Référence paire_trading | Intégrité référentielle |

8️⃣ Table statistiques_marche

| Colonne                               | Contrainte       | Type                    | Description                                               |
| ------------------------------------- | ---------------- | ----------------------- | --------------------------------------------------------- |
| `id_stat_marche`                      | PK               | Clé primaire            | Identifiant unique                                        |
| `periode`                             | CHECK `> 0`      | Vérification            | Période positive                                          |
| `date_maj`                            | CHECK `<= now()` | Vérification            | Pas de date future                                        |
| `(id_paire, nom_indicateur, periode)` | UNIQUE           | Unicité                 | Pas de doublons pour un indicateur d’une paire et période |
| `id_paire`                            | FK               | Référence paire_trading | Intégrité référentielle                                   |

9️⃣ Table detection_anomalie

| Colonne          | Contrainte       | Type                  | Description                 |
| ---------------- | ---------------- | --------------------- | --------------------------- |
| `id_anomalie`    | PK               | Clé primaire          | Identifiant unique          |
| `type`           | NOT NULL         | Vérification          | Type d’anomalie obligatoire |
| `date_detection` | CHECK `<= now()` | Vérification          | Pas de date future          |
| `id_ordre`       | FK               | Référence ordre       | Intégrité référentielle     |
| `id_user`        | FK               | Référence utilisateur | Intégrité référentielle     |
| `commentaire`    | NULL autorisé    | Texte libre           | Optionnel                   |

🔟 Table audit_trail

| Colonne       | Contrainte                              | Type                  | Description                |
| ------------- | --------------------------------------- | --------------------- | -------------------------- |
| `id_audit`    | PK                                      | Clé primaire          | Identifiant unique         |
| `table_cible` | NOT NULL                                | Vérification          | Table modifiée obligatoire |
| `record_id`   | NOT NULL                                | Vérification          | Record modifié obligatoire |
| `action`      | CHECK `IN ('INSERT','UPDATE','DELETE')` | Vérification          | Action cohérente           |
| `date_action` | CHECK `<= now()`                        | Vérification          | Pas de date future         |
| `id_user`     | FK                                      | Référence utilisateur | Intégrité référentielle    |
| `details`     | NULL autorisé                           | Texte libre           | Optionnel                  |
