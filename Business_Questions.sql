-- Business Question 1:
-- Which product categories generate the most revenue?

SELECT 
    t.product_category_name_english AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'  -- Only counting successful sales
GROUP BY t.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- Business Question 2:
-- Which states/regions are underperforming or generating the most sales?

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- Business Question 3: 
-- Delivery Performance & Bottlenecks

USE olist_ecommerce;

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    -- 1. Calculate the average actual delivery time in days
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days,
    -- 2. Calculate the average estimated delivery time promised to the customer
    ROUND(AVG(DATEDIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp)), 1) AS avg_estimated_days,
    -- 3. Total number of delayed orders
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS delayed_orders,
    -- 4. Percentage of orders that arrived late
    ROUND((SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(DISTINCT o.order_id)) * 100, 2) AS pct_delayed
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 10;

-- Business Question 4:
-- Customer Satisfaction & Review Analysis
USE olist_ecommerce;

SELECT 
    o.order_status,
    r.review_score,
    COUNT(DISTINCT o.order_id) AS total_orders,
    -- Calculate average delay for each score tier
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days,
    -- See how far past the estimate the worst deliveries went
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 1) AS avg_days_over_estimate
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score DESC;