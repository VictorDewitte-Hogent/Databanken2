/* DML */
/*
INSERT -> adding data
UPDATE -> changing data
DELETE -> removing data
MERGE -> combine INSERT, UPDATE and DELETE
*/

/* Tip for not destroying your database */
BEGIN TRANSACTION -- starts a new "transaction" --> Saves previous state of DB in buffer

-- several "destructive" commands can go here:
INSERT INTO Products(ProductName) 
values ('TestProduct');

-- only you (in  your session) can see changes
SELECT * FROM Products WHERE ProductID = (SELECT MAX(ProductID) FROM Products)

ROLLBACK;   --> ends transaction and restores database in previous state

-- COMMIT;  --> ends transaction and makes changes permanent


/* Insert of 1 row */

BEGIN TRANSACTION

INSERT INTO Products (ProductName, CategoryID, Discontinued)
VALUES ('Toblerone', 3, 0)

INSERT INTO Products
VALUES ('Sultana', null, 3, null, null, null, null, null, 1)

SELECT * FROM Products

ROLLBACK;

 

/* Insert of row(s) selected from other tables */

BEGIN TRANSACTION 

INSERT INTO Customers (CustomerID, ContactName, ContactTitle, CompanyName)
SELECT substring(FirstName,1,2) + substring(LastName,1,3), FirstName + ' ' + LastName, Title, 'EmployeeCompany'
FROM Employees

-- only you (in  your session) can see changes
SELECT * FROM Customers WHERE CompanyName = 'EmployeeCompany';

ROLLBACK 

/* UPDATE: modify values */

-- Increase the price of all products with 10%

BEGIN TRANSACTION 

UPDATE Products
SET UnitPrice = UnitPrice * 1.1

-- only you (in  your session) can see changes
SELECT * FROM Products

ROLLBACK;

-- Increase the price of the product Wheeler with 10%

BEGIN TRANSACTION

UPDATE Products
SET UnitPrice = UnitPrice * 1.1
WHERE ProductName LIKE '%Bröd%'

-- only you (in  your session) can see changes
SELECT * FROM Products

ROLLBACK;

-- Increase the price of all the 'Bröd' products with 10%and set all units in stock to 0

BEGIN TRANSACTION  

UPDATE Products
SET UnitPrice = UnitPrice * 1.1, UnitsInStock = 0
WHERE ProductName LIKE '%Bröd%'

-- only you (in  your session) can see changes
SELECT * FROM Products

ROLLBACK;

-- Standard SQL does not offer JOINs in an update statement
-- => you can only use subqueries to refer to another table
-- due to a change in the euro – dollar exchange rate, 
-- we must increase the unit price of products delivered by suppliers from the USA by 10%.

BEGIN TRANSACTION  

UPDATE Products
SET UnitPrice = (UnitPrice * 1.1)
WHERE SupplierID IN
	(SELECT SupplierID FROM Suppliers WHERE Country = 'USA')

-- only you (in  your session) can see changes
SELECT * FROM Products

ROLLBACK;

/* Delete: remove rows */

BEGIN TRANSACTION   

DELETE FROM Products
WHERE ProductName LIKE '%Bröd%'

-- only you (in  your session) can see changes
SELECT * FROM Products

ROLLBACK;

/* Difference between DELETE and TRUNCATE */
/* Do NOT execute this */
-- the identity value continues
DELETE FROM Products 

-- the identity value restarts from 1
TRUNCATE TABLE Products --> the identity value restarts from 1 + is more performant but does not offer WHERE clause

-- Standard SQL does not offer JOINs in an update statement
-- => you can only use subqueries to refer to another table

BEGIN TRANSACTION  

DELETE FROM OrderDetails 
WHERE OrderID IN 
	(SELECT OrderID FROM Orders WHERE OrderDate = (SELECT MAX(OrderDate) from Orders));

-- only you (in  your session) can see changes
SELECT * FROM OrderDetails

ROLLBACK;

/* Merge */

/* First execute following script to simulate the Excel file that has been imported to a temporary table ShippersUpdate */

DROP TABLE IF EXISTS ShippersUpdate;
-- Add everything from Shippers to ShippersUpdate
SELECT * INTO ShippersUpdate FROM Shippers

-- Add an extra record to ShippersUpdate
INSERT INTO ShippersUpdate VALUES ('Pickup','(503) 555-9647')

-- Update a record of ShippersUpdate
UPDATE ShippersUpdate SET Phone = '(503) 555-4512' WHERE ShipperID = 1

-- Remove a record from ShippersUpdate
DELETE FROM ShippersUpdate WHERE shipperID = 4


SELECT * FROM Shippers;
SELECT * FROM ShippersUpdate;



BEGIN TRANSACTION  

INSERT INTO Shippers
VALUES ('PostNL', '(503) 555-1236')

SELECT * FROM Shippers;
SELECT * FROM ShippersUpdate;

MERGE Shippers as t	-- t = target
USING ShippersUpdate as s -- s = source
ON (t.ShipperID = s.ShipperID)

-- Which rows are in source and have different values for CompanyName or Phone?
-- Update those rows in target with the values coming from source
WHEN MATCHED AND t.CompanyName <> s.CompanyName OR ISNULL(t.Phone,'') <> ISNULL(s.Phone,'') --> rows to update
THEN UPDATE SET t.CompanyName = s.CompanyName, t.Phone=s.Phone

-- Which rows are in target and not in source?
-- Add those rows to source
WHEN NOT MATCHED BY target --> new rows
THEN INSERT (CompanyName, Phone) VALUES (s.CompanyName,s.Phone)

-- Which rows are in source and not in target?
-- Delete those rows from target
WHEN NOT MATCHED BY source  --> rows to delete
THEN DELETE;

-- Check the result
SELECT * FROM Shippers
ROLLBACK;

