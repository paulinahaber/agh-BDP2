update dbo.stg_dimemp
set LastName = 'Nowak'
where EmployeeKey = 270;
update STG_DimEmp
set TITLE = 'Senior Design Engineer'
where EmployeeKey = 274;

update STG_DimEmp
set FIRSTNAME = 'Ryszard'
where EmployeeKey = 275

-- 5b
-- typ 2

-- 5c
-- typ 3
-- B��d: nie mo�na zmieni� imienia poniewa� w ustawieniach Slowly changing dimension zosta�o ustawione jako sta�y atrybut 