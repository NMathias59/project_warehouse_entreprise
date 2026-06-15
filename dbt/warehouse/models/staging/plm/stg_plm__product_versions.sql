{{ config(tags=['staging', 'plm']) }}

with base as (

    select * from {{ ref('base_plm__product_versions') }}

)

select
    cast(id                                 as varchar)   as id_product_version,
    cast(coalesce(product_id, '')           as varchar)   as product_id,
    cast(coalesce(version_number, '')       as varchar)   as version_number,
    cast(coalesce(status, '')               as varchar)   as status,
    cast(coalesce(change_summary, '')       as varchar)   as change_summary,
    cast(coalesce(approved_by, '')          as varchar)   as approved_by,
    cast(null as Nullable(DateTime64(3)))                 as approved_at,
    cast(effective_date                     as date)      as effective_date,
    cast(created_at                         as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                 as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
