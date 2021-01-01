USE [DataWarehouse]
GO

CREATE TABLE [dbo].[Dim_Customer]
(
    [Id] BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,    --very big 
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,  --+10
    [LastName] NVARCHAR(30) NOT NULL,
    [Company] NVARCHAR(90),
    [Address] NVARCHAR(80),
    [City] NVARCHAR(50),
    [State] NVARCHAR(50),
    [Country] NVARCHAR(50),
    [PostalCode] NVARCHAR(10),
    [Phone] NVARCHAR(24),
    [Fax] NVARCHAR(24),
    [Email] NVARCHAR(70) NOT NULL,
    [SupportRepId] INT,
	[SupportLastName] NVARCHAR(30),
	[SupportTitle] NVARCHAR(30),
	----SCD2
	[Start_Date_SupportRepId] DATE,
	[End_Date_SupportRepId] DATE,
	[Current_Flag_SupportRepId] bit, -- 1-64
);



CREATE TABLE [dbo].[Dim_Customer_temp]
(
    [Id] BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,    --very big 
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,  --+10
    [LastName] NVARCHAR(30) NOT NULL,
    [Company] NVARCHAR(90),
    [Address] NVARCHAR(80),
    [City] NVARCHAR(50),
    [State] NVARCHAR(50),
    [Country] NVARCHAR(50),
    [PostalCode] NVARCHAR(10),
    [Phone] NVARCHAR(24),
    [Fax] NVARCHAR(24),
    [Email] NVARCHAR(70) NOT NULL,
    [SupportRepId] INT,
	[SupportLastName] NVARCHAR(30),
	[SupportTitle] NVARCHAR(40),
	----SCD2
	[Start_Date_SupportRepId] DATE,
	[End_Date_SupportRepId] DATE,
	[Current_Flag_SupportRepId] bit, -- 1-64
);


