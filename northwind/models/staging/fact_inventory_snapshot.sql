WITH daily_inventory AS (
    SELECT
        dd.date_id AS snapshot_date_id,  -- Joining with dim_date to get the date_id for the current date
        p.product_id,
        p.units_in_stock,
        p.units_on_order,
        p.reorder_level
    FROM {{ ref('products') }} p  -- Assuming 'products' is your source or staging model for product inventory
    CROSS JOIN {{ ref('dim_date') }} dd  -- Joining with dim_date
    WHERE dd.date = DATE_TRUNC('day', CURRENT_TIMESTAMP)  -- Filtering for the current date
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id', 'snapshot_date_id']) }} AS inventory_snapshot_key,
    snapshot_date_id,
    product_id,
    units_in_stock,
    units_on_order,
    reorder_level
FROM daily_inventory
