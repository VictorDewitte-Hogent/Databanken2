/************************/
/******* Triggers ********/
/************************/

/*
A trigger: a database program, consisting of procedural and declarative instructons, 
saved in the catalogue and activated by the DBMS if a certain operation on the database 
is executed and if a certain condition is satisfied.

Comparable to SP but can't be called explicitly.
A trigger is automatically called by the DBMS with some DML, DDL, LOGON-LOGOFF commands
- DML trigger: with an insert, update or delete for a table or view  (in this course we further elaborate this type of cursors)
- DDL trigger: executed with a create, alter or drop of a table
- LOGON-LOGOFF trigger: executed when a user logs in or out (MS SQL Server: only LOGON triggers, Oracle: both)


DML triggers
- Can be executed with
	* insert
	* update
	* delete
- Are activated
	* before – before the IUD is processed (not supported by SQL Server)
	* instead of  –  instead of IUD command
	* after – after the IUID is processed (but before COMMIT), this is the default

Why using triggers?
- Validation of data and complex constraints
		* An employee can't be assigned to > 10 projects
		* An employee can only be assigned to a project that is assigned to his department
- Automatic generation of values
		* If an employee is assigned to a project the default value for the monthly bonus is set according to the project priority and his job category
- Support for alerts
		* Send automatic e-mail if an employee is removed from a project
- Auditing
	* Keep track of who did what on a certain table
- Replication and controlled update of redundant data
	* If an ordersdetail record changes, update the orderamount in the orders table
	* Automatic update of datawarehouse tables for reporting (see "Datawarehousing")

Advantages
- Major advantage
	* Store functionality in the DB and execute consistently with each change of data in the DB
- Consequences
	* no redundant code --> functionality is localised in a single spot, not scattered over different applications (desktop, web, mobile), written by different authors
	* written and tested 'once' by an experienced DBA
	* security --> triggers are in the DB so all security rules apply
	* more processing power --> for DBMS and DB
	* fits into client-server model --> 1 call to db-serve: al lot can be executed without further communication

Disadvantages
- Complexity
	* DB design, implementation are more complex by shifting functionality from application to DB
	* Very difficult to debug
- Hidden functionality
	* The user can be confronted with unexpected side effects from the trigger, possibly unwanted
	* Triggers can cascade, which is not always easy to predict when designing the trigger
- Performance
	* At each database change the triggers have to be reevaluated
- Portability
	* Restricted to the chosen database dialect (ex. Transact-SQL from MS)


Virtual tables with triggers --> zie slides
- deleted tablecontains copies of updated and deleted rows
	* During update or delete rows are moved from the triggering table to the deleted table
	* Those two table have no rows in common

- inserted tablecontains copies of updated or inserted rows
	* During update or insert each affected row is copied from the triggering table to the inserted table
	* All rows from the inserted table are also in the triggering table

*/

/*******************************/
/**** Delete after - trigger  **/
/*******************************/

-- Triggering instruction is a delete instruction
-- deleted – logical table with columns equal to columns of triggering table, containing a copy of delete rows


-- If a record in OrderDetails is removed => UnitsInStock in Products is updated
-- 1st try
CREATE OR ALTER TRIGGER deleteOrderDetails ON OrderDetails FOR delete
AS
DECLARE @deletedProductID INT = (SELECT ProductID From deleted)
DECLARE @deletedQuantity SmallINT = (SELECT Quantity From deleted)
UPDATE Products
SET UnitsInStock = UnitsInStock + @deletedQuantity
FROM Products WHERE ProductID = @deletedProductID

-- Testcode
BEGIN TRANSACTION
SELECT * FROM Products WHERE ProductID = 14 OR ProductID = 51
DELETE FROM OrderDetails WHERE OrderID = 10249
SELECT * FROM Products WHERE ProductID = 14 OR ProductID = 51
ROLLBACK;

-- In the previous solution: more than 1 record in deleted 
-- => use a cursor to loop through all the records in deleted
-- 2nd try
CREATE OR ALTER TRIGGER deleteOrderDetails ON OrderDetails FOR delete
AS
DECLARE deleted_cursor CURSOR 
FOR
SELECT ProductID, Quantity
FROM deleted

DECLARE @ProductID INT
DECLARE @Quantity SmallINT

-- open cursor
OPEN deleted_cursor

-- fetch data
FETCH NEXT FROM deleted_cursor INTO @ProductID, @Quantity

WHILE @@FETCH_STATUS = 0 
BEGIN 
	UPDATE Products
	SET UnitsInStock = UnitsInStock + @Quantity
	FROM Products WHERE ProductID = @ProductID
  	FETCH NEXT FROM deleted_cursor INTO @ProductID, @Quantity
END 

-- close cursor
CLOSE deleted_cursor

