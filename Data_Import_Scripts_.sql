CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;
-- 1. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
select * from customers;
-- 2. Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT, -- Note: Kaggle dataset spans typo 'lenght'
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 3. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- 4. Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- 5. Order Payments Table
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10, 2)
);

-- Loading .csv files directly from folder path 
-- 1. Load Customers
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Analytics_Project_Olist/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
select count(*) from customers;
-- 2. Load Products
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Analytics_Project_Olist/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, @v_cat_name, @v_name_len, @v_desc_len, @v_photo_qty, @v_weight, @v_length, @v_height, @v_width)
SET 
product_category_name = NULLIF(@v_cat_name, ''),
product_name_lenght = NULLIF(@v_name_len, ''),
product_description_lenght = NULLIF(@v_desc_len, ''),
product_photos_qty = NULLIF(@v_photo_qty, ''),
product_weight_g = NULLIF(@v_weight, ''),
product_length_cm = NULLIF(@v_length, ''),
product_height_cm = NULLIF(@v_height, ''),
product_width_cm = NULLIF(@v_width, '');

-- 3. Load Order Items
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Analytics_Project_Olist/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 4. Load Order Payments
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Analytics_Project_Olist/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Load Orders 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce_Analytics_Project_Olist/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, @v_pur, @v_app, @v_car, @v_del, @v_est)
SET 
order_purchase_timestamp = NULLIF(@v_pur, ''),
order_approved_at = NULLIF(@v_app, ''),
order_delivered_carrier_date = NULLIF(@v_car, ''),
order_delivered_customer_date = NULLIF(@v_del, ''),
order_estimated_delivery_date = NULLIF(@v_est, '');

-- Total number of rows in each table
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;