GO
CREATE OR ALTER PROCEDURE ETL_DimensionCustomer
AS
BEGIN
	
	--- Add new Customers to temp table without join to "Employee" table
	--- After this query, the new customers information will be in the temp table
	INSERT INTO  [DataWarehouse].[dbo].[Dim_Customer_temp]
							([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
							[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

	SELECT [CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [SupportRepId], NULL, NULL, NULL, NULL, NULL 
	FROM [StorageArea].[dbo].[SA_Customer] SAC
	WHERE SAC.CustomerId NOT IN (SELECT CustomerId
								 FROM [Dim_Customer])

	


	
	
	--- Add new Customers from temp table to Customer dimension
	--- In here we just join new Customers with "Employee" table which is much smaller and faster
	INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
							([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
							[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

	SELECT DCT.[CustomerId], DCT.[FirstName], DCT.[LastName], DCT.[Company], DCT.[Address], DCT.[City], DCT.[State], DCT.[Country], DCT.[PostalCode], DCT.[Phone],
		   DCT.[Fax], DCT.[Email], DCT.[SupportRepId], SAE.[LastName], SAE.[Title], GETDATE(), NULL, 1

	FROM [DataWarehouse].[dbo].[Dim_Customer_temp] DCT INNER JOIN [StorageArea].[dbo].[SA_Employee] SAE ON (DCT.SupportRepId = SAE.EmployeeId) 





	TRUNCATE TABLE [DataWarehouse].[dbo].[Dim_Customer_temp]
	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] ON




	--- SCD2 for [SupportRepId]
	--- Add all Customers to temp table which their supporter has been changed
	--- Note1: that we just need active rows(rows with current_flag = TRUE)
	--- Note2: we set their flag to zero and add endDate to them
	--- after this query, there will be customers info with changed supporter in temp table
	INSERT INTO [DataWarehouse].[dbo].[Dim_Customer_temp]
							([Id],[CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
							[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])
	
	SELECT DC.[Id], DC.[CustomerId], DC.[FirstName], DC.[LastName], DC.[Company], DC.[Address], DC.[City], DC.[State], DC.[Country], DC.[PostalCode], DC.[Phone], DC.[Fax], DC.[Email], 
							DC.[SupportRepId], DC.[SupportLastName], DC.[SupportTitle], DC.[Start_Date_SupportRepId], DATEADD(day, -1, GETDATE()), 0
	FROM [DataWarehouse].[dbo].[Dim_Customer] DC INNER JOIN [StorageArea].[dbo].[SA_Customer] SAC ON (DC.CustomerId = SAC.CustomerId)
	WHERE DC.Current_Flag_SupportRepId = 1 AND DC.SupportRepId <> SAC.SupportRepId




	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] OFF





	--- Delete rows which we already have in temp table
	DELETE FROM [DataWarehouse].[dbo].[Dim_Customer]
		   WHERE Id in (SELECT Id FROM [DataWarehouse].[dbo].[Dim_Customer_temp])


	
	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] ON




	--- Insert old data with (current_flag = 0) to Customer dimesion
	INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
							([Id],[CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
							[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])
	
	SELECT [Id],[CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
			[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId]
	FROM [DataWarehouse].[dbo].[Dim_Customer_temp]



	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] OFF





	--- Insert new data with (current_flag = ) to Customer dimension
	INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
							([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
							[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])
	
	SELECT DCT.[CustomerId], DCT.[FirstName], DCT.[LastName], DCT.[Company], DCT.[Address], DCT.[City], DCT.[State], DCT.[Country], DCT.[PostalCode], DCT.[Phone], DCT.[Fax], DCT.[Email], 
			SAC.[SupportRepId], SAE.[LastName], SAE.[Title], GETDATE(), NULL , 1
	FROM [DataWarehouse].[dbo].[Dim_Customer_temp] DCT  INNER JOIN [StorageArea].[dbo].[SA_Customer] SAC ON (DCT.CustomerId = SAC.CustomerId)
														INNER JOIN [StorageArea].[dbo].[SA_Employee] SAE ON (SAC.SupportRepId = SAE.EmployeeId)






	TRUNCATE TABLE [DataWarehouse].[dbo].[Dim_Customer_temp]
	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] ON






	--- SCD1 for lots of fields!!
	INSERT INTO [DataWarehouse].[dbo].[Dim_Customer_temp]
						([Id], [CustomerId] ,[FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
						[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

	SELECT DC.[Id] , DC.[CustomerId] ,SAC.[FirstName], SAC.[LastName], SAC.[Company], SAC.[Address], SAC.[City], SAC.[State], SAC.[Country], SAC.[PostalCode], SAC.[Phone], SAC.[Fax], SAC.[Email], 
						DC.[SupportRepId], DC.[SupportLastName], DC.[SupportTitle], DC.[Start_Date_SupportRepId], DC.[End_Date_SupportRepId], DC.[Current_Flag_SupportRepId]
	FROM [DataWarehouse].[dbo].[Dim_Customer] DC INNER JOIN [StorageArea].[dbo].[SA_Customer] SAC ON (DC.CustomerId = SAC.CustomerId)
	WHERE DC.Current_Flag_SupportRepId = 1 AND (DC.FirstName <> SAC.FirstName OR
												DC.LastName  <> SAC.LastName  OR
												DC.Company   <> SAC.Company   OR
												DC.Address   <> SAC.Address   OR
												DC.City      <> SAC.City      OR
												DC.Phone     <> SAC.Phone     OR
												DC.Fax       <> SAC.Fax       OR
												DC.Email     <> SAC.Email)



	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] OFF



	DELETE FROM [DataWarehouse].[dbo].[Dim_Customer]
			WHERE Id IN (SELECT Id FROM [DataWarehouse].[dbo].[Dim_Customer_temp])




	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] ON



	INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]([Id], [CustomerId] ,[FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
				[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

	SELECT [Id], [CustomerId] ,[FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], 
			[SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId]
	FROM [DataWarehouse].[dbo].[Dim_Customer_temp]




	SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] OFF
	TRUNCATE TABLE [DataWarehouse].[dbo].[Dim_Customer_temp]

END

EXEC ETL_DimensionCustomer


