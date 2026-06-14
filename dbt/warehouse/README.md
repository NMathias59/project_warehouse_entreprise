# Projet dbt `warehouse`

Projet dbt principal de la plateforme — transforme les données brutes ingérées par Airbyte dans ClickHouse en modèles analytiques prêts pour la BI.

**438 modèles** couvrant 12 domaines métier sur 4 couches.

---

## Sources

| Domaine | Schéma ClickHouse | Target dbt | Description |
|---------|-------------------|------------|-------------|
| ERP | `DB_WH_ERP` | `erp` | Produits, commandes, fournisseurs, stocks |
| Marketplace | `DB_WH_MKT` | `mkt` | Catalogue, paniers, livraisons, avis |
| CRM | `DB_WH_CRM` | `crm` | Contacts, opportunités, pipeline commercial |
| WMS | `DB_WH_WMS` | `wms` | Gestion d'entrepôt, mouvements de stock |
| MES | `DB_WH_MES` | `mes` | Exécution de production, ordres de fabrication |
| Marketing | `DB_WH_MARKETING` | `marketing` | Campagnes, leads, segments |
| SAV | `DB_WH_SAV` | `sav` | Tickets support, garanties, escalades |
| PLM | `DB_WH_PLM` | `plm` | Cycle de vie produit, nomenclatures, révisions |
| SIRH | `DB_WH_SIRH` | `sirh` | RH, collaborateurs, contrats, absences |
| QMS | `DB_WH_QMS` | `qms` | Qualité, non-conformités, audits |
| Finance | `DB_WH_FINANCE` | `finance` | Comptabilité, budgets, journaux |
| Procurement | `DB_WH_PROCUREMENT` | `procurement` | Achats, appels d'offres, réceptions |

---

## Architecture

```
Airbyte (PostgreSQL → ClickHouse)
        │
        ▼
┌──────────────────────────────────────────────────────┐
│  STAGING  (view)                                     │
│  stg_<domain>__<table>.sql                           │
│  · argMax CDC deduplication (_airbyte_extracted_at)  │
│  · Cast stricts + coalesce sur colonnes non-nullable │
│  · source() autorisé uniquement ici                  │
└──────────────────────┬───────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────┐
│  INTERMEDIATE  (ephemeral / CTE inline)              │
│  int_<domain>__<entités>_<verbe>.sql                 │
│  · Agrégations, jointures, enrichissements           │
│  · Jamais de source(), uniquement ref()              │
└──────────────────────┬───────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────┐
│  MARTS / CORE  (table MergeTree)                     │
│  dim_<entité>.sql  ·  fct_<processus>.sql            │
│  · Dimensions et faits business-conformed            │
│  · Consommés par les reports et la couche BI         │
└──────────────────────┬───────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
┌─────────────────────┐   ┌──────────────────────────┐
│  MARTS / REPORTS    │   │  MARTS / BI  (table)     │
│  rpt_<sujet>.sql    │   │  bi_<dom>__<kpi>.sql     │
│  · ref() dim_* et   │   │  · Cross-domaines        │
│    fct_* uniquement │   │  · Dashboards BI tools   │
└─────────────────────┘   └──────────────────────────┘
```

---

## Modèles par couche

| Couche | Nombre | Matérialisation |
|--------|--------|-----------------|
| Staging | 210 | `view` |
| Intermediate | 44 | `ephemeral` |
| Marts / Core | 113 | `table` (MergeTree) |
| Marts / Reports | 44 | `table` (MergeTree) |
| Marts / BI | 27 | `table` (MergeTree) |
| **Total** | **438** | |

---

## Structure des fichiers

```
models/
├── staging/
│   ├── erp/            # 66 modèles
│   ├── market_place/   # 56 modèles
│   ├── crm/            #  7 modèles
│   ├── wms/            #  9 modèles
│   ├── mes/            #  8 modèles
│   ├── marketing/      #  7 modèles
│   ├── sav/            #  8 modèles
│   ├── plm/            #  7 modèles
│   ├── sirh/           # 11 modèles
│   ├── qms/            #  8 modèles
│   ├── finance/        # 11 modèles
│   └── procurement/    # 12 modèles
│
├── intermediate/
│   └── <domain>/       # CTE inline, jamais matérialisées
│
└── marts/
    ├── erp/core/          dim_* + fct_*
    ├── erp/reports/       rpt_* (ref dim_*/fct_* uniquement)
    ├── market_place/core/ + reports/
    ├── crm/core/          + reports/
    ├── wms/core/          + reports/
    ├── mes/core/          + reports/
    ├── marketing/core/    + reports/
    ├── sav/core/          + reports/
    ├── plm/core/          + reports/
    ├── sirh/core/         + reports/
    ├── qms/core/          + reports/
    ├── finance/core/      + reports/
    ├── procurement/core/  + reports/
    ├── BI_LOGISTIQUE/     bi_log__*
    ├── BI_MARKETING/      bi_mkt__*
    ├── BI_PRODUCTION/     bi_prod__*
    ├── BI_FINANCE/        bi_fin__*
    ├── BI_RH/             bi_rh__*
    └── BI_SAV/            bi_sav__*
```

---

## Targets disponibles

Définis dans `profiles.yml` (profile `warehouse`) :

```
erp · mkt · crm · wms · mes · marketing · sav · plm · sirh · qms · finance · procurement
```

Utilisation :

```bash
# Run tous les modèles d'un domaine
dbt run --target erp
dbt run --target wms

# Sélection fine par tag
dbt run --select tag:staging,tag:erp
dbt run --select tag:marts,tag:finance
dbt run --select path:models/marts/erp/core/
```

---

## Conventions de nommage

| Préfixe | Couche | Exemple |
|---------|--------|---------|
| `stg_<domaine>__` | Staging | `stg_erp__products` |
| `int_<domaine>__` | Intermediate | `int_erp__orders_enriched` |
| `dim_` | Marts core — dimension | `dim_products` |
| `fct_` | Marts core — fait | `fct_orders` |
| `rpt_` | Marts reports | `rpt_erp__revenue_by_month` |
| `bi_<dom>__` | BI cross-domaines | `bi_mkt__customer_360` |

---

## Patterns ClickHouse

**Déduplication CDC (staging)**
```sql
with source as (
    select * from {{ source('domain', 'table') }}
    where id is not null
),
deduped as (
    select
        id,
        argMax(field, _airbyte_extracted_at) as field,
        max(_airbyte_extracted_at)            as latest_extracted_at
    from source
    group by id
)
select
    cast(id as varchar) as id_entity,
    cast(coalesce(nullable_decimal, 0) as decimal(18,2))           as amount,
    if(date_col is null, toDate('9999-12-31'), cast(date_col as date)) as date_col,
    cast(latest_extracted_at as timestamp)                         as _etl_loaded_at
from deduped
```

**Table MergeTree (marts)**
```sql
{{ config(
    materialized = 'table',
    engine       = 'MergeTree()',
    order_by     = '(id_entity)',
    tags         = ['marts', 'domain']
) }}
```

---

## Orchestration

Les modèles sont exécutés par Airflow (Astronomer) dans le conteneur `dbt-on-astro_ce4cf1-scheduler-1`.

```bash
# Accéder au conteneur
docker exec -it dbt-on-astro_ce4cf1-scheduler-1 bash

# Dans le conteneur
cd /usr/local/airflow/dbt/warehouse
dbt run --target erp
dbt test --target erp
```

Documentation complète (architecture, orchestration, troubleshooting ClickHouse) : voir le [README racine](../../README.md).
