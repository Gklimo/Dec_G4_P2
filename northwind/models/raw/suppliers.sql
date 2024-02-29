select 
    cast(supplier_id as integer) as supplier_id,
    cast(lower(company_name) as varchar) as company_name,
    cast(lower(contact_name) as varchar) as contact_name,
    cast(lower(address) as varchar) as address,
    cast(lower(city) as varchar) as city,
    cast(lower(region) as varchar) as region,
    cast(lower(postal_code) as varchar) as postal_code,
    cast(lower(phone) as varchar) as phone,
    cast(lower(country) as varchar) as country,
    cast(lower(fax) as varchar) as fax,
    cast(lower(homepage) as varchar) as homepage
from {{ source('northwind', 'suppliers') }}