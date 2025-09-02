SELECT * FROM orders;

-- Data Analysis

-- Find Top 10 highest revenue generating products
SELECT
	product_id,
	SUM(sale_price) AS sales
FROM orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- Find top 5 highest selling products in each region
WITH cte AS(
SELECT
	region,
	product_id,
	SUM(quantity) AS total_quantity,
	ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(quantity) DESC) AS rn
FROM orders
GROUP BY region, product_id
) 
SELECT * 
FROM cte
WHERE rn <= 5;

-- Find month over month growth comparison for 2022 and 2023 sales
SELECT
	EXTRACT(YEAR FROM order_date) AS order_year,
	EXTRACT(MONTH FROM order_date) AS order_month,
	SUM(sale_price) AS sales
FROM orders
GROUP BY 
	GROUPING SETS(
		(order_year, order_month)
	)
ORDER BY order_month ASC, order_year ASC;

-- For each category which month had highest sales
WITH cte AS(
SELECT
	category,
	EXTRACT(MONTH FROM order_date) AS order_month,
	EXTRACT(YEAR FROM order_date) AS order_year,
	SUM(sale_price) AS sales,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) AS rn
FROM orders
GROUP BY category, order_month, order_year
ORDER BY order_month
)
SELECT
	*
FROM cte
WHERE rn = 1
ORDER BY sales DESC;

-- Which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS(
SELECT
	sub_category,
	EXTRACT(YEAR FROM order_date) AS order_year,
	SUM(profit) AS profit
FROM orders
GROUP BY sub_category,order_year
), cte2 AS(
SELECT 
	sub_category,
	SUM(CASE WHEN order_year = 2022 THEN profit ELSE 0 END) AS profit_2022,
	SUM(CASE WHEN order_year = 2023 THEN profit ELSE 0 END) AS profit_2023
FROM cte
GROUP BY sub_category
)
SELECT 
	*,
	(profit_2023 - profit_2022) * 100 / profit_2022 AS diff_profit
FROM cte2
ORDER BY diff_profit DESC
LIMIT 1;




