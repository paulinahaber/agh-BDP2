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
-- B³¹d: nie mo¿na zmieniæ imienia poniewa¿ w ustawieniach Slowly changing dimension zosta³o ustawione jako sta³y atrybut 