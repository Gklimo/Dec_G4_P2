WITH product_data AS (
    SELECT
        p.product_key,
        p.product_id,
        p.product_name,
        p.quantity_per_unit,
        p.unit_price,
        p.units_in_stock,
        p.units_on_order,
        p.extracted_at,
        p.discontinued,
        p.reorder_level,
        s.supplier_id,
        s.company_name AS supplier_name,
        s.city AS supplier_city,
        s.region AS supplier_region,
        s.country AS supplier_country,
        c.category_id,
        c.category_name
    FROM {{ ref('products') }} AS p
    INNER JOIN {{ ref('categories') }} AS c ON c.category_id = p.category_id
    INNER JOIN {{ ref('suppliers') }} AS s ON s.supplier_id = p.supplier_id
),

ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY extracted_at DESC
        ) AS rank
    FROM product_data
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
    extracted_at,
    CASE WHEN rank = 1 THEN TRUE ELSE FALSE END AS is_current,
    CASE WHEN rank = 1 THEN CURRENT_TIMESTAMP ELSE extracted_at END AS valid_from,
    CASE WHEN rank = 1 THEN NULL ELSE LEAD(extracted_at, 1) OVER (PARTITION BY product_id ORDER BY extracted_at DESC) END AS valid_to
FROM ranked_products
