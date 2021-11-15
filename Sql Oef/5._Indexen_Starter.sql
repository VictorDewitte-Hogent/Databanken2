
-- Example 1
SELECT * FROM Employee1

SELECT * FROM Employee2

-- Example 2
SELECT lastname FROM Employee1

SELECT lastname FROM Employee2

-- Covering index
SELECT lastname FROM Employee1 WHERE lastname = 'Duffy'

SELECT lastname, title FROM Employee1 WHERE lastname = 'Duffy'

CREATE NONCLUSTERED INDEX EmpLastName_Incl_Title 
ON Employee1(lastname) INCLUDE (title);

-- 1 index with several columns vs.several indexes with 1 column 
CREATE NONCLUSTERED INDEX EmpLastNameFirstname ON Employee1(lastname, firstname);



SELECT lastname, firstname FROM Employee1
WHERE firstname = 'Chris';



-- Test: Only combined index on lastname and firstname
DROP INDEX EmpLastName ON Employee1;

SELECT lastname, firstname FROM Employee1
WHERE lastname = 'Preston'

SELECT lastname, firstname FROM Employee1
WHERE firstname = 'Chris';

-- With extra index on firstname and covering of lastname
create nonclustered index EmpFirstnameIncLastname ON employee1(firstname)
INCLUDE (lastname);

SELECT lastname, firstname FROM Employee1
WHERE lastname = 'Preston'

SELECT lastname, firstname FROM Employee1
WHERE firstname = 'Chris';

-- Use of indexes with functions and wildcards
SELECT lastname, firstname FROM Employee1
WHERE lastname = 'Preston'

SELECT lastname, firstname FROM Employee1
WHERE SUBSTRING(lastname, 2, 1) = 'r'

SELECT lastname, firstname FROM Employee1
WHERE lastname LIKE '%r%'



-- Tips & Tricks: (1) Avoid the use of functions
-- BAD
SELECT lastname, firstname, birthdate
FROM Employee1
WHERE Year(BirthDate) = 1980;
 
-- GOOD
SELECT lastname, firstname, birthdate
FROM Employee1
WHERE BirthDate >= '1980-01-01' AND BirthDate <  '1981-01-01';

-- Tips & Tricks: (2) Avoid the use of functions

CREATE INDEX EmpLastName ON Employee1 (LastName ASC);

-- BAD
SELECT LastName
FROM Employee1
WHERE substring(LastName,1,1) = 'D';
 
-- GOOD
SELECT LastName
FROM Employee1
WHERE LastName like 'D%';

-- Tips & Tricks: (3) avoid calculations, isolate columns
-- BAD 
SELECT EmployeeID, FirstName, LastName
FROM Employee1
WHERE Salary*1.10 > 100000;
 
-- GOOD
SELECT EmployeeID, FirstName, LastName
FROM Employee1
WHERE Salary > 100000/1.10;


-- Tips & Tricks: (4) prefer OUTER JOIN above UNION
-- BAD 
SELECT lastname, firstname, orderid
from Employee1 e join Orders o on e.EmployeeID = o.employeeid
union
select lastname, firstname, null
from Employee1 
where EmployeeID not in (select EmployeeID from Orders)

-- GOOD
SELECT lastname, firstname, orderid
from Employee1 e left join Orders o on e.EmployeeID = o.employeeid;

-- Tips & tricks(5) avoid ANY and ALL
-- BAD 
SELECT lastname, firstname, birthdate
from Employee1 
where BirthDate >= all(select BirthDate from Employee1)

-- GOOD
SELECT lastname, firstname, birthdate
from Employee1 
where BirthDate = (select max(BirthDate) from Employee1)
