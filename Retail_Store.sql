CREATE DATABASE retail_store;
USE retail_store;
SELECT * FROM customer;
DESCRIBE customer;

SELECT * FROM transactions;

SELECT * FROM prod_cat_info;

# Change the format of the date as dd-mm-yyyy
SELECT DATE_FORMAT(DOB, '%d%m%y') AS formatted_date
FROM customer;

SELECT date_format(tran_date, '%d%m%y') AS formatted_date
FROM transactions;


SELECT * FROM customer
WHERE customer_Id IS NULL
OR DOB IS NULL
OR Gender IS NULL 
OR city_code IS NULL;

-- Q.1> Finding the total number of rows in 3 tables each in the database 

SELECT 'customers' AS TABLE_NAME, COUNT(*) AS total_record FROM Customer
UNION ALL
SELECT 'prod_cat_info' AS TABLE_NAME,COUNT(*) AS total_record FROM  prod_cat_info
UNION ALL
SELECT 'transactions' AS TABLE_NAME,COUNT(*) AS total_record FROM transactions
UNION ALL
SELECT 'grand_total' AS TABLE_NAME, SUM(total_record) FROM 
(SELECT 'Customer' AS TABLE_NAME, COUNT(*) AS total_record FROM Customer
UNION ALL
SELECT 'prod_cat_info' AS TABLE_NAME,COUNT(*) AS total_record FROM  prod_cat_info
UNION ALL
SELECT 'transactions' AS TABLE_NAME,COUNT(*) AS total_record FROM transactions) AS T1;

-- Q.2> Find Gross-Sales from transactions

SELECT SUM(total_amt) AS gross_sales
FROM transactions
WHERE Qty > 0 ; 

-- Q.3> Find Returns from transactoins table

SELECT COUNT(DISTINCT transaction_id) AS total_return_transactions 
FROM transactions
WHERE Qty < 0 ;

-- Q.4> Find  the net revenue

SELECT SUM(total_amt) AS net_revenue
FROM transactions;

-- Q.5> Revenue trending by year

SELECT YEAR(STR_TO_DATE(tran_date, '%d-%m-%y')) AS year,
SUM(total_amt) AS net_revenue
FROM transactions
GROUP BY YEAR(STR_TO_DATE(tran_date, '%d-%m-%y'))
ORDER BY year;
-- Q.6> Which CHANNEL earns the most ?

SELECT store_type AS channel,
SUM(total_amt) AS net_revenue
FROM transactions
GROUP BY store_type
ORDER BY net_revenue DESC 
LIMIT 1 ;

-- Q.7> Which CATEGORY earns the most ?

SELECT p.prod_cat AS category,
SUM(t.total_amt) AS net_revenue
FROM transactions t
JOIN prod_cat_info p ON t.prod_cat_code = p.prod_cat_code
GROUP BY p.prod_cat
ORDER BY net_revenue DESC 
LIMIT 1 ; 

-- Q.8> Which SUBCATEGORY earns the most ?

SELECT p.prod_subcat AS subcategory,
SUM(t.total_amt) AS net_revenue
FROM transactions t
JOIN prod_cat_info p ON t.prod_cat_code = p.prod_cat_code
GROUP BY p.prod_subcat
ORDER BY net_revenue DESC
LIMIt 1 ; 

-- Q.9> Which Customers are the most valuable according to gender ?

SELECT c.gender AS gender,
SUM(total_amt) AS net_revenue
FROM transactions t
JOIN customer c ON t.cust_id = c.customer_id
GROUP BY c.gender
ORDER BY net_revenue desc
limit 1 ;

-- Q.10> Which Customers are the most valuable according to city ?

SELECT c.city_code AS city,
SUM(total_amt) AS net_revenue
FROM transactions t
JOIN customer c ON t.cust_id = c.customer_id
GROUP BY city
ORDER BY net_revenue desc
limit 1 ;

-- Q.11> Which Customers are the most valuable according to age ?

SELECT CASE
WHEN timestampdiff(YEAR, c.DOB, CURDATE()) BETWEEN 18 AND 29
THEN '18-29'
WHEN timestampdiff(YEAR, c.DOB, CURDATE()) BETWEEN 30 AND 39
THEN '30-39'
WHEN timestampdiff(YEAR, c.DOB, CURDATE()) BETWEEN 40 AND 49
THEN '40-49'
WHEN timestampdiff(YEAR, c.DOB, CURDATE()) BETWEEN 50 AND 59
THEN '50-59'
ELSE 'Other'
END AS age_group,
SUM(total_amt) AS net_revenue
FROM transactions t
JOIN customer c ON t.cust_id = c.customer_id
GROUP BY age_group
ORDER BY net_revenue desc
limit 1 ;

-- Q.12> Where are return rates highest by product category?

SELECT
p.prod_cat AS category,
COUNT(DISTINCT CASE
WHEN t.Qty < 0 THEN transaction_id END) AS return_transactions,
COUNT(DISTINCT t.transaction_id) AS total_transactions,
ROUND(100.0*COUNT(DISTINCT CASE WHEN t.Qty < 0 THEN t.transaction_id END) / NULLIF(COUNT(DISTINCT t.transaction_id),0),2)
AS return_rate_pct
FROM transactions t
JOIN prod_cat_info p
ON t.prod_cat_code = p.prod_cat_code
GROUP BY category
ORDER BY return_rate_pct DESC
LIMIT 1 ;
