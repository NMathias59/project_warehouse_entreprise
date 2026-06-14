{{ config(tags=['staging', 'procurement']) }}

with source as (

    select * from {{ source('procurement', 'supplier_evaluations') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(supplier_id,            _airbyte_extracted_at) as supplier_id,
        argMax(evaluation_year,        _airbyte_extracted_at) as evaluation_year,
        argMax(evaluation_quarter,     _airbyte_extracted_at) as evaluation_quarter,
        argMax(quality_score,          _airbyte_extracted_at) as quality_score,
        argMax(delivery_score,         _airbyte_extracted_at) as delivery_score,
        argMax(responsiveness_score,   _airbyte_extracted_at) as responsiveness_score,
        argMax(price_score,            _airbyte_extracted_at) as price_score,
        argMax(overall_score,          _airbyte_extracted_at) as overall_score,
        argMax(status,                 _airbyte_extracted_at) as status,
        argMax(evaluated_by,           _airbyte_extracted_at) as evaluated_by,
        argMax(created_at,             _airbyte_extracted_at) as created_at,
        argMax(updated_at,             _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                            as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                        as varchar)       as id_supplier_evaluation,
    cast(coalesce(supplier_id, '')                 as varchar)       as supplier_id,
    coalesce(evaluation_year, 0)                                     as evaluation_year,
    coalesce(evaluation_quarter, 0)                                  as evaluation_quarter,
    cast(coalesce(quality_score, 0)                as decimal(18,2)) as quality_score,
    cast(coalesce(delivery_score, 0)               as decimal(18,2)) as delivery_score,
    cast(coalesce(responsiveness_score, 0)         as decimal(18,2)) as responsiveness_score,
    cast(coalesce(price_score, 0)                  as decimal(18,2)) as price_score,
    cast(coalesce(overall_score, 0)                as decimal(18,2)) as overall_score,
    cast(coalesce(status, '')                      as varchar)       as status,
    cast(coalesce(evaluated_by, '')                as varchar)       as evaluated_by,
    cast(created_at                                as timestamp)     as created_at,
    toDateTimeOrNull(toString(updated_at))                           as updated_at,
    cast(latest_extracted_at                       as timestamp)     as _etl_loaded_at
from deduped
