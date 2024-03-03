select 
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as employee_key,
    cast(employee_id as integer) as employee_id,
    cast(lower(last_name) as varchar) as last_name,  
    cast(lower(first_name) as varchar) as first_name,
    cast(lower(title) as varchar) as title,
    cast(lower(region) as varchar) as region,
    cast(lower(country) as varchar) as country,
    cast(hire_date as date) as hire_date,
    cast(birth_date as date) as birth_date,
    {{ dbt_utils.generate_surrogate_key(['reports_to']) }} as reports_to_key,
    cast(reports_to as integer) as reports_to,
    cast(_airbyte_extracted_at as datetime) AS extracted_at

from {{ source('northwind', 'employees') }}
