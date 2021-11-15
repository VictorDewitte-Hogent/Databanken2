/** Statistical functions **/

-- SUM
-- Give the total stock value
SELECT SUM(UnitsInStock * UnitPrice) as InventoryValue
FROM Products

-- AVG
-- What is the average number of products in stock?
SELECT AVG(UnitsInStock) AS AverageStock 
FROM Products

-- COUNT
-- Returns the number of rows, or a number of NOT NULL values in a column
-- Count the number of products (= all rows)
SELECT COUNT(*) as NumberOfProducts
FROM Products

-- Count the number of NOT NULL values in column CategoryID
SELECT COUNT(CategoryID) as NumberOfCategoryID
FROM Products

-- Count the number of different NOT NULL values in column CategoryID
SELECT COUNT(DISTINCT CategoryID) as NumberOfCategoryID
FROM Products

-- MIN and MAX
-- What is the cheapest and most expensive unit price?
SELECT MIN(UnitPrice) AS Minimum, MAX(UnitPrice) AS Maximum 
FROM Products

-- TOP !!Be aware
-- Select the top 5 of the cheapest products
SELECT TOP 5 ProductID, UnitPrice
FROM Products
ORDER BY UnitPrice

-- Select the 5 most expensive products
SELECT TOP 5 ProductID, UnitPrice
FROM Products
ORDER BY UnitPrice DESC

/** GROUP BY **/
/**
GROUP BY clause : 
- The table is divided into groups of rows with common characteristics.
- Per group one unique row!
- For each group statistical functions can be applied. 
- The column names (or grouping criteria) mentioned in the GROUP BY clause can also appear in the SELECT clause
**/

-- Show the number of products per category
SELECT CategoryID, COUNT(ProductID) As NumberOfProductsPerCategory
FROM Products
GROUP BY CategoryID

-- Show per category the number of products with UnitPrice > 15
SELECT CategoryID, COUNT(ProductID) As NumberOfProductsPerCategory
FROM Products
WHERE UnitPrice > 15
GROUP BY CategoryID

-- HAVING clause --> Select or reject groups based on group characteristics
-- Statistical functions CANNOT be used in WHERE, only in HAVING

-- Show the categories that contain more than 10 products
SELECT CategoryID, COUNT(ProductID) As NumberOfProductsPerCategory
FROM Products
GROUP BY CategoryID
HAVING COUNT(ProductID) > 10


-- Show the categories that contain more than 10 products with UnitPrice > 15
SELECT CategoryID, COUNT(ProductID) As NumberOfProductsPerCategory
FROM Products
WHERE UnitPrice > 10
GROUP BY CategoryID
HAVING COUNT(ProductID) > 10

-- If statistical functions appear in the SELECT, then all items in the SELECT-list 
-- have to be either statistical functions or group identifications
SELECT CategoryID, MIN(UnitPrice) As Minimum
FROM Products

/* Exercises */
-- 1. Count the amount of products (columnname 'amount of products'), AND the amount of products in stock (= unitsinstock not empty) (columnname 'Units in stock') 
SELECT COUNT(Title) AS 'Number of Sales Representatives'
FROM Employees
WHERE title = 'Sales Representative';

-- 2. How many employees have a function of Sales Representative (columnname 'Number of Sales Representative')? 
-- 3. Give the date of birth of the youngest employee (columnname 'Birthdate youngest') and the oldest (columnname 'Birthdate oldest').
-- 4. What's the number of employees who will retire (at 65) within the first 20 years? 
-- 5. Show a list of different countries where 2 of more suppliers are from. Order alphabeticaly. 
-- 6. Which suppliers offer at least 5 products with a price less than 100 dollar? Show supplierId and the number of different products. 
-- The supplier with the highest number of products comes first. 











