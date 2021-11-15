/* Window functions */

/*
• Often business managers want to compare current sales to previous sales
• Previous sales can be:
– sales during the previous month
– average sales during the last three months
– last year’s sales until current date (year-to-date)
• Window functions offer a solution to these kind of problems in a single, efficient SQL query
• Introduced in SQL: 2003

OVER clause
• Results of a SELECT are partitioned
• Numbering, ordering and aggregate functions per partition
• The OVER clauses creates partitions and ordering
• The partition behaves as a window that shifts over the data
• The OVER clause can be used with standard aggregate functions
(sum, avg, …) or specific window functions (rank, lag,…)

*/

-- Example
-- Make an overview of the UnitsInStock per Category and per Product
SELECT CategoryID, ProductID, UnitsInStock
FROM Products
order by CategoryID, ProductID




-- Add an extra column to calculate the running total of UnitsInStock per Category
-- Solution 1 -> correlated subquery
SELECT CategoryID, ProductID, UnitsInStock,
(SELECT SUM(UnitsInStock) 
 FROM Products 
 WHERE CategoryID = p.CategoryID  
  and ProductID <= p.ProductID) TotalUnitsInStockPerCategory
FROM Products p
order by CategoryID, ProductID;

-- Using a correlated subquery this is very inefficient as for each line the complete sum is recalculated


-- Solution 2 -> OVER clause => simpler + more efficient
-- The sum is calculated for each partition
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductID) TotalUnitsInStockPerCategory
FROM Products
ORDER BY CategoryID, ProductID

-- Give the cumulative number of Orders for each customer for each year
/*
ALFKI	2017	3
ALFKI	2018	6
ANATR	2016	1
ANATR	2017	3
ANATR	2018	4
ANTON	2016	1
ANTON	2017	6
ANTON	2018	7
...
*/



-- Give the cumulative number of Suppliers for each country
/*
7	Pavlova, Ltd.				Australia	1
24	G'day, Mate					Australia	2
10	Refrescos Americanas LTDA	Brazil	1
25	Ma Maison					Canada	1
29	Forêts d'érables			Canada	2
21	Lyngbysild					Denmark	1
23	Karkki Oy					Finland	1
18	Aux joyeux ecclésiastiques	France	1
27	Escargots Nouveaux			France	2
28	Gai pâturage				France	3
...
*/







/* RANGE */
/*
Real meaning of window functions: apply to a window that shifts over the result set
The previous query works with the default window: start of resultset to current row
*/

-- the previous query is the shorter version of the following query. Exactly the same resultset!
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductID RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) TotalUnitsInStockPerCategory
FROM Products
order by CategoryID, ProductID



/*
With RANGE you have three valid options:
- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
- RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
PARTITION is optional, ORDER BY is mandatory
*/

-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductID RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) TotalUnitsInStockPerCategory
FROM Products
order by CategoryID, ProductID

-- RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductID RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) TotalUnitsInStockPerCategory
FROM Products
order by CategoryID, ProductID

-- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY CategoryID, ProductID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) TotalUnitsInStockPerCategory
FROM Products
order by CategoryID, ProductID


-- Give for each customer for each year the number of orders and the total number over orders over all years using PARTITION BY
/*
ALFKI	2017	3	6
ALFKI	2018	3	6
ANATR	2016	1	4
ANATR	2017	2	4
ANATR	2018	1	4
ANTON	2016	1	7
ANTON	2017	5	7
ANTON	2018	1	7
AROUT	2016	2	13
AROUT	2017	7	13
AROUT	2018	4	13
BERGS	2016	3	18
BERGS	2017	10	18
BERGS	2018	5	18
...
*/

