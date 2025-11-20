drop table if exists Zepto;

create table Zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);

-- DATA EXPLORATION

--Check number of rows
SELECT COUNT(*)
FROM Zepto;

--View the first 10 rows of the dataset
SELECT *
FROM Zepto
LIMIT 10;


--Looking for null  values
SELECT *
FROM Zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--Exploring all the different product categories
SELECT DISTINCT category
FROM Zepto
ORDER BY category;


--Checking products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM Zepto
GROUP BY outOfStock;

--Checking product names present multiple times
SELECT name, COUNT(sku_id) as "Stock Keeping Units"
FROM Zepto
GROUP BY name
HAVING count(sku_id)>1
ORDER BY count(sku_id)DESC;


--DATA CLEANING

--Checking for products where maximum retail price might be zero.
SELECT *
FROM Zepto
WHERE mrp = 0 
OR discountedSellingPrice = 0;

--A product has been found to contain zero as it's mrp thus  it has to be deleted

DELETE
FROM Zepto
WHERE mrp = 0;

--Converting paise to rupees
UPDATE Zepto
SET mrp=mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0;

--Checking if mrp and sellected sellingprice are updated
SELECT mrp, discountedSellingPrice
FROM Zepto
LIMIT 5;

--BUSINESS INSIGHTS:
--1: Find the top 10 best-value products on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM Zepto
ORDER BY discountPercent DESC
LIMIT 10;
   --This is useful for customers to know the burgains and for businesses to identify products being heavily promoted.


--2: What are the products with high mrp but OutOfStock?
SELECT DISTINCT name, mrp
FROM Zepto
WHERE outOfStock=TRUE
AND mrp>300
ORDER BY mrp DESC;
   --This helps the company know products that are being bought frequently thus enabling them to restock preventing loss in revenue.


--3: Calculate the estimated revenue for each category.
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM Zepto
GROUP BY category
ORDER BY total_revenue;


--4: Find all the products where mrp is greater tha 500 rupees and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM Zepto
WHERE mrp > 500 
AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;


--5: Identify the top 5 categories offering the highest average discount percentage.
SELECT category, 
ROUND(AVG(discountPercent),2) as avg_discount
FROM Zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

   --Useful in marketing teams to understand where most price cuts happen and how they can optimise them accordingly. 
   

--6: Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM Zepto
WHERE weightInGms >=100
ORDER BY price_per_gram;



--7: Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN  weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM Zepto;
   --Gooc for delivery planning.


--8: What is the total inventory weight Per Category?
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM Zepto
GROUP BY category
ORDER BY total_weight DESC;
   --Great for warehouse planning