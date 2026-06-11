{{
    config(
        materialized='incremental',
        unique_key='id_pipeline_event',
        incremental_strategy='append',
        engine='MergeTree()',
        order_by='(occurred_at, id_pipeline_event)',
        tags=['marts', 'crm', 'fct'],
        pre_hook="{{ clickhouse_delete_existing_rows(ref('stg_crm__pipeline_events'), 'id_pipeline_event', 'id_pipeline_event', 'occurred_at', var('dev_lookback_days')) }}"
    )
}}

select
    id_pipeline_event,
    opportunity_id,
    stage_from,
    stage_to,
    notes,
    owner_id,
    occurred_at,
    created_at
from {{ ref('stg_crm__pipeline_events') }}
{% if is_incremental() %}
where occurred_at >= today() - interval {{ var('dev_lookback_days') }} day
{% endif %}
