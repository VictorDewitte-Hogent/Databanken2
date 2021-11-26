USE [AdventureWorksDW]

CREATE TABLE	[dbo].[DimDate]
	(	[DateKey] INT primary key, 
		[FullDateAlternateKey] [date] NOT NULL,
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[EnglishDayNameOfWeek] [varchar](10) NOT NULL,
		[DutchDayNameOfWeek] [varchar](10) NOT NULL,
		[DayOfWeek] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[EnglishMonthName] [varchar](10) NOT NULL,
		[DutchMonthName] [varchar](10) NOT NULL,
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6)
	)
GO