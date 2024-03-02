WITH ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY extracted_at DESC
        ) AS rank
    FROM {{ ref('customers') }}
)

SELECT
    customer_key,
    customer_id,
    company_name,
    contact_name,
    contact_title,
    region,
    country,
    extracted_at,
    CASE WHEN rank = 1 THEN TRUE ELSE FALSE END AS is_current,
    CASE WHEN rank = 1 THEN CURRENT_TIMESTAMP ELSE extracted_at END AS valid_from,
    CASE WHEN rank = 1 THEN NULL ELSE LEAD(extracted_at, 1) OVER (PARTITION BY customer_id ORDER BY extracted_at DESC) END AS valid_to
FROM ranked_customers
