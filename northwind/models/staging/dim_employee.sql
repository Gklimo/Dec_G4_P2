select 
    employee_key,
    employee_id,
    last_name,
    first_name,
    title,
    city,
    employee_country,
    employee_region,
    employee_age,
    hire_date,
    birth_date,
    reports_to_key,
    reports_to,
    valid_from,
    valid_to
FROM {{ ref('employees') }}