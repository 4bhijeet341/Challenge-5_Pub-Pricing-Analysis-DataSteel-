CREATE TABLE pubs (
pub_id INT PRIMARY KEY,
pub_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50)
);
--------------------
-- Create the 'beverages' table
CREATE TABLE beverages (
beverage_id INT PRIMARY KEY,
beverage_name VARCHAR(50),
category VARCHAR(50),
alcohol_content FLOAT,
price_per_unit DECIMAL(8, 2)
);
--------------------
-- Create the 'sales' table
CREATE TABLE sales (
sale_id INT PRIMARY KEY,
pub_id INT,
beverage_id INT,
quantity INT,
transaction_date DATE,
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id),
FOREIGN KEY (beverage_id) REFERENCES beverages(beverage_id)
);
--------------------
-- Create the 'ratings' table CREATE TABLE ratings ( rating_id INT PRIMARY KEY, pub_id INT, customer_name VARCHAR(50), rating FLOAT, review TEXT, FOREIGN KEY (pub_id) REFERENCES pubs(pub_id) );
--------------------
-- Insert sample data into the 'pubs' table
INSERT INTO pubs (pub_id, pub_name, city, state, country)
VALUES
(1, 'The Red Lion', 'London', 'England', 'United Kingdom'),
(2, 'The Dubliner', 'Dublin', 'Dublin', 'Ireland'),
(3, 'The Cheers Bar', 'Boston', 'Massachusetts', 'United States'),
(4, 'La Cerveceria', 'Barcelona', 'Catalonia', 'Spain');
--------------------
-- Insert sample data into the 'beverages' table
INSERT INTO beverages (beverage_id, beverage_name, category, alcohol_content, price_per_unit)
VALUES
(1, 'Guinness', 'Beer', 4.2, 5.99),
(2, 'Jameson', 'Whiskey', 40.0, 29.99),
(3, 'Mojito', 'Cocktail', 12.0, 8.99),
(4, 'Chardonnay', 'Wine', 13.5, 12.99),
(5, 'IPA', 'Beer', 6.8, 4.99),
(6, 'Tequila', 'Spirit', 38.0, 24.99);
--------------------
INSERT INTO sales (sale_id, pub_id, beverage_id, quantity, transaction_date)
VALUES
(1, 1, 1, 10, '2023-05-01'),
(2, 1, 2, 5, '2023-05-01'),
(3, 2, 1, 8, '2023-05-01'),
(4, 3, 3, 12, '2023-05-02'),
(5, 4, 4, 3, '2023-05-02'),
(6, 4, 6, 6, '2023-05-03'),
(7, 2, 3, 6, '2023-05-03'),
(8, 3, 1, 15, '2023-05-03'),
(9, 3, 4, 7, '2023-05-03'),
(10, 4, 1, 10, '2023-05-04'),
(11, 1, 3, 5, '2023-05-06'),
(12, 2, 2, 3, '2023-05-09'),
(13, 2, 5, 9, '2023-05-09'),
(14, 3, 6, 4, '2023-05-09'),
(15, 4, 3, 7, '2023-05-09'),
(16, 4, 4, 2, '2023-05-09'),
(17, 1, 4, 6, '2023-05-11'),
(18, 1, 6, 8, '2023-05-11'),
(19, 2, 1, 12, '2023-05-12'),
(20, 3, 5, 5, '2023-05-13');
--------------------
-- Insert sample data into the 'ratings' table
INSERT INTO ratings (rating_id, pub_id, customer_name, rating, review)
VALUES
(1, 1, 'John Smith', 4.5, 'Great pub with a wide selection of beers.'),
(2, 1, 'Emma Johnson', 4.8, 'Excellent service and cozy atmosphere.'),
(3, 2, 'Michael Brown', 4.2, 'Authentic atmosphere and great beers.'),
(4, 3, 'Sophia Davis', 4.6, 'The cocktails were amazing! Will definitely come back.'),
(5, 4, 'Oliver Wilson', 4.9, 'The wine selection here is outstanding.'),
(6, 4, 'Isabella Moore', 4.3, 'Had a great time trying different spirits.'),
(7, 1, 'Sophia Davis', 4.7, 'Loved the pub food! Great ambiance.'),
(8, 2, 'Ethan Johnson', 4.5, 'A good place to hang out with friends.'),
(9, 2, 'Olivia Taylor', 4.1, 'The whiskey tasting experience was fantastic.'),
(10, 3, 'William Miller', 4.4, 'Friendly staff and live music on weekends.');
--------------------

--Questions&Answers--

--1. How many pubs are located in each country??
SELECT country, COUNT(pub_id) as pub_count
FROM pubs
GROUP BY country
--
--2. What is the total sales amount for each pub, including the beverage price and quantity sold?
WITH sales_quantity as(
  SELECT p.pub_name, (s.quantity * b.price_per_unit) as sales
  FROM sales s
  INNER JOIN beverages b on s.beverage_id = b.beverage_id
  INNER JOIN pubs p on p.pub_id = s.pub_id)
  
