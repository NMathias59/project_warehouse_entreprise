{{
    config(
        materialized='incremental',
        unique_key='id_activity',
        incremental_strategy='append',
        engine='MergeTree()',
        order_by='(occurred_at, id_activity)',
        tags=['marts', 'crm', 'fct'],
        pre_hook="{{ clickhouse_delete_existing_rows(ref('stg_crm__activities'), 'id_activity', 'id_activity', 'occurred_at', var('dev_lookback_days')) }}"
    )
}}

select
    id_activity,
    activity_type,
    subject,
    body,
    outcome,
    direction,
    owner_id,
    account_id,
    contact_id,
    opportunity_id,
    duration_minutes,
    occurred_at,
    created_at
from {{ ref('stg_crm__activities') }}
{% if is_incremental() %}
where occurred_at >= today() - interval {{ var('dev_lookback_days') }} day
{% endif %}
