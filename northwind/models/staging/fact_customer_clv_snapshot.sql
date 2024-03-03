WITH customer_orders AS (
    SELECT
        o.customer_id,
        CAST(o.order_date AS DATE) AS order_date,
        SUM(od.unit_price * od.quantity) as total_order_revenue
    FROM {{ ref('orders') }} AS o
    INNER JOIN {{ ref('order_details') }} AS od ON o.order_id = od.order_id
    GROUP BY o.customer_id, CAST(o.order_date AS DATE)
),

monthly_customer_revenue AS (
    SELECT
        co.customer_id,
        DATE_TRUNC('month', co.order_date) AS month_start_date,  -- Finding the first day of the month for each order
        COUNT(*) AS total_orders,
        SUM(co.total_order_revenue) AS total_revenue
    FROM customer_orders co
    GROUP BY co.customer_id, DATE_TRUNC('month', co.order_date)
),

monthly_customer_revenue_with_date_id AS (
    SELECT
        mcr.*,
        dd.date_id AS snapshot_date_id  -- Getting the date_id for the snapshot_date
    FROM monthly_customer_revenue mcr
    INNER JOIN {{ ref('dim_date') }} dd ON mcr.month_start_date = dd.date
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'snapshot_date_id']) }} AS clv_snapshot_key,
    customer_id,
    snapshot_date_id,
    total_orders,
    total_revenue,
    CASE WHEN total_orders > 0 THEN total_revenue / total_orders ELSE 0 END AS average_order_value
FROM monthly_customer_revenue_with_date_id
