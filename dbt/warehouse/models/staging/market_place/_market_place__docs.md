# Marketplace Staging Layer Documentation

This directory contains the dbt staging models for the **Marketplace** domain. These models serve as the foundational layer of our warehouse, transforming raw data from ClickHouse into a clean, standardized format suitable for downstream business logic (Marts).

## Overview

The staging layer processes raw tables from the `DB_WH_MKT` database. Each model follows a strictly standardized pattern to ensure consistency across the entire pipeline:

1.  **Source Extraction**: Uses dbt `source` macros to pull data directly from the `marketplace` schema in ClickHouse.
2.  **Column Standardization**: 
    - Renames raw columns to a consistent prefixing convention (e.g., `stg_mkt__[entity]_id`).
    - Standardizes timestamps and status indicators.
3.  **CDC Metadata Preservation**: Maintains critical Change Data Capture (CDC) metadata such as `_ab_cdc_lsn`, `_ab_cdc_updated_at`, and `_ab_cdc_deleted_at` where available, enabling incremental downstream processing.

## Technical Implementation Pattern

Every model in this directory follows a 3-step CTE structure:

```sql
with source as (
    -- Direct pull from ClickHouse raw table
    select * from {{ source('marketplace', 'raw_table_name') }}
),

renamed as (
    -- Column renaming and type casting
    select
        id as stg_mkt__entity_id,
        ...
    from source
)

select * from renamed
```

## Data Quality & Testing Strategy

To ensure the reliability of our downstream analytics, every staging model is subject to automated quality checks:

- **Uniqueness**: The primary identifier (e.	e.g., `stg_mkt__order_id`) is tested for uniqueness across all records.
- **Integrity**: Primary keys are strictly tested for `not_null` constraints.
- **Schema Consistency**: Any deviation in the raw source schema that breaks these tests will trigger a failure in our CI/CD pipeline.

## Model Inventory by Domain

### 1. Customer & Loyalty
*Models related to user profiles, authentication metadata, and loyalty programs.*
- `stg_mkt__customers`: Core profile data.
- `stg_mkt__customer_addresses`: Shipping and billing locations.
- `stg_mkt__loyalty_points`: Transaction history of points.
- `stg_mkt__loyalty_transactions`: Point balance changes.
- `stg_mkt__newsletter_subscriptions`: Marketing preferences.

### 2. Product Catalog & Pricing
*Models managing the core marketplace offering.*
- `stg_mkt__products`: Core product attributes.
- `stg_mkt__brands`: Brand metadata and logos.
- `stg_mkt__categories`: Product hierarchy/taxonomy.
- `stg_mkt__product_prices`: Current and historical pricing.
- `stg_mkt__product_specifications`: Technical attributes.
- `stg_mkt__product_images`: Media assets for products.
- `stg_mkt__product_tags`: Searchable metadata tags.

### 3. Ordering & Transactions
*Models covering the lifecycle of a purchase.*
- `stg_mkt__orders`: The main transaction record.
- `stg_mkt__order_lines`: Individual items within an order.
- `stg_mkt__payments`: Payment event logs.
- `stg_mkt__payment_methods`: Supported payment types.
- `stg_mkt__invoices`: Billing and invoice generation.
- `stg_mkt__refunds`: Returns and refund processing.

### 4. Logistics & Inventory
*Models for fulfillment and warehouse management.*
- `stg_mkt__shipments`: Delivery tracking and status.
- `stg_mkt__carts`: User session and basket metadata.
- `stg_mkt__cart_items`: Individual items in baskets.
- `stg_mkt__warehouses`: Warehouse facility information.
- `stg_mkt__stock_levels`: Real-time availability data.

## Data Lineage
`ClickHouse (DB_WH_MKT)` $\rightarrow$ `dbt staging (stg_mkt_*)` $\rightarrow$ `Warehouse Marts (fct_* / dim_*)`

---
*Last updated: 2026-06-10*
