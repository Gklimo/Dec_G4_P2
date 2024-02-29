select 
    cast(category_id as integer) as category_id,
    cast(lower(category_name) as varchar) as category_name,
    cast(lower(description) as varchar) as description,
    picture
from {{ source('northwind', 'categories') }}