/* JOIN */

-- JOIN
-- Give the productID, productName and CategoryName for each product
SELECT p.productID, p.productName, c.CategoryName
FROM Products p join Categories c
ON p.CategoryID = c.CategoryID

-- old style
SELECT ProductID, ProductName, CategoryName
FROM Products, Categories
WHERE Products.CategoryID = Categories.CategoryID

-- Using Aliases
SELECT ProductID, ProductName, CategoryName
FROM Products p JOIN Categories c
ON p.CategoryID = c.CategoryID

-- old style
SELECT ProductID, ProductName, CategoryName
FROM Products p, Categories c
WHERE p.CategoryID = c.CategoryID

-- INNER JOIN of > 2 tables
-- Give for each product the ProductName, the CategoryName and the CompanyName of the supplier
SELECT p.ProductID, p.ProductName, c.CategoryName, s.CompanyName
FROM Products p JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Suppliers s ON p.SupplierID = s.SupplierID


-- INNER JOIN with itself
-- Show all employees and the name of whom they have to report to
select e1.employeeID,
e1.lastname + ' ' + e1.firstname as employee,
e2.lastname + ' ' + e2.firstname as boss
from employees e1 inner join employees e2 on
e1.reportsto=e2.employeeid;

-- LEFT JOIN
-- Show the number of shippings per Shipper
SELECT s.ShipperID, s.CompanyName, COUNT(OrderID) As NumberOfShippings
FROM Shippers s JOIN Orders o
ON s.shipperID = o.shipVia
GROUP BY s.ShipperID, s.CompanyName

SELECT s.ShipperID, s.CompanyName, COUNT(OrderID) As NumberOfShippings
FROM Shippers s LEFT JOIN Orders o
ON s.shipperID = o.shipVia
GROUP BY s.ShipperID, s.CompanyName

-- RIGHT JOIN
-- Give the employees to whom no one reports
SELECT e1.Firstname + ' ' + e1.LastName As Employee,
e2.Firstname + ' ' + e2.LastName As ReportsTo
FROM Employees e1 RIGHT JOIN Employees e2
ON e1.ReportsTo = e2.EmployeeID
WHERE e1.Firstname + ' ' + e1.LastName IS NULL

-- FULL OUTER JOIN is the combination(=UNION) of LEFT and RIGHT OUTER JOIN
SELECT o.OrderID, s.ShipperID, s.CompanyName
FROM Shippers s FULL OUTER JOIN Orders o
ON s.shipperID = o.shipVia


-- CROSS JOIN
-- Make a schedule in which each employee should contact each customer
SELECT s.CompanyName, e.FirstName + ' ' + e.LastName As Emp
FROM Suppliers s CROSS JOIN Employees e

/* UNION INTERSECT EXCEPT */

-- UNION
-- Give an overview of all employees (lastname and firstname, city and postal code) 
-- and all customers (name, city and postal code)
SELECT lastname + ' ' + firstname as name, city, postalcode
FROM Employees
UNION
SELECT CompanyName, city, postalcode
FROM Customers

-- INTERSECT
select city, country from customers
intersect
select city, country from suppliers

-- EXCEPT
-- Which products have never been ordered? 
SELECT productid
FROM products
EXCEPT
SELECT productid
FROM orderdetails

/* Exercises */
-- 1. Which suppliers (SupplierID and CompanyName) deliver Dairy Products? 
SELECT DISTINCT s.SupplierID, s.CompanyName
FROM Suppliers s JOIN Products p ON s.SupplierID = p.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName LIKE '%Dairy'
-- 2. Give for each supplier the number of orders that contain products of that supplier. 
-- Show supplierID, companyname and the number of orders.
-- Order by companyname.
SELECT s.SupplierID, s.CompanyName , count(DISTINCT od.OrderID) as NrOfOrders
FROM Suppliers s JOIN Products p ON p.SupplierID = s.SupplierID
JOIN OrderDetails od ON od.ProductID = p.ProductID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY s.CompanyName
-- 3. What’s for each category the lowest UnitPrice? Show category name and unit price. 
SELECT c.CategoryName, MIN(p.UnitPrice) As 'Minimum UnitPrice'
FROM Products p JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID
-- 4. Give for each ordered product: productname, the least (columnname 'Min amount ordered') and the most ordered (columnname 'Max amount ordered'). Order by productname.
SELECT p.ProductName, MIN(od.Quantity) AS 'Min amount ordered', Max(od.Quantity) As 'Max Amount ordered'
FROM Products p JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY p.ProductName
-- 5. Give a summary for each employee with orderID, employeeID and employeename.
-- Make sure that the list also contains employees who don’t have orders yet.
SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS 'Name', o.OrderID
FROM Employees e LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID

