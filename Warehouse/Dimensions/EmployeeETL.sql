USE DataWarehouse
GO
CREATE OR ALTER PROCEDURE ETL_DimensionEmployee
AS
BEGIN
	--insert new employees to dimension
	INSERT INTO Dim_Employee(EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate,HireDate, [Address], City, [State], Country, PostalCode, Phone, Fax, Email, [Start_date], [End_Dte], [Current_Flag], [Change_Flag])
	SELECT					 EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate,HireDate, [Address], City, [State], Country, PostalCode, Phone, Fax, Email, GETDATE()   , NULL	 , 0			 , 1
	FROM [StorageArea].[dbo].[SA_Employee]
	WHERE EmployeeId not in (SELECT EmployeeId
							 FROM [DataWarehouse].dbo.Dim_Employee
							 WHERE [Current_Flag] = 1)


	
	SELECT DE.EmployeeId, DE.LastName, DE.FirstName, DE.Title, DE.ReportsTo, DE.BirthDate, DE.HireDate, DE.[Address], DE.City, DE.[State], DE.Country, DE.PostalCode, DE.Phone, DE.Fax, DE.Email, GETDATE() AS Start_date   , NULL AS [End_Dte]     , 1 AS [Current_Flag],
			CASE
				WHEN DE.ReportsTo != SE.ReportsTo AND DE.Title = SE.Title THEN 1
				WHEN DE.ReportsTo = SE.ReportsTo AND DE.Title != SE.Title THEN 2
				ELSE 3
			END AS Change_Flag
	INTO #TEMP
	FROM [StorageArea].[dbo].[SA_Employee] SE INNER JOIN [DataWarehouse].dbo.Dim_Employee DE ON (SE.EmployeeId = DE.EmployeeId AND DE.Current_Flag = 1)
	WHERE DE.ReportsTo != SE.ReportsTo OR DE.Title != SE.Title


	UPDATE [DataWarehouse].dbo.Dim_Employee
	SET [End_Dte] = DATEADD(day, -1, GETDATE()), Current_Flag = 0
	WHERE Current_Flag = 1 AND EmployeeId IN (SELECT EmployeeId
											FROM #TEMP)

	INSERT Dim_Employee(EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate,    HireDate,    [Address],    City,    [State],    Country,    PostalCode,    Phone,    Fax,    Email, [Start_date], [End_Dte], [Current_Flag], [Change_Flag] )
	SELECT EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, [Address], City, [State], Country, PostalCode, Phone, Fax, Email, Start_date   , [End_Dte]     , [Current_Flag], Change_Flag
	FROM #TEMP


END