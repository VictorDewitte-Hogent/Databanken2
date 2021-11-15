# Relational Databases & Datawarehousing
|Overview|
|:---|
|[Hoofdstuk 1: Sql Basic's](#sql-basic-concepts-rivisited)|



## SQL Basic concepts revisited

| Overview | |
|:----|:----|
|[Select, GROUP BY, Statistical functions](#select)|
|[Join, Union, Subquerry's,...](#)|
|[Modifying Data: insert, update, delete](#)|

### Select
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
|List of values | ```WHERE ... IN/ NOT IN ...```|
|Test for unknown/ empty values|```WHERE ... IS (NOT) NULL```|

<li>Formating Results</li>

|Task| Querry|
|:----|:----|
|Sorting of data (alphabeticly)| ```ORDER BY ...```|

<li>Select data conversion</li>

|Task| Querry|
|:----|:----|
|Convert example| ```SELECT CONVERT(VARCHAR,GETDATE(), 106) AS Today```|

<li>Extra's</li>
<img src="IMG\DataTypeConversion.png" width="800"><br>
<img src="IMG\StringFunctions.png" width="800"><br>
<img src="IMG\DateAndTime.png" width="800"><br> 
<img src="IMG\ArithmeticFunctions.png" width="800"><br> 

</ul>

