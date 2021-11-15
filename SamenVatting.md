# Relational Databases & Datawarehousing
|Overview|
|:---|
|[Hoofdstuk 1: Sql Basic's](#sql-basic-concepts-revisited)|



# SQL Basic concepts revisited

| Overview | |
|:----|:----|
|[Select, GROUP BY, Statistical functions](#select)|
|[Join, Union, Subquerry's,...](#)|
|[Modifying Data: insert, update, delete](#)|

## Select
<ul>
<li>Consulting table</li>



|Task | Querry|
|:----|:----|
|Specefie wich column u want | ```SELECT```| 
|Table Name|```FROM```|
|Filter condition on individual lines in the output|```WHERE```|
|Grouping of data | ```GROUP BY ```|
|Filter condition on groups|```HAVING```|
|Sorting|```ORDER BY```|
<li>WHERE</li>


|Task| Querry|
|:----|:----|
|Comparison operators| ```SELECT ... FROM ... WHERE ... >,<, =, >=,<=,<>```|
|Wild cards | ``` WHERE ... LIKE [wildcard]```|
|Logical Operators| ```WHERE ... AND,OR,NOT ...```|
|Values in an interval | ```WHERE ... (NOT) BETWEEN ... AND ...```|
|List of values | ```sql WHERE ... IN/ NOT IN ...```|
|Test for unknown/ empty values|```WHERE ... IS (NOT) NULL```|

<li>Formating Results</li>

|Task| Querry|
|:----|:----|
|Sorting of data (alphabeticly)| ```ORDER BY ...```|

<li>Select data conversion</li>

|Task| Querry|
|:----|:----|
|Convert example| ```SELECT CONVERT(VARCHAR,GETDATE(), 106) AS Today```|

<li>Case function</li>
Simple Case Function example

```sql
SELECT City, Region, 
Case Region 
    WHEN 'OR' THEN 'West'
    WHEN 'MI' THEN 'North'
    ELSE 'Elsewhere'
END AS RegionElaborated
FROM Suppliers
``` 

<li>Extra's</li>
<img src="IMG\DataTypeConversion.png" width="800"><br>
<img src="IMG\StringFunctions.png" width="800"><br>
<img src="IMG\DateAndTime.png" width="800"><br> 
<img src="IMG\ArithmeticFunctions.png" width="800"><br> 

</ul>

## GROUP BY and statistical functions


### Statiscal Functions
SQL has 5 Standard functions
<ul>

<li>SUM(expression)</li>
<li>AVG(expression): average</li>
<li>MIN(expression): minimum</li>
<li>MAX(expression): maximum</li>
<li>COUNT(*|[DISTINCT] column name): count</li>

</ul>

### SUM
Returns sum of all mumeric values<br>
```sql
Select SUM(... ) as something
FROM ...
```
### AVG
Returns the average of NOT NULL numeric values in a column<br>
```sql
Select avg(...) as something
FROM ... 
```
### Zelfde voor count en min max pretty self explainotory

### GROUP BY
<img src="IMG\GROUPBY.png" width="600"><br><br>
Example: 

```sql
SELECT CategoryID,COUNT(ProductID) As NumberOfProductsPerCategory
FROM Products
GROUP BY CategoryID
```
### EXTRA's met having
<img src="IMG\Having.png" width="800"><br>
<img src="IMG\Having2.png" width="800"><br>
