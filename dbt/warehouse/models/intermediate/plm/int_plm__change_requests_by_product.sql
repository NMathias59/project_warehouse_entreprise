{{ config(materialized='ephemeral', tags=['intermediate', 'plm']) }}

with change_requests as (
    select * from {{ ref('stg_plm__change_requests') }}
)

select
    product_id,
    count(id_change_request)                                                as nb_change_requests,
    countIf(status in ('draft', 'submitted', 'under_review'))               as nb_open,
    countIf(status = 'approved')                                            as nb_approved,
    countIf(status = 'implemented')                                         as nb_implemented,
    countIf(status = 'rejected')                                            as nb_rejected,
    countIf(priority in ('high', 'critical'))                               as nb_high_priority,
    max(submitted_at)                                                       as last_request_at
from change_requests
group by
    product_id
