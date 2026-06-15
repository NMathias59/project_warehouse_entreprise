{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__supplier_evaluations') }}

)

select
    cast(id                                        as varchar)       as id_supplier_evaluation,
    cast(coalesce(supplier_id, '')                 as varchar)       as supplier_id,
    0                                                                as evaluation_year,
    0                                                                as evaluation_quarter,
    cast(coalesce(quality_score, 0)                as decimal(18,2)) as quality_score,
    cast(coalesce(delivery_score, 0)               as decimal(18,2)) as delivery_score,
    cast(coalesce(responsiveness_score, 0)         as decimal(18,2)) as responsiveness_score,
    cast(coalesce(price_score, 0)                  as decimal(18,2)) as price_score,
    cast(coalesce(overall_score, 0)                as decimal(18,2)) as overall_score,
    cast(''                                        as varchar)       as status,
    cast(coalesce(evaluated_by, '')                as varchar)       as evaluated_by,
    cast(created_at                                as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                            as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
