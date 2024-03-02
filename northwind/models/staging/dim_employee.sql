WITH employee_data AS (
    SELECT
        e.*,
        dd1.date_id AS hire_date_id,  -- Joining with dim_date for hire_date
        dd2.date_id AS birth_date_id,  -- Joining with dim_date for birth_date
        dd3.date_id AS extracted_date_id  -- Joining with dim_date for extracted_at
    FROM {{ ref('employees') }} e
    LEFT JOIN {{ ref('dim_date') }} dd1 ON e.hire_date = dd1.date
    LEFT JOIN {{ ref('dim_date') }} dd2 ON e.birth_date = dd2.date
    LEFT JOIN {{ ref('dim_date') }} dd3 ON e.extracted_at = dd3.date
),

ranked_employees AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY extracted_date_id DESC
        ) AS rank
    FROM employee_data
)

SELECT
    employee_key,
    employee_id,
    last_name,
    first_name,
    title,
    region,
    country,
    hire_date_id,
    birth_date_id,
    date_trunc('year', current_date) - date_trunc('year', birth_date) as employee_age,
    date_trunc('year', current_date) - date_trunc('year', hire_date) as hire_period,
    reports_to_key,
    reports_to,
    extracted_date_id,
    CASE WHEN rank = 1 THEN TRUE ELSE FALSE END AS is_current,
    CASE WHEN rank = 1 THEN (SELECT MAX(date_id) FROM {{ ref('dim_date') }}) ELSE extracted_date_id END AS valid_from_date_id,
    CASE WHEN rank = 1 THEN NULL ELSE LEAD(extracted_date_id, 1) OVER (PARTITION BY employee_id ORDER BY extracted_date_id DESC) END AS valid_to_date_id
FROM ranked_employees
