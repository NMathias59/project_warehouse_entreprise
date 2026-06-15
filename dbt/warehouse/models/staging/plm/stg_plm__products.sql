{{ config(tags=['staging', 'plm']) }}

with base as (

    select * from {{ ref('base_plm__products') }}

)

select
    cast(id                               as varchar)   as id_product,
    cast(coalesce(code, '')               as varchar)   as code,
    cast(coalesce(name, '')               as varchar)   as name,
    cast(coalesce(description, '')        as varchar)   as description,
    cast(coalesce(product_family, '')     as varchar)   as product_family,
    cast(coalesce(lifecycle_status, '')   as varchar)   as lifecycle_status,
    cast(''                               as varchar)   as responsible_id,
    cast(null as Nullable(Date32))                      as launch_date,
    cast(null as Nullable(Date32))                      as end_of_life_date,
    cast(created_at                       as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
