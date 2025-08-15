-- 1. Customers Table
DROP TABLE IF EXISTS CUstomers;
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(25),
    address TEXT,
    registration_date DATE DEFAULT CURRENT_DATE
);
SELECT * FROM Customers;

-- 2. Restaurants Table
DROP TABLE IF EXISTS Restaurants;
CREATE TABLE Restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    rating DECIMAL(2,1),
    cuisine_type VARCHAR(50)
);
SELECT * FROM Restaurants;

-- 3. Menu Items Table
DROP TABLE IF EXISTS Menu_Items;
CREATE TABLE Menu_Items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);
SELECT * FROM Menu_Items;

-- 4. Delivery Person Table
DROP TABLE IF EXISTS Delivery_Person;
CREATE TABLE Delivery_Person (
    delivery_person_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(25),
    vehicle_type VARCHAR(50)
);
SELECT * FROM Delivery_Person;

-- 5. Orders Table
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id) ON DELETE CASCADE,
    restaurant_id INT REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    delivery_person_id INT REFERENCES Delivery_Person(delivery_person_id)
);
SELECT * FROM Orders;

-- 6. Order Details Table
DROP TABLE IF EXISTS Order_Details;
CREATE TABLE Order_Details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id) ON DELETE CASCADE,
    item_id INT REFERENCES Menu_Items(item_id) ON DELETE CASCADE,
    quantity INT NOT NULL
);
SELECT * FROM Order_Details;

-- 7. Payments Table
DROP TABLE IF EXISTS Payments;
CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(25),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT * FROM Payments;

-- Analytical Queries

-- Top 5 Most Ordered Items : 
SELECT mi.name, SUM(od.quantity) AS total_sold
FROM Order_Details od
JOIN Menu_Items mi ON od.item_id = mi.item_id
GROUP BY mi.name
ORDER BY total_sold DESC
LIMIT 5;

-- Restaurant with Highest Average Order Value : 
SELECT r.name, AVG(o.total_amount) AS avg_order_value
FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.name
ORDER BY avg_order_value DESC
LIMIT 5;

-- Most Active Customers : 
SELECT c.name, COUNT(o.order_id) AS total_orders
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.name
ORDER BY total_orders DESC
LIMIT 5;

-- Popular Payment Methods :
SELECT payment_method, COUNT(*) AS usage_count
FROM Payments
GROUP BY payment_method
ORDER BY usage_count DESC;

-- Highest-Priced Menu Item per Restaurant :
SELECT DISTINCT ON (restaurant_id) restaurant_id, name, price
FROM Menu_Items
ORDER BY restaurant_id, price DESC;

-- Day of the Week with Most Orders :
SELECT TO_CHAR(order_date, 'Day') AS day_of_week, COUNT(*) AS order_count
FROM Orders
GROUP BY day_of_week
ORDER BY order_count DESC;

-- Customer Retention Rate (Month to Month) :
WITH monthly_customers AS (
  SELECT DATE_TRUNC('month', order_date) AS month, customer_id
  FROM Orders
  GROUP BY month, customer_id
)
SELECT curr.month, 
       ROUND(100.0 * COUNT(DISTINCT curr.customer_id) 
       / NULLIF(COUNT(DISTINCT prev.customer_id), 0), 2) AS retention_rate
FROM monthly_customers curr
LEFT JOIN monthly_customers prev 
  ON curr.customer_id = prev.customer_id
 AND curr.month = prev.month + INTERVAL '1 month'
GROUP BY curr.month
ORDER BY curr.month;


