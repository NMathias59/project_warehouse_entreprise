{{ config(tags=['staging', 'plm']) }}

select
    cast('' as varchar)              as id_certification,
    cast('' as varchar)              as product_id,
    cast('' as varchar)              as certification_type,
    cast('' as varchar)              as certification_body,
    cast('' as varchar)              as certificate_number,
    cast('' as varchar)              as status,
    cast(null as Nullable(Date32))   as valid_from,
    cast(null as Nullable(Date32))   as valid_until,
    cast(null as Nullable(DateTime64(3))) as created_at,
    cast(null as Nullable(DateTime64(3))) as updated_at,
    cast(now() as timestamp)         as _etl_loaded_at
from {{ source('plm', 'certifications') }}
where 1 = 0
