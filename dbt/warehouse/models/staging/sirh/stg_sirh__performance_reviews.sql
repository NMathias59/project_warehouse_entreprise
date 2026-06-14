{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'performance_reviews') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(employee_id,                _airbyte_extracted_at) as employee_id,
        argMax(reviewer_id,                _airbyte_extracted_at) as reviewer_id,
        argMax(review_period_year,         _airbyte_extracted_at) as review_period_year,
        argMax(review_type,                _airbyte_extracted_at) as review_type,
        argMax(overall_rating,             _airbyte_extracted_at) as overall_rating,
        argMax(strengths,                  _airbyte_extracted_at) as strengths,
        argMax(areas_for_improvement,      _airbyte_extracted_at) as areas_for_improvement,
        argMax(objectives_next_period,     _airbyte_extracted_at) as objectives_next_period,
        argMax(status,                     _airbyte_extracted_at) as status,
        argMax(submitted_at,               _airbyte_extracted_at) as submitted_at,
        argMax(validated_at,               _airbyte_extracted_at) as validated_at,
        argMax(created_at,                 _airbyte_extracted_at) as created_at,
        argMax(updated_at,                 _airbyte_extracted_at) as updated_at,
        max(_airbyte_extracted_at)                                as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                        as varchar)   as id_performance_review,
    cast(coalesce(employee_id, '')                 as varchar)   as employee_id,
    cast(coalesce(reviewer_id, '')                 as varchar)   as reviewer_id,
    coalesce(review_period_year, 0)                              as review_period_year,
    cast(coalesce(review_type, '')                 as varchar)   as review_type,
    cast(coalesce(overall_rating, '')              as varchar)   as overall_rating,
    cast(coalesce(strengths, '')                   as varchar)   as strengths,
    cast(coalesce(areas_for_improvement, '')       as varchar)   as areas_for_improvement,
    cast(coalesce(objectives_next_period, '')      as varchar)   as objectives_next_period,
    cast(coalesce(status, '')                      as varchar)   as status,
    toDateTimeOrNull(toString(submitted_at))                     as submitted_at,
    toDateTimeOrNull(toString(validated_at))                     as validated_at,
    cast(created_at                                as timestamp) as created_at,
    toDateTimeOrNull(toString(updated_at))                       as updated_at,
    cast(latest_extracted_at                       as timestamp) as _etl_loaded_at
from deduped
