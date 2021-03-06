# Relational Databases & Datawarehousing

| Inhoud                                                                   |
| :----------------------------------------------------------------------- |
| [0. praktische info](#praktische-info)                                   |
| [1. SQL review](#SQL-review)                                             |
| [2. SQL Advanced](#SQL-advanced)                                         |
| [3. Window functions](#window-functions)                                 |
| [4. DB Programming](#Database-Programming)                                     |
| [5. Indexen](#indexen)                                                   |
| [6. Basics of Transaction Management](#basics-of-transaction-management) |
| [7a. DWH + BI](#DWH-BI)                                                  |
| [7b. AdventureWorks Intro - Starschema - Filling](#AdventureWorks)       |

# praktische info

# SQL review

## Data Definition Language | DDL

- CREATE
- ALTER
- DROP

## Data Manipulation Language | DML

- SELECT
- INSERT
- UPDATE
- DELETE

## Data Control Language | DCL

- GRANT
- REVOKE
- DENY

<br>

| Wildcard | Description                           |
| -------- | ------------------------------------- |
| %        | 1 or more characters                  |
| \_       | 1 character                           |
| []       | 1 char in a specified range           |
| [^]      | every char not in the specified range |

<br>

| Clause   | Description                                        |
| -------- | -------------------------------------------------- |
| SELECT   | Specifies the colums to show up in the output      |
| DISTINCT | filters out the duplicates                         |
| FROM     | Table names                                        |
| WHERE    | Filter condition on individual lines in the output |
| GROUP BY | Grouping of data                                   |
| HAVING   | Filter conditions on groups                        |
| ORDER BY | Sorting                                            |

<br>

## WHERE

> =, >, >=, <, <=, <>  
> OR, AND, NOT  
> IN, NOT IN  
> IS NULL, IS NOT NULL  
> wildcards

<br>

## ORDER BY

> DESC

<br>

## Aliases

> AS 'insert name here'

<br>

## Calculated results

> +, -, /, \*

<br>

## Diverse functions

| type   | function                                                       |
| ------ | -------------------------------------------------------------- |
| format | LTRIM, RTRIM, LEN, LEFT, RIGHT, SUBSTRING, REPLACE, CONCAT ... |
| date   | DATEADD, DATEDIFF, DAY, MONTH, YEAR, GETDATE()                 |
| math   | ABS, ROUND, FLOOR, CEILING, COS, SIN, AVG, SUM                 |
| null   | ISNULL                                                         |
| other  | TOP, STR                                                       |

<br>

## CASE

```SQL
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END;
```

<br>

| having vs where |                                                      |
| --------------- | ---------------------------------------------------- |
| having          | works on groups, conditions on aggregation functions |
| where           | only works on indivdual rows                         |

<br>

## Consulting more then 1 table

> JOIN
>
> - inner join
> - outer join
> - cross join
>
> UNIONS <br>
> Subquery's
>
> - simple nested query's
> - correlated query's
> - operator EXISTS <br>
>
> SET operators <br>
> Common table expressions

<br>

## JOIN

![JOIN Scheme](IMG/JOINsceme.png)

### INNER JOIN

```SQL
SELECT column_name(s)
FROM table1
INNER JOIN table2
ON table1.column_name = table2.column_name;
```

### OUTER JOIN

```SQL
-- left outer join
SELECT column_name(s)
FROM table1 x
LEFT JOIN table2 y
ON x.column_name = y.column_name;

-- right outer join
SELECT column_name(s)
FROM table1 x
RIGHT JOIN table2 y
ON x.column_name = y.column_name;

--- Full outer join
SELECT column_name(s)
FROM table1 x
FULL OUTER JOIN table2 y
ON x.column_name = y.column_name
WHERE condition;
```

### CROSS JOIN

```SQL
SELECT column_name(s)
FROM table1 x
CROSS JOIN table2 y;
```

<br>

# SQL advanced

## Subqueries

- outer level query -> the first SELECT. This is the main question.
- inner level query -> the SELECT in the WHERE or HAVING clause. subquery.

The subquery is:

- always executed first
- always between ()
- Subqueries can be nested at > 1 level

a subquery can return **one value** or **a list of values**

<br>

### Subquery returns a single value

```SQL
--- products that cost more then the average

SELECT ProductID, ProductName, UnitPrice As MaxPrice
FROM Products
WHERE UnitPrice > (SELECT AVG (UnitPrice) FROM Products)


--- Who is the youngest employee from the USA

SELECT LastName, FirstName
FROM Employees
WHERE Country = 'USA'
AND BirthDate = (SELECT MAX(Birthdate) FROM Employees WHERE Country = 'USA')
```

<br>

### Subquery returns a single column

```SQL
--- Give all customers that have not placed an order yet

SELECT *
FROM customers
WHERE CustormerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)

--- method via JOIN

SELECT *
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL

```

<br>

### ANY and ALL keywords

|     |                                                                           |
| --- | ------------------------------------------------------------------------- |
| ANY | greater than every value                                                  |
| ALL | returns true if all values returned in the subquery satisfy the condition |

<br>

### Correlated subqueries

- inner query depends on the information of the outer query.
- subquery is executed for each row in the main query.
- the order is from top to bottom, not from bottom to top as in a simple subquery.

```SQL
SELECT ...
FROM table a
WHERE expression operator (
    SELECT ...
    From table
    WHERE expression operator a.columnname
)
```

Example: Give employees with a salary larger than the avarage salary.
```SQL
SELECT FirstName + ' ' + LastName As FullName, Salary, ReportsTo
FROM Employees AS e
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE ReportsTo = e.ReportsTo)
```
### Subqueries and the EXISTS operator

- The operator exists test existence of a result set (Also a NOT EXISTS operator)

Example:
```SQL
SELECT * 
FROM Customers As c
WHERE EXISTS (SELECT * FROM Orders WHERE CustomerID = c.CustomerID)
```

### 3 ways to accomplish the same result

Example:
- OUTER JOIN
```SQL
SELECT *
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL
```
- Simple Subquery
```SQL
SELECT *
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)
```
- Correlated subquery
```SQL
SELECT *
FROM Customers As c
WHERE NOT EXISTS
(SELECT * FROM Orders WHERE CustomerID = c.CustomerID)
```
### Subqueries in the FORM-clause

- Since the result of a query is a table it can be used in the FROM-clause.
- In MS-SQL Server the table in the subquery must have a name. You can optionally also rename the columns.
- A subquery in the FROM clause is called a derived table.
- Example: Give per region the total sales (region USA+Canada = North America, rest = Rest of World).
```SQL
SELECT Regionclass, COUNT(OrderID)
FROM(SELECT CASE c.Country 
WHEN 'USA' THEN 'Northern America' 
WHEN 'Canada' THEN 'Northern America' 
ELSE 'Rest of world' 
END AS Regionclass, o.OrderID 
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID)
AS Totals(Regionclass, OrderID)
GROUP BY Regionclass
```
## Subqueries in the SELECT-clause
- In a SELECT clause scalar (simple or correlated) subqueries can be used
    - Example: Give for each employee how much they earn more (or less) than the average salary of all employees with the same supervisor.
    ```SQL
    SELECT LastName, FirstName, Salary, Salary - (
        SELECT AVG(Salary)
        FROM Employees
        WHERE RepourtsTo = e.ReportsTo
    )
    FROM Employees e
    ```

### Subqueries in the SELECT- and FROM-clause
- Example: Give per category the price of the cheapest product and a product that has that price.
```SQL 
SELECT category, MinUnitPrice,
(
    SELECT TOP 1 ProductID
    FROM Products
    WHERE CategoryID = Category AND UnitPrice = MinUnitPrice
) AS ProductID
FROM
(
    SELECT CategoryID, MIN(UnitPrice)
    FROM Products p
    GROUP BY CategoryID
) AS CategoryMinPrice(Category, MinUnitPrice)
```
## DML

### SQL - DML basic tasks
- SELECT -> consulting data
- INSERT -> adding data
- UPDATE -> changing data
- DELETE -> removing data
- MERGE -> combine INSERT, UPDATE and DELETE

### Tip for not destorying your database
- The statements in this chapter are destructive.
- SQL has no UNDO by default!
- BUT you can 'simulate' UNDO if you take precautions.
```SQL 
/* Tip for not destroying ur database */
BEGIN TRANSACTION -- starts a new "transaction" -> Saves previous state of DB in buffer

--Several "destructive" commands can go here:
INSERT INTO Products(ProductName)
VALUES ('TestProduct')

-- Only you (in your session) can see changes
SELECT * FROM Products WHERE ProuctID = (SELECT MAX(ProductID) FROM Products)

ROLLBACK; --> ENDS transaction and restores database in previous state
-- COMMIT; --> ENDS transaction and makes changes permanent!!
```

## DML: INSERT: add new records

### Addint data - INSERT
- The INSERT statement adds data in a table
    - add one row through via specification
    - add selected row(s) from other tables

### INSERT of 1 row
- Method 1: specify only the (not NULL) values for specific columns.
- Method 2: specify all column values
- If the indentity is generated automatically, this column can't be mentioned.
```SQL
--1.
INSERT INTO Products(ProductName, CategoryID, Discontinued)
VALUES ('Toblerone', 3, 0)

--2.
INSERT INTO Products
Values ('Sultana', null,3,null,null, null, null, null,1z)
```

### INSERT of rows selected from other tables
- Mandatory fields have to be specified, unless they have a DEFAULT value.
- Contraints (see further) are validated.
- Unmentioned colums get the value NULL or the DEFAULT value in any.
Example:
```SQL
INSERT INTO Customers(CustomerID, ContactName, ContactTitle, CompanyName)
SELECT substring(FirstName,1,2)+ substring(LastName,1,3), FirstName + ' ' + LastName, Title, 'EmployeeCompany'
FROM Employees
```

## DML: UPDATE: modify values

### Changing data - UPDATE
- Changing all rows in a table
    - Example
    ```SQL
    UPDATE Products
    SET UnitPrice = UnitPrice *1.1
    ```
- Changing 1 row or a group of rows
    - Example
    ```SQL
    UPDATE Products
    Set UnitPrice = UnitPrice *1.1, UnitStock = 0
    WHERE ProductName Like '%Brod%'
    ```
- Change rows based on data in another table
    - Standard SQL does not offer JOINs in an update statement -> You can only use subqueries to refer to another table
    - Example: Due to change in the euro - dollar exchange rate, we have to increase the unit price of products delivered by suppliers from the USA by 10%
    ```SQL
    UPDATE Products
    SET UnitPrice = (UnitPrice * 1.1)
    WHERE SuppliersID in 
    (SELECT SupplierID FROM SUppliers WHERE Country = 'USA')
    ```
## DML: DELETE: Remove records

### Removing data - DELETE

- Delete some rows
    - Example
    ```sql
    DELETE FROM Products
    WHERE ProductName LIKE '%Brod%'
    ```
- Delete all rows in a table
    - via DELETE the identity values continues
    ```sql
    -- the identity value continues
    DELETE FROM Products
    ```
    - via TRUNCATE the identity value restarts from 1
    Truncate is also more performant, but does not offer WHERE clause: it's all or nothing
    ```sql
    -- The identity value restarts fromm 1
    TRUNCATE TABLE Products
    ```

### DELETE - Based on data in another table
- Change rows based on data in antoher table
    - Again no JOIN, only subquery
    - Exaple: Delete the orderdetails for all orders form the most recent orderdate
    ```SQL
    DELETE FROM OrderDetails
    WHERE OrderID IN
    (SELECT OrderID FROM Orders WHERE OrderDate = (SELECT MAX(OrderDate) FROM Orders))
    ```
### DML: MERGE: combine INSERT, UPDATE, DELETE

### Merge
- With MERGE you can combine INSERT, UPDATE and DELETE.
- Very common use case: users work on a Excel sheet to update a relatively large amount of records because Excel offers a better overview than their ERP tool.

- Script to create temporary table
```SQL
/* First execute following script to simulate the Excel file that has been imported to a temporary table ShippersUpdate */
DROP TABLE IF EXISTS ShippersUpdate;
-- Add everything from shippers to shippersUpdate
SELECT * INTO ShippersUpdate FROM Shippers

--Add an extra record to shippersUpdate
INSERT INTTO ShippersUpdate Values('Pickup', '(503) 555-9647')

-- Update a record of shippersUpdate
UPDATE ShippersUpdate SET Phone = ' (503) 555-4512' WHERE ShipperID = 1

-- REMOVE a record fromm ShippersUpdate
DELETE FROM ShippersUpdate WHERE ShipperID = 4
```

Merge result:

<img src="IMG\MergeResult.png" width=800>

## Views

### Views - Introduction
- Definition
    - A view is a saved SELECT statement
    - A view can be seen as a virtual table composed of other tables & views
    - No data is stored in the view itself, at each referral the underlying SELECT is re-executed.
- Advantages
    - Hide complexity of the database
    - Used for securing data acces
    - Organise data for export to other applications
```SQL
CREATE VIEW view_name [(Column_List)] AS Select_Stement
[With check option]
```
- Number of columns in (Column_List) = # Columns in select
- The select statement may not contain an order by
- With check option: in case of mutation through the view (Insert, update, delete) it is chekced if the new data also conforms to the view conditions

### Views - CRUD operations

- Creating a view
```SQL
CREATE VIEW V_ProductsCustomer(Productcode, company, quantity)
AS SELECT od.ProductID, c.CompanyName, SUM(od.Quantity)
FROM Customers c
JOIN Orders o ON o.CustomerID - c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY od.ProductID, c.CompanyName
```
- Using a view 
```SQL
SELECT * FROM V_ProductsCustomer
```
- Changing a view
```SQL
ALTER VIEW V_ProductsCustomer(productcode, company)
AS SELECT od.ProductID, c.CompanyName
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
JOIN OrderDetails od on o.OrderID = od.OrderID
GROUP BY od.ProductID, c.CompanyName
```
- Deleting a view
```SQL
DROP VIEW V_ProductsCustomer
```

### Update of views
- An updateable view
    - Has no distinct or top clause in the select statement
    - Has no statistical functions in the select statement
    - Has no calculted value in the select
    - Has no Group by in the select
    - Does not use a union
- All other views are read-only views
- In general view are updatable if the system is able to translate the updates to individual records and fields in the underlying tables. So use you common sense.

### Working with updatable views
- UPDATE
    - You can update only once
    - Withouth check option
        - After the update a row can disappear from the view
    - With check option
        - An error is generated if after the update the row would no longer be part of view
- INSERT 
    - You can only insert in one table
    - All mandatory colums have to appear in the view and the insert
- DELETE
    - The delete can only be used with a VIEW based on exactly one table.

Examples: 

<img src="IMG\UpdateViews1.png" width=800>

<img src="IMG\UpdateViews2.png" width=800>

## COMMON TABLE EXPRESSIONS

### Common Table Expressions: The WITH component
- Example: Give the avarage number of orders for all customers
- Solution 1 -> Using subqueries
```sql
SELECT AVG(numberOfOrders *1.0) AS AverageNumberOfOrdersPerCustomer 
FROM
(
    SELECT customerID, COUNT(orderID)
    FROM orders
    GROUP BY customerID
) AS numberOfOrdersPerCustomer(customerID, numberOfOrders)
```
- Solution 2 -> USING CTE's
- Using the WITH-Componetn you can give the subquery its own name (with column names) and reuse it in the rest of the query.
```SQL
WITH numberofOrdersPerCUstomer(customerID, numberOfOrders) AS
(SELECT customerID, COUNT(orderID)
From orders
GROUP BY customerID
)
SELECT AVG(numberOfOrders *1.0) AS AvarageNumberOfOrdersPerCustomer
FROM numberOfOrdersPerCustomer
```
- The WITH-component has two application areas:
    - Simplify SQL-insturctions, e.g. simplified alternative for simple subqueries or avoid repetition of SQL constructs
    - Traverse recursivly hieracrchical and network structures

### CTE's versus Views
- Similarities
    - With ~ Create View
    - Both are virtual tables
- Differences
    - A CTE only exist during the SELECT-Statement
    - A CTE is not visible for ohter users and apps
### CTE's vers Subqueries
- Similarities
    - Both are virtual tables
- Differences
    - A CTE can be reused in the same qeury
    - A subquery is defined in the clause wher it is used
    - A simple subquery can always be replaced by a CTE

### CTE's to simplify queries
- Example: Give per category the minimum price and all products with that mninmum price
```sql
-- Solution 1 -> with subqueries
SELECT CategoryID, ProductID, UnitPrice
From Products p
WHERE UnitPrice = (SELECT MIN(UnitPrice) FROM Products WHERE CategoryID = p.CategoryID)
```
```SQL
-- Solution 2 -> with CTE's
WITH CategoryMinPrice(Category, MinPrice)
AS (SELECT CategoryID, MIN(UnitPrice)
    FROM Products AS p
    GROUP BY CategoryID)

SELECT Category, MinPrice, p.ProductID
FROM Products AS p
JOIN CategoryMinPrice AS c ON p.CategoryID - c.Category AND p.UnitPrice = c.MinPrice
```
### CTE's with more than 1 WITH - component

- Example: Give per year per customer the relative contribution of this customer to the total revenue
- Step 1: Calculate the total revenue per year
```SQL 
SELECT YEAR(OrderDate), SUM(od.UnitPrice*od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate)
```
- Step 2: Calculate the total revenue per year per customer
```SQL
SELECT YEAR(OrderDate), o.CustomerID, SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), o.CustomerID
```
- Step 3: Combine both

<img src="IMG\CombineBoth.png" width=800>

### Recursive SELECTS's
- Recursivity means: ...
- This allows you to solve problems live:
    - Who are the friends of my friends etc.()
    - What is the hierarchy of an organisation?
    - Find the parts and subparts of a product
- Example: Give the integers form 1 to 5
```SQL
WITH numbers(number) AS
(SELECT 1
    UNION all
    SELECT number +1
    FROM numbers
    WHERE number <5)

SELECT * FROM numbers
```
- Characteristics of recusive use of WITH
    - The with component consists of (at least) 2 expressions, combined with union all
    - A temp table is consulted in the second expression
    - At least one of the expressions may not refer to the temp table

### Recursive SELECT's: max number of recurisons = 100
- Example: Give the mubmers from 1 to 999
```SQL
WITH numbers(number) AS
(SELECT 1
    UNION all
    SELECT number +1
    FROM numbers
    WHERE number<999)
SELECT * FROM numbers
```
## Window Functions

### Window fucntions: business case

- Often business managers want to compare current sales to previous sales
- Window functions offer a solution to these kind of problems in a single, efficient SQL query

### OVER Clause
- Results of a SELECT are partitioned
- Numbering, ordering and aggregate functions per partition
- The `OVER` clauses creates partitions and ordering
- The partition behaves as a window that shifts over the data
- The OVER clause can be used with standard aggregate functions (sum, avg...) or specific window fucntions (rank, lag ...)

- Example: Make an overview of the UnitInStock per Category and per Product
```SQL
SELECT CategoryID, ProductID, UnitInStock
FROM Products
ORDER BY CategoryID, ProductID
```
- Add an extra column to calculate the running total of Units per Category
- Sol 1: Correlated subquery 8 (Inefficient as for each line the complete sum is recalculated)
```SQL
SELECT CategoryID, ProductID, UnitInStock,
(SELECT SUM(UnitInStock)
FROM Products
WHERE CategoryID = p.CategoryID
    AND ProductID <= p.ProductID) TotalUnitsInStockPerCategory
From Products p
ORDER BY CategoryID, ProductID
```
- Sol 2: `OVER` Clause (simpler + more efficient, The sum is calculated for each partition)
```SQL
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductsID) TotalUnitsInStockPerCategory
FROM Products
ORDER BY CategoryID, ProductID
```

### Window functions - RANGE
- Real meaning of window functions: apply to a window that shifts over the result set
- The previous query works with the default window: start of result set to current row
```SQL
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductsID
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) TotalUnitsInStockPerCategory
FROM Products
ORDER BY CategoryID, ProductID
```
- With `Range` you have three valid options:
    - `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
    - `RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING`
    - `RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`
- Partition is optional, ORDER BY is mandatory


 UNBOUNDED PRECEDING AND CURRENT ROW |  CURRENT ROW AND UNBOUNDED FOLLOWING |  UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
:-----------------------------------:|:------------------------------------:|:--------------------------------------------:
<img src="IMG\RangePrecedingCurrentRow.png" width=200>|<img src="IMG\RangeCurrentFollowing.png" width=200>|<img src="IMG\RangePrecedingFollowing.png" width=200>

### Window Functions - ROWS
- When you use RANGE, the current row is compared to other rows and grouped based on the ORDER BY predicate.
- This is not always disirable. You might actually want a physical offset.
- In this scenario, you would specify ROWS instead of RANGE. This gives you Three options in addition to the three options enumerated previously:
    - `ROWS BETWEEN N PRECEDING AND CURRENT ROW`
    - `ROWS BETWEEN CURRENT ROW AND N FOLLOWING`
    - `ROWS BETWEEN N PRECEDING AND N FOLLOWING`
- Examples: Make an overview of the salary per employee and the average salary of this employee and the 2 employees preceding him
```SQL
SELECT EmployeeID, FirstName + ' ' + LastName AS FullName, Salary, AVG(Salary) 
OVER (ORDER BY Salary DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS AvgSalary2Preceding
FROM Employees
```
<img src="IMG\RowsBetweenN.png">

- Example2: Make an overview of the salary per employee and the average salary of this employee and the 2 employees following him
```SQL
SELECT EmployeeID, FirstName + ' ' + LastName AS FullName, Salary, AVG(Salary)
OVER (ORDER BY Salary DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS AvgSalary2Following
FROM Employees
```
<img src="IMG\RowsBetweenCurrent.png">

- Example3: Make an overview of the salary per employee and the avarage salary of this employee and the employee preceding and following him.
```SQL
SELECT EmployeeID, FirstName + ' ' + LastName AS FullName, Salary, AVG(Salary)
OVER (ORDER BY Salary DESC ROWS BETWEEN 1 ROW AND 1 FOLLOWING) AS AvgSalary2Following
FROM Employees
```
<img src="IMG\RowsBetweenNandFOllowing.png">

- ROW_NUMBER() nubmers the output of a result set. More specifically, returns the sequential number of a row within a partition of a result set, starting at 1 for the first row in each partition.

- RANK() returns the rank of each row within the partition of a result set. The rank of a row is one plus the number of ranks that come before the row in question 

- ROW_NUMBER and RANK are similar. ROW_NUMBER numbers all rows sequentially (for example 1, 2, 3, 4, 5). 

- RANK provides the same numeric value for ties (for example 1, 2, 2, 4, 5).
- DENSE_RANK() returns the rank of each row within the partition of a result set, with no gaps in the ranking values (for example 1, 2, 2, 3, 4). 
- PCT_RANK() shows the ranking on a scale from 0 -1

Example 1: Give ROW_NUMBER / RANK / DENSE_RANK / PERCENT_RANK for each employee based on his salary.
```SQL
SELECT EmployeeID, FirstName + ' ' + LastName as 'Full Name', Title, Salary,
ROW_NUMBER() OVER (ORDER_BY Salary DESC) as 'ROW_NUMBER',
RANK() OVER (ORDER_BY Salary DESC) as 'Rank',
DENSE_RANK() OVER (ORDER_BY Salary DESC) as 'DENSE_RANK',
PERCENT_RANK() OVER (ORDER_BY Salary DESC) as 'PERCENT_RANK'
FROM Employees
```
<img src="IMG\GiveRow_Numer1.png" width=600>

Example 2: Give ROW_NUMBER / RANK / DENSE_RANK / PERCENT_RANK per title for each employee based on his salary.
```SQL
SELECT EmployeeID, FirstName + ' ' + LastName as 'Full Name', Title, Salary,
ROW_NUMBER() OVER (PARTITION BY Title ORDER BY Salary DESC) as 'ROW_NUMBER',
RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) as 'Rank',
DENSE_RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) as 'DENSE_RANK',
PERCENT_RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) as 'PERCENT_RANK'
FROM Employees
```
<img src="IMG\GiveRow_Number2.png" width=600>

## LAG and LEAD

- LAG refers to the previous line. This is short for LAG(...,1)
- LAG(...,2) refers to the line before the previous line,...
- LEAD refers to the next line. This is short for LEAD(...,1)
- LEAD(...,2) refers to the line after the next line,...

### LAG
- Example: Calculate for each emploeyee the percentage difference between this employee and the employee preceding him.
```sql
SELECT EmployeeID, FirstName + ' '+ LastName, Salary, 
FORMAT((Salary - LAG(Salary) OVER(ORDER BY Salary DESC)) / Salary, 'P') AS EarnLessThanPreceding
FROM Employees
```

### LEAD
- Example: Calculate for each employee the percentage difference between this employee and the employee following him
```sql
SELECT EmployeeID,FirstName +' '+LastName,Salary,
FORMAT((Salary -LEAD(Salary)OVER (ORDERBYSalary DESC))/Salary,'P')As EarnsMoreThanFollowing
FROM Employees
```

# Database Programming

## SQL as complete language (PSM)

### Persistent Stored Modules
- Originally SQL was not a complete programming language
    - But SQL could be embedded in a standard progreamming language
- SQL/PSM, as a complete programming language
    - variables, constants, datatypes
    - operators
    - Controle structures
        - if, case, while, for...
    - procedures, functions
    - exception handling

- PSM = stored procedures and stored functions
- Examples
    - SQL Server: Transact SQL
    - Oracle: PL/ SQL
    - DB2: SQL PL

## Stored Procedures
### Stored procedure
A stored procedure is a named collection of SQL and control-of-flow commands (program) that is stored as a database object

- What?
    - Analogous to procedures/functions/methods in other languages
    - Can be called from a program, trigger or stored procedure
    - Is saved in the catalogue
    - Accepts input and output parameters
    - Returns status information about the correct or incorrect execution of the stored procedure
    - Contains the tasks to be executed

### Local variables
- A variable name always starts with a @
```SQL
DECLARE @variable_name1 data_type [, @variable_name2 data_type ...]
```
- Assign a value to a variable
```sql
SET @variable_name = expression
SELECT @varaible_name = column_specification
```
- SET and SELECT are equivalent, but set is ANSI standard
- With select you can assign a value to several variables at once:
```SQL
DECLARE @maxQuantity SMALLINT, @maxUnitPrice MONEY, @minUnitPrice MONEY
SET @maxQuantity = (SELECT MAX(quantity) FROM OrderDetails)
SELECT @maxQuantity = MAX(quantity) FROM OrderDetails
SELECT @maxUnitPrice = MAX(UnitPrice), @minUnitPrice = MIN(UnitPrce) FROM Products
```
- PRINT: SQL Server Management Studio shows a message in the message tab
```SQL
PRINT string_expression
```
- As an alternative you can also use SELECT
```Sql
DECLARE @maxQuantity SMALLINT
SELECT @maxQuantity = MAX(quantity) FROM OrderDetails

--RESULT in tab messages
PRINT 'The maximum orderd quantity is ' + STR(@maxQuantity)

--Result in tab result
SELECT 'The maximum orderd quantity is ' + STR(@maxQuantity)
```
### Operators in Transact SQL
- Arithmetic operators: 
    - -,+,*,/,%(modulo)
- Comparison operators:
    - <,>,=,..., IS NULL, LIKE, BETWEEN, IN
- Alphanumeric operators
    - +(String concatenation)
- Logic operators
    - AND, OR, NOT

### Control flow with Transact SQL
```SQL
CREATE PROCEDURE ShowFirstXEmployees @x INT,@missed INT OUTPUT
AS
DECLARE @empid INT,@fullname VARCHAR(100),@city NVARCHAR(30),@total int SET@empid =1
SELECT@total =COUNT(*)
FROM Employees
--SET @total = (SELECT COUNT(*) FROM Employees)
SET @missed =10 
IF @x > @total
    SELECT @x =COUNT(*)
    FROM Employees 
ELSE
    SET @missed = @total - @x 
WHILE @empid <= @x 
BEGIN 
    SELECT @fullname =firstname +' '+lastname, @city =city 
    FROM Employees 
    WHERE employeeid = @empid
    PRINT'Full Name : '+@fullname
    PRINT'City : '+@city
    PRINT'-----------------------'
    SET @empid = @empid +1
END
```

```SQL
--- Testcode
DECLARE @NumberOfMissedEmployees INT
SET @numberOfMissedEmployees = 0
EXEC ShowFirstXEmployees 5, @numberOfMissedEmployees OUT -- don't forget out
PRINT 'Number of missed employees: ' + STR(@numberOfMissedEmployees)
```

### Creation of SP
```SQL
CREATE PROCEDURe <proc_name> [parameter declaratie]
AS
<sql_statements>
```
- Create db object: via DDL instruction
- Syntax control upon creation. The SP is only stored in the DB if it is syntactically correct

```SQL
CREATE PROCEDURE OrdersSelectAll
AS
SELECT * FROM Orders
```

OR 

<img src="IMG\CreationOfSP.png" width=800>
<br>

### Procedural database objects
- Initial behaviour of a stored procedure <br><img src="IMG\ProceduralDatabaseObjects.png" width=800>


<br>

### Changing and removing a SP
```SQL
ALTER PROCEDURE <proc_name> [parameter declaration]
AS
<sql_statements>
```
```SQL
DROP PROCEDURE <proc_name>
```

<br>

### Return value of SP
- After execution a SP `returns a value`
    - Of type INT
    - Default return value=0
- RETURN statement
    - Execution of SP stops
    - Return value can be specified

```SQL 
--- Creation of SP with explicit return value
CREATE PROCEDURE OrderSelectAll AS
SELECT * FROM Orders
RETURN @@ROWCOUNT
```
```SQL
--- Use of SP with return value.
--- Result of print comes in Messages tab.
DECLARE @numberOfOrders INT
EXEC @numberOfOrders = OrdersSelectAll
PRINT 'We have ' + STR(@numberOfOrders) + ' orders.'
```

### SP with parameters
- Types of parameters
    - A parameter is passed to the SP with an INPUT parameter
    - With an OUTPUT you can possibly pass a value to the SP and get a value back

```SQL
CREATE PROCEDURE OrdersSelectAllForCustomers @customerID int, @numberOfOrders int OUTPUT
AS 
SELECT @numberOfOrders = COUNT(*)
FROM orders
WHERE custumerID = @customerID

-- Use of a default value for the imput parameter
CREATE PROCEDURE OrdersSelectAllForCustomer @customerID int = 5, @nubmerOfOrders int OUTPUT
AS 
SELECT @nubmerOfOrders = COUNT(*)
FROM Orders
WHERE customerID = @customerID
```
- Calling the SP
    - Always provide keyword OUTPUT for output parameters
    - 2 ways to pass actual parameters
        - use formal parameter name (order unimportant)
        - positional
```sql
-- Pass param by explicit use of formal parameters
DECLARE @nmbrOfOrders INT
EXECUTE OrdersSelectAllForCustomer @customerID = 5, @numberOFOrders = @nmbrOfOrders OUTPUT
PRINT @nmberOfOrders

-- Positional parameter passing
DECLARE @nmbrOfOrders INT
EXECUTE OrdersSelectAllForCustomer 5, @nmbrOfOrders OUTPUT
PRINT @nmbrOfOrders
```

### Error handling in Transact SQL

- `RETURN`
    - Immediate end of execution of the batch procedure
- `@@error`
    - Contains error number of last executed SQL instruction
    - Value = 0 if OK
- `RAISERROR`
    - Returns user definded error or system error
- `Use of TRY ... CATCH block`

### ERROR handling -> using @@error

```sql
CREATE
PROCEDURE ProductInsert @productName nvarchar(50)=NULL, @categoryID int=NULL AS 
DECLARE @errormsg int 
INSERT INTO Products(ProductName,CategoryID,Discontinued)VALUES (@productName,@categoryID,0)
--save @@error to avoid overwriting by consecutive statements
SET @errormsg =@@error
IF @errormsg =0
    PRINT'SUCCESS! The product has been added.'
ELSE IF @errormsg =515 
    PRINT'ERROR! ProductName is NULL.'
ELSE IF @errormsg =547 
    PRINT'ERROR! CategoryID doesn''t exist.'
ELSE PRINT'ERROR! Unable to add new product. Error:'+str(@errormsg)

RETURN @errormsg
--Testcode
BEGIN TRANSACTION
    EXEC ProductInsert 'Wokkels', 10 
    SELECT * FROM Products WHERE productName LIKE'%Wokkels%'
ROLLBACK;
```

- All systems error messages are in the system table sysmessages
```SQL
SELECT * FROM master.dbo.sysmessages WHERE error = @@ERROR
```
- Create your own messages using raiserror
    - RAISERROR(msg, severity, state)
        - msg - the error message
        - severity - value between 0 and 18
        - state - value between 1 and 127, to distinguish between consecutive calls with same message.
### Error handling -> using RAISERROR
```SQL
CREATE
PROCEDURE ProductInsert @productName nvarchar(50)=NULL, @categoryID int=NULL AS 
DECLARE @errormsg int 
INSERT INTO Products(ProductName,CategoryID,Discontinued)VALUES (@productName,@categoryID,0)
--save @@error to avoid overwriting by consecutive statements
SET @errormsg =@@error
IF @errormsg =0
    PRINT 'SUCCES! The product has been added.'
ELSE IF @errormsg = 515
    RAISERROR ('ProductName or CategoryID is NULL.',18,1)
ELSE IF 
    RAISERROR ('',18,1)
ELSE PRINT '' +str(@errormsg)

return @errormsg

-- Testcode
BEGIN TRANSACTION
    EXEC ProductInsert 'Wokkels', 10
    SELECT * FROM Products WHERE productName LIKE '%Wokkels%'
ROLLBACK;
```

### Exception handling: catch-block functions
- ERROR_LINE(): line number where exception occurred
- ERROR_MESSAGE(): error message
- ERROR_PROCEDURE(): SP where exception occured
- ERROR_NUMBER(): error number
- ERROR_SEVERITY(): severity level

### Throw
- Is an alternative to RAISERROR
- Raises an exception and transfers execution to a CATCH block of a TRY...CATCH contstruct in SQL Server.
- Without parameters: only in catch block (= rethrowing the caught exception)
- With parameters: also outside catch block
- create your own user defined exceptions
    - THROW (error_number, message, state)
        - error_number: represent the exception. Is an int between 50000 and 2147483647.
        - state: value between 1 and 127, to distinguish between consectutive calls with the same message.

## Functions

### Why user defined functions?
- Give the age of each employee:
```sql
SELECT lastname, firstname, birthdate, GETDATE() as today, DATEDIFF(YEAR,birthdate,GETDATE()) age
FROM employees
```
first one will not be happy


- Give the age of each employee:
```sql
SELECT lastname, firstname, birthdate, GETDATE() as today, DATEDIFF(YEAR,birthdate,GETDATE())/365 age
FROM employees
```
Better but doesn't take into account leap years

### Solution: user defined function
```sql
CREATE FUNCTION GetAge(@birthdate AS DATE,@eventdate AS DATE)
RETURNS INT AS
BEGIN 
    RETURN
    DATEDIFF(year,@birthdate,@eventdate)
       CASE WHEN 100 *MONTH(@eventdate)+DAY(@eventdate)
       <100 *MONTH(@birthdate)+DAY(@birthdate)
       
    THEN 1 ELSE 0 
    END;
END;

--- How to use?
SELECT lastname,firstname,birthdate,GETDATE() As today,dbo.GetAge(birthdate,GETDATE()) age
FROM employees
```

### User defined functions 
- Give per product category the price of the cheapest product that costs more than x $ and a product with that price.
```SQL
Select lastname, firstname, birthdate,GETDATE() as today, DATEDIFF(DAY,birthdate,GETDATE()) / 365 age
FROM Employees
```

## CURSORS

- `SQL statements are processing complete resultsets and not individual rows. Cursors allow to process individual rows to perform complex row specefic operations that can't (easily) be performed with a single SELECT, UPDATE or DELETE statement.`
- A cursor is a database object that refers to the result of a query. It allows to specify the row from the resultset you wish to process.
- 5 important cursor related statements
    - DECLARE CURSOR - creates and defines the cursor
    - OPEN - opens the declared cursor
    - FETCH - fetches 1 row
    - CLOSE - closes teh cursor (counterpart of OPEN)
    - DEALLOCATE - remove the cursor definition

<img src="IMG\Cursors.png" width=800>

### Cursor declaration

```sql
DECLARE <cursor_name> [INSENSITIVE] [SCROLL] CURSOR FOR <SELECT_statement>
[FOR {READ ONLY | UPDATE [OF <column list>]}]
```
- INSENSITIVE
    - The cursor uses a temporary copy of the data
        - Changes in underlying tables after opening the cursor are not reflected in data fetched by the cursor 
        - The cursor can't be used to change data (read-only, see below)
    - If INSENSITIVE is omitted, deletes and updates are refelected in the cursor
        - -> less performant because each row fetch executes a SELECT
- SCROLL
    - All fetch operations are allowed 
        - FIRST, LAST, PRIOR, NEXT, RELATIVE and ABSOLUTE
        - Might result in difficult to understand code
    - If SCROLL is omitted only NEXT can be used
- READ ONLY
    - Prohibits data changes in underlying tables through cursor 
- UPDATE
    - Data changes are allowed
    - Specify columns that can be changed via the cursor

### Opening a cursor

```sql
OPEN <cursor name>
```
- The cursor is opened
- The cursor is "filled"
    - The select statement is executed. A "virtual table" is filled with the "active set".
- The cursor's current row pointer is positioned just before the first row in the result set.


### Fetching data with a cursor
```sql
FETCH [NEXT | PRIOR | FIRST | LAST | {ABSOLUTE | RELATIVE <row number>}]
FROM <cursor name>
[INTO <variable name>[,...<last variable name>]]
```
- The cursor is positioned
    - On the next (or previous, first, last,...) row
    - Default only NEXT is allowed
        - For other ways use a SCROLL-able cursor
- Data is fetched
    - without INTO clause resulting data is shown on screen
    - with INTO clause data is assigned to the specified variables
        - Declare a corresponding variable for each column in the cursor SELECT

### Closing a cursor
```sql
CLOSE <cursor name>
```
- The cursor is closed
    - The cursor definition remains
    - Cursor can be reopened

### Deallocating a cursor
```sql
DEALLOCATE <cursor name>
```
- The cursor definition is removed
    - If this was the last reference to the cursor all cursor resources (the "virtual table") are released.
    - If the cursor has not been closed yet `DEALLOCATE` wil close the cursor.

### Example 1
```SQL
--declare cursor
DECLARE suppliers_cursor CURSOR
FOR 
SELECT SupplierID, CompanyName, City
FROM Suppliers
WHERE Country ='USA'
DECLARE @supplierID INT, @companyName NVARCHAR(30), @city NVARCHAR(15)
--open cursor
OPEN suppliers_cursor
--fetch data
FETCH NEXT FROM suppliers_cursor INTO @supplierID, @companyName, @city 

WHILE @@FETCH_STATUS=0 
BEGIN
    PRINT'Supplier: '+ str(@SupplierID) + ' ' + @companyName + ' ' + @city
    FETCH NEXT FROM suppliers_cursor INTO @supplierID, @companyName, @city
END
--close cursor
CLOSE suppliers_cursor
--deallocate cursor 
DEALLOCATE suppliers_cursor
```
### Nested cursors

- In real-life programs you often need to declare and use two or more cursors in the same block.
- Often these cursors are related to each other by parameters.
- One common example is the need for multi-level reports in which each level of the report uses rows from a different cursor.


### Update and delete via cursors
```sql
DELETE FROM <table name>
WHERE CURRENT OF <cursor name>

UPDATE <table name>
SET ...
WHERE CURRENT OF <cursor name>
```
- Positioned update/delete
    - Deletes/updates the row the cursor referred in WHERE CURRENT OF points to
    - = cursor based positioned update/delete

## TRIGGERS

A `trigger`: a database program, consisting of procedural and declarative instructions, saved in the catalogue and activated by the DBMS if a certain operation on the database is executed and if a certain condition is satisfied.

- Comparable to SP but `can't be called explicitly`
    - A trigger is `automatically called by the DBMS` with some DML, DDL, LOGON-LOGOFF commands
        - DML trigger: with an `insert, update or delete` for a table or view (in this course we further elaborate this type of cursors)
        - DDL trigger: eecuted with a `create, alter or drop` of a table
        - LOGON-LOGOFF trigger: executed when a user logs in or out (MS SQL Server: only LOGON triggers, Oracle: both)

- DML triggers
    - Can be executed with
        - `insert`
        - `update`
        - `delete`
    - Are activated
        - `before` - before the IUD is processed (not supported by SQL Server)
        - `instead of` - instead of IUD command
        - `after` - after the IUID is processed (but before COMMIT), this is the defautl
    - In some DMBS you can also specify how many times the cursor is activated
        - `for each row`
        - `for each statement`

### Procedural database objects

- Procedural programs

|Types| Saved as| Executrion | Supports parameters |
|:---   |:----  |:----      |:----                  |
|Script| separate file | client tool| no|
|Stored Procedure| database object| via application or SQL script| yes|
|User defined function| database object| via application or SQL script| yes|
|Trigger| database object| via DML statement| no|

### Why using triggers?

- Validation of data and complex constraints
    - An employee can't be assigned to > 10 projects
    - An employee can only be assigned to a project that is assigned to his department
- automatic generation of values
    - If an employee is assigned to a project the default value for the monthly bonus is set acoording to the porject priority and his job category
- Support for alerts
    - Send automatci e-mail if an employee is removed from a project
- Auditing
    - Keep track of who did what on a certain table
- Replication and controlled update of redundant data
    - If an ordersdetail record changes, update the orderamount in the orders table
    - Automatic update of datawarehouse tables for reporting (see "Datawarehousing")

### Advantages
- Major advantagse
    - Store functionality in the DB and execute consistently with each change of data in the DB
- Consequences
    - no redundant code
        - functionality is localised in a single spot, not scattered over different applications (desktop, web, mobile), written by different authors
    - written and tested 'once' by an experienced DBA
    - security
        - triggers are in the DB so all security rules apply
    - more processing power
        - for DBMS and DB
    - fits into clinet-server model
        - 1 call to db-serve: al lot can be executed without further communication

### Disadvantages

- Complexity
    - DB design, implementation are more complex by shifting functionality from application to DB
    - Very difficult to debug
- Hidden functionality
    - The user can be confronted with unexpected side effects from the trigger, possibly unwanted
    - Triggers can cascade, which is not always easy to predict when designing the trigger
- Performance
    - At each database change the triggers have to be reevaluated
- Portability
    - Restricted to the chosen database dialect (ex. Transact-SQL from MS)


### Comparison of trigger functionality

### "Virtual" tables with triggers
- 2 temporary tables
    - `deleted` table contains copies of updated and deleted rows
        - During update or delete rows are moved from the triggering table to the `deleted` table
        - Those two table have no rows in common
    - `inserted` table conatains copies of updated or inserted rows
        - During update or insert each affected row is copied from the triggering table to the `inserted` table
        - All rows from the inserted table are also in the triggering table

- `deleted` and `inserted` table

<img src="IMG\VirtualTablesWithTriggers1.png" width=800>
<img src="IMG\VirtualTablesWithTriggers2.png" width=800>
<img src="IMG\VirtualTablesWithTriggers3.png" width=800>
<img src="IMG\VirtualTablesWithTriggers4.png" width=800>

### Creation of an after trigger

```sql
CREATE TRIGGER triggerName
ON TABLE
FOR [INSERT, UPDATE, DELETE]
AS ...
```
- Only by SysAdmin or dbo
- Linked to one table; not to a view
- Is executed
    - After execution of the triggering action, i.e. insert, update, delete
    - After copy of the changes to the temporary tables inserted and deleted
    - Before COMMIT
### Delete after - Trigger
- Triggering instruction is a delete instruction
    - deleted - logical table with columns equal to columns of triggering table, containing a copy of delete rows

```sql
-- If a record in OrderDetails is removed => UnitsInStock in Products should be updated
-- 1st try
CREATE OR ALTER TRIGGER deleteOrderDetails ON OrderDetails FOR DELETE
AS
DECLARE @deletedProductID INT=(SELECT ProductID From deleted)
DECLARE @deletedQuantity SmallINT=(SELECT Quantity From deleted)
UPDATE Products 
SET UnitsInStock = UnitsInStock + @deletedQuantity
FROM Products 
WHERE ProductID = @deletedProductID
--Testcode
BEGIN TRANSACTION
SELECT * FROM Products WHERE ProductID =14 OR ProductID =51 
DELETE FROM OrderDetails WHERE OrderID =10249 SELECT* FROM Products WHERE ProductID =14 OR ProductID =51 
ROLLBACK;
```
```sql
--If a record in OrderDetails is removed => UnitsInStock in Products should be updated
--In the previous solution: more than 1 record was found in deleted 
--=> error. Use a cursor instead to loop through all the records in deleted
--2nd try
CREATE OR ALTER TRIGGER deleteOrderDetails ON OrderDetails FOR delete 
AS 
DECLARE deleted_cursor CURSOR 
FOR 
SELECT ProductID,Quantity
FROM deleted
DECLARE @ProductID INT, @Quantity SmallINT
--open cursor
OPEN deleted_cursor
--fetch data
FETCH NEXT FROM deleted_cursor INTO @ProductID,@Quantity
WHILE @@FETCH_STATUS=0 
BEGIN 
    UPDATE Products
    SET UnitsInStock =UnitsInStock +@Quantity
    FROM Products WHERE ProductID = @ProductID 
    FETCH NEXT FROM deleted_cursor INTO@ProductID,@Quantity
END
    
--close cursor
CLOSE deleted_cursor
--deallocate cursor
DEALLOCATE deleted_cursor
```
### Insert after - trigger

- triggering instruction is an insert statement
    - inserted - logical table with columns equal to columns of triggering table, containing a copy of inserted rows
```sql
--If a new record is inserted in OrderDetails => check if the unitPrice is not too low or too high
CREATE OR ALTER TRIGGER insert OrderDetails ON OrderDetails FOR insert 
AS 
DECLARE @insertedProductID INT=(SELECT ProductID From inserted)
DECLARE @insertedUnitPrice Money=(SELECT UnitPrice From inserted) 
DECLARE @unitPrice From Products Money=(SELECT UnitPrice FROM Products WHERE ProductID = @insertedProductID) 
IF @insertedUnitPrice NOT BETWEEN @unitPrice From Products *0.85 AND @unitPrice From Products *1.15 
BEGIN 
    ROLLBACK TRANSACTION 
    RAISERROR ('The inserted unit price can''t be correct',14,1)
END
--Testcode
BEGIN TRANSACTION
INSERT INTO OrderDetails VALUES (10249,72,60.00,10,0.15)SELECT* FROM OrderDetails WHERE OrderID =10249
ROLLBACK
```

### Insert after - trigger
- Triggering instruction is an insert statement
    - Remark: when triggering by INSERT-SELECT statement more than one record can be added at once. The trigger code is executed only once, but will insert a new record for each inserted record.
- Triggering instruction is an update statement
```sql
--If a record is updated in OrderDetails => check if the new unitPrice is not too low or too high
--If so, rollback the transaction and raise an error
CREATE OR ALTER TRIGGER updateOrderDetails ON OrderDetails FOR update 
AS 
DECLARE @updatedProductID INT=(SELECT ProductID From inserted)
DECLARE @updatedUnitPrice Money=(SELECT UnitPrice From inserted) 
DECLARE @unitPrice From Products Money=(SELECT UnitPrice FROM Products WHERE ProductID =@updatedProductID) 
IF @updatedUnitPrice NOT BETWEEN @unitPrice From Products *0.85 AND @unitPrice From Products *1.15 
BEGIN 
    ROLLBACK TRANSACTION 
    RAISERROR ('The updated unit price can''t be correct',14,1)
END
--Testcode 
BEGIN TRANSACTION 
UPDATE OrderDetails SET UnitPrice =60 WHERE OrderID =10249 AND ProductID =14 
SELECT *FROM OrderDetails WHERE OrderID =10249 
ROLLBACK;
```

