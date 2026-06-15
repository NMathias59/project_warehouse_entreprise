{{ config(tags=['staging', 'plm']) }}

with base as (

    select * from {{ ref('base_plm__bom_headers') }}

)

select
    cast(id                                    as varchar)   as id_bom_header,
    cast(coalesce(product_version_id, '')      as varchar)   as product_version_id,
    cast(''                                    as varchar)   as bom_type,
    cast(coalesce(status, '')                  as varchar)   as status,
    0                                                        as total_components,
    cast(created_at                            as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                    as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
