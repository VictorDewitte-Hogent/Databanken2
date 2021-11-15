/*** VIEWS ***/

/*
Definition
- A view is a saved SELECT statement
- A view can be seen as a virtual table composed of other tables & views
- No data is stored in the view itself, at each referral the underlying SELECT is re-executed;

Advantages
- Hide complexity of the database
	- Hide complex database design
	- Make large and complex queries accessible and reusable
	- Can be used as a partial solution for complex problems
- Used for securing data access: revoke access to tables and grant access to customised views. 
- Organise data for export to other applications
*/

-- Creating a view
CREATE VIEW V_ProductsCustomer(productcode, company, quantity)
AS SELECT od.ProductID, c.CompanyName, sum(od.Quantity)
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY od.ProductID, c.CompanyName;

-- Use of a view
SELECT * FROM V_ProductsCustomer;

-- Changing a view
ALTER VIEW V_ProductsCustomer(productcode, company)
AS SELECT od.ProductID, c.CompanyName
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY od.ProductID, c.CompanyName;

-- Dropping a view
DROP VIEW V_ProductsCustomer;

/* views as partial solution for complex problems */

-- Create a view with the number of orders per employee per year
CREATE VIEW vw_number_of_orders_per_employee_per_year
AS 
SELECT EmployeeID, YEAR(OrderDate) As OrderYear, COUNT(OrderID) As NumberOfOrders
FROM Orders
GROUP BY EmployeeID, YEAR(OrderDate)

-- Check the result
SELECT * FROM vw_number_of_orders_per_employee_per_year

-- Add the running total. Use the view.
SELECT EmployeeID, OrderYear, NumberOfOrders,
(SELECT SUM(NumberOfOrders) 
FROM vw_number_of_orders_per_employee_per_year
WHERE OrderYear <= vw.OrderYear AND EmployeeID = vw.EmployeeID
) As TotalNumberOfOrders
FROM vw_number_of_orders_per_employee_per_year vw
ORDER BY EmployeeID, OrderYear


/* Updatable views */

/*
An updatable view
- Has no distinct or top clause in the select statement
- Has no statistical functions in the select statement
- Has no calculated value in the select statement
- Has no group by in the select statement
- Does not use a union
All other views are read-only views
*/

/* Views with/without check option: example */

/* Sometimes, you create a view to reveal the partial data of a table. 
However, a simple view is updatable therefore it is possible to update data which is not visible through the view. 
This update makes the view inconsistent. 
To ensure the consistency of the view, you use the WITH CHECK OPTION clause when you create or modify the view.

The WITH CHECK OPTION is an optional clause of the CREATE VIEW statement. 
The WITH CHECK OPTION prevents a view from updating or inserting rows that are not visible through it. 
In other words, whenever you update or insert a row of the base tables through a view, 
SQLServer ensures that the insert or update operation is conformed with the definition of the view.
*/


DROP VIEW IF EXISTS productsOfCategory1;
DROP VIEW IF EXISTS productsOfCategory1Bis;

-- Create a view without "with check option"
CREATE VIEW productsOfCategory1
AS SELECT * FROM Products WHERE CategoryID = 1

-- Insert product from CategoryID 2 => although Wokkels is from CategoryID = 2, it can be added through the view
INSERT INTO productsOfCategory1 (ProductName, CategoryID)
VALUES ('Lays Wokkels', 2) 

SELECT * FROM Products WHERE ProductName LIKE '%Wokkels%'

DELETE FROM Products
WHERE ProductName LIKE '%Wokkels%'

-- Create a view with "with check option"
CREATE VIEW productsOfCategory1Bis
AS SELECT * FROM Products WHERE CategoryID = 1
WITH CHECK OPTION

-- Insert product from producttype 2 =>  although Wokkels is from CategoryID = 2, it can be added through the view
INSERT INTO productsOfCategory1Bis (ProductName, CategoryID)
VALUES ('Lays Wokkels', 2) 

/* Exercises */

-- Exercise 1
-- The company wants to weekly check the stock of their products.
-- If the stock is below 15, they'd like to order more to fulfill the need.

-- (1.1) Create a QUERY that shows the ProductId, ProductName and the name of the supplier, do not forget the WHERE clause.
SELECT ProductID, ProductName, CompanyName
From Products p Join Suppliers s ON p.SupplierID = s.SupplierID
WHERE UnitsInStock < 15

-- (1.2) Turn this SELECT statement into a VIEW called: vw_products_to_order.
Create View vw_products_to_order_(productId, ProductName, Companyname)
as 
Select productId, productname, companyName
From Products p Join Suppliers s ON p.SupplierID = s.SupplierID
WHERE UnitsInStock < 15


-- (1.3) Query the VIEW to see the results.


-- Exercise 2
-- The company has to increase prices of certain products. 
-- To make it seem the prices are not increasing dramatically they're planning to spread the price increase over multiple years. 
-- In total they'd like a 10% price for certain products. The list of impacted products can grow over the coming years. 
-- We'd like to keep all the logic of selecting the correct products in 1 SQL View, in programming terms 'keeping it DRY'. 
-- The updating of the items is not part of the view itself.
-- The products in scope are all the products with the term 'Bröd' or 'Biscuit'.

-- (2.1) Create a simple SQL Query to get the correct resultset


-- (2.2) Turn this SELECT statement into a VIEW called: vw_price_increasing_products.


-- (2.3) Query the VIEW to see the results.


-- (2.4) Increase the price of the resultset of the VIEW: vw_price_increasing_products by 2%
begin transaction  



rollback;