SELECT pub_name, SUM(sales) as total_sales
FROM sales_quantity
GROUP BY pub_name
ORDER BY total_sales DESC;
--
--3. Which pub has the highest average rating?
WITH highest_avg_rating_pub as(
  SELECT p.pub_name as pub_name,
  ROUND(AVG(r.rating:: DECIMAL),2) as avg_rating,
  DENSE_RANK() OVER(ORDER BY AVG(r.rating) DESC) as drnk
  FROM pubs p
  INNER JOIN ratings r ON p.pub_id = r.pub_id
  GROUP BY p.pub_name)
  
SELECT pub_name, avg_rating
FROM highest_avg_rating_pub
WHERE drnk = 1;
--
--4. What are the top 5 beverages by sales quantity across all pubs?
WITH beverages_sales_quantity as(
	SELECT b.beverage_name as beverage,
  	SUM(s.quantity) as quantity,
  	DENSE_RANK() OVER(ORDER BY SUM(s.quantity) DESC) as drnk
  	FROM beverages b
  	INNER JOIN sales s ON b.beverage_id = s.beverage_id
  	GROUP BY b.beverage_name)
    
SELECT beverage, quantity
FROM beverages_sales_quantity
WHERE drnk <= 5
--
--5. How many sales transactions occurred on each date?
SELECT COUNT(sale_id) as transactions, transaction_date
FROM sales
GROUP BY transaction_date
ORDER BY transaction_date;
--
--6. Find the name of someone that had cocktails and which pub they had it in.
SELECT r.customer_name, p.pub_name
FROM sales s
INNER JOIN beverages b ON s.beverage_id = b.beverage_id
INNER JOIN ratings r ON r.pub_id = s.pub_id
INNER JOIN pubs p ON p.pub_id = r.pub_id
AND b.category = 'Cocktail';
--
--7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?
SELECT category,ROUND(AVG(price_per_unit),2) as avg_price_per_unit
FROM beverages
WHERE category != 'Spirit'
GROUP BY category
--
--8. Which pubs have a rating higher than the average rating of all pubs?
  SELECT p.pub_id, p.pub_name, 
  ROUND(AVG(r.rating:: DECIMAL),2) as avg_rating
  FROM pubs p
  INNER JOIN ratings r ON p.pub_id = r.pub_id
  GROUP BY p.pub_id
  HAVING ROUND(AVG(r.rating:: DECIMAL),2) > 
  (SELECT ROUND(AVG(rating:: DECIMAL),2)
  FROM ratings);
--
--9. What is the running total of sales amount for each pub, ordered by the transaction date?
SELECT p.pub_id,p.pub_name,s.transaction_date,
SUM(s.quantity * b.price_per_unit) OVER(PARTITION BY p.pub_name ORDER BY s.transaction_date) as sales
FROM pubs p
INNER JOIN sales s ON p.pub_id = s.pub_id
INNER JOIN beverages b ON b.beverage_id = s.beverage_id
ORDER BY p.pub_id, s.transaction_date
--
--10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?

WITH CTEA as(
  SELECT p.country,
  b.category, 
  ROUND(AVG(b.price_per_unit),2) as avg_price_per_cat
  FROM sales s
  INNER JOIN pubs p ON s.pub_id = p.pub_id
  INNER JOIN beverages b ON b.beverage_id = s.beverage_id
  GROUP BY p.country, b.category)

,CTEB as(
  SELECT p.country,
  ROUND(AVG(b.price_per_unit),2) as avg_price_overall
  FROM sales s
  INNER JOIN pubs p ON s.pub_id = p.pub_id
  INNER JOIN beverages b ON b.beverage_id = s.beverage_id
  GROUP BY p.country)
  
SELECT 
CTEA.country, CTEA.category, CTEA.avg_price_per_cat, CTEB.avg_price_overall
FROM CTEA
INNER JOIN CTEB ON CTEA.country = CTEB.country
ORDER BY country, category;
--

--11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?
WITH overall_bev_sales as(
	SELECT p.pub_id, 
        p.pub_name, 
        SUM(s.quantity * b.price_per_unit) as overall_bev_sales
  	FROM sales s
  	INNER JOIN pubs p ON s.pub_id = p.pub_id
  	INNER JOIN beverages b ON b.beverage_id = s.beverage_id
  	GROUP BY p.pub_id)
    
, sales_category as(
  	SELECT p.pub_id, p.pub_name, b.category,
  	SUM(s.quantity * b.price_per_unit) as category_sales
  	FROM sales s
	INNER JOIN pubs p ON s.pub_id = p.pub_id
  	INNER JOIN beverages b ON b.beverage_id = s.beverage_id
  	GROUP BY p.pub_id,p.pub_name, b.category)
    
SELECT obs.pub_id, obs.pub_name,
               obs.overall_bev_sales,
               sc.category,
               sc.category_sales,
              ROUND((sc.category_sales/obs.overall_bev_sales) * 100 ,2) as percent_contribution
FROM overall_bev_sales obs
INNER JOIN sales_category sc 
ON obs.pub_id = sc.pub_id
GROUP BY obs.pub_id, obs.pub_name,obs.overall_bev_sales, sc.category, sc.category_sales
ORDER BY obs.pub_id