-- deallocate cursor
DEALLOCATE deleted_cursor


-- Testcode
BEGIN TRANSACTION
SELECT * FROM Products WHERE ProductID = 14 OR ProductID = 51
DELETE FROM OrderDetails WHERE OrderID = 10249
SELECT * FROM Products WHERE ProductID = 14 OR ProductID = 51
ROLLBACK

/*******************************/
/**** Insert after - trigger  **/
/*******************************/

-- Triggering instruction is an insert statement
-- inserted – logical table with columns equal to columns of triggering table, containing a copy of inserted rows
-- Remark: when triggering by INSERT-SELECT statement more than one record can be added at once. 
-- The trigger code is executed only once, but will insert a new record for each inserted record


-- If a new record is inserted in OrderDetails => check if the unitPrice is not too low or too high
-- If so, rollback the transaction and raise an error
CREATE OR ALTER TRIGGER insertOrderDetails ON OrderDetails FOR insert
AS
DECLARE @insertedProductID INT = (SELECT ProductID From inserted)
DECLARE @insertedUnitPrice Money = (SELECT UnitPrice From inserted)
DECLARE @unitPriceFromProducts Money = (SELECT UnitPrice FROM Products WHERE ProductID = @insertedProductID)
IF @insertedUnitPrice NOT BETWEEN @unitPriceFromProducts * 0.85 AND @unitPriceFromProducts * 1.15
BEGIN
	ROLLBACK TRANSACTION 
	RAISERROR ('The inserted unit price can''t be correct', 14,1)
END 

-- Testcode
BEGIN TRANSACTION
INSERT INTO OrderDetails 
VALUES (10249, 72, 60.00, 10, 0.15)
SELECT * FROM OrderDetails WHERE OrderID = 10249
ROLLBACK


/*******************************/
/**** Update after - trigger  **/
/*******************************/

-- Triggering instruction is an update statement 

-- If a record is updated in OrderDetails => check if the new unitPrice is not too low or too high
-- If so, rollback the transaction and raise an error
CREATE OR ALTER TRIGGER updateOrderDetails ON OrderDetails FOR update
AS
DECLARE @updatedProductID INT = (SELECT ProductID From inserted)
DECLARE @updatedUnitPrice Money = (SELECT UnitPrice From inserted)
DECLARE @unitPriceFromProducts Money = (SELECT UnitPrice FROM Products WHERE ProductID = @updatedProductID)
IF @updatedUnitPrice NOT BETWEEN @unitPriceFromProducts * 0.85 AND @unitPriceFromProducts * 1.15
BEGIN
	ROLLBACK TRANSACTION 
	RAISERROR ('The updated unit price can''t be correct', 14,1)
END 

-- Testcode
BEGIN TRANSACTION
UPDATE OrderDetails SET UnitPrice = 60 WHERE OrderID = 10249 AND ProductID = 14
SELECT * FROM OrderDetails WHERE OrderID = 10249
ROLLBACK

-- Conditional execution of triggers: execute only if a specific column is mentioned in update or insert

CREATE OR ALTER TRIGGER updateOrderDetails ON OrderDetails FOR update
AS
-- If a record is updated in OrderDetails => check if the new unitPrice is not too low or too high
-- If so, rollback the transaction and raise an error
IF update(unitPrice)
BEGIN
	DECLARE @updatedProductID INT = (SELECT ProductID From inserted)
	DECLARE @updatedUnitPrice Money = (SELECT UnitPrice From inserted)
	DECLARE @unitPriceFromProducts Money = (SELECT UnitPrice FROM Products WHERE ProductID = @updatedProductID)
	IF @updatedUnitPrice NOT BETWEEN @unitPriceFromProducts * 0.85 AND @unitPriceFromProducts * 1.15
	BEGIN
		ROLLBACK TRANSACTION 
		RAISERROR ('The updated unit price can''t be correct', 14,1)
	END 
END

-- If a record is updated in OrderDetails => check if the new discount is not too low or too high
-- If so, rollback the transaction and raise an error
IF update(Discount)
BEGIN
	SELECT Discount FROM inserted
	DECLARE @updatedDiscount REAL = (SELECT Discount FROM inserted)
	IF @updatedDiscount NOT BETWEEN 0 AND 0.25
	BEGIN
		ROLLBACK TRANSACTION 
		RAISERROR ('The updated discount can''t be correct', 15,1)
	END 
END


-- Testcode
BEGIN TRANSACTION
UPDATE OrderDetails SET Discount = 0.5 WHERE OrderID = 10249 AND ProductID = 14
SELECT * FROM OrderDetails WHERE OrderID = 10249
ROLLBACK


/**********************************/
/**** Triggers and transactions  **/
/**********************************/

