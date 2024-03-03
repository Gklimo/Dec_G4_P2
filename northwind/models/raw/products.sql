select 
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    cast(product_id as integer) as product_id,
    cast(lower(product_name) as varchar) as product_name,
    cast(supplier_id as integer) as supplier_id,
    cast(category_id as integer) as category_id,
    cast(quantity_per_unit as varchar) as quantity_per_unit,
    cast(unit_price as integer) as unit_price,
    cast(units_in_stock as integer) as units_in_stock,
    cast(units_on_order as integer) as units_on_order,
    cast(reorder_level as integer) as reorder_level,
    cast(discontinued as integer) as discontinued,
    cast(_airbyte_extracted_at as datetime) AS extracted_at

from {{ source('northwind', 'products') }}