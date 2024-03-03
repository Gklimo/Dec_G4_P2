-- No products should be free
select *
from {{ ref('dim_product') }}
where unit_price = 0
