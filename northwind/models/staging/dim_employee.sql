WITH ranked_employees AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY extracted_at DESC
        ) AS rank
    FROM {{ ref('employees') }}
)

SELECT
    employee_key,
    employee_id,
    last_name,
    first_name,
    title,
    region,
    country,
    hire_date,
    birth_date,
    reports_to_key,
    reports_to,
    extracted_at,
    CASE WHEN rank = 1 THEN TRUE ELSE FALSE END AS is_current,
    CASE WHEN rank = 1 THEN CURRENT_TIMESTAMP ELSE extracted_at END AS valid_from,
    CASE WHEN rank = 1 THEN NULL ELSE LEAD(extracted_at, 1) OVER (PARTITION BY employee_id ORDER BY extracted_at DESC) END AS valid_to
FROM ranked_employees
