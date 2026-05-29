{% macro clickhouse_delete_existing_rows(source_relation, target_pk, source_pk, date_col, days) -%}
{#
  Génère une commande SQL ClickHouse pour supprimer les lignes existantes
  dans la table cible (this) correspondant aux clés présentes dans la
  table source et récentes (date_col dans les last `days` jours).

  Usage: clickhouse_delete_existing_rows(ref('stg_model'), 'id', 'id', 'date_col', 7)
#}

{% do log("Generating clickhouse delete hook for source='" ~ source_relation ~ "'", info=True) %}

{# Normaliser la référence source en chaîne qualified: database.schema.table ou schema.table #}
{% if source_relation is mapping %}
  {# lorsque ref() retourne un Relation-like object #}
  {% set src_db = source_relation.database if source_relation.database is not none else none %}
  {% set src_schema = source_relation.schema if source_relation.schema is not none else source_relation.namespace %}
  {% set src_ident = source_relation.identifier %}
{% else %}
  {# si la valeur fournie est déjà une chaîne, on l'utilise telle quelle #}
  {% set src_db = none %}
  {% set src_schema = none %}
  {% set src_ident = source_relation %}
{% endif %}

{% if src_db %}
  {% set src_qualified = src_db ~ '.' ~ src_schema ~ '.' ~ src_ident %}
{% elif src_schema and src_ident %}
  {% set src_qualified = src_schema ~ '.' ~ src_ident %}
{% else %}
  {% set src_qualified = src_ident %}
{% endif %}

{# Construire la table cible fully-qualified à partir de `this` #}
{% set tgt_db = this.database if this.database is not none else none %}
{% set tgt_schema = this.schema if this.schema is not none else this.database %}
{% set tgt_ident = this.identifier %}
{% if tgt_db %}
  {% set tgt_qualified = tgt_db ~ '.' ~ tgt_schema ~ '.' ~ tgt_ident %}
{% else %}
  {% set tgt_qualified = tgt_schema ~ '.' ~ tgt_ident %}
{% endif %}

{# Si la table cible n'existe pas encore, ne rien retourner (pas de hook) #}
{% set tgt_relation = adapter.get_relation(database=tgt_db, schema=tgt_schema, identifier=tgt_ident) %}
{% if tgt_relation is none %}
  {{ return('') }}
{% endif %}

{# Construire la commande ALTER TABLE ... DELETE WHERE ... #}
{% set sql = "ALTER TABLE IF EXISTS " ~ tgt_qualified ~
            " DELETE WHERE " ~ target_pk ~ " IN (SELECT " ~ source_pk ~
            " FROM " ~ src_qualified ~ " WHERE " ~ date_col ~
            " >= subtractDays(now(), " ~ days|string ~ "))" %}

{{ return(sql) }}

{%- endmacro %}

