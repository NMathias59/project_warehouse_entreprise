{{ config(tags=['staging', 'qms']) }}

with source as (

    select * from {{ source('qms', 'supplier_evaluations') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(supplier_ref,  _airbyte_extracted_at) as supplier_id,
        argMax(overall_score, _airbyte_extracted_at) as overall_score,
        argMax(supplier_ref,  _airbyte_extracted_at) as evaluated_by,
        argMax(created_at,    _airbyte_extracted_at) as created_at,
        argMax(updated_at,    _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                   as latest_extracted_at
    from source
    group by id

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
    cast(coalesce(evaluated_by, '')                as varchar)       as evaluated_by,
    cast(created_at                                as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                           as updated_at,
    cast(latest_extracted_at                       as timestamp)     as _etl_loaded_at
from deduped
