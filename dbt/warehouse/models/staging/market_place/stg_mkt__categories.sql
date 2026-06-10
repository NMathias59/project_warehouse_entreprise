with source as (
    select * from {{ source('marketplace', 'categories') }}
),

renamed as (
    select
        _airbyte_raw_id as categorie__airbyte_raw_id,
        _airbyte_extracted_at as categorie__airbyte_extracted_at,
        _airbyte_meta as categorie__airbyte_meta,
        _airbyte_generation_id as categorie__airbyte_generation_id,
        id as categorie_id,
        name as categorie_name,
        slug as categorie_slug,
        position as categorie_position,
        parent_id as categorie_parent_id,
        created_at as categorie_created_at,
        deleted_at as categorie_deleted_at,
        updated_at as categorie_updated_at,
        _ab_cdc_lsn as categorie__ab_cdc_lsn,
        description as categorie_description,
        _ab_cdc_deleted_at as categorie__ab_cdc_deleted_at,
        _ab_cdc_updated_at as categorie__ab_cdc_updated_at
    from source
)

select * from renamed
