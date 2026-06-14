{{ config(materialized='ephemeral', tags=['intermediate', 'procurement']) }}

with rfqs as (
    select * from {{ ref('stg_procurement__rfqs') }}
),

rfq_responses as (
    select * from {{ ref('stg_procurement__rfq_responses') }}
),

suppliers as (
    select * from {{ ref('stg_procurement__suppliers') }}
),

rfq_lines as (
    select * from {{ ref('stg_procurement__rfq_lines') }}
),

rfq_lines_agg as (
    select
        rfq_id,
        count(id_rfq_line)      as nb_rfq_lines
    from rfq_lines
    group by rfq_id
)

select
    rr.id_rfq_response,
    rr.rfq_id,
    rr.supplier_id,
    any(s.name)                                                             as supplier_name,
    any(r.status)                                                           as rfq_status,
    rr.status                                                               as response_status,
    rr.unit_price,
    rr.lead_time_days,
    rr.received_at,
    any(rla.nb_rfq_lines)                                                   as nb_rfq_lines,
    rank() OVER (PARTITION BY rr.rfq_id ORDER BY rr.unit_price ASC)         as price_rank,
    rank() OVER (PARTITION BY rr.rfq_id ORDER BY rr.lead_time_days ASC)     as lead_time_rank
from rfq_responses as rr
left join rfqs as r
    on r.id_rfq = rr.rfq_id
left join suppliers as s
    on s.id_supplier = rr.supplier_id
left join rfq_lines_agg as rla
    on rla.rfq_id = rr.rfq_id
group by
    rr.id_rfq_response,
    rr.rfq_id,
    rr.supplier_id,
    rr.status,
    rr.unit_price,
    rr.lead_time_days,
    rr.received_at
