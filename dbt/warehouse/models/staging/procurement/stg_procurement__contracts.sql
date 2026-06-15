{{ config(tags=['staging', 'procurement']) }}

with base as (

    select * from {{ ref('base_procurement__contracts') }}

)

select
    cast(id                                  as varchar)       as id_contract,
    cast(coalesce(reference, '')             as varchar)       as reference,
    cast(coalesce(supplier_id, '')           as varchar)       as supplier_id,
    cast(coalesce(contract_type, '')         as varchar)       as contract_type,
    cast(coalesce(status, '')                as varchar)       as status,
    cast(coalesce(title, '')                 as varchar)       as title,
    cast(coalesce(total_amount, 0)           as decimal(18,2)) as total_amount,
    cast(''                                  as varchar)       as currency,
    cast(start_date                          as date)          as start_date,
    cast(end_date                            as date)          as end_date,
    cast(null as Nullable(DateTime64(3)))                      as signed_at,
    cast(''                                  as varchar)       as created_by,
    cast(created_at                          as timestamp)     as created_at,
    cast(null as Nullable(DateTime64(3)))                      as updated_at,
    cast(latest_extracted_at                as timestamp)     as _etl_loaded_at
from base
