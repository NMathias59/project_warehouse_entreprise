{{ config(materialized='view', tags=['staging', 'sirh']) }}

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
    max(_airbyte_extracted_at)                    as latest_extracted_at
from {{ source('sirh', 'performance_reviews') }}
where id is not null
group by id