select distinct CustomerID, year(orderDate),
    count(orderID) over (partition by CustomerID, year(OrderDate)),
    count(orderID) over (partition by CustomerID order by year(orderDate) RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
from Orders
order by customerID, year(orderDate)



-- Give the relative number of Customers for each country using PARTITION BY
/*
Argentina	3.30%
Austria	2.20%
Belgium	2.20%
Brazil	9.89%
Canada	3.30%
Denmark	2.20%
Finland	2.20%
France	12.09%
Germany	12.09%
Ireland	1.10%
*/

-- Step 1: Calculate for each country the number of customer for this country and the total number of customers
-- Step 2: Turn the precious SQL statement into a CTE and calculate the relative number of customer per country
-- Alternative??
Select Distinct Country,
Count(CustomerID) Over (Partition By Country Order By CustomerID) as NumberOfCUstomersByCountry,
Count(CustomerID) Over (Order By country Range Between unbounded PRECEDING and unbounded FOllowing) as TotalNumberOfCustomers
From Customers


Select Distinct country,
Count(CustomerID) OVER(Partition by country Order By CustomerID Range Between unbounded PRECEDING and unbounded FOllowing)
FROM Customers

/* ROWS */
/*
When you use RANGE, the current row is compared to other rows and grouped based on the ORDER BY predicate. 
This is not always desirable. You might actually want a physical offset.
In this scenario, you would specify ROWS instead of RANGE. This gives you three options in addition to the three options enumerated previously:
- ROWS BETWEEN N PRECEDING AND CURRENT ROW
- ROWS BETWEEN CURRENT ROW AND N FOLLOWING 
- ROWS BETWEEN N PRECEDING AND N FOLLOWING 
*/

-- Make an overview of the salary per employee and the average salary of this employee and the 2 employees preceding him

SELECT EmployeeID, FirstName + ' ' + LastName As FullName,  Salary, AVG(Salary) OVER (ORDER BY Salary DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) As AvgSalary2Preceding
FROM Employees

-- Make an overview of the salary per employee and the average salary of this employee and the 2 employees following him

SELECT EmployeeID, FirstName + ' ' + LastName As FullName,  Salary, AVG(Salary) OVER (ORDER BY Salary DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) As AvgSalary2Following
FROM Employees

-- Make an overview of the salary per employee and the average salary of this employee and the employee preceding and following him

SELECT EmployeeID, FirstName + ' ' + LastName As FullName,  Salary, AVG(Salary) OVER (ORDER BY Salary DESC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) As AvgSalary1Preceding1Following
FROM Employees


/* WINDOW FUNCTIONS */
/*
ROW_NUMBER() numbers the output of a result set. More specifically, 
returns the sequential number of a row within a partition of a result set, starting at 1 for the first row in each partition.

RANK() returns the rank of each row within the partition of a result set. 
The rank of a row is one plus the number of ranks that come before the row in question.

ROW_NUMBER and RANK are similar. ROW_NUMBER numbers all rows sequentially (for example 1, 2, 3, 4, 5). 
RANK provides the same numeric value for ties (for example 1, 2, 2, 4, 5).

DENSE_RANK() returns the rank of each row within the partition of a result set, with no gaps in the ranking values (for example 1, 2, 2, 3, 4).

PERCENT_RANK() shows the ranking on a scale from 0 - 1 
*/

-- Give ROW_NUMBER / RANK / DENSE_RANK / PERCENT_RANK for each employee based on his salary
SELECT EmployeeID, FirstName + ' ' + LastName As 'Full Name', Title, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) As 'ROW_NUMBER',
RANK() OVER (ORDER BY Salary DESC) AS 'RANK',
DENSE_RANK() OVER (ORDER BY Salary DESC) AS 'DENSE_RANK',
PERCENT_RANK() OVER (ORDER BY Salary DESC) AS 'PERCENT_RANK'
FROM Employees

-- Give ROW_NUMBER / RANK / DENSE_RANK / PERCENT_RANK per title for each employee based on his salary
SELECT EmployeeID, FirstName + ' ' + LastName As 'Full Name', Title, Salary,
ROW_NUMBER() OVER (PARTITION BY Title ORDER BY Salary DESC) As 'ROW_NUMBER',
RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) AS 'RANK',
DENSE_RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) AS 'DENSE_RANK',
PERCENT_RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) AS 'PERCENT_RANK'
FROM Employees



/* LAG */
/*
LAG refers to the previous line. This is short for LAG(…, 1)
LAG(…, 2) refers to the line before the previous line, …
*/

-- Calculate for each employee the percentage difference between this employee and the employee preceding him
SELECT EmployeeID, FirstName + ' ' + LastName,  Salary, FORMAT((Salary - LAG(Salary)  OVER (ORDER BY Salary DESC)) / Salary, 'P') As EarnsLessThanPreceding
FROM Employees


