{{ config(materialized='view') }}

WITH sales_data AS (
    SELECT
        fs.sales_key,
        fs.order_id,
        fs.product_id,
        fs.customer_id,
        fs.employee_id,
        fs.quantity,
        fs.revenue,
        fs.order_date_id,
        fs.required_date_id,
        fs.shipped_date_id
    FROM {{ ref('fact_sale') }} fs
),

customer_data AS (
    SELECT
        dc.customer_id,
        dc.company_name,
        dc.contact_name,
        dc.region AS customer_region
    FROM {{ ref('dim_customer') }} dc
),

employee_data AS (
    SELECT
        de.employee_id,
        de.first_name||' '||de.last_name AS employee_name,
        de.region AS employee_region,
        de.employee_age
    FROM {{ ref('dim_employee') }} de
),

product_data AS (
    SELECT
        dp.product_id,
        dp.product_name,
        dp.category_name
    FROM {{ ref('dim_product') }} dp
)

SELECT
    sd.*,
    cd.company_name,
    cd.contact_name,
    cd.customer_region,
    ed.employee_name,
    ed.employee_region,
    ed.employee_age,
    pd.product_name,
    pd.category_name,
    odt.date AS order_date,
    odt.year AS order_year,
    odt.quarter AS order_quarter,
    odt.month AS order_month,
    odt.is_holiday,
    rdt.date AS required_date,
    sdt.date AS shipped_date
FROM sales_data sd
LEFT JOIN customer_data cd ON sd.customer_id = cd.customer_id
LEFT JOIN employee_data ed ON sd.employee_id = ed.employee_id
LEFT JOIN product_data pd ON sd.product_id = pd.product_id
LEFT JOIN {{ ref('dim_date') }} odt ON sd.order_date_id = odt.date_id
LEFT JOIN {{ ref('dim_date') }} rdt ON sd.required_date_id = rdt.date_id
LEFT JOIN {{ ref('dim_date') }} sdt ON sd.shipped_date_id = sdt.date_id
