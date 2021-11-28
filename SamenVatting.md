# Relational Databases & Datawarehousing

| Inhoud                                                                   |
| :----------------------------------------------------------------------- |
| [0. praktische info](#praktische-info)                                   |
| [1. SQL review](#SQL-review)                                             |
| [2. SQL Advanced](#SQL-advanced)                                         |
| [3. Window functions](#window-functions)                                 |
| [4. DB Programming](#DB-programming)                                     |
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
