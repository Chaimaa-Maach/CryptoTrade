# 🚀 CryptoTrade – PostgreSQL Advanced Optimization Project

## 📌 Description du projet

**CryptoTrade** est une plateforme de trading de cryptomonnaies en temps réel conçue pour gérer :

- 📈 Des **millions d’ordres par jour**
- ⚡ Un **carnet d’ordres à faible latence**
- 💼 Des **portefeuilles multi-cryptos**
- 🧾 Un **audit trail complet** pour la conformité
- 📊 Des **analyses de marché avancées**
- 🚨 La **détection d’anomalies** (wash trading, spoofing, pump & dump)

Ce projet met l’accent sur la **performance PostgreSQL**, en limitant volontairement la base à **10 tables** afin d’optimiser chaque composant en profondeur.

---

## 🎯 Objectifs techniques

- Gérer un **grand volume d’ordres** avec une latence minimale
- Accélérer les **requêtes analytiques complexes**
- Calculer des **indicateurs financiers** (VWAP, RSI, volatilité)
- Garantir la **cohérence des portefeuilles** malgré la concurrence
- Détecter des **comportements suspects**
- Mettre en place un **monitoring PostgreSQL avancé**

---

## 🧱 Modélisation de la base de données

### Tables principales (10)

| Table | Description |
|-----|------------|
| `utilisateur` | Utilisateurs de la plateforme |
| `cryptomonnaie` | Référentiel des cryptos |
| `paire_trading` | Paires de trading |
| `portefeuille` | Soldes par utilisateur et crypto |
| `ordre` | Ordres (achat / vente) |
| `trade` | Exécutions des ordres |
| `prix_marche` | Historique des prix |
| `statistiques_marche` | Indicateurs calculés |
| `detection_anomalie` | Détection de comportements suspects |
| `audit_trail` | Audit et traçabilité |

✔ Modélisation normalisée (1FN → 3FN)  
✔ Types PostgreSQL adaptés aux fortes volumétries  

---

## 🛠️ Implémentation PostgreSQL

### 1️⃣ Création des tables

- Clés primaires (`PRIMARY KEY`)
- Contraintes métier (`CHECK`)
- Clés étrangères (FK) lorsque compatibles avec le partitionnement
- Gestion des contraintes sur tables partitionnées

---

### 2️⃣ Indexation avancée

Types d’index utilisés :

- **B-tree**
- **Index composites**
- **Index partiels**
- **Index couvrants (`INCLUDE`)**
- **Index uniques métier**

🎯 Objectifs :
- Accélérer les `JOIN`
- Optimiser les `ORDER BY`
- Réduire les accès disque
- Améliorer les performances analytiques

---

### 3️⃣ Partitionnement

Tables partitionnées :

| Table | Type | Clé de partition |
|----|----|----|
| `ordre` | RANGE | `date_creation` |
| `trade` | RANGE | `date_execution` |
| `audit_trail` | RANGE | `date_action` |

✔ Réduction du volume scanné  
✔ Vacuum plus efficace  
✔ Scalabilité améliorée  

---

## 📊 Fonctions & Indicateurs de marché

Fonctions PostgreSQL implémentées pour :

- 📈 **VWAP** (Volume Weighted Average Price)
- 📉 **RSI** (Relative Strength Index)
- 📊 **Volatilité**
- 📦 **Volumes de marché**

Sources des calculs :
- `trade` → VWAP, volumes
- `prix_marche` → RSI, volatilité

---

## 🔍 Analyses avancées SQL

### ✔ Window Functions
- Moyennes mobiles
- Cumuls
- Classements temporels
- Indicateurs financiers

### ✔ LATERAL JOIN
- Statistiques dépendantes par utilisateur ou par paire
- Derniers trades par paire

### ✔ DISTINCT ON
- Dernier prix par paire
- Dernier état d’un ordre

### ✔ Recursive CTE
- Détection de patterns suspects
- Analyse comportementale
- Chaînes d’ordres anormales

---


## ⚙️ Tuning & Monitoring

Optimisations mises en place :

- 🔧 Ajustement de `work_mem` (réduction des temp file spills)
- 🔄 Optimisation du `fillfactor` pour maximiser les HOT updates
- 📈 Monitoring via :
  - `pg_stat_statements`
  - `pg_statio_user_tables`
  - `auto_explain`

🎯 Objectifs :
- Identifier les requêtes lentes
- Améliorer les estimations du planner
- Surveiller la santé globale de la base

---

## ✅ Résultats

- ✔ Latence réduite
- ✔ Requêtes analytiques optimisées
- ✔ Base scalable et maintenable
- ✔ Architecture prête pour la production

Ce projet démontre une **maîtrise avancée de PostgreSQL** :
modélisation, indexation, partitionnement, tuning, analyse avancée et monitoring.

---

## 🧠 Compétences mises en œuvre

- PostgreSQL avancé
- Data Engineering
- SQL analytique
- Optimisation des performances
- Architecture de bases de données
- Monitoring et tuning

---

## 👤 Auteur

**Chaimaa**  
Data Analyst / Data Engineer  
Projet académique & portfolio professionnel
