USE amazon_sales_data;

-- Data Cleaning

SELECT *
FROM amazonsales;

SELECT count(*)
FROM amazonsales;

CREATE TABLE amazonsales_staging AS
select *
FROM amazonsales;

SELECT *
FROM amazonsales_staging;

SELECT count(*)
FROM amazonsales_staging;

DESCRIBE amazonsales_staging;

SELECT `Order ID`, COUNT(*)
FROM amazonsales_staging
GROUP BY `Order ID`
HAVING COUNT(*) > 1;

SELECT `ship-country`
FROM amazonsales_staging
GROUP BY `ship-country`;

-- Deleting Unwanted columns

ALTER TABLE amazonsales_staging
DROP COLUMN ASIN,
DROP COLUMN SKU,
DROP COLUMN `promotion-ids`,
DROP COLUMN `fulfilled-by`,
DROP COLUMN currency,
DROP COLUMN `ship-postal-code`,
DROP COLUMN `ship-country`;

SHOW COLUMNS
FROM amazonsales_staging;

ALTER TABLE amazonsales_staging
DROP COLUMN `index`,
DROP COLUMN `Unnamed: 22`;

SELECT DISTINCT Category
FROM amazonsales_staging
GROUP BY Category;

-- Standardizing the data

SELECT *
FROM amazonsales_staging;

ALTER TABLE amazonsales_staging
CHANGE COLUMN `Order ID` order_id VARCHAR(50),
CHANGE COLUMN `Sales Channel` sales_channel VARCHAR(50),
CHANGE COLUMN `ship-service-level` ship_service_level VARCHAR(50),
CHANGE COLUMN `Courier Status` courier_status VARCHAR(50),
CHANGE COLUMN `ship-city` ship_city VARCHAR(50),
CHANGE COLUMN `ship-state` ship_state VARCHAR(50);

UPDATE amazonsales_staging
SET `Date` = STR_TO_DATE(`Date`, '%m-%d-%Y');

ALTER TABLE amazonsales_staging
MODIFY COLUMN `Date` DATE;

ALTER TABLE amazonsales_staging
MODIFY COLUMN `Amount`  DECIMAL(10,2);

SHOW COLUMNS
FROM amazonsales_staging;

-- Handling missing/Null values

SELECT Status, courier_status
FROM amazonsales_staging
GROUP BY Status, courier_status;

UPDATE amazonsales_staging
SET courier_status = 'Unshipped'
WHERE courier_status iS NULL OR courier_status = '';

## Exploratory Data Analysis

SELECT *
FROM amazonsales_staging;

-- Sales overview
SELECT SUM(Amount) AS total_revenue
FROM amazonsales_staging;

SELECT Count(order_id) AS total_orders
FROM amazonsales_staging;

SELECT AVG(Amount) AS Avg_order_value
FROM amazonsales_staging;

-- Time Based Analysis
SELECT `Date`, SUM(Amount) AS Revenue
FROM amazonsales_staging
GROUP BY `Date`
ORDER BY Revenue DESC;

-- Product Analysis
SELECT Category, SUM(Qty) AS total_units, SUM(Amount) AS Revenue
FROM amazonsales_staging
GROUP BY Category
ORDER BY Revenue DESC;

-- Order & Delivery Analysis
SELECT Status, COUNT(*)
FROM amazonsales_staging
GROUP BY Status;

SELECT courier_status, COUNT(*)
FROM amazonsales_staging
GROUP BY courier_status;

-- Geographic Analysis
SELECT ship_state, SUM(Amount) AS Revenue
FROM amazonsales_staging
GROUP BY ship_state
ORDER BY Revenue DESC;

SELECT ship_city, SUM(Amount) AS Revenue
FROM amazonsales_staging
GROUP BY ship_city
ORDER BY Revenue DESC;

-- Business Insights
SELECT B2B, COUNT(*) AS orders, SUM(Amount) AS revenue
FROM amazonsales_staging
GROUP BY B2B;

SELECT Fulfilment, COUNT(*)
FROM amazonsales_staging
GROUP BY Fulfilment;

SELECT ship_service_level, COUNT(*)
FROM amazonsales_staging
GROUP BY ship_service_level;

-- Cancellation Rate
SELECT (SUM(CASE WHEN `Status` LIKE '%Cancel%' THEN 1 ELSE 0 END)/COUNT(*)) * 100 AS Cancel_rate
FROM amazonsales_staging;

-- Ranking as per orders delivered
SELECT ship_state, COUNT(DISTINCT order_id) AS delivered_orders, 
      RANK()OVER(ORDER BY COUNT(DISTINCT order_id) DESC) AS Ranking
FROM amazonsales_staging
WHERE `Status` LIKE '%Deliver%'
GROUP BY ship_state;   
	


















