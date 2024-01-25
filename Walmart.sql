CREATE DATABASE IF NOT EXISTS salesDataWalmart;

USE salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12,4) NOT NULL,
rating FLOAT(2,1)
);


--------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Feature Engineering ---------------------------------------------

-- time of the day

SELECT 
	time,
    (CASE 
		WHEN   `time`    BETWEEN "00:00:00" AND "12:00:00" THEN "Mornging"
        WHEN   `time`    BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
	)AS time_of_date
FROM sales;  


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20); -- Here I have added a new feature column in a table 

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);




-- day name
SELECT 
	DATE,
    DAYNAME(DATE)
FROM sales;
	
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- month name
SELECT
	date,
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

--------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- Generic -----------------------------------------------------

-- 1. How many unique cities does the data have ?

SELECT COUNT(DISTINCT(city)) as Number_of_cities
FROM sales;


-- 2. In which city is each branch ?
SELECT DISTINCT branch
FROM sales;

SELECT 
	DISTINCT city,
    branch
FROM sales;


--------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- Product -------------------------------------------

-- 1. How many unique product lines does the data have ?

SELECT 
	COUNT(DISTINCT product_line) as number_of_product_lines
FROM sales;


-- 2. What is the most common payment method ?
SELECT 
	payment_method,
	COUNT(payment_method) as ctn
FROM sales
GROUP BY payment_method
ORDER BY COUNT(*) DESC;

-- 3. What is the most selling product line ?

/* In youtube video this was the query */
SELECT 
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY COUNT(product_line) DESC;


SELECT 
	product_line,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_line
ORDER BY total_quantity DESC;


-- 4. What is the total revenue by month ?

SELECT 
	DISTINCT YEAR(date)
FROM sales;

SELECT 
	DISTINCT month_name
FROM sales;

SELECT 
	month_name,
    SUM(total) as total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;


-- 5. What month had the largest COGS ?
SELECT 
	month_name
    ,SUM(COGS) AS monthly_COGS
FROM sales
GROUP BY month_name
ORDER BY SUM(COGS) DESC;

-- 6. What product line had the largest revenue ?
SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 7. What is the city with largest revenue ?
SELECT
	branch,
    city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city,branch
ORDER BY total_revenue DESC;

-- 8. What product line had the largest VAT ?
SELECT 
	product_line,
    SUM(VAT) AS total_VAT
FROM sales
GROUP BY product_line
ORDER BY total_VAT DESC;


--  9. Fetch each product line and add a column to those product line showing "Good", "Bad".Good if it's better than average sales. 
/*SELECT 
	product_line,
    AVG(
FROM sales
GROUP BY product_line */


-- 10. which branch sold more products than average product sold ?
SELECT
	branch,
    SUM(quantity) AS total_sold
FROM sales
GROUP BY branch
HAVING SUM(quantity) > ( SELECT AVG(quantity) FROM sales)   
ORDER BY total_sold DESC ;
    
    
-- 11. What is the most comman product line by gender ?
SELECT 
	gender,
    product_line,
	COUNT(product_line) as cnt
FROM sales
GROUP BY  gender, product_line
ORDER BY gender,COUNT(product_line) DESC;


-- 12. What is the average rating of each product line ?
SELECT 
	product_line,
	ROUND(AVG(rating),2) AS average_rating
FROM sales
GROUP BY product_line;

--------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------- Sales -----------------------------------------------

-- 1. numbaer of sales mad in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY total_Sales DESC;

-- 2.  Which of the customer types brings the most revenue ?
SELECT 
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;
	

-- 3.  Which city has the largest tax percnentage/ VAT (Value Added Tax) ?
SELECT 
	city,
    SUM(VAT) as tax
FROM sales
GROUP BY city
ORDER BY tax DESC;

-- 4.  Which customer type pays the most in VAT ?
SELECT 
	customer_type,
    SUM(VAT) as tax
FROM sales 
GROUP BY customer_type
ORDER BY tax DESC;

----------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------- Customer ------------------------------------------------------

-- 1. How many unique type customer does the data have ?

SELECT
	 count(Distinct customer_type) AS number_of_unique_customer_type
FROM sales;

-- 2. How many unique payment method does the data have ? 
SELECT
	 count(Distinct payment_method) AS number_of_unique_customer_type
FROM sales;


-- 3. What is the most common customer type ?
SELECT 
	COUNT(*) AS most_common_customer_type
FROM sales
GROUP BY customer_type
ORDER BY most_common_customer_type DESC;


-- 5. what is the gender of most of the customers ?
SELECT 
	gender,
    count(*) as number_of_customer
FROM sales
GROUP BY gender
ORDER BY number_of_customer DESC;


-- 6. what is the gender distribution per branch ?
SELECT
	branch,
    gender,
    COUNT(gender)
FROM sales
GROUP BY branch,gender
ORDER BY branch,gender;


-- 7. which time of the day do customers gives most ratings ?
SELECT
	time_of_day,
    SUM(rating) as total_rating
FROM sales
GROUP BY time_of_day
ORDER BY total_rating DESC;


SELECT 
		time_of_day,
        AVG(rating) AS average_rating
FROM sales 
GROUP BY time_of_day
ORDER BY average_rating DESC;

-- 8. which time of the day do customers give most ratings per branch ?
SELECT 
	branch,
	time_of_day,
    SUM(rating) AS total_rating
FROM sales
GROUP BY branch,time_of_day
ORDER BY branch,total_rating DESC;


-- 9. which day of the week has the best avg rating ? 
SELECT 
	day_name,
    AVG(rating) AS average_ratings
FROM sales
GROUP BY day_name
ORDER BY average_ratings DESC;

-- 10. which day of the week has the best avg rating per branch ?
SELECT 
	branch,
	day_name,
    AVG(rating) AS average_ratings
FROM sales
GROUP BY branch,day_name
ORDER BY branch, average_ratings DESC;

	
    
