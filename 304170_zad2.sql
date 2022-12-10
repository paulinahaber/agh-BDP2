--b
DROP TABLE IF EXISTS AdventureWorksDW2019.dbo.stg_dimemp ;
--a
SELECT de.EmployeeKey, de.FirstName, de.LastName, de.Title
INTO AdventureWorksDW2019.dbo.stg_dimemp
FROM AdventureWorksDW2019.dbo.DimEmployee de
WHERE EmployeeKey BETWEEN 270 AND 275;

--c
DROP TABLE IF EXISTS AdventureWorksDW2019.dbo.scd_dimemp ;
CREATE TABLE AdventureWorksDW2019.dbo.scd_dimemp (
 EmployeeKey int ,
 FirstName nvarchar(50) not null,
 LastName nvarchar(50) not null,
 Title nvarchar(50),
 StartDate datetime,
 EndDate datetime,
);INSERT INTO dbo.scd_dimemp (EmployeeKey, FirstName, LastName, Title)SELECT * FROM dbo.stg_dimemp;