/* LEAD */
/*
LEAD refers to the next line. This is short for LEAD(…, 1)
LEAD(…, 2) refers to the line after the next line, …
*/


-- Calculate for each employee the percentage difference between this employee and the employee following him
SELECT EmployeeID, FirstName + ' ' + LastName,  Salary, FORMAT((Salary - LEAD(Salary)  OVER (ORDER BY Salary DESC)) / Salary, 'P') As EarnsMoreThanFollowing
FROM Employees


-- Exercises

-- Create the following overview in which each customer gets a sequential number. 
-- The number is reset when the country changes
/*
country		rownum	CompanyName
Argentina	1		Cactus Comidas para llevar
Argentina	2		Océano Atlántico Ltda.
Argentina	3		Rancho grande
Austria		1		Ernst Handel
Austria		2		Piccolo und mehr
Belgium		1		Maison Dewey
Belgium		2		Suprêmes délices
Brazil		1		Comércio Mineiro
Brazil		2		Familia Arquibaldo
Brazil		3		Gourmet Lanchonetes
Brazil		4		Hanari Carnes
...
*/
SELECT CustomerID, ContactName As 'Full Name', Country, 
ROW_NUMBER() OVER (PARTITION BY Country  ORDER BY CompanyName ) As 'ROW_NUMBER'

FROM Customers

--Excersise 1.5
-- Step 1: First create an overview that shows for each productid the amount sold per year
SELECT ProductID,Year(orderDate) as 'Year', SUM(Quantity) as 'Amount Sold'
FROM OrderDetails od Join orders o on od.OrderID = o.OrderID
GROUP BY ProductId,YEAR(OrderDate)
Order BY ProductId,YEAR(OrderDate)


-- Step 2: Now create an overview that shows for each productid the amount sold per year and for the previous year.
/*
1	2016	125	NULL
1	2017	304	125
1	2018	399	304
2	2016	226	NULL
2	2017	435	226
2	2018	396	435
3	2016	30	NULL
3	2017	190	30
3	2018	108	190
...
*/
WITH ProductsSoldPerYear(ProductID, orderdate, quantity ) as(
SELECT ProductID,Year(orderDate) as 'Year', SUM(Quantity) as 'Amount Sold'
FROM OrderDetails od Join orders o on od.OrderID = o.OrderID
GROUP BY ProductId,YEAR(OrderDate)

)


SELECT ProductID,orderdate, quantity,
LAG(Quantity) over (partition by productID order by OrderDate)

FROM ProductsSoldPerYear
Order BY ProductId,orderdate




-- Step 3: Use a CTE and the previous SQL Query to calculate the year over year performance for each productid. 
-- If the amountPreviousYear is NULL, then the year over year performance becomes N/A.

/*
1	2016	125	NULL	N/A
1	2017	304	125	143.20%
1	2018	399	304	31.25%
2	2016	226	NULL	N/A
2	2017	435	226	92.48%
2	2018	396	435	-8.97%
3	2016	30	NULL	N/A
3	2017	190	30	533.33%
3	2018	108	190	-43.16%
...
*/
WITH ProductsSoldPerYear(ProductID, orderdate, quantity ) as(
SELECT ProductID,Year(orderDate) as 'Year', SUM(Quantity) as 'Amount Sold'
FROM OrderDetails od Join orders o on od.OrderID = o.OrderID
GROUP BY ProductId,YEAR(OrderDate)

)
,Cte2(ProductID, Oderdate, quantity , laggy) as
(

SELECT ProductID,orderdate, quantity,
LAG(Quantity) over (partition by productID order by OrderDate)

FROM ProductsSoldPerYear
)

Select ProductID, Oderdate, quantity , laggy,  
CASE
    WHEN ((quantity - laggy) * 1.0 / quantity) IS NULL THEN 'N/A'
    ELSE FORMAT((quantity - laggy) * 1.0 / laggy, 'P')
    END AS YearOverYear
From cte2
Order by ProductID, Oderdate
-- Exercise2 
-- Step 1: First create an overview of the revenue (unitprice * quantity) per year per employeeid
/*
1	2016	38789,00
1	2017	97533,58
1	2018	65821,13
2	2016	22834,70
2	2017	74958,60
2	2018	79955,96
3	2016	19231,80
3	2017	111788,61
3	2018	82030,89
4	2016	53114,80
4	2017	139477,70
4	2018	57594,95
...
*/

