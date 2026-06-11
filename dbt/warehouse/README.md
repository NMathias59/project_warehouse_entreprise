# Projet dbt `warehouse`

Projet dbt principal de la plateforme — transforme les données brutes ERP (`DB_WH_ERP`) et Marketplace (`DB_WH_MKT`) ingérées par Airbyte dans ClickHouse en modèles analytiques prêts pour la BI.

## Couches

| Couche | Matérialisation | Préfixes | Contenu |
|---|---|---|---|
| `staging/` | view | `stg_erp__`, `stg_mkt__` | Mapping 1-to-1 avec les sources (rename, cast, NULLs) |
| `intermediate/` | ephemeral | `int_erp__`, `int_mkt__` | Logique métier intermédiaire, non exposée |
| `marts/*/core/` | table / incremental | `dim_*`, `fct_*` | Dimensions et faits par domaine métier |
| `marts/*/reports/` | table | `rpt_erp__`, `rpt_mkt__` | Tables dénormalisées prêtes BI |

## Démarrage rapide

```powershell
dbt deps
dbt debug --target erp     # vérifier la connexion ClickHouse
dbt build --target erp     # run + tests complets
```

Targets disponibles : `erp` (défaut, schéma `DB_WH_ERP`) et `mkt` (schéma `DB_WH_MKT`) — voir `profiles.yml`.

📖 Documentation complète (architecture, modèles, macros, troubleshooting ClickHouse) : voir le [README racine](../../README.md).