-- A trigger is part of the same transaction as the triggering instruction
-- Inside the trigger this transaction can be ROLLBACKed
-- Although a trigger in SQL Server occurs after the triggering instruction, that instruction can still be undone in the trigger


/****************************************************************/
/**** 1 trigger for insert and/or update and/or delete  *********/
/****************************************************************/

-- 1 Trigger can be used for update and/or insert and/or delete
-- If necessary, you can  distinguish between insert, update and delete


-- To check if this is an insert operation
IF NOT EXISTS (SELECT * FROM deleted)
BEGIN

END

-- To check if this is a delete operation
IF NOT EXISTS (SELECT * FROM inserted)
BEGIN

END


-- If a record is inserted or updated in OrderDetails => check if the new unitPrice is not too low or too high
-- If so, rollback the transaction and raise an error
CREATE OR ALTER TRIGGER updateOrInsertOrderDetails ON OrderDetails FOR update, insert
AS
DECLARE @updatedProductID INT = (SELECT ProductID From inserted)
DECLARE @updatedUnitPrice Money = (SELECT UnitPrice From inserted)
DECLARE @unitPriceFromProducts Money = (SELECT UnitPrice FROM Products WHERE ProductID = @updatedProductID)
IF @updatedProductID NOT BETWEEN @unitPriceFromProducts * 0.85 AND @unitPriceFromProducts * 1.15
BEGIN
	ROLLBACK TRANSACTION 
	RAISERROR ('The unit price can''t be correct', 14,1)
END 


-- Testcode
BEGIN TRANSACTION
UPDATE OrderDetails SET UnitPrice = 60 WHERE OrderID = 10249 AND ProductID = 14
SELECT * FROM OrderDetails WHERE OrderID = 10249
ROLLBACK

/****************/
/**** Remarks  **/
/****************/

/*
In addition to differences in syntax, the SQL products also differ in the functionality of triggers. 
Some interesting questions are:
- Can multiple triggers be defined for a single table and a specific transaction? 
  Sequence problems that can affect the result
- Can processing a statement belonging to a trigger action trigger another trigger?
  One mutation in an application can lead to a waterfall of mutations, recursion
- When exactly is a trigger action processed? 
  Immediately after the change or before the commit statement
- Can triggers be defined on catalog tables?
*/

/******************/
/**** Exercises  **/
/******************/

-- Exercise 1
-- Create a trigger that, when adding a new employee, sets the reportsTo attribute 
-- to the employee to whom the least number of employees already report.



Create or alter Trigger Insert_employee on Employees for insert
as
Declare @ReportsTo int = 0
Select TOP(1) @ReportsTo = ReportsTo
From Employees
Where ReportsTo is not null
group by ReportsTo
Order By Count(EmployeeID) asc

UPDATE Employees set ReportsTo = @ReportsTo
Where EmployeeID = (select EmployeeID from inserted)




-- Testcode
BEGIN TRANSACTION
INSERT INTO Employees(LastName,FirstName)
VALUES ('New','Emplo');

SELECT EmployeeID, LastName, FirstName, ReportsTo
FROM Employees
ROLLBACK

-- Exercise 2
create table ProductsAudit
(
	AuditID int identity(1,1) not null,
	UserName nvarchar(128) not null default System_User,
	CreatedAt DateTime default getdate(),
	Operation nvarchar(10)
)

/* 
Create a new table called ProductsAudit with the following columns:
AuditID --> Primary Key + Identity
UserName --> NVARCHAR(128) + Default value = SystemUser
CreatedAt --> DateTime + Default value = UTC Time
Operation --> NVARCHAR(10): The name of the operation we performed on a row (Updated, Created, Deleted)

If the table is already present, drop it.
Create a trigger for all actions (Update, Delete, Insert) to persist the mutation of the Products table.
Use system functions to populate the UserName and CreatedAt.
*/
Create or alter trigger Trigger_products on products for UPdate, insert, delete 
as
Declare @operation nvarchar(10)
--insert?
if not exists(select * from deleted)
begin 
	set @operation = 'insert'
end
--delete?
if not exists(select * from inserted)
begin 
	set @operation = 'delete'
end
else
begin
	set @operation = 'update'
end
insert into ProductsAudit(UserName,CreatedAt,Operation)
Values (SYSTEM_USER, GETDATE(),@operation)

-- TestCode
BEGIN TRANSACTION
DECLARE @productId INT;


INSERT INTO Products(ProductName, Discontinued)
VALUES('New product100', 0)
SET @productId =@@IDENTITY;
UPDATE Products
SET productName = 'abc'
WHERE ProductID = @productId

DELETE FROM Products
WHERE ProductID = @productId

SELECT * FROM ProductsAudit -- Changes should be seen here.
ROLLBACK