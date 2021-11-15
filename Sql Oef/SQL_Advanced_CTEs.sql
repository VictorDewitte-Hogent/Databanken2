/* Common Table Expression */

/* Common Table Expression: The WITH component */

-- Give the average number of orders for all customers
-- Solution 1
-- First calculate the number of orders per customer (Subquery in FROM)
-- Afterwards calculate the AVG

SELECT AVG(numberOfOrders * 1.0) As AverageNumberOfOrdersPerCustomer -- *1.0 to force floating point
FROM
(
SELECT customerid, COUNT(orderid)
FROM orders
GROUP BY customerid
) AS numberOfOrdersPerCustomer(customerid, numberOfOrders)

-- Solution 2
-- Using the WITH-component you can give the subquery its own name (with column names) 
-- and reuse it in the rest of the query (possibly several times):

WITH numberOfOrdersPerCustomer(customerid, numberOfOrders) AS
(SELECT customerid, COUNT(orderid)
FROM orders
GROUP BY customerid)

SELECT AVG(numberOfOrders * 1.0) As AverageNumberOfOrdersPerCustomer
FROM numberOfOrdersPerCustomer









WITH averageUnitPricePerCategory(CategoryID, AverageUnitPrice)
AS
(SELECT CategoryID, AVG(UnitPrice)
FROM Products
GROUP BY CategoryID)

 

SELECT ProductID, productName, UnitPrice, AverageUnitPrice
FROM products p JOIN averageUnitPricePerCategory a
ON p.CategoryID = a.CategoryID

/* CTE's versus Views 

Similarities 
- WITH ~ CREATE VIEW
- Both are virtual tables: the content is derived from other tables

Differences 
- A CTE only exists during the SELECT-statement
- A CTE is not visible for other users and applications
*/


/* CTE's versus Subqueries 
Similarities 
- Both are virtual tables:  the content is derived from other tables

Differences 
- A CTE can be reused in the same query
- A subquery is defined in the clause where it is used (SELECT/FROM/WHERE/…)
- A CTE is defined on top of the query
- A simple subquery can always be replaced by a CTE
*/

-- CTE's to simplify queries

-- Give per category the minimum price and all products with that minimum price 

-- Solution 1
SELECT CategoryID, ProductID, UnitPrice
FROM Products p
WHERE UnitPrice = (SELECT MIN(UnitPrice) FROM Products WHERE CategoryID = p.CategoryID)

-- Solution 2
WITH CategoryMinPrice(Category, MinPrice)
AS (SELECT CategoryID, MIN(UnitPrice)
    FROM Products AS p
    GROUP BY CategoryID)

SELECT Category, MinPrice, p.ProductID
FROM Products AS p
JOIN CategoryMinPrice AS c ON p.CategoryID = c.Category AND p.UnitPrice = c.MinPrice;

-- CTE's with > 1 WITH-component

-- Give per year per customer the relative contribution of this customer to the total revenue

-- Step 1 -> Total revenue per year
SELECT YEAR(OrderDate), SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate)

-- Step 2 -> Total revenue per year per customer
SELECT YEAR(OrderDate), o.CustomerID, SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), o.CustomerID

-- Step 3 -> Combine both
WITH TotalRevenuePerYear(RevenueYear, TotalRevenue)
AS
(SELECT YEAR(OrderDate), SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate)),

TotalRevenuePerYearPerCustomer(RevenueYear, CustomerID, Revenue) 
AS
(SELECT YEAR(OrderDate), o.CustomerID, SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), o.CustomerID)

SELECT CustomerID, pc.RevenueYear, FORMAT(Revenue / TotalRevenue, 'P') As RelativePart
FROM TotalRevenuePerYearPerCustomer pc INNER JOIN TotalRevenuePerYear t 
ON pc.RevenueYear = t.RevenueYear
ORDER BY 2 ASC, 3 DESC


/* Recursive SELECT's */

/*
'Recursive' means: we continue to execute a table expression until a condition is reached.

This allows you to solve problems like:
- Who are the friends of my friends etc. (in a social network)?
- What is the hierarchy of an organisation ? 
- Find the parts and subparts of a product (bill of materials). 

*/

-- Give the integers from 1 to 5
WITH numbers(number) AS
	(SELECT 1 
	 UNION all 
 	 SELECT number + 1 
	 FROM numbers
 	 WHERE number < 5)

SELECT * FROM numbers;

/* Characteristics of recursive use of WITH:
- The with component consists of (at least) 2 expressions, combined with UNION ALL
- A temporary table is consulted in the second expression
- At least one of the expressions may not refer to the temporary table.
*/

-- Give the numbers from 1 to 999

WITH numbers(number) AS
	(SELECT 1 
	 UNION all 
 	 SELECT number + 1 
	 FROM numbers
 	 WHERE number < 999)

SELECT * FROM numbers;

