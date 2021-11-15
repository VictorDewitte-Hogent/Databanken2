/* SUBQUERYS */

/********************************************/
/* Subqueries in the WHERE OR HAVING clause */
/********************************************/

/* SUBQUERY that returns a single value */

-- What is the UnitPrice of the most expensive product?
SELECT MAX(UnitPrice) As MaxPrice FROM Products

-- Alternative?
SELECT TOP 1 productName, UnitPrice FROM products
ORDER BY unitPrice DESC

-- What is the most expensive product?
SELECT ProductID, ProductName, UnitPrice As MaxPrice 
FROM Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products)

-- Alternative???
SELECT TOP 1 ProductID, ProductName, UnitPrice As MaxPrice 
FROM Products 
ORDER BY UnitPrice DESC


-- Give the products that cost more than average
SELECT ProductID, ProductName, UnitPrice As MaxPrice 
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products)

-- Who is the youngest employee from the USA?
select CONCAT(LastName, ' ', FirstName) as 'Name', BirthDate --Geef mij de employee die,;
from Employees
where BirthDate = (select max(BirthDate) from Employees WHERE Country = 'USA') and Country = 'USA'

-- Give the full name of the employee who earns most
SELECT CONCAT(LastName, ' ' , FirstName) as 'Name', Salary
FROM Employees
WHERE Salary = (SELECT MAX(Salary) FROM Employees)

-- Give the name of the most frequently sold product
SELECT TOP 1 COUNT(ProductID) FROM OrderDetails GROUP BY ProductID ORDER by 1 DESC

SELECT p.productID, p.ProductName, COUNT(o.productID)
FROM OrderDetails o JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
HAVING Count(p.ProductID)=( SELECT TOP 1 COUNT(ProductID) FROM OrderDetails GROUP BY ProductID ORDER by 1 DESC)
/* SUBQUERY that returns a single column */

-- Give the CustomerID and CompanyName of all customers that already placed an order
SELECT c.CustomerID, c.CompanyName 
FROM Customers c
WHERE c.CustomerID IN (SELECT DISTINCT CustomerID FROM Orders)

-- Alternative?
SELECT DISTINCT c.CustomerID, c.CompanyName 
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID

-- Give the CustomerID and CompanyName of all customers that not yet placed an order
SELECT c.CustomerID, c.CompanyName 
FROM Customers c
WHERE c.CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)

-- Alternative?
SELECT c.CustomerID, c.CompanyName 
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID is NULL

-- Give the CompanyName of the shippers that haven't shipped anything yet
SELECT CompanyName
FROM Shippers s
WHERE s.ShipperID NOT IN(SELECT DISTINCT ShipVia FROM Orders)

-- Give the productID's for which some customers got a discount and other customers did not
SELECT ProductID
FROM Products
WHERE ProductID IN (SELECT DISTINCT ProductID FROM OrderDetails WHERE Discount > 0)
  AND ProductID IN (SELECT DISTINCT ProductID FROM OrderDetails WHERE Discount = 0)


-- ALL
-- Give all products that are more expensive 
-- than the most expensive product with CategoryName = 'Seafood'
SELECT *
FROM Products
WHERE UnitPrice > ALL(SELECT p.UnitPrice 
FROM Products p JOIN Categories c ON p.CategoryID = c.CategoryID 
WHERE c.CategoryName = 'Seafood')

-- Alternative?
SELECT *
FROM Products
WHERE UnitPrice > (SELECT MAX(UnitPrice) FROM Products p INNER JOIN Categories c ON p.CategoryID = c.CategoryID AND c.CategoryName = 'Seafood')


-- Give the most expensive product. 
SELECT *
FROM products
WHERE unitprice >= ALL(SELECT unitprice from products)

-- Alternative?
SELECT *
FROM products
WHERE unitprice = (SELECT MAX(unitprice) from products)



-- ANY
-- Give all products that are more expensive 
-- than one of the products with CategoryName = 'Seafood'
SELECT *
FROM Products
WHERE UnitPrice > ANY(SELECT p.UnitPrice FROM Products p INNER JOIN Categories c ON p.CategoryID = c.CategoryID AND c.CategoryName = 'Seafood')

-- Alternative?
SELECT *
FROM Products
WHERE UnitPrice > (SELECT MIN(p.UnitPrice) FROM Products p INNER JOIN Categories c ON p.CategoryID = c.CategoryID AND c.CategoryName = 'Seafood')


/* Correlated subquerys */
/*
In a correlated subquery the inner query depends on information from the outer query.
The subquery contains a search condition that refers to the main query, 
which makes the subquery depends on the main query
*/

-- Give employees with a salary larger than the average salary
SELECT FirstName + ' ' + LastName As FullName, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees)

-- Give the employees whose salary is larger 
-- than the average salary of the employees who report to the same boss.
SELECT FirstName + ' ' + LastName As FullName, ReportsTo, Salary
FROM Employees As e
WHERE Salary > 
(SELECT AVG(Salary) FROM Employees WHERE ReportsTo = e.ReportsTo)

