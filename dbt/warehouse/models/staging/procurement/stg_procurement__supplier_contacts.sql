{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__supplier_contacts') }}

)

select
    cast(id                               as varchar)   as id_supplier_contact,
    cast(coalesce(supplier_id, '')        as varchar)   as supplier_id,
    cast(coalesce(first_name, '')         as varchar)   as first_name,
    cast(''                               as varchar)   as last_name,
    cast(coalesce(email, '')              as varchar)   as email,
    cast(coalesce(phone, '')              as varchar)   as phone,
    cast(coalesce(role, '')               as varchar)   as role,
    cast(coalesce(is_primary, false)      as boolean)   as is_primary,
    cast(null as Nullable(DateTime64(3)))               as created_at,
    cast(null as Nullable(DateTime64(3)))               as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
