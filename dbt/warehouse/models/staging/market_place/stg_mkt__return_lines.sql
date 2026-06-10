with source as (
    select * from {{ source('marketplace', 'return_lines') }}
),

renamed as (
    select
        _airbyte_raw_id as return_line__airbyte_raw_id,
        _airbyte_extracted_at as return_line__airbyte_extracted_at,
        _airbyte_meta as return_line__airbyte_meta,
        _airbyte_generation_id as return_line__airbyte_generation_id,
        id as return_line_id,
        reason as return_line_reason,
        quantity as return_line_quantity,
        return_id as return_line_return_id,
        _ab_cdc_lsn as return_line__ab_cdc_lsn,
        order_line_id as return_line_order_line_id,
        _ab_cdc_deleted_at as return_line__ab_cdc_deleted_at,
        _ab_cdc_updated_at as return_line__ab_cdc_updated_at
    from source
)

select * from renamed