--> The maximum recursion 100 has been exhausted before statement completion.

-- Give the numbers from 1 to 999

WITH numbers(number) AS
	(SELECT 1 
	 UNION all 
 	 SELECT number + 1 
	 FROM numbers
 	 WHERE number < 999)

SELECT * FROM numbers
option (maxrecursion 1000);

--> Maxrecursion is MS SQL Server specific. 

-- Give the total revenue per month in 2016.Not all months occur

SELECT YEAR(OrderDate)*100 + Month(OrderDate) AS RevenueMonth, SUM(od.UnitPrice * od.Quantity) AS Revenue
FROM Orders o INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY YEAR(OrderDate)*100 + Month(OrderDate)

-- Solution: Generate all months with CTE ...
WITH Months AS
(SELECT 201601 as RevenueMonth
UNION ALL
SELECT RevenueMonth + 1
FROM Months
WHERE RevenueMonth < 201612)
SELECT * FROM Months;

-- And combine with outer join
WITH Months(RevenueMonth) AS
(SELECT 201601 as RevenueMonth
UNION ALL
SELECT RevenueMonth + 1
FROM Months
WHERE RevenueMonth < 201612),

Revenues(RevenueMonth, Revenue)
AS
(SELECT YEAR(OrderDate)*100 + Month(OrderDate) AS RevenueMonth, SUM(od.UnitPrice * od.Quantity) AS Revenue
FROM Orders o INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY YEAR(OrderDate)*100 + Month(OrderDate))

SELECT m.RevenueMonth, ISNULL(r.Revenue, 0) As Revenue
FROM Months m LEFT JOIN Revenues r ON m.RevenueMonth = r.RevenueMonth



/* Recursively traversing a hierarchical structure */

-- Give all employees who report directly or indirectly to Andrew Fuller (employeeid=2)
-- Step 1 returns all employees that report directly to Andrew Fuller
-- Step 2 adds the 2nd 'layer': who reports to someone who reports to A. Fuller
-- ....

WITH Bosses (boss, emp)
AS
(SELECT ReportsTo, EmployeeID
FROM Employees
WHERE ReportsTo IS NULL
UNION ALL
SELECT e.ReportsTo, e.EmployeeID
FROM Employees e INNER JOIN Bosses b ON e.ReportsTo = b.emp)

SELECT * FROM Bosses
ORDER BY boss, emp;

-- Change the previous solution to the following solution
/*
boss	emp		title					level	path
NULL	2		Vice President, Sales	1		Vice President, Sales
2		5		Sales Manager			2		Vice President, Sales<--Sales Manager
2		10		Business Manager		2		Vice President, Sales<--Business Manager
2		13		Marketing Director		2		Vice President, Sales<--Marketing Director
5		1		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		3		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		4		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		6		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		7		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		8		Inside Sales Coordinator	3	Vice President, Sales<--Sales Manager<--Inside Sales Coordinator
5		9		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
...
*/

WITH Bosses (boss, emp, title, level, path)
AS
(SELECT ReportsTo, EmployeeID, Title, 1, convert(varchar(max), Title)
FROM Employees
WHERE ReportsTo IS NULL
UNION ALL
SELECT e.ReportsTo, e.EmployeeID, e.Title, b.level + 1, convert(varchar(max), b.path + '<--' + e.title)
FROM Employees e INNER JOIN Bosses b ON e.ReportsTo = b.emp)

SELECT * FROM Bosses
ORDER BY boss, emp;

/* Exercises */

-- 1. Give per region the number of orders (region USA + Canada = North America, rest = Rest of World).
-- Solution 1
SELECT 
CASE c.Country
WHEN 'USA' THEN 'Northern America'
WHEN 'Canada' THEN 'Northern America'
ELSE 'Rest of world' 
END AS Regionclass, COUNT(o.OrderID) As NumberOfOrders
FROM Customers c JOIN Orders o 
ON c.CustomerID = o.CustomerID
GROUP BY
CASE c.Country
WHEN 'USA' then 'Northern America'
WHEN 'Canada' then 'Northern America'
ELSE 'Rest of world' 
END

-- Solution 2 -> avoid copy-paste (subquery in FROM)
SELECT Regionclass, COUNT(OrderID)
FROM
(
SELECT 
CASE c.Country
WHEN 'USA' THEN 'Northern America'
WHEN 'Canada' THEN 'Northern America'
ELSE 'Rest of world' 
END AS Regionclass, o.OrderID
FROM Customers c JOIN Orders o 
ON c.CustomerID = o.CustomerID
) 
AS Totals(Regionclass, OrderID)
GROUP BY Regionclass

