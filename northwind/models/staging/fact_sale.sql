with orders as (
    select
        cast(order_id as integer) as order_id,
        cast(lower(customer_id) as varchar) as customer_id,  
        cast(employee_id as integer) as employee_id,
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
        cast(order_id as integer) as order_id,
        cast(product_id as integer) as product_id,
        unit_price,
        quantity,
        discount,
        (1-discount) * unit_price * quantity  as revenue
    from {{ ref('order_details') }}
),

orders_joined as (
    select
        o.*,
        od.date_id as order_date_id,  -- Joining with dim_date to get the date_id
        rd.date_id as required_date_id,
        sd.date_id as shipped_date_id
    from orders as o
    inner join {{ ref('dim_date') }} as od on o.order_date = od.date 
    inner join {{ ref('dim_date') }} as rd on o.required_date = rd.date 
    inner join {{ ref('dim_date') }} as sd on o.shipped_date = sd.date 

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
    oj.order_date_id,
    oj.required_date_id,
    oj.shipped_date_id,
    ship_city,
    ship_region,
    ship_country,
    unit_price,
    quantity,
    discount,   
    revenue
from orders_joined as oj
inner join order_details as od
    on oj.order_id = od.order_id
