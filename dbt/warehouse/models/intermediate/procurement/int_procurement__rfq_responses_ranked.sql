{{ config(materialized='view', tags=['intermediate', 'procurement']) }}

with rfq_lines_agg as (
    select
        rfq_id,
        count(id_rfq_line) as nb_rfq_lines
    from {{ ref('stg_procurement__rfq_lines') }}
    group by rfq_id
)

select
    rr.id_rfq_response                                                              as id_rfq_response,
    rr.rfq_id                                                                       as rfq_id,
    rr.supplier_id                                                                  as supplier_id,
    any(s.name)                                                                     as supplier_name,
    any(r.status)                                                                   as rfq_status,
    rr.status                                                                       as response_status,
    rr.unit_price                                                                   as unit_price,
    rr.lead_time_days                                                               as lead_time_days,
    rr.received_at                                                                  as received_at,
    any(rla.nb_rfq_lines)                                                           as nb_rfq_lines,
    rank() OVER (PARTITION BY rr.rfq_id ORDER BY rr.unit_price ASC)                as price_rank,
    rank() OVER (PARTITION BY rr.rfq_id ORDER BY rr.lead_time_days ASC)            as lead_time_rank
from {{ ref('stg_procurement__rfq_responses') }} as rr
left join {{ ref('stg_procurement__rfqs') }} as r
    on r.id_rfq = rr.rfq_id
left join {{ ref('stg_procurement__suppliers') }} as s
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
