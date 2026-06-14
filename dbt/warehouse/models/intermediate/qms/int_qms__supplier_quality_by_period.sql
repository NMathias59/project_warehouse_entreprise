{{ config(materialized='ephemeral', tags=['intermediate', 'qms']) }}

with supplier_evaluations as (
    select * from {{ ref('stg_qms__supplier_evaluations') }}
)

select
    supplier_id,
    evaluation_year,
    count(id_supplier_evaluation)          as nb_evaluations,
    avg(overall_score)                     as avg_overall_score,
    avg(quality_score)                     as avg_quality_score,
    avg(delivery_score)                    as avg_delivery_score,
    avg(responsiveness_score)              as avg_responsiveness_score,
    min(overall_score)                     as min_overall_score,
    max(overall_score)                     as max_overall_score
from supplier_evaluations
group by
    supplier_id,
    evaluation_year
