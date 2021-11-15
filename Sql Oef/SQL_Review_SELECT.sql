-- Show all data of all products	
SELECT *
FROM Products

-- Show for all a products productID, name and unitprice
SELECT productid, productname, unitprice
FROM Products

-- Show productid, productname and unitprice of all products from category 1
SELECT productid, productname, unitprice
FROM Products
WHERE categoryID = 1

-- Show productID, name, units in stock for all products with less than 5 units in stock
SELECT productid, productname, unitprice
FROM Products
WHERE UnitsInStock < 5

-- Show productID, name, units in stock for all products for which the name starts with A
SELECT productid, productname, unitprice
FROM Products
WHERE productname >= 'A' AND productname < 'B'

-- Wildcards (searching for patterns)
-- Always in combination with operator LIKE, NOT LIKE
-- Wildcard symbols:
-- % -> arbitrary sequence of 0, 1  or more characters
-- _  -> 1 character
-- [ ]  -> 1 character in a specified range
-- [^] -> every character not in the specified range

-- Show productID and name of the products for which the second letter is in the range a-k
SELECT productid, productname
FROM Products
WHERE productname LIKE '_[a-k]%'

-- OR, AND, NOT
SELECT ProductID, ProductName, SupplierID, UnitPrice
FROM Products
WHERE ProductName LIKE 'T%' OR (ProductID = 46 AND UnitPrice > 16.00)

-- BETWEEN, NOT BETWEEN
-- Select the products (name and unit price) for which the unit price is between 10 and 15 euro (boundaries included)
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 10 AND 15

-- IN, NOT IN
-- Show ProductID, ProductName and SupplierID of the products supplied by suppliers with ID 1, 3 or 5
SELECT ProductID, ProductName, SupplierID
FROM Products
WHERE SupplierID in (1,3,5)

-- IS NULL,  IS NOT NULL
-- * NULL values occur if no value has been specified for a column when creating a record
-- * A NULL is not equal to 0 (for numerical values), blank or empty string (for character values)!
-- * NULL fields are considered as equal (for e.g. testing with DISTINCT)
-- * If a NULL value appears in an expression the result is always NULL
-- Select suppliers from an unknown region
SELECT CompanyName, Region
FROM Suppliers
WHERE Region IS NULL

-- Be careful with NULL!
SELECT CompanyName, Region
FROM Suppliers
WHERE Region <> 'OR'

SELECT CompanyName, Region
FROM Suppliers
WHERE Region <> 'OR' OR Region IS NULL

-- ORDER BY
-- Show an alphabetic list of product names
SELECT ProductName
FROM Products
ORDER BY ProductName      -- or ORDER BY 1

-- Show productid, name, categoryID of the products sorted by categoryID. 
-- If the category is the same products with the highest price appear first.
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM Products
ORDER BY CategoryID, UnitPrice DESC

-- DISTINCT / ALL
-- DISTINCT filters out duplicates lines in the output
-- ALL (default) shows all rows, including duplicates
-- Show all suppliers that supply products
SELECT SupplierID
FROM Products
ORDER BY SupplierID 

SELECT DISTINCT SupplierID
FROM Products
ORDER BY SupplierID 

-- Exercises
-- 1. Give the names of all products containing the word 'bröd' or with a name of 7 characters.
-- 2. Show the productname and the reorderlevel of all products with a level between 10 and 50 (boundaries included)

-- SELECT and aliases
-- Select ProductID, ProductName of the products.
SELECT ProductID AS ProductNummer, ProductName AS 'Name Product'
FROM Products

-- Arithmetic operators : +, -, /, *
-- Give name and inventory value of the products
SELECT ProductName, UnitPrice * UnitsInStock  AS InventoryValue
FROM Products

-- ISNULL: replaces NULL values with specified value
SELECT ISNULL(UnitPrice, 10.00) 
FROM Products 

-- Conversions
-- Implicit conversions
SELECT ProductId, ProductName, UnitsInStock FROM Products

SELECT ProductId, ProductName, UnitsInStock * 1.0 FROM Products

-- Explicit conversions
SELECT CONVERT(VARCHAR, getdate(), 106) As Today 

SELECT * 
FROM Orders
WHERE FORMAT(ShippedDate,'dd/MM/yyyy')='10/07/2020'

-- String functions
SELECT STR(ProductID) + ',' + ProductName AS Product
FROM Products

SELECT ProductName, '$' As Currency, Unitprice
FROM Products

SELECT CONCAT(Address,' ',City) FROM Employees
SELECT Address + ' ' + City FROM Employees

SELECT SUBSTRING(Address, 1, 5) FROM Employees

SELECT LEFT(Address,5) FROM Employees

SELECT RIGHT(Address,5) FROM Employees

SELECT LEN(Address) FROM Employees

SELECT LOWER(Address) FROM Employees

SELECT UPPER(Address) FROM Employees

SELECT RTRIM(LTRIM(Address)) FROM Employees

-- Date / time functions
SELECT GETDATE()

SELECT DATEADD (year, 2, GETDATE())
SELECT DATEADD (month, 2, GETDATE())
SELECT DATEADD (day, 2, GETDATE())

SELECT DATEDIFF(day,BIRTHDATE,GETDATE()) As NumberOfDays
FROM Employees

SELECT DAY(GETDATE())

SELECT MONTH(GETDATE())

SELECT YEAR(GETDATE())

SELECT GETDATE()

SELECT GETUTCDATE()

SELECT SYSDATETIME()

SELECT SYSDATETIMEOFFSET()

-- Arithmetic functions
SELECT ABS(-10) -- 10

SELECT ROUND(10.75, 1)  -- 10.8

SELECT FLOOR(10.75)   -- 10

SELECT CEILING(10.75) -- 11

-- CASE
-- Simple CASE expression
SELECT City, Region, 
CASE region 
  WHEN 'OR' THEN 'West'
  WHEN 'MI' THEN 'North'
  ELSE 'Elsewhere'
END As RegionElaborated
FROM Suppliers

-- Searched CASE expression
SELECT CONVERT(varchar(20), ProductName) As 'Shortened ProductName',
   CASE 
      WHEN UnitPrice IS NULL THEN 'Not yet priced'      
      WHEN UnitPrice < 10 THEN 'Very Reasonable Price'
      WHEN UnitPrice >= 10 and UnitPrice < 20 THEN 'Affordable'
      ELSE 'Expensive!'
   END AS 'Price Category'
FROM Products
ORDER BY UnitPrice






