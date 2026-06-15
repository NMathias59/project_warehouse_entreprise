# 🏭 Project Warehouse Entreprise — Data Platform ERP + Marketplace + CRM

> Pipeline de données complet d'un ERP, d'une marketplace e-commerce **et d'un CRM** vers un Data Warehouse ClickHouse — ingestion via **Airbyte** (self-hosted Docker), orchestration **Apache Airflow** (Astronomer Cosmos) et transformations **dbt**.

---

## 📋 Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Architecture technique](#2-architecture-technique)
3. [Structure du projet](#3-structure-du-projet)
4. [Prérequis](#4-prérequis)
5. [Installation et démarrage](#5-installation-et-démarrage)
6. [Projet dbt — Détail](#6-projet-dbt--détail)
   - [Couche Staging](#61-couche-staging)
   - [Couche Intermediate](#62-couche-intermediate)
   - [Couche Marts](#63-couche-marts)
   - [Couche Reports](#64-couche-reports)
7. [Commandes dbt courantes](#7-commandes-dbt-courantes)
8. [Macros personnalisées](#8-macros-personnalisées)
9. [Orchestration Airflow](#9-orchestration-airflow)
10. [Bonnes pratiques appliquées](#10-bonnes-pratiques-appliquées)
11. [Sécurité — Credentials](#11-sécurité--credentials)
12. [Troubleshooting ClickHouse](#12-troubleshooting-clickhouse)

---

## 1. Vue d'ensemble

Ce projet implémente un entrepôt de données analytique pour **trois systèmes sources** : un ERP, une marketplace e-commerce et un CRM, plus un domaine **WMS** (Warehouse Management System).

**Domaines ERP** (source `DB_WH_ERP`) :

| Domaine métier      | Description                                         |
|---------------------|-----------------------------------------------------|
| 💰 **Finance**      | Budgets, rapprochements bancaires, journaux comptables, transactions |
| 👤 **RH**           | Employés, contrats, congés, feuilles de temps        |
| 📦 **Inventaire**   | Stock composants, alertes, mouvements, n° de série, inventaires |
| 🛒 **Achats**       | Bons de commande, fournisseurs, réceptions, retours, factures fournisseurs |
| 🏷️ **Catalogue**    | Produits, marques, catégories, composants, modèles PC, BOM |
| ⚙️ **Opérations**   | Ordres de fabrication, réparations, qualité (staging uniquement) |

**Domaines Marketplace** (source `DB_WH_MKT`) :

| Domaine métier         | Description                                       |
|------------------------|---------------------------------------------------|
| 🛍️ **Commerce**        | Commandes, paiements, remboursements, retours, clients, promotions, codes remise |
| 🏷️ **Catalogue**       | Produits, marques, catégories, prix, bundles PC   |
| 🚚 **Logistique**      | Expéditions, transporteurs, méthodes/zones de livraison, stock |
| 🎧 **Service client**  | Tickets support, avis produits                    |

**Domaine WMS** (source `DB_WH_WMS`) :

| Domaine métier         | Description                                                   |
|------------------------|---------------------------------------------------------------|
| 📍 **Emplacements**    | Locations d'entrepôt (allées, racks, niveaux, zones)          |
| 📥 **Réceptions**      | Réceptions marchandises, lignes de réception                  |
| 📤 **Expéditions**     | Expéditions, lignes d'expédition                              |
| 🛒 **Picking**         | Ordres de picking, lignes de picking                          |
| 📦 **Stock**           | Mouvements de stock, ajustements d'inventaire                 |

**Domaines CRM** (source `DB_WH_CRM`) :

| Domaine métier       | Description                                              |
|----------------------|----------------------------------------------------------|
| 🏢 **Comptes**       | Comptes clients/prospects, LTV, segmentation, portefeuille |
| 👥 **Contacts**      | Contacts rattachés aux comptes, liens cross-domaine       |
| 💼 **Ventes**        | Opportunités, pipeline, probabilité, montant estimé       |
| 📞 **Activités**     | Appels, emails, réunions, demos — historique commercial   |
| 📋 **Tâches**        | Tâches assignées, suivi délais, complétion               |
| 📊 **Pipeline**      | Historique des changements d'étape, vélocité de vente    |

**Stack technique :**

```
ERP (PostgreSQL)   Marketplace (PostgreSQL)   CRM (PostgreSQL)
        │                   │                       │
        └───────────────────┼───────────────────────┘
                            ▼
          Airbyte (self-hosted Docker)
          (ingestion CDC / full refresh)
                            │
                            ▼ tables raw dans ClickHouse
          Apache Airflow  ──────────────  Astronomer Cosmos
          (orchestration)                  (DAG dbt natif)
                            │
                            ▼
                       dbt Core 1.11.2
                       (transformations)
                            │
                            ▼
                    ClickHouse 25.x
                    (Data Warehouse)
          schemas: DB_WH_ERP / DB_WH_MKT / DB_WH_CRM
```

---

## 2. Architecture technique

### Composants

| Composant          | Version      | Rôle                                        |
|--------------------|--------------|---------------------------------------------|
| **Airbyte**        | self-hosted  | Ingestion ERP → ClickHouse (raw)            |
| dbt Core           | 1.11.2       | Transformations SQL                         |
| dbt-clickhouse     | 1.9.8        | Adapter ClickHouse pour dbt                 |
| ClickHouse         | 25.7.x       | Moteur OLAP, stockage analytique            |
| Apache Airflow     | Astronomer   | Orchestration des DAGs                      |
| astronomer-cosmos  | 1.10.0       | Intégration native dbt ↔ Airflow            |
| Docker             | —            | Conteneurisation Airbyte + Airflow          |

### Flux de données complet

```
┌─────────────────────────────────────────────────────────────┐
│  SOURCES (ERP + Marketplace)                                │
│  PostgreSQL / autre SGBDR                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │  Airbyte Connectors
                           │  (full refresh ou CDC)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  INGESTION — Airbyte self-hosted (Docker)                   │
│  • UI : http://localhost:8000                               │
│  • Connecteurs : Postgres Source → ClickHouse Destination   │
│  • Sync mode : Full Refresh / Incremental (CDC)             │
│  • Destinations : DB_WH_ERP, DB_WH_MKT et DB_WH_CRM          │
└──────────────────────────┬──────────────────────────────────┘
                           │  Tables raw ClickHouse
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  TRANSFORMATION — dbt Core 1.11.2 (via Airflow + Cosmos)   │
│                                                             │
│  staging/   → views    (nettoyage, cast, rename)            │
│  intermediate/ → ephemeral (logique métier, CTEs)           │
│  marts/.../core/    → tables (MergeTree, dims + facts)      │
│  marts/.../reports/ → tables (dénormalisées, prêtes BI)     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  DATA WAREHOUSE — ClickHouse 25.x                           │
│  Schemas : DB_WH_ERP / DB_WH_MKT / DB_WH_CRM                │
│  Consommé par : BI tools, dashboards, analyses              │
└─────────────────────────────────────────────────────────────┘
```

### Schémas ClickHouse

| Target dbt       | Schéma ClickHouse      | Usage                         |
|------------------|------------------------|-------------------------------|
| `erp`            | `DB_WH_ERP`            | Entrepôt ERP (par défaut)     |
| `mkt`            | `DB_WH_MKT`            | Entrepôt Marketplace          |
| `crm`            | `DB_WH_CRM`            | Entrepôt CRM                  |
| `wms`            | `DB_WH_WMS`            | Entrepôt WMS                  |
| `mes/marketing/sav/plm/sirh/qms/finance/procurement` | `DB_WH_*` | Domaines étendus |
| `bi_*`           | `DB_WH_BI_*`           | Datamarts BI cross-domaines   |

### Matérialisations par couche

```
staging/        → view        (léger, toujours frais, pas d'objet physique)
intermediate/   → ephemeral   (inline CTE, pas d'objet créé en base)
marts/.../core/ → table       (MergeTree, performant pour la BI)
                → incremental (grandes tables de faits, stratégie append)
marts/.../reports/ → table    (MergeTree, large/dénormalisé pour la BI)
```

---

## 3. Structure du projet

```
project_warehouse_entreprise/
├── Dockerfile                      # Image Astronomer + dbt venv
├── docker-compose.override.yml     # Mount du dossier dbt dans Airflow
├── requirements.txt                # Dépendances Python Airflow (astronomer-cosmos)
├── packages.txt                    # Packages système
├── dbt_best_practices.md           # Référence bonnes pratiques dbt (agents IA)
│
├── dags/
│   └── example_dbt_cosmos.py       # DAG Airflow dbt via Cosmos
│
├── include/
│   └── constants.py                # Chemins et configs partagés DAGs
│
├── plugins/                        # Plugins Airflow custom
│
├── tests/
│   └── dags/
│       └── test_dag_integrity.py   # Tests d'intégrité des DAGs
│
└── dbt/
    └── warehouse/                  # Projet dbt principal
        ├── dbt_project.yml         # Config projet dbt
        ├── profiles.yml            # Connexions ClickHouse (erp / mkt)
        │
        ├── macros/
        │   ├── clickhouse_delete_existing_rows.sql  # Hook suppression incrémental
        │   └── drop_table.sql                       # Utilitaire drop table
        │
        ├── models/
        │   ├── staging/
        │   │   ├── erp/            # ~67 vues de staging ERP (stg_erp__*)
        │   │   │   ├── _erp__sources.yml
        │   │   │   └── _erp__models.yml
        │   │   ├── market_place/   # ~56 vues de staging Marketplace (stg_mkt__*)
        │   │   │   ├── _market_place__sources.yml
        │   │   │   └── _market_place__models.yml
        │   │   └── crm/            # 7 vues de staging CRM (stg_crm__*)
        │   │       ├── _crm__sources.yml
        │   │       ├── _crm__models.yml
        │   │       └── _crm__docs.md
        │   │
        │   ├── intermediate/
        │   │   ├── erp/            # 9 modèles ephemeral (int_erp__*)
        │   │   ├── market_place/   # 3 modèles ephemeral (int_mkt__*)
        │   │   └── crm/            # 3 modèles ephemeral (int_crm__*)
        │   │
        │   └── marts/
        │       ├── erp/
        │       │   ├── core/                # Dims + facts ERP
        │       │   │   ├── catalog/         # Produits, marques, composants, PC models
        │       │   │   ├── financial/       # Comptabilité, banques, budgets
        │       │   │   ├── hr/              # Employés, contrats, congés, timesheets
        │       │   │   ├── inventory/       # Stock, entrepôts, n° de série
        │       │   │   └── procurement/     # Commandes achats, fournisseurs, factures
        │       │   └── reports/             # Tables reporting dénormalisées (rpt_erp__*)
        │       │       ├── financial/ ├── hr/ ├── inventory/ └── procurement/
        │       │
        │       ├── market_place/
        │       │   ├── core/                # Dims + facts Marketplace
        │       │   │   ├── catalog/         # Produits, marques, catégories
        │       │   │   ├── commerce/        # Commandes, paiements, clients, promos
        │       │   │   ├── customer_service/ # Avis, tickets support
        │       │   │   └── logistics/       # Expéditions, transporteurs, stock
        │       │   └── reports/             # Tables reporting dénormalisées (rpt_mkt__*)
        │       │       ├── catalog/ ├── commerce/ ├── customer_service/ └── logistics/
        │       │
        │       └── crm/
        │           ├── core/
        │           │   └── sales/           # Comptes, contacts, reps, opps, activités
        │           └── reports/             # Tables reporting dénormalisées (rpt_crm__*)
        │               ├── pipeline/        # Vue pipeline par opportunité
        │               └── sales/           # Performance par commercial
        │
        ├── seeds/                  # CSVs de référence statique
        └── target/                 # Artefacts compilés (gitignorés)
```

---

## 4. Prérequis

- **Docker Desktop** (pour Airflow **et** Airbyte)
- **Python 3.11+** (pour exécuter dbt en local)
- **ClickHouse** accessible sur `host.docker.internal:8123` (HTTP)
- **dbt-core** 1.11.x + **dbt-clickhouse** 1.9.8

```powershell
# Installation locale dbt
pip install dbt-core==1.11.2 dbt-clickhouse==1.9.8
```

---

## 5. Installation et démarrage

### 5.0 Démarrer Airbyte (self-hosted Docker)

```powershell
# Cloner Airbyte (si pas déjà fait)
git clone https://github.com/airbytehq/airbyte.git
Set-Location airbyte

# Lancer Airbyte
.\run-ab-platform.ps1
# ou sur Linux/Mac : ./run-ab-platform.sh
```

- **UI Airbyte :** http://localhost:8000 (user: `airbyte` / pass: `password`)
- **Configurer deux connexions** (une par source) :

  | Connexion         | Source                   | Destination ClickHouse |
  |-------------------|--------------------------|------------------------|
  | ERP               | PostgreSQL ERP           | Database : `DB_WH_ERP` |
  | Marketplace       | PostgreSQL Marketplace   | Database : `DB_WH_MKT` |
  | CRM               | PostgreSQL CRM           | Database : `DB_WH_CRM` |

  Paramètres communs de la destination ClickHouse :
  - Host : `host.docker.internal` (ou l'IP de ton ClickHouse)
  - Port : `8123`
  - Username / Password : selon ton `profiles.yml`

- **Sync mode recommandé :**
  - `Full Refresh | Overwrite` pour les petites tables de référence
  - `Incremental | Append` ou CDC pour les grandes tables transactionnelles

> ℹ️ Les tables créées par Airbyte dans ClickHouse seront préfixées `_airbyte_raw_` par défaut (selon la version). Les modèles `stg_erp__*` et `stg_mkt__*` de dbt pointent sur les tables **normalisées** créées par Airbyte (Basic Normalization désactivée = raw uniquement, les stagings dbt font la normalisation).

---

### 5.1 Démarrer la stack Airflow (Docker)

```powershell
# Depuis la racine du projet
docker compose up -d
```

Le `docker-compose.override.yml` monte automatiquement `./dbt` dans le conteneur Airflow sous `/usr/local/airflow/dbt`.

### 5.2 Installer les dépendances dbt

```powershell
Set-Location 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse'
dbt deps
```

### 5.3 Vérifier les connexions ClickHouse

```powershell
dbt debug --project-dir 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse' --target erp
dbt debug --project-dir 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse' --target mkt
```

### 5.4 Lancer un build complet

```powershell
# ERP (target par défaut)
dbt build --project-dir 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse' --target erp

# Marketplace
dbt build --project-dir 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse' --target mkt
```

---

## 6. Projet dbt — Détail

### 6.1 Couche Staging

**Matérialisation :** `view`
**Localisation :** `models/staging/erp/` et `models/staging/market_place/`
**Préfixes :** `stg_erp__` (source `erp`) et `stg_mkt__` (source `marketplace`)

Chaque modèle = un mapping 1-to-1 avec une table source. Les transformations se limitent à :
- Renommage et cast des colonnes
- Gestion des NULLs (`coalesce(col, '')` pour les colonnes texte non-nullables ClickHouse)
- Normalisation des types (dates, booléens, montants)

**ERP — ~67 modèles** couvrant : comptabilité (journaux, plan comptable, exercices fiscaux, banques, budgets), RH (employés, contrats, congés, timesheets), achats (commandes, réceptions, retours, fournisseurs, factures fournisseurs), inventaire (stock, entrepôts, emplacements, n° de série, inventaires), catalogue (produits, marques, composants, BOM, modèles PC), production (ordres de fabrication, réparations, qualité, garanties).

**Marketplace — ~56 modèles** couvrant : commerce (commandes, lignes, paiements, remboursements, retours, factures, avoirs), clients (comptes, adresses, paniers, wishlists, fidélité, newsletters), catalogue (produits, prix, historique prix, bundles PC, Q&A produits), logistique (expéditions, tracking, transporteurs, zones/méthodes/tarifs de livraison, stock), promotions (promos, codes remise, flash sales), SAV (tickets, messages, avis, votes).

**CRM — 7 modèles** couvrant : comptes (`accounts`), contacts, commerciaux (`sales_reps`), opportunités, activités commerciales, événements pipeline et tâches.

> ℹ️ **Note ClickHouse :** certaines colonnes source peuvent être NULL. Les colonnes `String` (non-Nullable) dans ClickHouse nécessitent `coalesce(col, '')` avant le CAST pour éviter `CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN`.

---

### 6.2 Couche Intermediate

**Matérialisation :** `ephemeral` (CTEs inlinés, aucun objet créé en base ClickHouse)
**Localisation :** `models/intermediate/erp/`, `models/intermediate/market_place/` et `models/intermediate/crm/`
**Préfixes :** `int_erp__`, `int_mkt__` et `int_crm__`

> ⚠️ **Compatibilité ClickHouse :** les modèles `ephemeral` ne doivent **pas** contenir de blocs `WITH` internes. ClickHouse ne supporte pas les WITH imbriqués générés par l'inlining dbt. Utiliser des `ref()` directs avec JOINs.

**ERP :**

| Modèle                                  | Description                                             |
|-----------------------------------------|---------------------------------------------------------|
| `int_erp__employee_overview`            | Vue consolidée employé + poste + département + contrat  |
| `int_erp__employee_contracts_stats`     | Stats salaire (min/max/avg) par employé                 |
| `int_erp__employee_with_contract_stats` | Employés enrichis avec statistiques contrats            |
| `int_erp__component_stock_status`       | État courant stock composants par emplacement           |
| `int_erp__component_stock_alerts`       | Alertes de stock (en-dessous du seuil minimum)          |
| `int_erp__product_stock_summary`        | Récapitulatif stock produit                             |
| `int_erp__purchase_orders_details`      | Détail lignes commandes + fournisseurs + produits       |
| `int_erp__purchase_order_status_stats`  | Stats commandes par statut                              |
| `int_erp__supplier_stats`               | Stats achats par fournisseur                            |

**Marketplace :**

| Modèle                                   | Description                                  |
|------------------------------------------|----------------------------------------------|
| `int_mkt__orders_joined_to_lines`        | Commandes jointes à leurs lignes             |
| `int_mkt__customers_aggregated_to_orders`| Agrégats commandes par client (LTV, volume)  |
| `int_mkt__products_aggregated_to_sales`  | Agrégats ventes par produit                  |

**CRM :**

| Modèle                                    | Description                                              |
|-------------------------------------------|----------------------------------------------------------|
| `int_crm__opportunities_with_pipeline`    | Opportunités enrichies avec vélocité pipeline (âge, nb changements d'étape, jours dans l'étape courante) |
| `int_crm__accounts_activity_stats`        | Agrégats activités/opps/revenus par compte               |
| `int_crm__sales_rep_stats`                | Performance agrégée par commercial (win rate, CA, tâches)|

---

### 6.3 Couche Marts

**Matérialisation :** `table` (MergeTree) ou `incremental` (stratégie `append`)
**Localisation :** `models/marts/erp/core/`, `models/marts/market_place/core/` et `models/marts/crm/core/`
**Moteur ClickHouse :** `MergeTree()` (configuré globalement dans `dbt_project.yml`)

#### ERP — 💰 Financial (`marts/erp/core/financial/`)

| Modèle                     | Type        | Description                      |
|----------------------------|-------------|----------------------------------|
| `dim_accounts`             | table       | Dimension plan comptable         |
| `dim_bank_accounts`        | table       | Dimension comptes bancaires      |
| `dim_budget_lines`         | table       | Dimension lignes budgétaires     |
| `dim_cost_centers`         | table       | Dimension centres de coût        |
| `fct_budget`               | table       | Fait budgets + lignes            |
| `fct_bank_transactions`    | incremental | Fait transactions bancaires      |
| `fct_bank_reconciliations` | incremental | Fait rapprochements bancaires    |
| `fct_journal_entries`      | incremental | Fait écritures comptables        |

#### ERP — 👤 HR (`marts/erp/core/hr/`)

| Modèle                   | Type        | Description                           |
|--------------------------|-------------|---------------------------------------|
| `dim_employees`          | table       | Dimension employés (enrichie)         |
| `dim_departments`        | table       | Dimension départements                |
| `dim_positions`          | table       | Dimension postes                      |
| `fct_employee_contracts` | table       | Fait contrats employés                |
| `fct_leaves`             | incremental | Fait congés (fenêtre glissante 7j)    |
| `fct_timesheets`         | incremental | Fait feuilles de temps                |

#### ERP — 📦 Inventory (`marts/erp/core/inventory/`)

| Modèle                        | Type        | Description                          |
|-------------------------------|-------------|--------------------------------------|
| `dim_warehouses`              | table       | Dimension entrepôts                  |
| `dim_warehouse_locations`     | table       | Dimension emplacements d'entrepôt    |
| `dim_serial_numbers`          | table       | Dimension numéros de série           |
| `fct_inventory_counts`        | table       | Fait inventaires physiques           |
| `fct_stock_level`             | incremental | Fait niveaux de stock                |
| `fct_component_stock_movement`| incremental | Fait mouvements de stock composants  |
| `fct_serial_tracking`         | incremental | Fait traçabilité des n° de série     |

#### ERP — 🏷️ Catalog (`marts/erp/core/catalog/`)

| Modèle                          | Type  | Description                            |
|---------------------------------|-------|----------------------------------------|
| `dim_brands`                    | table | Dimension marques                      |
| `dim_categories`                | table | Dimension catégories                   |
| `dim_products`                  | table | Dimension produits                     |
| `dim_components`                | table | Dimension composants                   |
| `dim_pc_models`                 | table | Dimension modèles PC                   |
| `dim_product_compatibilities`   | table | Compatibilités produit/composant       |
| `dim_product_specifications`    | table | Spécifications produit                 |
| `fct_component_stock_alerts`    | table | Fait alertes stock composants          |

#### ERP — 🛒 Procurement (`marts/erp/core/procurement/`)

| Modèle                      | Type        | Description                        |
|-----------------------------|-------------|------------------------------------|
| `dim_suppliers`             | table       | Dimension fournisseurs             |
| `dim_supplier_contacts`     | table       | Dimension contacts fournisseurs    |
| `fct_purchase_orders`       | incremental | Fait commandes d'achat             |
| `fct_purchase_order_status` | table       | Fait statuts des commandes         |
| `fct_purchase_receipt`      | incremental | Fait réceptions                    |
| `fct_purchase_return`       | incremental | Fait retours fournisseurs          |
| `fct_vendor_invoice`        | incremental | Fait factures fournisseurs         |
| `fct_supplier_contracts`    | incremental | Fait contrats fournisseurs         |

#### Marketplace — 🛍️ Commerce (`marts/market_place/core/commerce/`)

| Modèle               | Type        | Description                          |
|----------------------|-------------|--------------------------------------|
| `dim_customers`      | table       | Dimension clients (enrichie LTV)     |
| `dim_promotions`     | table       | Dimension promotions                 |
| `dim_discount_codes` | table       | Dimension codes remise               |
| `fct_orders`         | incremental | Fait commandes                       |
| `fct_payments`       | incremental | Fait paiements                       |
| `fct_refunds`        | table       | Fait remboursements                  |
| `fct_returns`        | table       | Fait retours clients                 |

#### Marketplace — 🏷️ Catalog (`marts/market_place/core/catalog/`)

| Modèle               | Type  | Description                            |
|----------------------|-------|----------------------------------------|
| `dim_mkt_products`   | table | Dimension produits (enrichie ventes)   |
| `dim_mkt_brands`     | table | Dimension marques                      |
| `dim_mkt_categories` | table | Dimension catégories                   |

#### Marketplace — 🚚 Logistics (`marts/market_place/core/logistics/`)

| Modèle                 | Type        | Description                       |
|------------------------|-------------|-----------------------------------|
| `dim_carriers`         | table       | Dimension transporteurs           |
| `dim_shipping_methods` | table       | Dimension méthodes de livraison   |
| `dim_mkt_warehouses`   | table       | Dimension entrepôts marketplace   |
| `fct_shipments`        | incremental | Fait expéditions                  |
| `fct_stock_levels`     | table       | Fait niveaux de stock             |

#### Marketplace — 🎧 Customer Service (`marts/market_place/core/customer_service/`)

| Modèle                | Type  | Description           |
|-----------------------|-------|-----------------------|
| `fct_reviews`         | table | Fait avis produits    |
| `fct_support_tickets` | table | Fait tickets support  |

#### CRM — 💼 Sales (`marts/crm/core/sales/`)

| Modèle                    | Type        | Description                                              |
|---------------------------|-------------|----------------------------------------------------------|
| `dim_crm_accounts`        | table       | Dimension comptes (enrichie activités + opps + revenus)  |
| `dim_crm_contacts`        | table       | Dimension contacts (full_name, lien cross-domaine)       |
| `dim_crm_sales_reps`      | table       | Dimension commerciaux (enrichie win rate, CA, pipeline)  |
| `fct_crm_opportunities`   | incremental | Fait opportunités (vélocité pipeline, incr. sur updated_at, fenêtre 30j) |
| `fct_crm_activities`      | incremental | Fait activités commerciales (incr. sur occurred_at, 7j)  |
| `fct_crm_pipeline_events` | incremental | Historique changements d'étape (incr. sur occurred_at, 7j)|
| `fct_crm_tasks`           | table       | Fait tâches (flags is_completed, is_on_time, is_overdue) |

---

### 6.4 Couche Reports

**Matérialisation :** `table` (MergeTree)
**Localisation :** `models/marts/erp/reports/`, `models/marts/market_place/reports/` et `models/marts/crm/reports/`
**Préfixes :** `rpt_erp__`, `rpt_mkt__` et `rpt_crm__`

Couche finale large et dénormalisée, consommée directement par les outils BI. Chaque report combine plusieurs marts en un seul modèle analytique prêt à l'emploi.

**ERP :**

| Modèle                              | Domaine     | Description                                  |
|-------------------------------------|-------------|----------------------------------------------|
| `rpt_erp__journal_entries_enriched` | financial   | Écritures comptables enrichies (comptes, centres de coût) |
| `rpt_erp__hr_workforce`             | hr          | Vue effectifs : employés + contrats + congés + temps |
| `rpt_erp__inventory_stock_status`   | inventory   | État du stock par entrepôt/emplacement       |
| `rpt_erp__component_movements`      | inventory   | Mouvements de stock composants enrichis      |
| `rpt_erp__procurement_orders`       | procurement | Commandes d'achat enrichies fournisseurs     |

**Marketplace :**

| Modèle                            | Domaine          | Description                              |
|-----------------------------------|------------------|------------------------------------------|
| `rpt_mkt__revenue_daily`          | commerce         | Chiffre d'affaires journalier            |
| `rpt_mkt__customer_ltv`           | commerce         | Lifetime value par client                |
| `rpt_mkt__product_performance`    | catalog          | Performance produit (ventes, avis)       |
| `rpt_mkt__logistics_performance`  | logistics        | Performance livraison (délais, transporteurs) |
| `rpt_mkt__customer_satisfaction`  | customer_service | Satisfaction client (avis, tickets)      |

**CRM :**

| Modèle                              | Domaine  | Description                                                      |
|-------------------------------------|----------|------------------------------------------------------------------|
| `rpt_crm__pipeline_overview`        | pipeline | Vue pipeline complète : opportunités enrichies compte + commercial + activités |
| `rpt_crm__sales_rep_performance`    | sales    | Performance par commercial : activités, win rate, CA, portefeuille, tendance 30j |

---

## 7. Commandes dbt courantes

```powershell
# Se placer dans le dossier du projet dbt
Set-Location 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse'

# --- Build & Run ---

# Run complet ERP
dbt run --target erp

# Run complet Marketplace
dbt run --target mkt

# Run complet CRM
dbt run --target crm

# Build complet (run + tests) — ERP
dbt build --target erp

# Build complet (run + tests) — Marketplace
dbt build --target mkt

# Build complet (run + tests) — CRM
dbt build --target crm

# Run d'un modèle spécifique (ERP)
dbt run --select dim_employees --target erp

# Run d'un modèle spécifique (Marketplace)
dbt run --select fct_orders --target mkt

# Run d'un modèle spécifique (CRM)
dbt run --select fct_crm_opportunities --target crm

# Run d'un dossier complet
dbt run --select path:models/marts/erp/core/financial --target erp
dbt run --select path:models/marts/market_place/core/commerce --target mkt
dbt run --select path:models/marts/crm/core/sales --target crm

# Run uniquement la couche reports
dbt run --select tag:reports --target erp
dbt run --select tag:reports --target mkt
dbt run --select tag:reports --target crm

# Run avec full-refresh (rebuild incrémentaux depuis zéro)
dbt run --full-refresh --select fct_leaves --target erp
dbt run --full-refresh --select fct_orders --target mkt
dbt run --full-refresh --select fct_crm_opportunities --target crm

# Run des modèles modifiés + leurs dépendants
dbt run --select state:modified+ --target erp

# --- Tests ---

# Lancer tous les tests
dbt test --target erp
dbt test --target mkt
dbt test --target crm

# Tests sur un modèle spécifique
dbt test --select dim_employees --target erp
dbt test --select fct_orders --target mkt
dbt test --select dim_crm_accounts --target crm

# --- Debug & Compilation ---

# Compiler sans exécuter (vérifier le SQL généré)
dbt compile --select dim_employees --target erp
dbt compile --select fct_orders --target mkt
dbt compile --select fct_crm_opportunities --target crm

# Vérifier les connexions
dbt debug --target erp
dbt debug --target mkt
dbt debug --target crm

# --- Documentation ---

# Générer la documentation (couvre les trois sources)
dbt docs generate --target erp

# Lancer le serveur de doc (http://localhost:8080)
dbt docs serve --target erp

# --- Nettoyage ---
dbt clean
```

---

## 8. Macros personnalisées

### `clickhouse_delete_existing_rows`

**Fichier :** `macros/clickhouse_delete_existing_rows.sql`

Génère une instruction `ALTER TABLE ... DELETE WHERE ... IN (SELECT ...)` pour supprimer les enregistrements existants avant un insert incrémental, sur une fenêtre de dates glissante.

**Signature :**
```sql
{{ clickhouse_delete_existing_rows(
    source_relation,   -- ref() ou relation source
    target_pk,         -- clé primaire dans la table cible
    source_pk,         -- clé primaire dans la table source
    date_col,          -- colonne de date pour filtrer la fenêtre
    days               -- nombre de jours dans la fenêtre glissante
) }}
```

**Exemple d'usage dans un modèle :**
```sql
{{
    config(
        materialized='incremental',
        pre_hook="{{ clickhouse_delete_existing_rows(ref('stg_erp__leaves'), 'id_leave', 'id_leave', 'starts_at', 7) }}"
    )
}}
```

> ℹ️ La macro retourne une chaîne vide si la table cible n'existe pas encore (premier run) — comportement sûr.

### `drop_table`

**Fichier :** `macros/drop_table.sql`

Utilitaire pour supprimer une table ClickHouse (usage en hooks ou scripts de maintenance).

---

## 9. Orchestration Airflow

Le DAG principal est `dags/warehouse_pipeline.py`.

### Pipeline en 3 phases

```
Phase 1+2 — 12 domaines en parallèle (limité par airbyte_pool)
  airbyte_trigger_<d> → airbyte_wait_<d> → dbt_run_<d> → dbt_test_<d>

Phase 3 — BI datamarts (déclenchés après les 12 dbt_test_*)
  dbt_run_bi_production → dbt_test_bi_production → dbt_run_bi_logistique
  dbt_run_bi_marketing / bi_finance / bi_rh / bi_sav  (parallèles)
```

### Configuration DAG

| Paramètre       | Valeur                                     |
|-----------------|--------------------------------------------|
| Schedule        | `0 3 * * *` (chaque nuit à 3h)            |
| Start date      | 2026-06-01                                 |
| Max active runs | 1                                          |
| Catchup         | False                                      |
| Notifications   | `on_failure_callback` sur toutes les tâches|

### Pool Airflow — concurrence Airbyte

Pour éviter de saturer Docker Desktop avec trop de syncs Airbyte simultanées, les tâches `airbyte_trigger_*` et `airbyte_wait_*` utilisent un pool dédié :

```bash
# À créer une fois après astro dev start (ou configurer dans Admin > Pools)
docker exec <scheduler-container> airflow pools set airbyte_pool 3 "Limite syncs Airbyte Docker local"
```

Le pool est aussi déclaré dans `airflow_settings.yaml` (recréé automatiquement au démarrage).

### Sensor Airbyte — résilience aux crashs transitoires

Le `AirbyteSyncSensor` gère les erreurs transitoires d'Airbyte (OOM, restart Docker) :

| Erreur                  | Comportement         |
|-------------------------|----------------------|
| `ConnectionError`       | reschedule (30s)     |
| `Timeout`               | reschedule (30s)     |
| `HTTPError` 5xx         | reschedule (30s)     |
| `HTTPError` 4xx         | échec immédiat       |
| Job Airbyte `failed`    | échec immédiat       |

### Auth Airbyte

OAuth2 `client_credentials` — token renouvelé à chaque poke. Si un job est déjà en cours (409), le trigger récupère son ID et le transmet au sensor.

**Chemins configurés** (`include/constants.py`) :

| Constante        | Valeur                                |
|------------------|---------------------------------------|
| `WAREHOUSE_DIR`  | `/usr/local/airflow/dbt/warehouse`    |
| `DBT_BIN`        | `/usr/local/airflow/dbt_venv/bin/dbt` |

**Volume Docker** — `docker-compose.override.yml` :
```yaml
services:
  scheduler:
    volumes:
      - ./dbt:/usr/local/airflow/dbt
```

---

## 10. Bonnes pratiques appliquées

Ce projet suit les recommandations dbt documentées dans `dbt_best_practices.md` :

| Pratique                                              | Statut |
|-------------------------------------------------------|--------|
| Ingestion via Airbyte (self-hosted, ERP + Marketplace)| ✅     |
| `source()` pointe sur les tables Airbyte              | ✅     |
| Nommage `stg_[source]__[entity]s`                     | ✅     |
| `source()` uniquement dans les stagings               | ✅     |
| Staging matérialisé en `view`                         | ✅     |
| Intermediate en `ephemeral`                           | ✅     |
| Marts en `table` / `incremental`                      | ✅     |
| Couche reports dénormalisée pour la BI                | ✅     |
| Tests `unique` + `not_null` sur les PKs               | ✅     |
| Fichiers YAML par dossier domaine                     | ✅     |
| `query-comment` pour traçabilité ClickHouse           | ✅     |
| `on_schema_change: append_new_columns`                | ✅     |
| `send_anonymous_usage_stats: false`                   | ✅     |

**Convention de nommage des colonnes :**

| Type       | Convention          | Exemple               |
|------------|---------------------|-----------------------|
| Clé primaire | `id_<entity>`     | `id_employee`         |
| Booléen    | `is_<something>`    | `is_active`           |
| Timestamp  | `<event>_at`        | `hired_at`, `created_at` |
| Date       | `<event>_date`      | `order_date`          |
| Montant    | snake_case complet  | `unit_price`, `total_ht` |

---

## 11. Sécurité — Credentials

### Fichiers sensibles

| Fichier         | Statut git   | Contenu                            |
|-----------------|--------------|------------------------------------|
| `.env`          | ignoré ✅    | Credentials réels (Airbyte, ClickHouse) |
| `.env.example`  | tracké ✅    | Template vide (pas de secrets)     |
| `profiles.yml`  | tracké ✅    | `env_var()` uniquement — pas de mot de passe en dur |

### Variables d'environnement requises

```bash
# ClickHouse
CLICKHOUSE_USER=admin
CLICKHOUSE_PASSWORD=<votre-mot-de-passe>

# Airbyte OAuth2
AIRBYTE_CLIENT_ID=<uuid>
AIRBYTE_CLIENT_SECRET=<secret>

# Connexions Airbyte (UUIDs)
AIRBYTE_CONN_ERP=<uuid>
AIRBYTE_CONN_CRM=<uuid>
AIRBYTE_CONN_MKT=<uuid>
# + optionnels : AIRBYTE_CONN_WMS, _MES, _MARKETING, _SAV, _PLM, _SIRH, _QMS, _FINANCE, _PROCUREMENT
```

> ⚠️ Si le repo a été public avec l'ancien `profiles.yml` (password en dur), changer le mot de passe ClickHouse et utiliser `git filter-branch` ou BFG Repo-Cleaner pour purger l'historique.

---

## 12. Troubleshooting ClickHouse

### ❌ Airbyte : tables non visibles dans ClickHouse après sync

- Vérifier que le sync a bien terminé (statut `Succeeded` dans l'UI Airbyte)
- Vérifier que le **schema** de destination correspond au bon schéma (`DB_WH_ERP`, `DB_WH_MKT` ou `DB_WH_CRM`)
- Airbyte crée parfois les tables dans un namespace différent : inspecter avec :
  ```sql
  SHOW TABLES FROM DB_WH_ERP;
  SHOW TABLES FROM DB_WH_MKT;
  SHOW TABLES FROM DB_WH_CRM;
  ```
- Si Basic Normalization est activée dans Airbyte, des tables `<entity>` normalisées sont créées à côté des `_airbyte_raw_<entity>`. Les sources dbt dans `_erp__sources.yml`, `_market_place__sources.yml` et `_crm__sources.yml` doivent pointer sur les bonnes tables.

### ❌ Airbyte : erreur de connexion ClickHouse destination

```
Connection refused to host.docker.internal:8123
```

- S'assurer que ClickHouse est bien accessible depuis le réseau Docker d'Airbyte
- Sur Windows/Mac, `host.docker.internal` résout automatiquement vers la machine hôte
- Sur Linux, ajouter `--add-host=host.docker.internal:host-gateway` au conteneur Airbyte, ou utiliser l'IP de la machine hôte directement

---

### ❌ `CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN`

```
Cannot convert NULL value to non-Nullable type: CAST(col, 'varchar')
```

**Cause :** colonne source NULL insérée dans un type `String` non-Nullable ClickHouse.

**Solution :** dans le modèle staging, entourer le CAST avec un COALESCE :
```sql
-- Avant
cast(col as varchar) as col

-- Après
cast(coalesce(col, '') as varchar) as col
```

---

### ❌ `SYNTAX_ERROR` sur `EXISTS ... DELETE`

```
Syntax error: failed at position 25 (EXISTS) ...
Expected one of: ON, a list of ALTER commands ...
```

**Cause :** le hook `pre_hook` produit une instruction mal formée.

**Solution :** vérifier le SQL compilé dans `target/compiled/` et s'assurer que la macro `clickhouse_delete_existing_rows` produit bien :
```sql
ALTER TABLE DB_WH_ERP.fct_leaves DELETE WHERE id_leave IN (SELECT ...)
```

---

### ❌ `UNKNOWN_IDENTIFIER` dans un modèle `ephemeral`

```
Unknown expression identifier `col_name` in scope WITH __dbt__cte__... AS (WITH ... )
```

**Cause :** ClickHouse ne supporte pas les WITH imbriqués générés par l'inlining des `ephemeral` qui contiennent eux-mêmes des CTEs.

**Solution :** réécrire les modèles `ephemeral` sans bloc `WITH` interne :

```sql
-- ❌ À éviter (génère un WITH imbriqué à l'inlining)
with employees as (select * from {{ ref('stg_erp__employees') }})
select ...

-- ✅ Correct pour un ephemeral ClickHouse
select e.id_employee, ...
from {{ ref('stg_erp__employees') }} as e
left join {{ ref('stg_erp__employee_contracts') }} as c
    on e.id_employee = c.employee_id
```

---

### 🔍 Commandes de debug ClickHouse

```sql
-- Dernières requêtes dbt
SELECT query, log_comment, query_duration_ms
FROM system.query_log
WHERE log_comment LIKE '%dbt%'
  AND type = 'QueryFinish'
ORDER BY event_time DESC
LIMIT 20;

-- Erreurs récentes
SELECT query, exception, event_time
FROM system.query_log
WHERE type = 'ExceptionWhileProcessing'
  AND event_time > now() - INTERVAL 1 HOUR
ORDER BY event_time DESC;
```

---

## Licence

Voir [LICENSE](LICENSE).
