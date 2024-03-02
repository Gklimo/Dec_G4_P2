WITH daily_inventory AS (
    SELECT
        DATE_TRUNC('day', CURRENT_TIMESTAMP) AS snapshot_date,
        product_id,
        units_in_stock,
        units_on_order,
        reorder_level
    FROM {{ ref('products') }}  -- Assuming 'products' is your source or staging model for product inventory
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id', 'snapshot_date']) }} AS inventory_snapshot_key,
    snapshot_date,
    product_id,
    units_in_stock,
    units_on_order,
    reorder_level
FROM daily_inventory
