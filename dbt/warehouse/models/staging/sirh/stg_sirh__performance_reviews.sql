{{ config(tags=['staging', 'sirh']) }}

with source as (

    select * from {{ source('sirh', 'performance_reviews') }}
    where id is not null

),

deduped as (

    select
        id,
        argMax(employee_id,         _airbyte_extracted_at) as employee_id,
        argMax(reviewer_id,         _airbyte_extracted_at) as reviewer_id,
        argMax(period_year,         _airbyte_extracted_at) as review_period_year,
        argMax(overall_score,       _airbyte_extracted_at) as overall_score,
        argMax(strengths,           _airbyte_extracted_at) as strengths,
        argMax(improvement_areas,   _airbyte_extracted_at) as areas_for_improvement,
        argMax(review_date,         _airbyte_extracted_at) as submitted_at,
        argMax(created_at,          _airbyte_extracted_at) as created_at,
        max(_airbyte_extracted_at)                         as latest_extracted_at
    from source
    group by id

)

select
    cast(id                                        as varchar)   as id_performance_review,
    cast(coalesce(employee_id, '')                 as varchar)   as employee_id,
    cast(coalesce(reviewer_id, '')                 as varchar)   as reviewer_id,
    coalesce(review_period_year, 0)                              as review_period_year,
    cast(''                                        as varchar)   as review_type,
    toString(coalesce(overall_score, 0))                         as overall_rating,
    cast(coalesce(strengths, '')                   as varchar)   as strengths,
    cast(coalesce(areas_for_improvement, '')       as varchar)   as areas_for_improvement,
    cast(''                                        as varchar)   as objectives_next_period,
    cast(''                                        as varchar)   as status,
    toDateTimeOrNull(toString(submitted_at))                     as submitted_at,
    cast(null as Nullable(DateTime64(3)))                        as validated_at,
    cast(created_at                                as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                        as updated_at,
    cast(latest_extracted_at                       as timestamp) as _etl_loaded_at
from deduped
