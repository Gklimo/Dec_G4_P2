select 
    p.product_key,
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    s.supplier_id,
    s.company_name,
    s.city,
    s.region,
    s.country,
    c.category_id,
    c.category_name
from {{ ref('products') }} as p
inner join {{ ref('categories') }} as c on c.category_id = p.category_id
inner join {{ ref('suppliers') }} as s on s.supplier_id = p.supplier_id

-- `ProductKey` (PK)
-- `ReorderLevel`
-- `Discontinued`
-- `EffectiveDate`
-- `EndDate`
-- `IsCurrent`