-- Give all products that cost more 
-- than the average unitprice of products of the same category
SELECT ProductName
from Products As p
where UnitPrice >
(SELECT AVG(UnitPrice) FROM Products where CategoryID = p.CategoryID)

-- Give the customers that ordered more often in 2016 than in 2017
SELECT CustomerID, Count(OrderID) as 'amount of orders'
FROM Orders o
WHERE YEAR(OrderDate) = 2016
GROUP BY CustomerID
HAVING COUNT(OrderID) > (SELECT Count(OrderID) as 'amount of orders'
	FROM Orders
	WHERE YEAR(OrderDate) = 2017 AND CustomerID = o.CustomerID
	GROUP BY CustomerID
)


/* Subqueries and the EXISTS operator */
-- Give the CustomerID and CompanyName of all customers that already placed an order
SELECT c.CustomerID, c.CompanyName 
FROM Customers c
WHERE EXISTS 
(SELECT * FROM Orders WHERE CustomerID = c.customerID)

-- Give the CustomerID and CompanyName of all customers that have not placed any orders yet
SELECT c.CustomerID, c.CompanyName 
FROM Customers c
WHERE NOT EXISTS 
(SELECT * FROM Orders WHERE CustomerID = c.customerID)

-- Alternative?
SELECT c.CustomerID, c.CompanyName 
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID is NULL


-- Alternative?
SELECT CustomerID, CompanyName 
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)




/*********************************/
/* Subqueries in the FROM clause */
/*********************************/


-- Give per region the number of orders (region USA + Canada = North America, rest = Rest of World).
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




/***********************************/
/* Subqueries in the SELECT clause */
/***********************************/

-- give for each employee how much they earn more (or less) than the average salary of all employees with the same supervisor

SELECT Lastname, Firstname, Salary, 
Salary -
(
    SELECT AVG(Salary)
    FROM Employees
    WHERE ReportsTo = e.ReportsTo
)
FROM Employees e



/***************************************************/
/* Subqueries in the SELECT and in the FROM clause */
/***************************************************/

-- Give per productclass the price of the cheapest product and a product that has that price. 


SELECT Category, MinUnitPrice,
(
    SELECT TOP 1 ProductID
    FROM Products
    WHERE CategoryID = Category AND UnitPrice = MinUnitPrice
) As ProductID
FROM
(
    SELECT CategoryID, MIN(UnitPrice)
    FROM Products p
    GROUP BY CategoryID
) AS CategoryMinPrice(Category, MinUnitPrice);


/* Application: running totals */

-- Give the cumulative sum of freight per year
SELECT OrderID, OrderDate, Freight,
(
	SELECT SUM(Freight) 
	FROM Orders
	WHERE YEAR(OrderDate) = YEAR(o.OrderDate) and OrderID <= o.OrderID
) As TotalFreight
FROM Orders o
ORDER BY Orderid;


/* Exercises */

-- 1. Give the id and name of the products that have not been purchased yet. 
--> Resultaat Leeg
SELECT ProductID , ProductName
FROM Products
WHERE ProductID NOT IN (SELECT DISTINCT ProductID From Orders)

-- 2. Select the names of the suppliers who supply products that have not been ordered yet.
--> Resultaat Leeg
SELECT CompanyName
FROM Suppliers s JOIN  Products  p ON s.SupplierID = p.SupplierID
WHERE ProductID NOT IN (SELECT DISTINCT ProductID From Orders)

-- 3. Give a list of all customers from the same country as the customer Maison Dewey
--> 
SELECT CompanyName
From Customers 
WHERE Country = (SELECT Country FROM Customers WHERE CompanyName = 'Maison Dewey')


-- 4. Calculate how much is earned by the management (like 'president' or 'manager'), the submanagement (like 'coordinator') and the rest
SELECT Title ,SUM(Salary)
FROM (
SELECT
CASE 
WHEN title LIKE '%president%' THEN 'Manager'
WHEN title LIKE '%manager%' THEN 'Manager'
WHEN title LIKE '%coordinator%' THEN 'Submanagement'
ELSE 'REST'
END AS Title, Salary
FROM Employees
)AS Totals(Title, Salary)
GROUP BY Title






-- 5. Give for each product how much the price differs from the average price of all products of the same category
SELECT ProductID, UnitPrice - ( 
SELECT AVG(UnitPrice)
FROM Products 
WHERE CategoryID = p.CategoryID)
FROM Products p





SELECT Lastname, Firstname, Salary, 
Salary -
(
    SELECT AVG(Salary)
    FROM Employees
    WHERE ReportsTo = e.ReportsTo
)
FROM Employees e
-- 6. Give per title the employee that was last hired
SELECT title, FirstName + LastName
FROM Employees e
WHERE HireDate = (SELECT HireDate From Employees WHERE Title = e.Title )

-- 7. Which employee has processed most orders? 
SELECT FirstName + LastName
From Employees
Where COUNT(

-- 8. What's the most common ContactTitle in Customers?
-- 9. Is there a supplier that has the same name as a customer?


