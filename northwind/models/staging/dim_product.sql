WITH product_data AS (
    SELECT
        p.product_key,
        p.product_id,
        p.product_name,
        p.quantity_per_unit,
        p.unit_price,
        p.units_in_stock,
        p.units_on_order,
        p.discontinued,
        p.reorder_level,
        p.extracted_at,  -- Assuming this is still needed for joining with dim_date
        s.supplier_id,
        s.company_name AS supplier_name,
        s.city AS supplier_city,
        s.region AS supplier_region,
        s.country AS supplier_country,
        c.category_id,
        c.category_name
    FROM {{ ref('products') }} AS p
    LEFT JOIN {{ ref('categories') }} AS c ON c.category_id = p.category_id
    LEFT JOIN {{ ref('suppliers') }} AS s ON s.supplier_id = p.supplier_id
),

product_dates AS (
    SELECT
        pd.*,
        dd.date_id AS extracted_date_id  -- Joining with dim_date to get the date_id for extracted_at
    FROM product_data pd
    LEFT JOIN {{ ref('dim_date') }} dd ON pd.extracted_at = dd.date  -- Assuming your dim_date table has a 'date' column
),

ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY extracted_date_id DESC  -- Using date_id for ordering
        ) AS rank
    FROM product_dates
)

SELECT
    product_key,
    product_id,
    product_name,
    quantity_per_unit,
    unit_price,
    units_in_stock,
    units_on_order,
    supplier_id,
    supplier_name,
    supplier_city,
    supplier_region,
    supplier_country,
    category_id,
    category_name,
    discontinued,
    reorder_level,
    extracted_date_id,  -- Using date_id from dim_date
    CASE WHEN rank = 1 THEN TRUE ELSE FALSE END AS is_current,
    CASE WHEN rank = 1 THEN (SELECT MAX(date_id) FROM {{ ref('dim_date') }}) ELSE extracted_date_id END AS valid_from_date_id,  -- Using the latest date_id for current records
    CASE WHEN rank = 1 THEN NULL ELSE LEAD(extracted_date_id, 1) OVER (PARTITION BY product_id ORDER BY extracted_date_id DESC) END AS valid_to_date_id  -- Using the next date_id for historical records
FROM ranked_products
