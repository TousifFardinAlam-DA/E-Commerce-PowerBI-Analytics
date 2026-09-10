USE olist_ecommerce;
-- ================================================================
-- 1. Finding & Handling Missing Values
-- exactly how many orders didn't get a delivery date or approval timestamp.
-- in orders table
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    SUM(CASE
		   WHEN order_approved_at IS NULL
	           THEN 1 ELSE 0 END) AS missing_approval,
    SUM(CASE
           WHEN order_delivered_customer_date IS NULL 
			   THEN 1 ELSE 0 END) AS missing_delivery
FROM orders
GROUP BY order_status;

-- ===================================================================
-- 2. Calculating Core Business KPIs (Revenue & Orders)
/* 2.1 Total Revenue (Sum of item prices),
   2.2 Total Freight (Shipping costs paid by customers),
   2.3 Total Orders,
   2.4 Average Order Value (AOV). */
SELECT 
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM order_items;

-- ==========================================================================
-- 3. Top Revenue-Driving Product Categories
SELECT 
    p.product_category_name,
    COUNT(oi.product_id) AS items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_revenue DESC LIMIT 10;

-- ======================================================================
-- 4. Regional Analysis (Underperforming Areas)
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- ======================================================
-- 5. Payment Preferences & Customer Behavior
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_paid,
    ROUND(AVG(payment_value), 2) AS avg_transaction_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_paid DESC;
