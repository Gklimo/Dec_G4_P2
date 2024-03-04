select 
    {{ dbt_utils.generate_surrogate_key(["date.month_end_date", "sales.employee_key"]) }} as order_monthly_key,
    date.month_end_date as order_month_end_date,
    sales.employee_key as employee_key, 
    count(*) as sales_count,
from {{ ref('fact_sale') }} as sales
inner join {{ ref('dim_date_get') }} as date on date.date_day = sales.order_date
group by
    order_month_end_date,
    employee_key