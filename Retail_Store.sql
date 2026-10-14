CREATE DATABASE retail_store;
USE retail_store;

-- 1. Check the data Before Cleaning
-- 1.A> Preview the data
SELECT * FROM customer LIMIT 10;
SELECT * FROM transactions LIMIT 10;
SELECT * FROM prod_cat_info LIMIT 10;

-- 1.B> Check the number of records

SELECT COUNT(*) AS total_customers FROM customer;
SELECT COUNT(*) AS total_transactions FROM transactions;
SELECT COUNT(*) AS total_categories FROM prod_cat_info;

-- 2. Handling the MISSING VALUES
-- 2.A> For customer table

SELECT SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
SUM(CASE WHEN DOB IS NULL THEN 1 ELSE 0 END) AS missing_DOB,
SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
SUM(CASE WHEN city_code IS NULL THEN 1 ELSE 0 END) AS missing_city_code 
FROM customer; 

-- 2.B> For transactions table

SELECT SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS missing_transaction_id,
SUM(CASE WHEN cust_id IS NULL THEN 1 ELSE 0 END) AS missing_cust_id,
SUM(CASE WHEN tran_date IS NULL THEN 1 ELSE 0 END) AS missing_tran_date,
SUM(CASE WHEN prod_subcat_code IS NULL THEN 1 ELSE 0 END) AS missing_prod_subcat_code,
SUM(CASE WHEN prod_cat_code IS NULL THEN 1 ELSE 0 END) AS missing_prod_cat_code,
SUM(CASE WHEN Qty IS NULL THEN 1 ELSE 0 END) AS missing_Qty,
SUM(CASE WHEN Rate IS NULL THEN 1 ELSE 0 END) AS missing_Rate,
SUM(CASE WHEN Tax IS NULL THEN 1 ELSE 0 END) AS missing_Tax,
SUM(CASE WHEN total_amt IS NULL THEN 1 ELSE 0 END) AS missing_total_amt,
SUM(CASE WHEN Store_type IS NULL THEN 1 ELSE 0 END) AS missing_Store_type
FROM transactions;

-- 2.C> For prod_cat_info table

SELECT SUM(CASE WHEN prod_cat_code IS NULL THEN 1 ELSE 0 END) AS missing_prod_cat_code,
SUM(CASE WHEN prod_cat IS NULL THEN 1 ELSE 0 END) AS missing_prod_cat,
SUM(CASE WHEN prod_sub_cat_code IS NULL THEN 1 ELSE 0 END) AS missing_prod_sub_cat_code,
SUM(CASE WHEN prod_subcat IS NULL THEN 1 ELSE 0 END) AS missing_prod_subcat 
FROM prod_cat_info; 

-- 3. Check for DUPLICATE Records

SELECT
transaction_id, cust_id, tran_date, prod_cat_code, prod_subcat_code, Qty, Rate,Tax, total_amt, Store_type,
COUNT(*) AS duplicate_records
FROM transactions
GROUP BY
transaction_id, cust_id, tran_date, prod_cat_code, prod_subcat_code, Qty, Rate,Tax, total_amt, Store_type
HAVING COUNT(*) > 1 ;

-- 4. Removing DUPLICATE rows

DELETE FROM transactions
WHERE transaction_id IN(
SELECT transaction_id FROM
(SELECT transaction_id, ROW_NUMBER() OVER(PARTITION BY
transaction_id, cust_id, tran_date, prod_cat_code, prod_subcat_code, Qty, Rate,Tax, total_amt, Store_type
ORDER BY transaction_id) AS rn
FROM transactions)
AS duplicate_rows
WHERE rn > 1 );



-- 5. Change the format of the date as dd-mm-yyyy

SELECT tran_date AS old_date,
STR_TO_DATE(tran_date, '%d-%m-%y') AS converted_date
FROM transactions
LIMIT 20 ;

-- 6. ANALYSIS (EDA with SQL)

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

-- Q.13> Find the time range.

SELECT 
MIN(STR_TO_DATE(tran_date, '%d-%m-%y')) AS start_date,
MAX(STR_TO_DATE(tran_date, '%d-%m-%y')) AS end_date,
DATEDIFF(
MIN(STR_TO_DATE(tran_date, '%d-%m-%y')),
MAX(STR_TO_DATE(tran_date, '%d-%m-%y'))
)AS total_days,
TIMESTAMPDIFF(
MONTH,
MIN(STR_TO_DATE(tran_date, '%d-%m-%y')),
MAX(STR_TO_DATE(tran_date, '%d-%m-%y'))
)AS total_months,
TIMESTAMPDIFF(
YEAR,
MIN(STR_TO_DATE(tran_date, '%d-%m-%y')),
MAX(STR_TO_DATE(tran_date, '%d-%m-%y'))
)AS total_years

FROM transactions
WHERE STR_TO_DATE(tran_date, '%d-%m-%y') IS NOT NULL ;

-- Q.14> Find Month on Month Revenue.

WITH monthly_revenue AS(
SELECT
DATE_FORMAT(STR_TO_DATE(tran_date, '%d-%m-%y'), '%y-%m')
AS month,
SUM(total_amt) AS revenue
FROM transactions
WHERE STR_TO_DATE(tran_date, '%d-%m-%y') IS NOT NULL
GROUP BY DATE_FORMAT(STR_TO_FORMAT(tran_date, '%d-%m-%y'), '%y-%m')
),
revenue_comparision AS(
SELECT
month, revenue, LAG(revenue) OVER(ORDER BY month) AS previous_month_revenue
FROM monthly_revenue
)
SELECT
month, revenue, previous_month_revenue,
ROUND((revenue-previous_month_revenue)/NULLIF(previous_month_revenue,0)*100,2)
AS mom_growth_percentage
FROM revenue_comparison
ORDER BY month ;

-- Q.15> Calculate RFM values.

WITH customer_rfm AS(
SELECT cust_id,
MAX(STR_TO_DATE(tran_date, '%d-%m-%y')) AS last_purchase_date,
COUNT(DISTINCT transaction_id) AS frequency,
SUM(total_amt) AS monetary
FROM transactions
WHERE STR_TO_DATE(tran_date, '%d-%m-%y') IS NOT NULL
GROUP BY cust_id
)
SELECT cust_id, last_purchase_date,
DATEDIFF(
(SELECT MAX(STR_TO_DATE(tran_date, '%d-%m-%y')) FROM transactions),
last_purchase_date
) AS recency_days,
frequency,
ROUND(monetary,2) AS monetary
FROM customer_rfm
ORDER BY monetary DESC;
