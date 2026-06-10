with source as (
    select * from {{ source('marketplace', 'alembic_version') }}
),

renamed as (
    select
        _airbyte_raw_id as alembic_version__airbyte_raw_id,
        _airbyte_extracted_at as alembic_version__airbyte_extracted_at,
        _airbyte_meta as alembic_version__airbyte_meta,
        _airbyte_generation_id as alembic_version__airbyte_generation_id,
        _ab_cdc_lsn as alembic_version__ab_cdc_lsn,
        version_num as alembic_version_version_num,
        _ab_cdc_deleted_at as alembic_version__ab_cdc_deleted_at,
        _ab_cdc_updated_at as alembic_version__ab_cdc_updated_at
    from source
)

select * from renamed