Select EmployeeID ,Year(OrderDate), SUM(unitPrice * Quantity) as 'revenue'
From Orders o Join OrderDetails od on o.OrderId = od.orderID
Group by EmployeeID, Year(Orderdate)
Order by EmployeeID , Year(OrderDate)


-- Step 2: Now add a ranking per year per employeeid
/*
4	2016	53114,80	1
1	2016	38789,00	2
8	2016	23161,40	3
2	2016	22834,70	4
5	2016	21965,20	5
3	2016	19231,80	6
7	2016	18104,80	7
6	2016	17731,10	8
9	2016	11365,70	9
...
*/
With cte 
as(
Select EmployeeID as 'id',Year(OrderDate) as'year', SUM(unitPrice * Quantity) as 'revenue'
From Orders o Join OrderDetails od on o.OrderId = od.orderID
Group by EmployeeID, Year(Orderdate)

)
Select *, Rank() OVER ( ORDER BY year, revenue DESC) AS 'RANK'
From cte



-- Step 3: Imagine there is a bonussystem for all the employees: the best employee gets 10 000EUR bonus, the second one 5000 EUR, the third one 2500 EUR, …

/*
4	2016	53114,80	10000
1	2016	38789,00	5000
8	2016	23161,40	3333
2	2016	22834,70	2500
5	2016	21965,20	2000
3	2016	19231,80	1666
7	2016	18104,80	1428
6	2016	17731,10	1250
9	2016	11365,70	1111
...
*/
With cte 
as(
Select EmployeeID as 'id',Year(OrderDate) as'year', SUM(unitPrice * Quantity) as 'revenue'
From Orders o Join OrderDetails od on o.OrderId = od.orderID
Group by EmployeeID, Year(Orderdate)

)
Select *,(10000 /Rank() OVER ( ORDER BY year, revenue DESC)) AS 'Bonus'
From cte



-- Exercise: Calculate for each month the percentage difference between the revenue for this month and the previous month
/*
2016	7	30192,10	NULL	NULL
2016	8	26609,40	30192,10	-11.86%
2016	9	27636,00	26609,40	3.85%
2016	10	41203,60	27636,00	49.09%
2016	11	49704,00	41203,60	20.63%
2016	12	50953,40	49704,00	2.51%
2017	1	66692,80	50953,40	30.88%
2017	2	41207,20	66692,80	-38.21%
2017	3	39979,90	41207,20	-2.97%
2017	4	55699,39	39979,90	39.31%
2017	5	56823,70	55699,39	2.01%
2017	6	39088,00	56823,70	-31.21%
2017	7	55464,93	39088,00	41.89%
2017	8	49981,69	55464,93	-9.88%
2017	9	59733,02	49981,69	19.50%
*/

-- Step 1: calculate the revenue per year and per month
SELECT YEAR(orderDate) as 'orderYear',MONTH(Orderdate) as 'orderMonth',
Sum(quantity * unitPrice) as 'revenue'
From orders o JOIN OrderDetails od on o.OrderID = od.OrderId
Group by year(OrderDate), MONTH(OrderDate)
Order by year(orderdate), Month(orderdate)

-- Step 2: Add an extra column for each row with the revenue of the previous month
with cte
as
(SELECT YEAR(orderDate) as 'orderYear',MONTH(Orderdate) as 'orderMonth',
Sum(quantity * unitPrice) as 'revenue'
From orders o JOIN OrderDetails od on o.OrderID = od.OrderId
Group by year(OrderDate), MONTH(OrderDate))

Select * , lag(revenue) OVER(Order by orderYear,orderMonth) as RevenuePreviousMonth
From cte

-- Step 3: Calculate the percentage difference between this month and the previous month
WITH cte1(orderyear, ordermonth, revenue)
AS
(
SELECT YEAR(OrderDate), MONTH(ORDERDATE), SUM(UnitPrice * Quantity)
FROM Orders o JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),

cte2
AS
(
SELECT *, lag(revenue) OVER (order by orderyear, ordermonth) As RevenuePreviousMonth
FROM cte1
)

SELECT *, FORMAT((revenue - RevenuePreviousMonth) / RevenuePreviousMonth, 'P') 
FROM cte2

