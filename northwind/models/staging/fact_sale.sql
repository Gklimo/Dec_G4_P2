with orders as (
    select
        order_id,
        customer_id,
        employee_id,
        cast(order_date as date) as order_date,
        cast(required_date as date) as required_date,
        cast(shipped_date as date) as shipped_date,
        ship_city,
        ship_region,
        ship_country
    from {{ ref('orders') }}
),

order_details as (
    select
        order_id,
        product_id,
        unit_price,
        quantity,
        discount,
        unit_price * quantity as revenue
    from {{ ref('order_details') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['od.order_id', 'od.product_id']) }} as sales_key,
    od.product_id as product_id,
    od.order_id as order_id,
    {{ dbt_utils.generate_surrogate_key(['od.product_id']) }} as product_key,
    {{ dbt_utils.generate_surrogate_key(['od.order_id']) }} as order_key,
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as employee_key,
    employee_id,
    order_date,
    required_date,
    shipped_date,
    ship_city,
    ship_region,
    ship_country
    unit_price,
    quantity,
    discount,   
    revenue
from orders as o
inner join order_details as od
    on o.order_id = od.order_id
