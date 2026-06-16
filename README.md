# Data Warehouse Entreprise — Pipeline ERP/CRM/Marketplace vers ClickHouse

> Plateforme analytique complète couvrant **12 domaines métier** d'une entreprise industrielle : ingestion via **Airbyte** (self-hosted), orchestration via **Apache Airflow**, transformations via **dbt Core**, stockage dans **ClickHouse 25.7**.
> **436 modèles · 878 tests · 208 sources · 10 BI datamarts cross-domaines**

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Stack technique](#2-stack-technique)
3. [Architecture](#3-architecture)
4. [Domaines métier couverts](#4-domaines-métier-couverts)
5. [Structure du projet](#5-structure-du-projet)
6. [Couche Staging](#6-couche-staging)
7. [Couche Intermediate](#7-couche-intermediate)
8. [Couche Marts — Core](#8-couche-marts--core)
9. [Couche Marts — Reports](#9-couche-marts--reports)
10. [BI Datamarts cross-domaines](#10-bi-datamarts-cross-domaines)
11. [Orchestration Airflow](#11-orchestration-airflow)
12. [Spécificités ClickHouse 25.7](#12-spécificités-clickhouse-257)
13. [Commandes dbt](#13-commandes-dbt)
14. [Installation et démarrage](#14-installation-et-démarrage)
15. [Macros personnalisées](#15-macros-personnalisées)
16. [Bonnes pratiques appliquées](#16-bonnes-pratiques-appliquées)
17. [Troubleshooting](#17-troubleshooting)

---

## 1. Vue d'ensemble

Ce projet implémente un entrepôt de données analytique pour une **entreprise industrielle** disposant de plusieurs systèmes sources hétérogènes. L'objectif est de centraliser, nettoyer et modéliser les données pour alimenter des outils BI et des analyses décisionnelles.

### Périmètre fonctionnel

| # | Domaine | Système source | Base ClickHouse |
|---|---------|---------------|-----------------|
| 1 | **ERP** | PostgreSQL ERP | `DB_WH_ERP` |
| 2 | **CRM** | PostgreSQL CRM | `DB_WH_CRM` |
| 3 | **Marketplace** | PostgreSQL MKT | `DB_WH_MKT` |
| 4 | **WMS** — Warehouse Management | PostgreSQL WMS | `DB_WH_WMS` |
| 5 | **MES** — Manufacturing Execution | PostgreSQL MES | `DB_WH_MES` |
| 6 | **Marketing** — Campagnes & leads | PostgreSQL MKG | `DB_WH_MARKETING` |
| 7 | **SAV** — Service Après-Vente | PostgreSQL SAV | `DB_WH_SAV` |
| 8 | **PLM** — Product Lifecycle Mgmt | PostgreSQL PLM | `DB_WH_PLM` |
| 9 | **SIRH** — RH & paie | PostgreSQL SIRH | `DB_WH_SIRH` |
| 10 | **QMS** — Quality Management | PostgreSQL QMS | `DB_WH_QMS` |
| 11 | **Finance** — Comptabilité & budget | PostgreSQL FIN | `DB_WH_FINANCE` |
| 12 | **Procurement** — Achats | PostgreSQL PROC | `DB_WH_PROCUREMENT` |
| + | **BI datamarts** cross-domaines | — | `DB_BI_*` |

### Chiffres clés

| Métrique | Valeur |
|----------|--------|
| Modèles dbt | **436** |
| Tests dbt | **878** |
| Sources déclarées | **208** |
| Macros dbt | **3** |
| Domaines sources | **12** |
| BI datamarts | **10** |
| Targets dbt | **22** (12 domaines + 10 BI) |

---

## 2. Stack technique

| Composant | Version | Rôle |
|-----------|---------|------|
| **ClickHouse** | 25.7.1 | Moteur OLAP — stockage analytique, moteur MergeTree |
| **dbt Core** | 1.11.2 | Framework de transformation SQL |
| **dbt-clickhouse** | 1.9.8 | Adapter dbt ↔ ClickHouse |
| **Apache Airflow** | 3.x (Astronomer) | Orchestration des pipelines |
| **astronomer-cosmos** | 1.10.0 | Intégration native dbt dans Airflow |
| **Airbyte OSS** | self-hosted Docker | Ingestion CDC/full-refresh depuis 12 PostgreSQL |
| **Docker** | — | Conteneurisation Airflow + Airbyte |
| **Python** | 3.12 | Runtime Airflow + dbt venv isolé |

### Pourquoi ClickHouse ?

ClickHouse est un moteur OLAP orienté colonnes offrant des performances de lecture analytique bien supérieures à PostgreSQL sur des volumes importants. Ses caractéristiques utilisées dans ce projet :

- **MergeTree** : moteur de table principal, performant sur `ORDER BY` et `GROUP BY`
- **Vues** : légères, toujours fraîches, sans coût de stockage
- **`argMax(col, timestamp)`** : déduplication UPSERT sur les tables Airbyte (`_airbyte_extracted_at`)
- **`countIf` / `sumIf`** : agrégations conditionnelles natives
- **`toStartOfWeek` / `toMonth`** : fonctions temporelles intégrées
- **`allow_nullable_key`** : paramètre MergeTree pour `ORDER BY` sur colonnes nullables

---

## 3. Architecture

### Flux de données complet

```
┌──────────────────────────────────────────────────────────────────────┐
│  SOURCES  (12 × PostgreSQL)                                          │
│  ERP · CRM · MKT · WMS · MES · MKG · SAV · PLM · SIRH · QMS        │
│  FINANCE · PROCUREMENT                                               │
└─────────────────────────────┬────────────────────────────────────────┘
                              │  Connecteurs Airbyte
                              │  Full Refresh | CDC Incremental
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│  INGESTION — Airbyte OSS (Docker, http://localhost:8000)             │
│  • Auth OAuth2 client_credentials                                    │
│  • 12 connexions PostgreSQL → ClickHouse                             │
│  • Tables raw dans ClickHouse (colonnes Airbyte : _airbyte_*)        │
│  • Déduplication gérée côté dbt (argMax sur _airbyte_extracted_at)   │
└─────────────────────────────┬────────────────────────────────────────┘
                              │  Tables raw ClickHouse
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│  ORCHESTRATION — Apache Airflow (Astronomer, http://localhost:8080)  │
│                                                                      │
│  Phase 1+2 — 12 domaines en parallèle (pool airbyte_pool=3) :       │
│    airbyte_trigger_<d> → airbyte_wait_<d>                            │
│                        → dbt_run_<d> → dbt_test_<d>                 │
│                                                                      │
│  Phase 3 — BI datamarts (après tous les dbt_test_*) :               │
│    dbt_run_bi_production → dbt_test_bi_production                    │
│                         → dbt_run_bi_logistique                     │
│    dbt_run_bi_marketing / bi_finance / bi_rh / bi_sav               │
└─────────────────────────────┬────────────────────────────────────────┘
                              │  BashOperator → dbt venv isolé
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│  TRANSFORMATION — dbt Core 1.11.2                                    │
│                                                                      │
│  staging/      → VIEW        nettoyage, cast, rename, dédup          │
│  intermediate/ → VIEW        logique métier, enrichissement, JOINs   │
│  marts/core/   → TABLE       MergeTree, dims + faits, BI-ready       │
│  marts/reports/→ TABLE       MergeTree, large dénormalisé BI         │
│  marts/BI_*/   → TABLE       Cross-domaines, datamarts analytiques   │
└─────────────────────────────┬────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│  DATA WAREHOUSE — ClickHouse 25.7                                    │
│  18 schémas : DB_WH_{ERP,CRM,MKT,WMS,MES,MARKETING,SAV,PLM,         │
│               SIRH,QMS,FINANCE,PROCUREMENT}                          │
│               DB_BI_{PRODUCTION,LOGISTIQUE,MARKETING,FINANCE,       │
│                       RH,SAV,COMMERCIAL,ACHATS,QUALITE,PRODUIT}      │
│  Consommé par : outils BI, notebooks analytiques, dashboards         │
└──────────────────────────────────────────────────────────────────────┘
```

### Matérialisations dbt par couche

| Couche | Matérialisation | Moteur ClickHouse | Raison |
|--------|----------------|-------------------|--------|
| `staging/` | `view` | — | Toujours frais, aucun coût de stockage |
| `intermediate/` | `view` | — | Testable directement, évite les CTEs imbriquées ClickHouse |
| `marts/core/` | `table` | `MergeTree()` | Performant pour requêtes BI |
| `marts/core/` (grandes tables) | `incremental` | `MergeTree()` | Append sur fenêtre glissante |
| `marts/reports/` | `table` | `MergeTree()` | Large dénormalisé, prêt BI |
| `marts/BI_*/` | `table` | `MergeTree()` | Cross-domaines, datamarts analytiques |

> **Note architecture intermédiaire** : les modèles `intermediate/` ont été migrés de `ephemeral` vers `view` pour contourner une limitation ClickHouse 25.7 avec le nouvel analyseur de requêtes (`enable_analyzer=1` par défaut). Un `ephemeral` inliné dans un mart produisait des CTEs imbriquées que ClickHouse 25.7 ne peut pas résoudre quand les sous-CTEs référencent des VIEWs.

---

## 4. Domaines métier couverts

### ERP (`DB_WH_ERP`)
Système de gestion d'entreprise principal — comptabilité, RH, achats, inventaire, catalogue produits, production.

**Sous-domaines :** Finance interne · Ressources Humaines · Inventaire composants · Achats fournisseurs · Catalogue produits/BOM · Production/réparations

### CRM (`DB_WH_CRM`)
Gestion de la relation client — pipeline commercial, activités, comptes, contacts.

**Sous-domaines :** Comptes clients · Contacts · Opportunités · Activités commerciales · Pipeline · Tâches

### Marketplace (`DB_WH_MKT`)
Plateforme e-commerce — commandes, clients, catalogue, logistique, SAV.

**Sous-domaines :** Commerce (commandes, paiements, promotions) · Catalogue (produits, prix, bundles) · Logistique (expéditions, transporteurs) · Service client (tickets, avis)

### WMS (`DB_WH_WMS`)
Warehouse Management System — gestion physique de l'entrepôt.

**Entités :** Emplacements (allées, racks, zones) · Réceptions · Expéditions · Picking · Mouvements de stock · Ajustements d'inventaire

### MES (`DB_WH_MES`)
Manufacturing Execution System — suivi de la production en temps réel.

**Entités :** Ordres de production · Opérations · Centres de travail · Défauts qualité · Consommations matières

### Marketing (`DB_WH_MARKETING`)
Gestion des campagnes marketing digitales et génération de leads.

**Entités :** Campagnes · Performances publicitaires (impressions, clics, coût) · Envois email · Événements email (opened, clicked, bounced) · Audiences · Leads · UTM links

### SAV (`DB_WH_SAV`)
Service Après-Vente — tickets de support et résolution client.

**Entités :** Tickets support · Messages · Historique des statuts

### PLM (`DB_WH_PLM`)
Product Lifecycle Management — gestion du cycle de vie des produits.

**Entités :** Produits (versions, statut cycle de vie) · Nomenclatures (BOM/lignes) · Demandes de changement (CR)

### SIRH (`DB_WH_SIRH`)
Système d'Information RH — employés, contrats, postes, départements.

**Entités :** Employés · Contrats · Postes · Départements

### QMS (`DB_WH_QMS`)
Quality Management System — non-conformités, audits, actions correctives.

**Entités :** Non-conformités · Actions correctives · Audits · Constats d'audit · Plans de contrôle · Points de contrôle · Certifications · Évaluations fournisseurs

### Finance (`DB_WH_FINANCE`)
Comptabilité analytique — journaux, budgets, banque, comptes.

**Entités :** Comptes comptables · Centres de coût · Exercices fiscaux · Périodes comptables · Écritures comptables · Lignes d'écriture · Budgets · Lignes budgétaires · Transactions bancaires · Comptes bancaires · Conditions de paiement

### Procurement (`DB_WH_PROCUREMENT`)
Achats — fournisseurs, bons de commande, réceptions, appels d'offres.

**Entités :** Fournisseurs · Contacts fournisseurs · Bons de commande · Lignes de commande · Réceptions · Lignes de réception · Appels d'offres (RFQ) · Lignes RFQ · Réponses RFQ · Contrats · Lignes de contrat · Évaluations fournisseurs

---

## 5. Structure du projet

```
project_warehouse_entreprise/
├── Dockerfile                          # Image Astronomer + dbt venv Python 3.12
├── docker-compose.override.yml         # Mount ./dbt dans /usr/local/airflow/dbt
├── airflow_settings.yaml               # Pools Airflow (airbyte_pool=3)
│
├── dags/
│   └── warehouse_pipeline.py           # DAG principal — 3 phases, 12 domaines
│
├── include/
│   └── constants.py                    # Sélecteurs dbt, chemins, configs Airbyte
│
├── dbt/
│   └── warehouse/
│       ├── dbt_project.yml             # Config projet, matérialisations par défaut
│       ├── profiles.yml                # 18 targets ClickHouse (12 domaines + 6 BI)
│       │
│       ├── macros/
│       │   ├── clickhouse_delete_existing_rows.sql
│       │   └── drop_table.sql
│       │
│       └── models/
│           ├── staging/                # 12 sous-dossiers (1 par domaine)
│           │   ├── erp/                # ~67 vues stg_erp__*
│           │   ├── market_place/       # ~56 vues stg_mkt__*
│           │   ├── crm/                # 7 vues stg_crm__*
│           │   ├── wms/                # stg_wms__*
│           │   ├── mes/                # stg_mes__*
│           │   ├── marketing/          # stg_marketing__*
│           │   ├── sav/                # stg_sav__*
│           │   ├── plm/                # stg_plm__*
│           │   ├── sirh/               # stg_sirh__*
│           │   ├── qms/                # stg_qms__*
│           │   ├── finance/            # stg_finance__*
│           │   └── procurement/        # stg_procurement__*
│           │
│           ├── intermediate/           # 12 sous-dossiers (1 par domaine)
│           │   ├── erp/               # int_erp__* (9 modèles)
│           │   ├── market_place/      # int_mkt__* (3 modèles)
│           │   ├── crm/               # int_crm__* (3 modèles)
│           │   ├── wms/               # int_wms__*
│           │   ├── mes/               # int_mes__*
│           │   ├── marketing/         # int_marketing__*
│           │   ├── sav/               # int_sav__*
│           │   ├── plm/               # int_plm__*
│           │   ├── sirh/              # int_sirh__*
│           │   ├── qms/               # int_qms__*
│           │   ├── finance/           # int_finance__*
│           │   └── procurement/       # int_procurement__*
│           │
│           ├── marts/
│           │   ├── erp/core/{catalog,financial,hr,inventory,procurement,production}/
│           │   ├── erp/reports/{catalog,financial,hr,inventory,procurement}/
│           │   ├── market_place/core/{catalog,commerce,customer_service,logistics}/
│           │   ├── market_place/reports/{catalog,commerce,conversion,customer_service,logistics,marketing}/
│           │   ├── crm/core/sales/
│           │   ├── crm/reports/{pipeline,sales}/
│           │   ├── wms/core/inventory/  + wms/reports/operations/
│           │   ├── mes/core/production/ + mes/reports/production/
│           │   ├── marketing/core/acquisition/ + marketing/reports/performance/
│           │   ├── sav/core/support/    + sav/reports/support/
│           │   ├── plm/core/product/    + plm/reports/product/
│           │   ├── sirh/core/hr/        + sirh/reports/workforce/
│           │   ├── qms/core/quality/    + qms/reports/quality/
│           │   ├── finance/core/accounting/ + finance/reports/financial/
│           │   ├── procurement/core/sourcing/ + procurement/reports/sourcing/
│           │   ├── BI_PRODUCTION/
│           │   ├── BI_LOGISTIQUE/
│           │   ├── BI_MARKETING/
│           │   ├── BI_FINANCE/
│           │   ├── BI_RH/
│           │   ├── BI_SAV/
│           │   ├── BI_COMMERCIAL/
│           │   ├── BI_ACHATS/
│           │   ├── BI_QUALITE/
│           │   └── BI_PRODUIT/
│           │
│           └── seeds/
```

---

## 6. Couche Staging

**Matérialisation :** `view`  
**Convention :** `stg_<source>__<entité>` (double underscore séparateur source/entité)  
**Principe :** 1 modèle = 1 table source. Transformations limitées au nettoyage.

### Transformations appliquées dans chaque staging

```sql
-- 1. Déduplication Airbyte (argMax sur _airbyte_extracted_at)
select
    id,
    argMax(col, _airbyte_extracted_at) as col,
    max(_airbyte_extracted_at)         as _etl_loaded_at
from {{ source('domain', 'table') }}
where id is not null
group by id

-- 2. Cast des types avec protection NULL
cast(coalesce(col, '')       as varchar)       as col_string
cast(coalesce(col, 0)        as decimal(18,2)) as col_amount
cast(col                     as timestamp)     as col_at
cast(coalesce(col, false)    as boolean)       as is_flag

-- 3. Renommage cohérent (id_ prefix pour les PKs)
id as id_entity

-- 4. Colonnes absentes de la source → valeurs par défaut typées
cast('' as varchar)                    as missing_col
cast(0  as decimal(18,2))              as missing_amount
cast(null as Nullable(DateTime64(3))) as missing_timestamp
```

> **Pourquoi `argMax` et non `DISTINCT ON` ?** ClickHouse n'a pas de `DISTINCT ON`. La combinaison `GROUP BY id` + `argMax(col, timestamp)` est l'équivalent idiomatique ClickHouse pour récupérer la valeur la plus récente de chaque colonne par enregistrement.

### ERP — ~67 modèles
Comptabilité (journaux, comptes, exercices fiscaux, banques, budgets, centres de coût) · RH (employés, contrats, congés, feuilles de temps, postes, départements) · Achats ERP (commandes, réceptions, retours, fournisseurs, factures) · Inventaire (stock, entrepôts, emplacements, numéros de série, inventaires, alertes) · Catalogue (produits, marques, composants, BOM, modèles PC, compatibilités, spécifications, historique prix) · Production (ordres de fabrication, réparations, qualité)

### Marketplace — ~56 modèles
Commerce (commandes, lignes, paiements, remboursements, retours, factures, avoirs, promotions, codes remise, ventes flash) · Clients (comptes, adresses, paniers, wishlists, fidélité, newsletters) · Catalogue (produits, prix, historique prix, bundles PC, Q&A produits) · Logistique (expéditions, tracking, transporteurs, zones/méthodes/tarifs de livraison, stock) · SAV marketplace (tickets, messages, avis, votes)

### CRM — 7 modèles
Comptes · Contacts · Commerciaux (`sales_reps`) · Opportunités · Activités commerciales · Événements pipeline · Tâches

### WMS — 9 modèles
Locations · Entrepôts · Réceptions + lignes · Expéditions + lignes · Picking + lignes · Mouvements de stock · Ajustements d'inventaire

### MES — 6 modèles
Ordres de production · Opérations de production · Centres de travail · Défauts · Consommations matières · Indicateurs de performance production (KPI)

### Marketing — 8 modèles
Campagnes · Performances publicitaires · Envois email · Événements email · Audiences · Leads · Liens UTM · (Alembic version exclu)

### SAV — 4 modèles
Tickets · Messages · Historique statuts

### PLM — 6 modèles
Produits · Versions · Nomenclatures (BOM) · Lignes BOM · Demandes de changement

### SIRH — 4 modèles
Employés · Contrats · Postes · Départements

### QMS — 8 modèles
Non-conformités · Actions correctives · Audits · Constats d'audit · Plans de contrôle · Points de contrôle · Certifications · Évaluations fournisseurs

### Finance — 11 modèles
Comptes · Centres de coût · Exercices fiscaux · Périodes comptables · Écritures · Lignes d'écriture · Budgets · Lignes budgétaires · Transactions bancaires · Comptes bancaires · Conditions de paiement

### Procurement — 11 modèles
Fournisseurs · Contacts fournisseurs · Bons de commande · Lignes BC · Réceptions · Lignes réception · RFQ · Lignes RFQ · Réponses RFQ · Contrats · Lignes contrat · Évaluations fournisseurs

---

## 7. Couche Intermediate

**Matérialisation :** `view`  
**Convention :** `int_<domaine>__<description>` (double underscore domaine/description)  
**Principe :** logique métier complexe, enrichissement via JOINs, agrégations préparatoires.

> **Choix `view` vs `ephemeral`** : les modèles intermédiaires ont été explicitement matérialisés en `view` (au lieu de `ephemeral`) pour deux raisons : (1) compatibilité avec ClickHouse 25.7 qui ne peut pas résoudre `alias.column` dans un GROUP BY quand `alias` référence une VIEW via une CTE inlinée ; (2) testabilité directe des intermédiaires via `dbt test`.

### Modèles intermédiaires par domaine

**ERP (9 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_erp__employee_overview` | Employé + poste + département + contrat actif |
| `int_erp__employee_contracts_stats` | Stats salaire (min/max/avg) par employé |
| `int_erp__employee_with_contract_stats` | Employés enrichis avec statistiques contrats |
| `int_erp__component_stock_status` | État courant stock composants par emplacement |
| `int_erp__component_stock_alerts` | Alertes de stock sous le seuil minimum |
| `int_erp__product_stock_summary` | Récapitulatif stock produit toutes variantes |
| `int_erp__purchase_orders_details` | Lignes commandes + fournisseurs + produits |
| `int_erp__purchase_order_status_stats` | Statistiques commandes par statut |
| `int_erp__supplier_stats` | Performance agrégée par fournisseur |

**Marketplace (3 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_mkt__orders_joined_to_lines` | Commandes jointes à leurs lignes de détail |
| `int_mkt__customers_aggregated_to_orders` | LTV, nb commandes, panier moyen par client |
| `int_mkt__products_aggregated_to_sales` | Ventes, revenus, avis par produit |

**CRM (3 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_crm__opportunities_with_pipeline` | Opportunités + âge pipeline + nb changements étape |
| `int_crm__accounts_activity_stats` | Agrégats activités/opps/revenus par compte |
| `int_crm__sales_rep_stats` | Performance agrégée par commercial (win rate, CA) |

**WMS (4 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_wms__receipts_with_lines` | Réceptions enrichies avec lignes de détail |
| `int_wms__shipments_with_lines` | Expéditions enrichies avec lignes de détail |
| `int_wms__picking_performance` | Performance de picking (délais, taux complétion) |
| `int_wms__stock_levels_by_product_location` | Niveaux de stock par produit × emplacement |

**MES (1 modèle)**

| Modèle | Description |
|--------|-------------|
| `int_mes__production_orders_with_stats` | Ordres de production + nb opérations + défauts + consommations |

**Marketing (2 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_marketing__campaigns_with_performance` | Campagnes + emails envoyés/ouverts/cliqués + impressions publicitaires |
| `int_marketing__email_funnel_by_campaign` | Entonnoir email (envoi → délivré → ouvert → cliqué) par campagne |

**SAV (1 modèle)**

| Modèle | Description |
|--------|-------------|
| `int_sav__tickets_with_resolution_stats` | Tickets + nb messages + nb changements statut + délai résolution |

**PLM (2 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_plm__products_with_latest_version` | Produits enrichis avec leur dernière version active |
| `int_plm__change_requests_by_product` | Demandes de changement agrégées par produit |

**SIRH (1 modèle)**

| Modèle | Description |
|--------|-------------|
| `int_sirh__employees_with_contract` | Employés + poste + département + informations contrat actif |

**QMS (3 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_qms__non_conformities_with_actions` | NC enrichies avec nb/statut actions correctives |
| `int_qms__audit_results_aggregated` | Audits enrichis avec décompte constats par type et criticité |
| `int_qms__supplier_quality_by_period` | Qualité fournisseur agrégée par fournisseur × année |

**Finance (3 modèles)**

| Modèle | Description |
|--------|-------------|
| `int_finance__journal_entries_with_lines` | Lignes d'écriture + en-tête + compte + centre de coût |
| `int_finance__budget_vs_actuals` | Budget vs réalisé par compte × centre de coût × mois |
| `int_finance__bank_transactions_aggregated` | Transactions bancaires agrégées par compte × mois |

**Procurement (1 modèle)**

| Modèle | Description |
|--------|-------------|
| `int_procurement__purchase_orders_with_lines` | Bons de commande enrichis avec leurs lignes de détail |

---

## 8. Couche Marts — Core

**Matérialisation :** `table` (MergeTree) ou `incremental`  
**Convention :** `dim_<domaine>_<entité>` / `fct_<domaine>_<entité>`  
**Principe :** modélisation dimensionnelle classique (Kimball). Les dims contiennent les attributs descriptifs, les faits contiennent les mesures.

### Moteur ClickHouse — configuration type

```sql
{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(id_entity)',
    settings={'allow_nullable_key': 1},   -- requis si ORDER BY colonne nullable
    tags=['marts', 'domain', 'dim']
) }}
```

> `allow_nullable_key = 1` : les colonnes de clé de tri peuvent être Nullable. Nécessaire quand des colonnes issues de LEFT JOINs (potentiellement NULL) entrent dans le `ORDER BY`.

### Stratégie incrémentale

Les grandes tables de faits utilisent une stratégie `incremental` avec fenêtre glissante et suppression des doublons via hook :

```sql
{{ config(
    materialized='incremental',
    engine='MergeTree()',
    order_by='(id_fact, event_at)',
    pre_hook="{{ clickhouse_delete_existing_rows(
        ref('stg_domain__table'), 'id_fact', 'id_fact', 'event_at', 7
    ) }}"
) }}
```

### Marts par domaine

**WMS**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_wms_locations` | table | Emplacements (allée, rack, zone, entrepôt) |
| `fct_wms_receipts` | table | Faits réceptions avec lignes |
| `fct_wms_shipments` | table | Faits expéditions avec lignes |
| `fct_wms_picking_orders` | table | Faits ordres de picking avec métriques |
| `fct_wms_stock_levels` | table | Niveaux de stock par produit × emplacement |
| `fct_wms_stock_movements` | table | Mouvements de stock (entrées, sorties, transferts) |

**MES**

| Modèle | Type | Description |
|--------|------|-------------|
| `fct_mes_production_orders` | table | Faits ordres de production avec stats opérations/défauts |

**Marketing**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_marketing_campaigns` | table | Dimension campagnes marketing enrichie |
| `fct_marketing_email_funnel` | table | Entonnoir email par campagne |
| `fct_marketing_ad_performance` | table | Performances publicitaires (impressions, CPC, ROI) |
| `fct_marketing_leads` | table | Faits leads avec source et conversion |

**SAV**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_sav_tickets` | table | Dimension tickets support enrichie |
| `fct_sav_ticket_resolution` | table | Faits résolution (délais, statuts, nb messages) |

**PLM**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_plm_products` | table | Dimension produits PLM avec dernière version + CR |
| `fct_plm_bom` | table | Nomenclatures produits avec lignes |

**SIRH**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_sirh_employees` | table | Dimension employés enrichie (poste, département, contrat) |

**QMS**

| Modèle | Type | Description |
|--------|------|-------------|
| `fct_qms_non_conformities` | table | Faits non-conformités avec actions correctives |
| `fct_qms_audits` | table | Faits audits avec résultats agrégés |
| `fct_qms_corrective_actions` | table | Faits actions correctives CAPA |
| `fct_qms_certifications` | table | Faits certifications (ISO, etc.) |
| `fct_qms_supplier_quality` | table | Qualité fournisseur agrégée par période |

**Finance**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_finance_accounts` | table | Plan comptable |
| `dim_finance_cost_centers` | table | Centres de coût |
| `dim_finance_fiscal_years` | table | Exercices fiscaux |
| `fct_finance_journal_lines` | table | Lignes d'écriture comptable (statut posted) |
| `fct_finance_budget_lines` | table | Lignes budgétaires |
| `fct_finance_bank_transactions` | table | Transactions bancaires |

**Procurement**

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_procurement_suppliers` | table | Dimension fournisseurs enrichie (nb PO, score évaluation) |
| `fct_procurement_purchase_orders` | table | Faits bons de commande avec lignes |
| `fct_procurement_receipts` | table | Faits réceptions avec coût total |
| `fct_procurement_rfq_responses` | table | Réponses AO avec classement prix |
| `fct_procurement_supplier_evaluations` | table | Évaluations fournisseurs |

---

## 9. Couche Marts — Reports

**Matérialisation :** `table` (MergeTree)  
**Convention :** `rpt_<domaine>__<sujet>`  
**Principe :** large et dénormalisé, consommé directement par les outils BI sans transformation supplémentaire.

| Domaine | Modèle | Description |
|---------|--------|-------------|
| WMS | `rpt_wms__stock_status` | Stock actuel par produit × emplacement (zone, allée, rack) |
| WMS | `rpt_wms__receiving_performance` | Performance réceptions hebdo par fournisseur (taux conformité) |
| WMS | `rpt_wms__outbound_performance` | Performance expéditions avec métriques de picking |
| MES | `rpt_mes__production_kpis` | KPIs production (OEE, taux rebut, délais) |
| Marketing | `rpt_marketing__campaign_performance` | Performance campagne (emails, ads, ROI) |
| Marketing | `rpt_marketing__lead_funnel` | Entonnoir de conversion leads |
| Marketing | `rpt_marketing__channel_roi` | ROI par canal marketing |
| SAV | `rpt_sav__ticket_performance` | Performance SAV (MTTR, backlog, satisfaction) |
| PLM | `rpt_plm__product_lifecycle` | Cycle de vie produits (versions, CR en cours) |
| SIRH | `rpt_sirh__workforce_overview` | Vue effectifs RH (postes, contrats, ancienneté) |
| QMS | `rpt_qms__nc_overview` | Vue d'ensemble non-conformités (type, sévérité, délai) |
| QMS | `rpt_qms__audit_results` | Résultats audits avec taux conformité |
| QMS | `rpt_qms__supplier_quality` | Qualité fournisseur par période d'évaluation |
| Finance | `rpt_finance__journal_enriched` | Écritures comptables enrichies (compte, centre de coût) |
| Finance | `rpt_finance__budget_vs_actuals` | Budget vs réalisé avec écart et % variance |
| Finance | `rpt_finance__bank_summary` | Récapitulatif bancaire par compte et période |
| Procurement | `rpt_procurement__po_status` | Statut bons de commande avec info fournisseur |
| Procurement | `rpt_procurement__supplier_performance` | Performance fournisseurs (scores, délais) |
| Procurement | `rpt_procurement__rfq_analysis` | Analyse appels d'offres avec classement prix |
| ERP | `rpt_erp__journal_entries_enriched` | Écritures comptables ERP enrichies |
| ERP | `rpt_erp__hr_workforce` | Effectifs : employés + contrats + congés + temps |
| ERP | `rpt_erp__inventory_stock_status` | État stock par entrepôt/emplacement |
| ERP | `rpt_erp__procurement_orders` | Commandes achat ERP enrichies |
| MKT | `rpt_mkt__revenue_daily` | CA journalier marketplace |
| MKT | `rpt_mkt__customer_ltv` | Lifetime value par client |
| MKT | `rpt_mkt__product_performance` | Performance produit (ventes, avis) |
| MKT | `rpt_mkt__logistics_performance` | Performance livraison (délais, transporteurs) |
| CRM | `rpt_crm__pipeline_overview` | Pipeline commercial complet (opps + compte + commercial) |
| CRM | `rpt_crm__sales_rep_performance` | Performance commerciaux (win rate, CA, tendance 30j) |

---

## 10. BI Datamarts cross-domaines

Les datamarts BI combinent des données de **plusieurs domaines sources** pour des analyses transversales. Ils constituent la couche de consommation finale pour les dashboards et outils de BI.

### `BI_PRODUCTION` (`DB_BI_PRODUCTION`)

Croise **MES + WMS + PLM + ERP** pour la vision production :

| Modèle | Description |
|--------|-------------|
| `bi_prod__bom_vs_stock` | BOM vs disponibilité stock (couverture production) |
| `bi_prod__work_order_performance` | Performance des ordres de fabrication (délais, taux complétion) |
| `bi_prod__operator_performance` | Performance opérateurs (cadences, défauts par opérateur) |
| `bi_prod__quality_overview` | Vue qualité production (taux rebut, défauts par centre de travail) |
| `bi_prod__production_forecast` | Prévisions de production basées sur les tendances MES |
| `bi_prod__serial_tracking` | Traçabilité numéros de série (WMS + ERP) |

### `BI_LOGISTIQUE` (`DB_BI_LOGISTIQUE`)

Croise **WMS + MKT + ERP + BI_PRODUCTION** pour la vision logistique :

| Modèle | Description |
|--------|-------------|
| `bi_log__stock_overview` | Stock cross-domaines (ERP + MKT + WMS) |
| `bi_log__shortage_coverage` | Couverture des ruptures de stock (réf. `bi_prod__bom_vs_stock`) |
| `bi_log__stock_rotation` | Rotation des stocks par produit et emplacement |
| `bi_log__carrier_kpis` | KPIs transporteurs (délais, taux de livraison à temps) |
| `bi_log__reception_performance` | Performance des réceptions (conformité, délais fournisseurs) |
| `bi_log__supply_chain` | Vue chaîne d'approvisionnement end-to-end |

### `BI_MARKETING` (`DB_BI_MARKETING`)

Croise **Marketing + MKT + CRM** pour la vision marketing client :

| Modèle | Description |
|--------|-------------|
| `bi_mkt__customer_360` | Vue 360° client (MKT + CRM + fidélité) |
| `bi_mkt__revenue_pipeline` | CA confirmé MKT + pipeline CRM par jour |
| `bi_mkt__campaign_performance` | Performances cross-canal (newsletter, codes promo, flash sales) |
| `bi_mkt__wishlist_insights` | Analyse wishlist (désirés vs achetés, taux conversion) |
| `bi_mkt__churn_risk` | Scoring churn par client (never_ordered / active / at_risk / churning / churned) |
| `bi_mkt__cohort_retention` | Rétention par cohorte mensuelle (M+1, M+3, M+6, M+12) |
| `bi_mkt__product_affinity` | Matrice d'affinité produits (Jaccard, cross-sell) |

### `BI_FINANCE` (`DB_BI_FINANCE`)

Croise **Finance + ERP + Procurement** pour la vision financière :

| Modèle | Description |
|--------|-------------|
| `bi_fin__cash_flow` | Flux de trésorerie (entrées/sorties bancaires) |
| `bi_fin__budget_vs_actual` | Budget vs réalisé avec écart et % variance |
| `bi_fin__vendor_invoice_aging` | Vieillissement des factures fournisseurs par échéance |

### `BI_RH` (`DB_BI_RH`)

Croise **SIRH + ERP + Finance** pour la vision ressources humaines :

| Modèle | Description |
|--------|-------------|
| `bi_rh__workforce_overview` | Effectifs cross-domaines (SIRH + ERP) |
| `bi_rh__leave_management` | Gestion des congés (soldes, absences, tendances) |
| `bi_rh__timesheet_summary` | Récapitulatif feuilles de temps par employé et période |

### `BI_SAV` (`DB_BI_SAV`)

Croise **SAV + MKT + QMS** pour la vision qualité & satisfaction client :

| Modèle | Description |
|--------|-------------|
| `bi_sav__repair_performance` | Performance des réparations (délais, taux résolution) |
| `bi_sav__warranty_overview` | Vue garanties (taux retour, coûts, produits concernés) |

### `BI_COMMERCIAL` (`DB_BI_COMMERCIAL`)

Croise **CRM + MKT + ERP** pour la vision commerciale :

| Modèle | Description |
|--------|-------------|
| `bi_com__pipeline_dashboard` | Vue pipeline commercial (opportunités par étape et commercial) |
| `bi_com__sales_performance` | Performance des ventes (CA, win rate, panier moyen) |
| `bi_com__forecast_monthly` | Prévisions de ventes mensuelles (pipeline pondéré) |

### `BI_ACHATS` (`DB_BI_ACHATS`)

Croise **Procurement + ERP + Finance** pour la vision achats :

| Modèle | Description |
|--------|-------------|
| `bi_ach__purchase_order_tracking` | Suivi des bons de commande (statuts, délais, conformité) |
| `bi_ach__supplier_performance` | Performance fournisseurs (score, délais, taux de service) |

### `BI_QUALITE` (`DB_BI_QUALITE`)

Croise **QMS + MES + Procurement** pour la vision qualité globale :

| Modèle | Description |
|--------|-------------|
| `bi_qlt__non_conformity_dashboard` | Tableau de bord non-conformités (type, sévérité, délai résolution) |
| `bi_qlt__audit_results` | Résultats d'audits (taux conformité, constats, actions) |

### `BI_PRODUIT` (`DB_BI_PRODUIT`)

Croise **PLM + MES + WMS** pour la vision cycle de vie produit :

| Modèle | Description |
|--------|-------------|
| `bi_prd__product_lifecycle` | Cycle de vie produits (versions, statut, BOM stats) |
| `bi_prd__change_request_tracking` | Suivi des demandes de changement produit (CR en cours, délais) |

---

## 11. Orchestration Airflow

### DAG principal — `warehouse_pipeline.py`

| Paramètre | Valeur |
|-----------|--------|
| Schedule | `0 3 * * *` (chaque nuit à 3h UTC) |
| Start date | 2026-06-01 |
| Max active runs | 1 |
| Catchup | False |
| Notifications | `on_failure_callback` sur toutes les tâches |

### Architecture en 3 phases

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PHASE 1+2 — 12 domaines en parallèle (pool airbyte_pool = 3 slots max)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [airbyte_trigger_erp]  ──► [airbyte_wait_erp]  ──► [dbt_run_erp]  ──► [dbt_test_erp]
  [airbyte_trigger_crm]  ──► [airbyte_wait_crm]  ──► [dbt_run_crm]  ──► [dbt_test_crm]
  [airbyte_trigger_mkt]  ──► [airbyte_wait_mkt]  ──► [dbt_run_mkt]  ──► [dbt_test_mkt]
                                                   ──► [dbt_run_wms]  ──► [dbt_test_wms]
                                                   ──► [dbt_run_mes]  ──► [dbt_test_mes]
                              (optionnel si UUID    ──► [dbt_run_marketing] ──► ...
                               Airbyte configuré)   ──► [dbt_run_sav]  ──► ...
                                                   ──► [dbt_run_plm]  ──► ...
                                                   ──► [dbt_run_sirh] ──► ...
                                                   ──► [dbt_run_qms]  ──► ...
                                                   ──► [dbt_run_finance] ──► ...
                                                   ──► [dbt_run_procurement] ──► ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PHASE 3 — BI datamarts (déclenchés après les 12 dbt_test_*)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [dbt_run_bi_production] ──► [dbt_test_bi_production] ──► [dbt_run_bi_logistique]
  [dbt_run_bi_marketing]  ──► [dbt_test_bi_marketing]
  [dbt_run_bi_finance]    ──► [dbt_test_bi_finance]
  [dbt_run_bi_rh]         ──► [dbt_test_bi_rh]
  [dbt_run_bi_sav]        ──► [dbt_test_bi_sav]
  [dbt_run_bi_commercial] ──► [dbt_test_bi_commercial]
  [dbt_run_bi_achats]     ──► [dbt_test_bi_achats]
  [dbt_run_bi_qualite]    ──► [dbt_test_bi_qualite]
  [dbt_run_bi_produit]    ──► [dbt_test_bi_produit]

  Note : bi_logistique dépend de bi_production (bi_log__shortage_coverage
         référence bi_prod__bom_vs_stock) → démarre après dbt_test_bi_production.
```

### Sensor Airbyte — résilience et gestion des statuts

Le `AirbyteSyncSensor` custom gère les aléas réseau/Docker avec un mode `reschedule` (libère le worker slot entre chaque poll) :

| Statut API Airbyte | Comportement |
|-------------------|--------------|
| `running` / `pending` | Reschedule dans 30s (pas de blocage worker) |
| `succeeded` | ✅ Tâche terminée — dbt_run démarre |
| `incomplete` | ⚠️ Warning loggé — pipeline continue (sync partielle ou job reset Airbyte OSS) |
| `failed` / `cancelled` | ❌ Exception — tâche Airflow en erreur, notification |
| `ConnectionError` / Timeout | Reschedule 30s (erreur transitoire réseau/Docker) |
| `HTTP 5xx` | Reschedule 30s (crash/restart transitoire Airbyte) |
| `HTTP 4xx` | Exception immédiate (erreur de configuration) |

> **Pourquoi `incomplete` n'est pas fatal ?** Airbyte OSS peut retourner `incomplete` pour un job reset internalement (nouveau job_id créé en parallèle) pendant qu'une vraie sync tourne. Traiter `incomplete` comme une erreur bloque le pipeline indéfiniment sur un job_id qui ne changera plus.

### Auth Airbyte OAuth2

Token renouvelé à chaque poke du sensor via `client_credentials` :

```python
POST /api/v1/applications/token
{
  "client_id":     AIRBYTE_CLIENT_ID,
  "client_secret": AIRBYTE_CLIENT_SECRET,
  "grant_type":    "client_credentials"
}
```

Si un job est déjà en cours sur la connexion (HTTP 409), le trigger récupère l'ID du job existant via `/api/public/v1/jobs?connectionId=...` et le transmet au sensor via XCom.

### Pool Airflow — concurrence Airbyte

```bash
# Créer le pool (une fois après le démarrage)
airflow pools set airbyte_pool 3 "Limite syncs Airbyte simultanées"
```

Déclaré dans `airflow_settings.yaml` — recréé automatiquement au démarrage.

### Commande dbt dans les BashOperators

```bash
cd /usr/local/airflow/dbt/warehouse \
&& /usr/local/airflow/dbt_venv/bin/dbt run \
   --profiles-dir . \
   --target <domain> \
   --select "path:models/staging/<domain> path:models/intermediate/<domain> path:models/marts/<domain>"
```

Le dbt s'exécute dans un **virtualenv Python isolé** (`dbt_venv`) avec `dbt-core==1.8.9` + `dbt-clickhouse` — version différente du dbt local (1.11.2) pour compatibilité avec l'image Astronomer.

---

## 12. Spécificités ClickHouse 25.7

ClickHouse 25.7 active par défaut le nouvel analyseur de requêtes (`enable_analyzer=1`), plus strict que les versions précédentes. Plusieurs patterns SQL courants ne fonctionnent plus.

### Pattern 1 — `alias.column` dans GROUP BY depuis une VIEW

**Erreur :**
```
DB::Exception: Identifier 'je.period_id' cannot be resolved from table with name je.
```

**Cause :** ClickHouse 25.7 ne peut pas résoudre `alias.column` dans un GROUP BY quand `alias` référence une VIEW (ou une CTE wrappant une VIEW).

**Solution :** aliaser explicitement dans le SELECT, utiliser le nom non qualifié dans GROUP BY :

```sql
-- ❌ Problématique
select je.period_id
from stg_journal_entries as je
group by je.period_id

-- ✅ Correct
select je.period_id as period_id     -- alias explicite dans SELECT
from stg_journal_entries as je
group by period_id                   -- non qualifié dans GROUP BY
```

### Pattern 2 — CTEs imbriquées avec VIEWs

**Erreur :**
```
DB::Exception: Unknown expression identifier `col` in scope WITH __dbt__cte__... AS (WITH ...)
```

**Cause :** dbt inline les modèles `ephemeral` comme CTEs. Si l'ephemeral contient lui-même des CTEs référençant des VIEWs, ClickHouse 25.7 ne peut pas résoudre les identifiants dans les CTEs imbriquées.

**Solution :** convertir les `ephemeral` problématiques en `view`, utiliser des `ref()` directs :

```sql
-- ❌ Ephemeral avec CTEs (génère des WITH imbriqués)
{{ config(materialized='ephemeral') }}
with source as (select * from {{ ref('stg_table') }})
select ...

-- ✅ View avec refs directs
{{ config(materialized='view') }}
select ...
from {{ ref('stg_table') }} as t
left join {{ ref('stg_other') }} as o on o.id = t.foreign_id
```

### Pattern 3 — `allow_nullable_key` sur MergeTree

**Erreur :**
```
DB::Exception: Sorting key contains nullable columns, but merge tree setting
allow_nullable_key is disabled.
```

**Solution :** ajouter `settings={'allow_nullable_key': 1}` au config dbt :

```sql
{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(supplier_id, evaluation_period_year)',
    settings={'allow_nullable_key': 1}
) }}
```

### Pattern 4 — `NULL` dans `toStartOfWeek`

**Comportement :** `toStartOfWeek(NULL)` retourne `NULL` — les tests `not_null` échouent si la colonne source peut être NULL.

**Solution :** filtrer en amont :

```sql
from {{ ref('fct_receipts') }}
where received_at is not null   -- évite les week NULL
```

### Pattern 5 — Colonnes manquantes dans staging

Les sources Airbyte ne contiennent pas toujours toutes les colonnes attendues. Le pattern défensif dans les stagings :

```sql
-- Colonne absente de la source → valeur par défaut typée
cast(0   as decimal(18,2))             as missing_amount
cast(''  as varchar)                   as missing_text
cast(null as Nullable(DateTime64(3))) as missing_timestamp
where 1 = 0  -- table vide mais schema correct
```

---

## 13. Commandes dbt

```powershell
# Depuis le répertoire dbt
Set-Location 'C:\data_erp\project_warehouse_entreprise\dbt\warehouse'

# ── Run par domaine ──────────────────────────────────────────────────

dbt run --profiles-dir . --target erp
dbt run --profiles-dir . --target crm
dbt run --profiles-dir . --target mkt
dbt run --profiles-dir . --target wms
dbt run --profiles-dir . --target mes
dbt run --profiles-dir . --target marketing
dbt run --profiles-dir . --target sav
dbt run --profiles-dir . --target plm
dbt run --profiles-dir . --target sirh
dbt run --profiles-dir . --target qms
dbt run --profiles-dir . --target finance
dbt run --profiles-dir . --target procurement

# ── Run sélectif (staging + intermediate + marts d'un domaine) ───────

dbt run --profiles-dir . --target finance \
  --select "path:models/staging/finance path:models/intermediate/finance path:models/marts/finance"

# ── Tests par domaine ────────────────────────────────────────────────

dbt test --profiles-dir . --target finance \
  --select "path:models/staging/finance path:models/intermediate/finance path:models/marts/finance"

# ── BI datamarts ─────────────────────────────────────────────────────

dbt run --profiles-dir . --target bi_production
dbt run --profiles-dir . --target bi_logistique
dbt run --profiles-dir . --target bi_marketing
dbt run --profiles-dir . --target bi_finance
dbt run --profiles-dir . --target bi_rh
dbt run --profiles-dir . --target bi_sav

# ── Utilitaires ──────────────────────────────────────────────────────

# Compiler sans exécuter (inspecter le SQL généré)
dbt compile --profiles-dir . --target finance --select int_finance__budget_vs_actuals

# Vérifier les connexions
dbt debug --profiles-dir . --target finance

# Full-refresh (rebuild incrémentaux depuis zéro)
dbt run --profiles-dir . --target erp --full-refresh --select fct_leaves

# Run des modèles modifiés + leurs dépendants
dbt run --profiles-dir . --target erp --select "state:modified+"

# Générer et servir la documentation
dbt docs generate --profiles-dir . --target erp
dbt docs serve --profiles-dir . --target erp
```

---

## 14. Installation et démarrage

### Prérequis

- **Docker Desktop** (Windows/Mac) ou Docker Engine (Linux)
- **Python 3.11+** pour dbt en local
- **ClickHouse** accessible sur `host.docker.internal:8123`

### 1. Cloner et configurer l'environnement

```powershell
git clone <repo-url>
Set-Location project_warehouse_entreprise

# Copier le template d'environnement
Copy-Item .env.example .env
# Éditer .env avec vos credentials
```

### 2. Variables d'environnement requises

```bash
# ClickHouse
CLICKHOUSE_HOST=host.docker.internal
CLICKHOUSE_PORT=8123
CLICKHOUSE_USER=admin
CLICKHOUSE_PASSWORD=<password>

# Airbyte OAuth2
AIRBYTE_API_URL=http://host.docker.internal:8000
AIRBYTE_CLIENT_ID=<uuid>
AIRBYTE_CLIENT_SECRET=<secret>

# UUIDs connexions Airbyte (3 obligatoires, 9 optionnels)
AIRBYTE_CONN_ERP=<uuid>
AIRBYTE_CONN_CRM=<uuid>
AIRBYTE_CONN_MKT=<uuid>
# Optionnels (pipeline tourne même sans eux — sources vides)
AIRBYTE_CONN_WMS=<uuid>
AIRBYTE_CONN_MES=<uuid>
AIRBYTE_CONN_MARKETING=<uuid>
AIRBYTE_CONN_SAV=<uuid>
AIRBYTE_CONN_PLM=<uuid>
AIRBYTE_CONN_SIRH=<uuid>
AIRBYTE_CONN_QMS=<uuid>
AIRBYTE_CONN_FINANCE=<uuid>
AIRBYTE_CONN_PROCUREMENT=<uuid>
```

### 3. Démarrer Airbyte (self-hosted)

```powershell
git clone https://github.com/airbytehq/airbyte.git
Set-Location airbyte
.\run-ab-platform.ps1   # Windows
# ./run-ab-platform.sh  # Linux/Mac
```

UI Airbyte : http://localhost:8000 — Configurer les 12 connexions PostgreSQL → ClickHouse.

**Sync modes recommandés :**
- `Full Refresh | Overwrite` : tables de référence (produits, fournisseurs, employés)
- `Incremental | Append` : tables transactionnelles (commandes, écritures, mouvements)

### 4. Démarrer Airflow

```powershell
docker compose up -d
```

Le `docker-compose.override.yml` monte `./dbt` dans le conteneur sous `/usr/local/airflow/dbt`.

**UI Airflow :** http://localhost:8080

```powershell
# Créer le pool Airbyte (une fois)
docker exec <scheduler-container> airflow pools set airbyte_pool 3 "Airbyte concurrency"
```

### 5. Installer dbt en local

```powershell
pip install dbt-core==1.11.2 dbt-clickhouse==1.9.8
Set-Location dbt/warehouse
dbt deps
dbt debug --profiles-dir . --target erp
```

---

## 15. Macros personnalisées

### `clickhouse_delete_existing_rows`

Génère un `ALTER TABLE ... DELETE WHERE id IN (SELECT id FROM source WHERE date >= now() - INTERVAL N DAY)`. Utilisé en `pre_hook` sur les tables incrémentales pour éviter les doublons sur la fenêtre de rejeu.

```sql
{{
    config(
        materialized='incremental',
        engine='MergeTree()',
        pre_hook="{{ clickhouse_delete_existing_rows(
            ref('stg_erp__leaves'), 'id_leave', 'id_leave', 'starts_at', 7
        ) }}"
    )
}}
```

La macro retourne une chaîne vide si la table cible n'existe pas encore (premier run).

### `drop_table`

Utilitaire pour supprimer une table ClickHouse — utilisé dans des hooks de maintenance ou scripts de reset.

---

## 16. Bonnes pratiques appliquées

| Pratique | Détail |
|----------|--------|
| **Ingestion découplée** | Airbyte gère l'ingestion raw — dbt ne lit jamais les sources directement via SQL |
| **`source()` dans staging uniquement** | Les marts et intermediates utilisent uniquement `ref()` |
| **Nommage strict** | `stg_` / `int_` / `dim_` / `fct_` / `rpt_` / `bi_` — préfixes fonctionnels |
| **Double underscore** | Séparateur source/entité : `stg_finance__journal_entries` |
| **Tests systématiques** | `unique` + `not_null` sur toutes les PKs, `not_null` sur les FKs critiques |
| **`accepted_values` compatibles 1.8.9** | Syntaxe `values: [...]` directe (pas d'`arguments:` wrapper — incompatible dbt < 1.9) |
| **`allow_nullable_key`** | Déclaré sur tous les MergeTree dont l'`ORDER BY` peut contenir des NULL |
| **Déduplication Airbyte** | `argMax(col, _airbyte_extracted_at)` + `GROUP BY id` dans chaque staging |
| **Colonnes manquantes** | Stub typés (`cast(0 as decimal)`, `where 1=0`) pour les sources incomplètes |
| **query-comment** | Traçabilité des requêtes dbt dans `system.query_log` ClickHouse |
| **on_schema_change** | `append_new_columns` sur les incrementals |
| **Sensor non-bloquant** | Mode `reschedule` Airflow — libère le worker slot entre chaque poll Airbyte |
| **venv isolé** | dbt 1.8.9 dans Airflow, dbt 1.11.2 en local — pas de conflit de version |

### Convention de nommage des colonnes

| Type | Convention | Exemples |
|------|-----------|---------|
| Clé primaire | `id_<entité>` | `id_employee`, `id_purchase_order` |
| Clé étrangère | `<entité>_id` | `supplier_id`, `campaign_id` |
| Booléen | `is_<état>` | `is_active`, `is_over_budget` |
| Timestamp | `<événement>_at` | `created_at`, `resolved_at` |
| Date | `<événement>_date` | `entry_date`, `hire_date` |
| Compteur | `nb_<entité>` | `nb_orders`, `nb_messages` |
| Taux/ratio | `<nom>_rate` / `<nom>_pct` | `open_rate`, `variance_pct` |
| Montant | snake_case complet | `total_amount`, `budget_amount` |

---

## 17. Troubleshooting

### ClickHouse — `UNKNOWN_IDENTIFIER` (alias.column dans GROUP BY)

```
DB::Exception: Identifier 'alias.col' cannot be resolved from table with name alias.
```

Ajouter un `AS col_name` dans le SELECT et utiliser `col_name` non qualifié dans GROUP BY. Voir [Section 12](#12-spécificités-clickhouse-257).

### ClickHouse — `CANNOT_INSERT_NULL_IN_ORDINARY_COLUMN`

```
Cannot convert NULL value to non-Nullable type
```

Dans le staging, entourer le CAST d'un COALESCE :
```sql
cast(coalesce(col, '') as varchar) as col
```

### ClickHouse — `UNKNOWN_TABLE` sur un intermédiaire

```
DB::Exception: Unknown table expression identifier 'DB_WH_X.int_domain__model'
```

Le modèle intermédiaire n'est pas encore matérialisé (s'il était précédemment `ephemeral`). Lancer `dbt run --select int_domain__model` avant le test.

### Airflow — Sensor bloqué sur `incomplete`

Si `airbyte_wait_<domain>` reste bloqué : Airbyte a renvoyé `incomplete` pour un job reset. Depuis la version actuelle du DAG, `incomplete` est traité comme un avertissement non-fatal — le pipeline continue. Si le sensor reste bloqué sur une ancienne version du DAG, forcer l'état `FAILED` via l'UI Airflow pour débloquer.

### dbt — `arguments` key dans `accepted_values`

```
macro 'dbt_macro__test_accepted_values' takes no keyword argument 'arguments'
```

La syntaxe `arguments:` dans `accepted_values` n'est supportée qu'à partir de dbt 1.9+. Airflow utilise dbt 1.8.9. Utiliser la syntaxe directe :

```yaml
# ❌ dbt 1.11+ uniquement
- accepted_values:
    arguments:
      values: ['a', 'b']

# ✅ Compatible 1.8.9+
- accepted_values:
    values: ['a', 'b']
```

### Airbyte — Tables non visibles dans ClickHouse

```sql
-- Lister toutes les tables d'un schéma
SHOW TABLES FROM DB_WH_FINANCE;

-- Dernières requêtes dbt
SELECT query, log_comment, query_duration_ms
FROM system.query_log
WHERE log_comment LIKE '%dbt%'
  AND type = 'QueryFinish'
ORDER BY event_time DESC LIMIT 20;

-- Erreurs récentes ClickHouse
SELECT query, exception, event_time
FROM system.query_log
WHERE type = 'ExceptionWhileProcessing'
  AND event_time > now() - INTERVAL 1 HOUR
ORDER BY event_time DESC;
```

---

## Licence

Voir [LICENSE](LICENSE).
