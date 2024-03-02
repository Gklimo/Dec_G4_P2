WITH ranked_customers AS (
    SELECT
        c.*,
        dd.date_id as extracted_date_id,  -- Joining with dim_date to get the date_id for extracted_at
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY c.extracted_at DESC
        ) AS rank
    FROM {{ ref('customers') }} c
    JOIN {{ ref('dim_date') }} dd ON c.extracted_at = dd.date  -- Assuming your dim_date table has a 'date' column
)

SELECT
    customer_key,
    customer_id,
    company_name,
    contact_name,
    contact_title,
    region,
    country,
    extracted_date_id,  -- Using date_id from dim_date
    CASE WHEN rank = 1 THEN TRUE ELSE FALSE END AS is_current,
    CASE WHEN rank = 1 THEN (SELECT date_id FROM {{ ref('dim_date') }} WHERE date = CURRENT_DATE) ELSE extracted_date_id END AS valid_from,
    CASE WHEN rank = 1 THEN NULL ELSE LEAD(extracted_date_id, 1) OVER (PARTITION BY customer_id ORDER BY extracted_at DESC) END AS valid_to
FROM ranked_customers