-- Solution 3 (with CTE's)
WITH Countries ( country, costumers)
as
(
SELECT 
CASE c.Country
WHEN 'USA' THEN 'Northern America'
WHEN 'Canada' THEN 'Northern America'
ELSE 'Rest of world' 
END AS Regionclass, o.OrderID
FROM Customers c JOIN Orders o 
ON c.CustomerID = o.CustomerID
) 
SELECT * FROM country, costumers;



-- 2 Make a histogram of the number of orders per customer, so show how many times each number occurs. 
-- E.g. in the graph below: 1 customer placed 1 order, 2 customers placed 2 orders, 7 customers placed 3 orders, etc. 

/*

nr	NumberOfCustomers
1	1
2	2
3	7
4	6
5	10
6	8
7	7
...

*/

Select Count(orderID)
From Orders
-- 3. Give the customers of the Country in which most customers live
--cte1: number of customers per country
--cte2: maximum
with cte1(country, numberOfCustomers)
AS
(SELECT country, count(customerID)
FROM customers
GROUP BY country),

 

cte2(maximumNumberOfCustomers)
As
(SELECT MAX(numberOfCustomers)
FROM cte1)

 

SELECT c.country, numberOfCustomers, companyname
FROM cte1 JOIN cte2 ON numberOfCustomers = maximumNumberOfCustomers
JOIN customers c ON cte1.country = c.country
-- 4. Give all employees except for the eldest
-- Solution 1 (using Subqueries)
SELECT MIN(Birthdate) FROM Employees
Select * 
From Employees
Where BirthDate >(Select min(Birthdate) From Employees)

-- Solution 2 (using CTE's)

With cte1(minBirthdate)
as
(Select MIN(Birthdate) From Employees)

Select *
From Employees JOIN cte1 on BirthDate>minBirthdate


-- 5.  What is the total number of customers and suppliers?
--> cte1 for total number of customers
--> cte2 for total number of suppliers
--> cross join
With cte1(numberOfCustomers)
as
(Select Count(CustomerID) From Customers),

 cte2(numberOfSuppliers)
as
(Select Count(SupplierID) From Suppliers)

Select numberOfCustomers + numberOfSuppliers
From cte1 cross join cte2
-- 6. Give per title the eldest employee
With cte1(Title, minBirthDate)
as
(SELECT title, MIN(Birthdate) FROM Employees GROUP BY Title)



Select  e.Title , EmployeeID, FirstName +' ' + LastName
from cte1 join Employees e on minBirthdate = e.birthDate

-- 7. Give per title the employee that earns most
With cte1(Title, maxSalaris)
as
(SELECT title, MAX(salary) FROM Employees GROUP BY Title) 

Select e.title , CONCAT(FirstName , ' ' ,Lastname)as 'Name'
From cte1  join Employees e on maxSalaris = e.Salary
-- 8. Give the titles for which the eldest employee is also the employee who earns most
With cte1(Title, minBirthDate)
as
(SELECT title, MIN(Birthdate) FROM Employees GROUP BY Title),
 cte2(Title, maxSalaris)
as
(SELECT title, MAX(salary) FROM Employees GROUP BY Title) 
Select *
FROM cte1 a JOIN Employees e on a.title = e.title And a.minBirthDate = e.birthDate JOIN cte2 b on b.title = e.Title

-- 9. Execute the following script:
CREATE TABLE Parts 
(
    [Super]   CHAR(3) NOT NULL,
    [Sub]     CHAR(3) NOT NULL,
    [Amount]  INT NOT NULL,
    PRIMARY KEY(Super, Sub)
);

INSERT INTO Parts VALUES ('O1','O2',10);
INSERT INTO Parts VALUES ('O1','O3',5);
INSERT INTO Parts VALUES ('O1','O4',10);
INSERT INTO Parts VALUES ('O2','O5',25);
INSERT INTO Parts VALUES ('O2','O6',5);
INSERT INTO Parts VALUES ('O3','O7',10);
INSERT INTO Parts VALUES ('O6','O8',15);
INSERT INTO Parts VALUES ('O8','O11',5);
INSERT INTO Parts VALUES ('O9','O10',20);
INSERT INTO Parts VALUES ('O10','O11',25);



WITH Bosses (boss, emp, title, level, path)
AS
(SELECT ReportsTo, EmployeeID, Title, 1, convert(varchar(max), Title)
FROM Employees
WHERE ReportsTo IS NULL
UNION ALL
SELECT e.ReportsTo, e.EmployeeID, e.Title, b.level + 1, convert(varchar(max), b.path + '<--' + e.title)
FROM Employees e INNER JOIN Bosses b ON e.ReportsTo = b.emp)

SELECT * FROM Bosses
ORDER BY boss, emp;


-- Show all parts that are directly or indirectly part of O2, so all parts of which O2 is composed.
-- Add an extra column with the path as below: 

/*
SUPER	SUB		PAD
O2		O5		O2 <-O5
O2		O6		O2 <-O6
O6		O8		O2 <-O6 <-O8
O8		O11		O2 <-O6 <-O8 <-O11

*/

