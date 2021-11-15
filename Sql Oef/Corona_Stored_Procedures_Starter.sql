-- Exercise 1
-- Write a stored procedure to update already existing values 
-- for new_cases for a specific country and report_date
-- (1) If there isn't a record for the specific country and report_date 
-- (so you can't do the update), an exception is thrown
-- (2) Check if the new value is reasonable. 
-- A reasonable value is a value that is not 25% higher or lower than the average number of new cases of the past week
-- If not, throw an exception
-- (3) Do the update. Make sure the total_cases is updated too.
-- (4) Write testcode. Use transactions in order to keep the original data unchanged.
-- You can find the error messages in Messages
-- (4.1) Update the new_cases of Belgica on 2021-09-10 to 2200 (previous value was 2190)
-- (4.2) Update the new_cases of Belgium on 2021-09-10 to 3200 (previous value was 2190)
-- (4.3) Update the new_cases of Belgium on 2021-09-10 to 2200 (previous value was 2190)



-- Testcode 1

BEGIN TRANSACTION 
-- Original value = 2190
EXEC UpdateNewCases 'Belgica', '2021-09-10', 2200

-- only you (in  your session) can see changes
SELECT * FROM coviddata WHERE country = 'Belgium' and report_date >= '2021-09-10'

ROLLBACK;

-- Testcode 2

BEGIN TRANSACTION 
-- Original value = 2190
EXEC UpdateNewCases 'Belgium', '2021-09-10', 3200

-- only you (in  your session) can see changes
SELECT * FROM coviddata WHERE country = 'Belgium' and report_date >= '2021-09-10'

ROLLBACK;

-- Testcode 3

BEGIN TRANSACTION 
-- Original value = 2190
EXEC UpdateNewCases 'Belgium', '2021-09-10', 2200

-- only you (in  your session) can see changes
SELECT * FROM coviddata WHERE country = 'Belgium' and report_date >= '2021-09-10'

ROLLBACK;


-- Exercise 2

-- Write a stored procedure UpdatePopulation to update the population of a country
-- (1) If there isn't a country with the given name, an exception is thrown
-- (2) According to this website: https://www.indexmundi.com/map/?v=24&l=nl the population growth per country is a value between 5% and -8%. 
-- If the new value for the population for the given country doesn't meet
-- this constraints, an exception is thrown
-- (3) Write testcode. Use transactions in order to keep the original data unchanged.
-- You can find the error messages in Messages
-- (3.1) Update the population of Belgica to 11600000
-- (3.2) Update the population of Belgium to 21600000 
-- (3.3) Update the population of Belgium to 11600000 





-- Testcode 1

begin transaction  
-- Original value = 11589616
EXEC UpdatePopulation 'Belgica', 11600000

-- only you (in  your session) can see changes
select population from countries where country = 'Belgium'

rollback;

-- Testcode 2

begin transaction  
-- Original value = 11589616
EXEC UpdatePopulation 'Belgium', 21600000

-- only you (in  your session) can see changes
select population from countries where country = 'Belgium'

rollback;


-- Testcode 3

begin transaction  
-- Original value = 11589616
EXEC UpdatePopulation 'Belgium', 11600000

-- only you (in  your session) can see changes
select population from countries where country = 'Belgium'

rollback;

-- Exercise 3
-- Write a SP
-- (1) Calculate and print the startdate of the first golf in Belgium
-- (2) Calculate and print the enddate of the first golf in Belgium
-- (3) Calculate and print the startdate of the second golf in Belgium
-- (4) Calculate and print the enddate of the second golf in Belgium
-- (5) Calculate and print the total number of days and the total number of deaths during the first golf in Belgium
-- (6) Calculate and print the total number of days and the total number of deaths during the second golf in Belgium
-- We define the beginning (ending) of a golf 
-- when the 14 days moving average of positive_rate becomes >= (<) 0.06

/*
Start Golf 1: 07 Mar 2020
End Golf 1: 05 May 2020

Start Golf 2: 05 Oct 2020
End Golf 2: 14 Jan 2021

Number of days in Golf 1: 59
Number of days in Golf 2: 101

Number of deaths in Golf 1: 8016
Number of deaths in Golf 2: 10230
*/


