{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__suppliers') }}

)

select
    cast(id                                       as varchar)   as id_supplier,
    cast(coalesce(code, '')                       as varchar)   as code,
    cast(coalesce(name, '')                       as varchar)   as name,
    cast(coalesce(supplier_type, '')              as varchar)   as supplier_type,
    if(coalesce(is_active, false), 'active', 'inactive')       as status,
    cast(coalesce(country_code, '')               as varchar)   as country_code,
    cast(''                                       as varchar)   as city,
    toString(coalesce(payment_terms_days, 0))                  as payment_terms_id,
    cast(coalesce(currency, '')                   as varchar)   as currency,
    cast(''                                       as varchar)   as tax_id,
    cast(coalesce(is_active, false)               as boolean)   as is_active,
    cast(created_at                               as timestamp) as created_at,
    cast(null as Nullable(DateTime64(3)))                       as updated_at,
    cast(latest_extracted_at                as timestamp) as _etl_loaded_at
from base
