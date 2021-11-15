-- 1. On which day(s) the highest number of new cases was reported in Belgium?
SELECT report_date
FROM CovidData
WHERE new_cases = (SELECT new_cases From CovidData WHERE country = 'Belgium') 
-- 2. On which day(s) the highest number of new deaths was reported for each country?
SELECT report_date

-- 3. Which country(ies) was(were) the first to start vaccinations?

-- 4. Give for each country the percentage of fully vaccinated people
-- based on the most recent data on the fully vaccinated people for that country
-- Order the results in a descending way
-- You could try to solve this taking into account that - for now - the number of fully vaccinated people is an always increasing number.
-- But once the vaccination campaign is done and old people are dying and new babies are born, it's possible this won't be the case any more.



-- 5. Assume that all people in Belgium got fully vaccinated from elder to younger. 
-- We don't take into account people on priority lists like doctors, nurses, ...
-- On which day all Belgians of 70 or older were fully vaccinated?


-- 6. Give an overview of the cumulative sum of Corona deaths for each country
-- Give country, report_date, new_deaths and the cumulative sum
-- Order by country and report_date


-- 7. Give for each continent the countries in which the life_expectancy
-- is higher than the average life_expectancy of that continent


-- 8. Which country(ies) have the highest value for median_age