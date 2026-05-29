{{ config(tags=['staging', 'erp']) }}

with source as (
    select * from {{ source('erp', 'supplier_evaluations') }}
)

select
    cast(id as varchar)              as id_supplier_evaluation,
    cast(supplier_id as varchar)     as supplier_id,
    cast(notes as varchar)           as notes,
    cast(period as date)             as period,
    cast(score_price as int)         as score_price,
    cast(score_quality as int)       as score_quality,
    cast(score_delivery as int)      as score_delivery,
    cast(created_at as timestamp)    as created_at
from source
where id is not null
