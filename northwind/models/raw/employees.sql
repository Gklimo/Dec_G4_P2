{{
    config(
        materialized="incremental",
    )
}}

WITH RankedEmployees AS (
    SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as employee_key,
    cast(employee_id as integer) as employee_id,
    cast(lower(last_name) as varchar) as last_name,  
    cast(lower(first_name) as varchar) as first_name,
    cast(lower(title) as varchar) as title,
    cast(lower(region) as varchar) as employee_region,
    cast(lower(city) as varchar) as city,
    cast(lower(country) as varchar) as employee_country,
    cast(hire_date as date) as hire_date,
    cast(birth_date as date) as birth_date,
    {{ dbt_utils.generate_surrogate_key(['reports_to']) }} as reports_to_key,
    cast(reports_to as integer) as reports_to,
    cast(_ab_cdc_updated_at as datetime) AS valid_from,
    LEAD(_ab_cdc_updated_at) OVER (PARTITION BY employee_id ORDER BY _ab_cdc_updated_at) AS valid_to,
    date_trunc('year', current_date) - date_trunc('year', birth_date) as employee_age,
    date_trunc('year', current_date) - date_trunc('year', hire_date) as hire_period,
    FROM
        {{ source('northwind', 'employees') }}
)
select 
    employee_key,
    employee_id,
    last_name,
    first_name,
    title,
    employee_region,
    city,
    employee_country,
    employee_age,
    hire_period,
    hire_date,
    birth_date,
    reports_to_key,
    reports_to,
    valid_from,
    valid_to
from 
    RankedEmployees

{% if is_incremental() %}
    where valid_from > (select max(valid_from) from {{ this }} )
{% endif %}