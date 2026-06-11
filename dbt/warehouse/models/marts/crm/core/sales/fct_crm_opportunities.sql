{{
    config(
        materialized='incremental',
        unique_key='id_opportunity',
        incremental_strategy='append',
        engine='MergeTree()',
        order_by='(created_at, id_opportunity)',
        tags=['marts', 'crm', 'fct'],
        pre_hook="{{ clickhouse_delete_existing_rows(ref('stg_crm__opportunities'), 'id_opportunity', 'id_opportunity', 'updated_at', 30) }}"
    )
}}

select
    o.id_opportunity,
    o.title,
    o.stage,
    o.status,
    o.origin,
    o.account_id,
    o.owner_id,
    o.source_order_id,
    o.probability,
    o.amount_estimated,
    o.expected_close_at,
    o.created_at,
    o.updated_at,
    p.age_days,
    p.nb_stage_changes,
    p.first_stage_change_at,
    p.last_stage_change_at,
    p.days_in_current_stage
from {{ ref('stg_crm__opportunities') }} as o
left join {{ ref('int_crm__opportunities_with_pipeline') }} as p
    on p.id_opportunity = o.id_opportunity
{% if is_incremental() %}
where o.updated_at >= today() - interval {{ var('dev_lookback_days') }} day
{% endif %}
