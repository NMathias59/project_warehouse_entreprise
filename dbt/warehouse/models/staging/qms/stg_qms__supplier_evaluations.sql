{{ config(tags=['staging', 'qms']) }}

with base as (

    select * from {{ ref('base_qms__supplier_evaluations') }}

)

select
    cast(id                                        as varchar)       as id_supplier_evaluation,
    cast(coalesce(supplier_id, '')                 as varchar)       as supplier_id,
    0                                                                as evaluation_period_year,
    0                                                                as evaluation_period_quarter,
    cast(coalesce(overall_score, 0)                as decimal(18,2)) as overall_score,
    cast(0                                         as decimal(18,2)) as delivery_score,
    cast(0                                         as decimal(18,2)) as quality_score,
    cast(0                                         as decimal(18,2)) as responsiveness_score,
    cast(''                                        as varchar)       as status,
    cast(coalesce(supplier_id, '')                 as varchar)       as evaluated_by,
    cast(created_at                                as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                           as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
