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
        customer_id,
        DATE_TRUNC('month', order_date) AS snapshot_date,
        COUNT(*) AS total_orders,
        SUM(total_order_revenue) AS total_revenue
    FROM customer_orders
    GROUP BY customer_id, DATE_TRUNC('month', order_date)
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'snapshot_date']) }} AS clv_snapshot_key,
    customer_id,
    snapshot_date,
    total_orders,
    total_revenue,
    CASE WHEN total_orders > 0 THEN total_revenue / total_orders ELSE 0 END AS average_order_value
FROM monthly_customer_revenue
