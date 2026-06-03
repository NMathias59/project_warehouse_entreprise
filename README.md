# 🏭 Project Warehouse Entreprise — Data Platform ERP

> Pipeline de données complet d'un ERP vers un Data Warehouse ClickHouse — ingestion via **Airbyte** (self-hosted Docker), orchestration **Apache Airflow** (Astronomer Cosmos) et transformations **dbt**.

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
7. [Commandes dbt courantes](#7-commandes-dbt-courantes)
8. [Macros personnalisées](#8-macros-personnalisées)
9. [Orchestration Airflow](#9-orchestration-airflow)
10. [Bonnes pratiques appliquées](#10-bonnes-pratiques-appliquées)
11. [Troubleshooting ClickHouse](#11-troubleshooting-clickhouse)

---

## 1. Vue d'ensemble

Ce projet implémente un entrepôt de données analytique pour un système ERP. Il couvre :

| Domaine métier      | Description                                         |
|---------------------|-----------------------------------------------------|
| 💰 **Finance**      | Budgets, rapprochements bancaires, journaux comptables, transactions |
| 👤 **RH**           | Employés, contrats, congés, feuilles de temps        |
| 📦 **Inventaire**   | Stock composants, alertes, mouvements               |
| 🛒 **Achats**       | Bons de commande, fournisseurs, réceptions           |
| 🏷️ **Catalogue**    | Produits, marques, catégories                        |
| ⚙️ **Opérations**   | Ordres de fabrication, qualité (en cours)           |

**Stack technique :**

```
ERP (PostgreSQL/autre)
        │
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
   schema: DB_WH_ERP
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
│  SOURCE (ERP)                                               │
│  PostgreSQL / autre SGBDR                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │  Airbyte Connector
                           │  (full refresh ou CDC)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  INGESTION — Airbyte self-hosted (Docker)                   │
│  • UI : http://localhost:8000                               │
│  • Connecteurs : Postgres Source → ClickHouse Destination   │
│  • Sync mode : Full Refresh / Incremental (CDC)             │
│  • Destination : tables raw dans DB_WH_ERP                  │
└──────────────────────────┬──────────────────────────────────┘
                           │  Tables raw ClickHouse
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  TRANSFORMATION — dbt Core 1.11.2 (via Airflow + Cosmos)   │
│                                                             │
│  staging/   → views    (nettoyage, cast, rename)            │
│  intermediate/ → ephemeral (logique métier, CTEs)           │
│  marts/     → tables   (MergeTree, prêt BI)                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  DATA WAREHOUSE — ClickHouse 25.x                           │
│  Schema : DB_WH_ERP                                         │
│  Consommé par : BI tools, dashboards, analyses              │
└─────────────────────────────────────────────────────────────┘
```

### Schémas ClickHouse

| Target dbt | Schéma ClickHouse | Usage                    |
|------------|-------------------|--------------------------|
| `erp`      | `DB_WH_ERP`       | Entrepôt ERP (principal) |
| `mkt`      | `DB_WH_MKT`       | Entrepôt Marketing (futur) |

### Matérialisations par couche

```
staging/      → view        (léger, toujours frais, pas d'objet physique)
intermediate/ → ephemeral   (inline CTE, pas d'objet créé en base)
marts/        → table       (MergeTree, performant pour la BI)
              → incremental (pour les grandes tables avec updates)
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
        │   │   └── erp/            # ~65 vues de staging ERP
        │   │       ├── _erp__sources.yml
        │   │       ├── _erp__models.yml
        │   │       ├── _erp__docs.md
        │   │       └── stg_erp__*.sql
        │   │
        │   ├── intermediate/
        │   │   └── erp/            # 9 modèles ephemeral
        │   │       ├── _erp__models.yml
        │   │       └── int_erp__*.sql
        │   │
        │   └── marts/
        │       └── erp/
        │           └── core/
        │               ├── financial/   # Modèles financiers
        │               ├── hr/          # Modèles RH
        │               ├── inventory/   # Modèles inventaire
        │               ├── catalog/     # Modèles catalogue produit
        │               ├── operations/  # (en cours)
        │               └── procurement/ # (en cours)
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
- **Configurer la Source :** ton SGBDR ERP (ex. PostgreSQL connector)
- **Configurer la Destination :** ClickHouse connector
  - Host : `host.docker.internal` (ou l'IP de ton ClickHouse)
  - Port : `8123`
  - Database : `DB_WH_ERP`
  - Username / Password : selon ton `profiles.yml`
- **Sync mode recommandé :**
  - `Full Refresh | Overwrite` pour les petites tables de référence
  - `Incremental | Append` ou CDC pour les grandes tables transactionnelles

> ℹ️ Les tables créées par Airbyte dans ClickHouse seront préfixées `_airbyte_raw_` par défaut (selon la version). Les modèles `stg_erp__*` de dbt pointent sur les tables **normalisées** créées par Airbyte (Basic Normalization désactivée = raw uniquement, les stagings dbt font la normalisation).

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

### 5.3 Vérifier la connexion ClickHouse

```powershell
dbt debug --project-dir 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse' --target erp
```

### 5.4 Lancer un build complet

```powershell
dbt build --project-dir 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse' --target erp
```

---

## 6. Projet dbt — Détail

### 6.1 Couche Staging

**Matérialisation :** `view`
**Localisation :** `models/staging/erp/`
**Préfixe :** `stg_erp__`

Chaque modèle = un mapping 1-to-1 avec une table source ERP. Les transformations se limitent à :
- Renommage et cast des colonnes
- Gestion des NULLs (`coalesce(col, '')` pour les colonnes texte non-nullables ClickHouse)
- Normalisation des types (dates, booléens, montants)

**Modèles disponibles (sélection) :**

| Modèle                           | Description                        |
|----------------------------------|------------------------------------|
| `stg_erp__employees`             | Employés                           |
| `stg_erp__employee_contracts`    | Contrats employés                  |
| `stg_erp__departments`           | Départements                       |
| `stg_erp__positions`             | Postes                             |
| `stg_erp__leaves`                | Congés                             |
| `stg_erp__timesheets`            | Feuilles de temps                  |
| `stg_erp__budgets`               | Budgets                            |
| `stg_erp__budget_lines`          | Lignes de budget                   |
| `stg_erp__bank_transactions`     | Transactions bancaires             |
| `stg_erp__bank_reconciliations`  | Rapprochements bancaires           |
| `stg_erp__journal_entries`       | Écritures comptables               |
| `stg_erp__purchase_orders`       | Bons de commande                   |
| `stg_erp__suppliers`             | Fournisseurs                       |
| `stg_erp__products`              | Produits                           |
| `stg_erp__components`            | Composants                         |
| `stg_erp__component_stock`       | Stock composants                   |
| `stg_erp__work_orders`           | Ordres de fabrication              |

> ℹ️ **Note ClickHouse :** certaines colonnes source peuvent être NULL. Les colonnes `String` (non-Nullable) dans ClickHouse nécessitent `coalesce(col, '')` avant le CAST pour éviter `CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN`.

---

### 6.2 Couche Intermediate

**Matérialisation :** `ephemeral` (CTEs inlinés, aucun objet créé en base ClickHouse)
**Localisation :** `models/intermediate/erp/`
**Préfixe :** `int_erp__`

> ⚠️ **Compatibilité ClickHouse :** les modèles `ephemeral` ne doivent **pas** contenir de blocs `WITH` internes. ClickHouse ne supporte pas les WITH imbriqués générés par l'inlining dbt. Utiliser des `ref()` directs avec JOINs.

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

---

### 6.3 Couche Marts

**Matérialisation :** `table` (MergeTree) ou `incremental`
**Localisation :** `models/marts/erp/core/`
**Moteur ClickHouse :** `MergeTree()` (configuré globalement dans `dbt_project.yml`)

#### 💰 Financial (`marts/erp/core/financial/`)

| Modèle                     | Type        | Description                      |
|----------------------------|-------------|----------------------------------|
| `dim_account`              | table       | Dimension plan comptable         |
| `dim_bank_account`         | table       | Dimension comptes bancaires      |
| `dim_buget_line`           | table       | Dimension lignes budgétaires     |
| `dim_cost_center`          | table       | Dimension centres de coût        |
| `fct_budget`               | table       | Fait budgets + lignes            |
| `fct_bank_transactions`    | incremental | Fait transactions bancaires      |
| `fct_bank_reconciliations` | incremental | Fait rapprochements bancaires    |
| `fct__journal_entries`     | incremental | Fait écritures comptables        |

#### 👤 HR (`marts/erp/core/hr/`)

| Modèle                  | Type        | Description                           |
|-------------------------|-------------|---------------------------------------|
| `dim_employee`          | table       | Dimension employés (enrichie)         |
| `dim_departement`       | table       | Dimension départements                |
| `dim_position`          | table       | Dimension postes                      |
| `fct_employee_cotracts` | table       | Fait contrats employés                |
| `fct_leaves`            | incremental | Fait congés (fenêtre glissante 7j)    |
| `fct_timesheets`        | incremental | Fait feuilles de temps                |

#### 📦 Inventory (`marts/erp/core/inventory/`)

| Modèle               | Type  | Description       |
|----------------------|-------|-------------------|
| `fct_invotory_count` | table | Fait inventaires  |

#### 🏷️ Catalog (`marts/erp/core/catalog/`)

| Modèle      | Type  | Description       |
|-------------|-------|-------------------|
| `dim_brand` | table | Dimension marques |

---

## 7. Commandes dbt courantes

```powershell
# Se placer dans le dossier du projet dbt
Set-Location 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse'

# --- Build & Run ---

# Run complet (tous les modèles)
dbt run --target erp

# Build complet (run + tests)
dbt build --target erp

# Run d'un modèle spécifique
dbt run --select dim_employee --target erp

# Run d'un dossier complet
dbt run --select path:models/marts/erp/core/financial --target erp

# Run avec full-refresh (rebuild incrémentaux depuis zéro)
dbt run --full-refresh --select fct_leaves --target erp

# Run des modèles modifiés + leurs dépendants
dbt run --select state:modified+ --target erp

# --- Tests ---

# Lancer tous les tests
dbt test --target erp

# Tests sur un modèle spécifique
dbt test --select dim_employee --target erp

# --- Debug & Compilation ---

# Compiler sans exécuter (vérifier le SQL généré)
dbt compile --select dim_employee --target erp

# Voir le SQL compilé
type target\compiled\warehouse\models\marts\erp\core\hr\dim_employee.sql

# Vérifier la connexion
dbt debug --target erp

# --- Documentation ---

# Générer la documentation
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

Le fichier `dags/example_dbt_cosmos.py` définit un DAG Airflow qui exécute le projet dbt via [Astronomer Cosmos](https://astronomer.github.io/astronomer-cosmos/).

**Configuration :**

| Paramètre          | Valeur                        |
|--------------------|-------------------------------|
| Schedule           | `@daily`                      |
| Start date         | 2025-04-01                    |
| Max active tasks   | 1                             |
| Max active runs    | 1                             |
| Is paused          | False (démarre immédiatement) |

**Chemins configurés** (`include/constants.py`) :

| Constante            | Valeur                                    |
|----------------------|-------------------------------------------|
| `warehouse_path`     | `/usr/local/airflow/dbt/warehouse`        |
| `dbt_executable`     | `/usr/local/airflow/dbt_venv/bin/dbt`     |

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

| Pratique                                    | Statut |
|---------------------------------------------|--------|
| Ingestion via Airbyte (self-hosted)         | ✅     |
| `source()` pointe sur les tables Airbyte    | ✅     |
| Nommage `stg_[source]__[entity]s`           | ✅     |
| `source()` uniquement dans les stagings     | ✅     |
| Staging matérialisé en `view`               | ✅     |
| Intermediate en `ephemeral`                 | ✅     |
| Marts en `table` / `incremental`            | ✅     |
| Tests `unique` + `not_null` sur les PKs     | ✅     |
| Fichiers YAML par dossier source            | ✅     |
| `query-comment` pour traçabilité ClickHouse | ✅     |
| `on_schema_change: append_new_columns`      | ✅     |
| `send_anonymous_usage_stats: false`         | ✅     |

**Convention de nommage des colonnes :**

| Type       | Convention          | Exemple               |
|------------|---------------------|-----------------------|
| Clé primaire | `id_<entity>`     | `id_employee`         |
| Booléen    | `is_<something>`    | `is_active`           |
| Timestamp  | `<event>_at`        | `hired_at`, `created_at` |
| Date       | `<event>_date`      | `order_date`          |
| Montant    | snake_case complet  | `unit_price`, `total_ht` |

---

## 11. Troubleshooting ClickHouse

### ❌ Airbyte : tables non visibles dans ClickHouse après sync

- Vérifier que le sync a bien terminé (statut `Succeeded` dans l'UI Airbyte)
- Vérifier que le **schema** de destination correspond bien à `DB_WH_ERP`
- Airbyte crée parfois les tables dans un namespace différent : inspecter avec :
  ```sql
  SHOW TABLES FROM DB_WH_ERP;
  ```
- Si Basic Normalization est activée dans Airbyte, des tables `<entity>` normalisées sont créées à côté des `_airbyte_raw_<entity>`. Les sources dbt dans `_erp__sources.yml` doivent pointer sur les bonnes tables.

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
