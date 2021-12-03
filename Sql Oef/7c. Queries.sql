-- Query 1
-- What is the average price per musical style based on EntPricePerDay. 
-- Only take into account StyleStrength = 1. Order by average price in descending way.
SELECT ms.StyleName, AVG(e.EntPricePerDay)
FROM musical_styles ms JOIN Entertainer_Styles es ON ms.StyleID = es.StyleID JOIN Entertainers e ON e.EntertainerID = es.EntertainerID
WHERE es.StyleStrength = 1
GROUP BY ms.StyleName
ORDER BY 2 DESC
-- Query 2
-- What are the earnings of each agent per quarter
-- Only take into account the commissionrate of the agent and the contractprice
WITH cte
AS
(SELECT agentid, contractprice , YEAR(startdate) AS startyear, DATEPART(quarter, startdate) AS startQuarter
FROM Engagements)

SELECT e.startQuarter, e.startyear, e.AgentId, SUM(e.ContractPrice*a.commissionRate) AS Something
FROM cte e JOIN Agents a ON a.AgentID= e.AgentID
GROUP BY e.AgentID, e.Quarter, e.Year
ORDER BY AgentID, startyear, StartQuarter 
-- Query 3
-- What are the customers that have booked the same entertainer every year (every year = every year bookings are registered).
-- The image below shows only a part of the resultset
select EntertainerID, CustomerID, count(distinct year(StartDate))
from Engagements
group by EntertainerID, CustomerID
having count(distinct year(StartDate)) = (
    select count(distinct year(StartDate))
    from Engagements
)

-- Query 4
-- We are looking for a Rhythm and Blues group. Which entertainer is the most popular one?
with cte
as (
    select e.EntertainerID, COUNT(en.EngagementNumber) as NumberOfEngagements
    from Engagements en join Entertainers e on e.EntertainerID = en.EntertainerID
        join Entertainer_Styles es on e.EntertainerID = es.EntertainerID
        join Musical_Styles ms on ms.StyleID = es.StyleID
    where ms.StyleName = 'Rhythm and Blues'
    group by e.EntertainerID
)
select *
from cte
where cte.NumberOfEngagements = (select max(NumberOfEngagements) from cte)

-- Query 5
-- What is the TOP 3 of most booked musical styles
-- Only take into account StyleStrength = 1. 

-- Query 6
-- Give for each year the top 3 of most popular entertainers (= entertainers with most engagements for that year)
-- first step: count van de engagements per entertainer per year
-- second step: dense_rank
-- third step: top 3
