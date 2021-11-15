-- Write triggers that update the total_cases when a row is inserted/deleted

Create or Alter trigger delete_RowCorona ON coviddata For delete
as
Declare @report_date datetime2(7), @country nvarchar(50), @newCases int
Select @report_date = report_date , @country = country, @newCases = new_cases
from deleted

Update CovidData
set Total_cases -= @newCases
where country = @country and report_date > @report_date


--TestCode
Begin Transaction
Select * From CovidData
Where Country = 'Belgium' and report_date > '2021-09-17'

DELETE FROM CovidData where Country = 'Belgium' and report_date = '2021-09-20'

Select * From CovidData
Where Country = 'Belgium' and report_date > '2021-09-17'
RollBack