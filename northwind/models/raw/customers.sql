select 
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    cast(customer_id as varchar) AS customer_id,
    cast(lower(company_name) as varchar) as company_name,  
    cast(lower(contact_name) as varchar) as contact_name,
    cast(lower(contact_title) as varchar) as contact_title,
    cast(lower(region) as varchar) as region,
    cast(lower(country) as varchar) as country,
    cast(_airbyte_extracted_at as datetime) AS extracted_at

from {{ source('northwind', 'customers') }}
