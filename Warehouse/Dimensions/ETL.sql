USE [DataWarehouse]
GO
CREATE OR ALTER PROCEDURE ETL_DimensionGenre
AS
BEGIN
  INSERT INTO [DataWarehouse].[dbo].[Dim_Genre]
  SELECT GenreId, Name
  FROM [StorageArea].[dbo].[SA_Genre]
  WHERE GenreId not in (SELECT GenreId
  FROM [DataWarehouse].[dbo].[Dim_Genre])  
  INSERT into [DataWarehouse].[dbo].[LogTable]VALUES('[DataWarehouse].[dbo].[Dim_Genre]', 'Load Data', NULL, GETDATE())

END

GO
CREATE OR ALTER PROCEDURE ETL_DimensionMediaType
AS
BEGIN
    INSERT INTO [DataWarehouse].[dbo].[Dim_MediaType]
    SELECT MediaTypeId, Name
    FROM [StorageArea].[dbo].[SA_MediaType]
    WHERE MediaTypeId not in (SELECT MediaTypeId
    FROM [DataWarehouse].[dbo].[Dim_MediaType])  
    INSERT into [DataWarehouse].[dbo].[LogTable]VALUES('[DataWarehouse].[dbo].[Dim_MediaType]', 'Load Data', NULL, GETDATE())

END
GO


CREATE OR ALTER PROCEDURE ETL_DimensionArtist
AS
BEGIN
    INSERT INTO [DataWarehouse].[dbo].[Dim_Artist]
    SELECT ArtistId, Name
    FROM [StorageArea].[dbo].[SA_Artist]
    WHERE ArtistId not in (SELECT ArtistId
    FROM [DataWarehouse].[dbo].[Dim_Artist])
    INSERT into [DataWarehouse].[dbo].[LogTable]VALUES('[DataWarehouse].[dbo].[Dim_Artist]', 'Load Data', NULL, GETDATE())

END

GO
CREATE OR ALTER PROCEDURE ETL_DimensionLocation
AS
BEGIN
  INSERT INTO [DataWarehouse].[dbo].[Dim_Location]
 SELECT DISTINCT City, Country
FROM [StorageArea].[dbo].[SA_Customer] AS SAC
WHERE NOT exists (SELECT DISTINCT City, Country
                  FROM [DataWarehouse].[dbo].[Dim_Location] AS DWL
                  WHERE
                  DWL.City = [SAC].City AND DWL.Country = SAC.Country)

  INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[Dim_Location]', 'Load Data', NULL, GETDATE())

END





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



  INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[Dim_Customer_temp]', 'Add new Customers to temp table without join to Employee table', NULL, GETDATE())




  --- Add new Customers from temp table to Customer dimension
  --- In here we just join new Customers with "Employee" table which is much smaller and faster
  INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
    ([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

  SELECT DCT.[CustomerId], DCT.[FirstName], DCT.[LastName], DCT.[Company], DCT.[Address], DCT.[City], DCT.[State], DCT.[Country], DCT.[PostalCode], DCT.[Phone],
    DCT.[Fax], DCT.[Email], DCT.[SupportRepId], SAE.[LastName], SAE.[Title], GETDATE(), NULL, 1

  FROM [DataWarehouse].[dbo].[Dim_Customer_temp] DCT INNER JOIN [StorageArea].[dbo].[SA_Employee] SAE ON (DCT.SupportRepId = SAE.EmployeeId)



  INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[Dim_Customer]', 'Add new Customers from temp table to Customer dimension', NULL, GETDATE())




  TRUNCATE TABLE [DataWarehouse].[dbo].[Dim_Customer_temp]
  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] ON


  INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[Dim_Customer_temp]', 'Truncate temp table', NULL, GETDATE())




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




  INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[Dim_Customer_temp]', 'Add all Customers to temp table which their supporter has been changed', NULL, GETDATE())



  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] OFF





  --- Delete rows which we already have in temp table
  DELETE FROM [DataWarehouse].[dbo].[Dim_Customer]
		   WHERE Id in (SELECT Id
  FROM [DataWarehouse].[dbo].[Dim_Customer_temp])


  INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[Dim_Customer]', 'Delete rows which we already have in temp table', NULL, GETDATE())



  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] ON




  --- Insert old data with (current_flag = 0) to Customer dimesion
  INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
    ([Id],[CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

  SELECT [Id], [CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId]
  FROM [DataWarehouse].[dbo].[Dim_Customer_temp]


  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Customer]', 'Insert old data with(current_flag = 0) to Customer dimesion', NULL, GETDATE())



  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] OFF





  --- Insert new data with (current_flag = ) to Customer dimension
  INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
    ([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

  SELECT DCT.[CustomerId], DCT.[FirstName], DCT.[LastName], DCT.[Company], DCT.[Address], DCT.[City], DCT.[State], DCT.[Country], DCT.[PostalCode], DCT.[Phone], DCT.[Fax], DCT.[Email],
    SAC.[SupportRepId], SAE.[LastName], SAE.[Title], GETDATE(), NULL , 1
  FROM [DataWarehouse].[dbo].[Dim_Customer_temp] DCT INNER JOIN [StorageArea].[dbo].[SA_Customer] SAC ON (DCT.CustomerId = SAC.CustomerId)
    INNER JOIN [StorageArea].[dbo].[SA_Employee] SAE ON (SAC.SupportRepId = SAE.EmployeeId)


  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Customer]', 'Insert new data with (current_flag = ) to Customer dimension', NULL, GETDATE())




  TRUNCATE TABLE [DataWarehouse].[dbo].[Dim_Customer_temp]
  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] ON

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Customer_temp]', 'Truncate temp table', NULL, GETDATE())




  --- SCD1 for lots of fields!!
  INSERT INTO [DataWarehouse].[dbo].[Dim_Customer_temp]
    ([Id], [CustomerId] ,[FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

  SELECT DC.[Id] , DC.[CustomerId] , SAC.[FirstName], SAC.[LastName], SAC.[Company], SAC.[Address], SAC.[City], SAC.[State], SAC.[Country], SAC.[PostalCode], SAC.[Phone], SAC.[Fax], SAC.[Email],
    DC.[SupportRepId], DC.[SupportLastName], DC.[SupportTitle], DC.[Start_Date_SupportRepId], DC.[End_Date_SupportRepId], DC.[Current_Flag_SupportRepId]
  FROM [DataWarehouse].[dbo].[Dim_Customer] DC INNER JOIN [StorageArea].[dbo].[SA_Customer] SAC ON (DC.CustomerId = SAC.CustomerId)
  WHERE DC.Current_Flag_SupportRepId = 1 AND (DC.FirstName <> SAC.FirstName OR
    DC.LastName  <> SAC.LastName OR
    DC.Company   <> SAC.Company OR
    DC.Address   <> SAC.Address OR
    DC.City      <> SAC.City OR
    DC.Phone     <> SAC.Phone OR
    DC.Fax       <> SAC.Fax OR
    DC.Email     <> SAC.Email)


  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Customer_temp]', 'load date, SCD1 for lots of fields', NULL, GETDATE())



  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer_temp] OFF



  DELETE FROM [DataWarehouse].[dbo].[Dim_Customer]
			WHERE Id IN (SELECT Id
  FROM [DataWarehouse].[dbo].[Dim_Customer_temp])


INSERT into [DataWarehouse].[dbo].[LogTable]
VALUES('[DataWarehouse].[dbo].[Dim_Customer]', 'Delete rows which we already have in temp table', NULL, GETDATE())




  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] ON



  INSERT INTO [DataWarehouse].[dbo].[Dim_Customer]
    ([Id], [CustomerId] ,[FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId])

  SELECT [Id], [CustomerId] , [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email],
    [SupportRepId], [SupportLastName], [SupportTitle], [Start_Date_SupportRepId], [End_Date_SupportRepId], [Current_Flag_SupportRepId]
  FROM [DataWarehouse].[dbo].[Dim_Customer_temp]


  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Customer]', 'Insert new data with (current_flag = ) to Customer dimension', NULL, GETDATE())




  SET IDENTITY_INSERT [DataWarehouse].[dbo].[Dim_Customer] OFF
  TRUNCATE TABLE [DataWarehouse].[dbo].[Dim_Customer_temp]

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Customer_temp]', 'Truncate temp table', NULL, GETDATE())


END

GO
CREATE OR ALTER PROCEDURE ETL_DimensionTrack
AS
BEGIN

  UPDATE [DataWarehouse].[dbo].[Dim_Track]
	SET [DataWarehouse].[dbo].[Dim_Track].Current_Flag_UnitPrice=0 ,
		[DataWarehouse].[dbo].[Dim_Track].End_Date_UnitPrice=GETDATE()
	WHERE [DataWarehouse].[dbo].[Dim_Track].Current_Flag_UnitPrice=1
    AND TrackId in (SELECT DT.TrackId
    FROM [DataWarehouse].[dbo].[Dim_Track] as DT inner join [StorageArea].[dbo].[SA_Track] as ST on (DT.TrackId=ST.TrackId)
    WHERE DT.UnitPrice<>ST.UnitPrice)

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Track]', 'Update flag unit price', NULL, GETDATE())


  INSERT INTO DataWarehouse.dbo.Dim_Track
    ([TrackId] ,[Name],[AlbumId],[AlbumTitle],[ArtistId],[ArtistName],[MediaTypeId]
    ,[MediaTypeName],[GenreId],[GenreName],[Composer],[Milliseconds],[Bytes],[UnitPrice],[AddDate],[Start_Date_UnitPrice],[End_Date_UnitPrice],[Current_Flag_UnitPrice])
  SELECT T.[TrackId], T.[Name], T.[AlbumId], A.[Title], Ar.[ArtistId], Ar.[Name], T.[MediaTypeId], M.[Name], T.[GenreId]
	  , G.[Name], T.[Composer], T.[Milliseconds], T.[Bytes], T.[UnitPrice], T.[AddDate], GETDATE(), NULL, 1
  FROM [StorageArea].[dbo].[SA_Track] as T inner join StorageArea.dbo.SA_Genre as G on (T.GenreId=G.GenreId)
    inner join StorageArea.dbo.SA_Album as A on (T.AlbumId=A.AlbumId)
    inner join StorageArea.dbo.SA_MediaType as M on (T.MediaTypeId=M.MediaTypeId)
    inner join StorageArea.dbo.SA_Artist as Ar on (A.ArtistId=Ar.ArtistId)
  WHERE TrackId in (SELECT DT.TrackId
  FROM [DataWarehouse].[dbo].[Dim_Track] as DT inner join [StorageArea].[dbo].[SA_Track] as ST on (DT.TrackId=ST.TrackId)
  WHERE DT.UnitPrice<>ST.UnitPrice)

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Track]', 'Insert updated data', NULL, GETDATE())

  INSERT INTO DataWarehouse.dbo.Dim_Track
    ([TrackId] ,[Name],[AlbumId],[AlbumTitle],[ArtistId],[ArtistName],[MediaTypeId]
    ,[MediaTypeName],[GenreId],[GenreName],[Composer],[Milliseconds],[Bytes],[UnitPrice],[AddDate],[Start_Date_UnitPrice],[End_Date_UnitPrice],[Current_Flag_UnitPrice])
  SELECT T.[TrackId], T.[Name], T.[AlbumId], A.[Title], Ar.[ArtistId], Ar.[Name], T.[MediaTypeId], M.[Name], T.[GenreId]
	  , G.[Name], T.[Composer], T.[Milliseconds], T.[Bytes], T.[UnitPrice], T.[AddDate], GETDATE(), NULL, 1
  FROM [StorageArea].[dbo].[SA_Track] as T inner join StorageArea.dbo.SA_Genre as G on (T.GenreId=G.GenreId)
    inner join StorageArea.dbo.SA_Album as A on (T.AlbumId=A.AlbumId)
    inner join StorageArea.dbo.SA_MediaType as M on (T.MediaTypeId=M.MediaTypeId)
    inner join StorageArea.dbo.SA_Artist as Ar on (A.ArtistId=Ar.ArtistId)
  WHERE TrackId not in (SELECT TrackId
  FROM [DataWarehouse].[dbo].[Dim_Track])

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Track]', 'Insert new tracks', NULL, GETDATE())


END


GO
CREATE OR ALTER PROCEDURE ETL_DimensionAlbum
AS
BEGIN
  INSERT INTO [DataWarehouse].[dbo].[Dim_Album]
    (AlbumId, Title, ArtistId, ArtistName)
  SELECT Album.AlbumId, Album.Title, Album.ArtistId, Artist.[Name]
  FROM [StorageArea].[dbo].[SA_Album] as Album inner join [StorageArea].[dbo].[SA_Artist] as Artist on (Album.ArtistId = Artist.ArtistId)
  WHERE AlbumId not in (SELECT AlbumId
  FROM [DataWarehouse].[dbo].[Dim_Album])
  
INSERT into [DataWarehouse].[dbo].[LogTable]
VALUES('[DataWarehouse].[dbo].[Dim_Album]', 'Load Data', NULL, GETDATE())

END

GO
CREATE OR ALTER PROCEDURE ETL_DimensionEmployee
AS
BEGIN
	--insert new employees to dimension
	INSERT INTO Dim_Employee(EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate,HireDate, [Address], City, [State], Country, PostalCode, Phone, Fax, Email, [Start_date], [End_Dte], [Current_Flag], [Change_Flag])
	SELECT					 EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate,HireDate, [Address], City, [State], Country, PostalCode, Phone, Fax, Email, GETDATE()   , NULL	 , 1			 , 0
	FROM [StorageArea].[dbo].[SA_Employee]
	WHERE EmployeeId not in (SELECT EmployeeId
							 FROM [DataWarehouse].dbo.Dim_Employee
							 WHERE [Current_Flag] = 1)

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'insert new employees to dimension', NULL, GETDATE())



	DROP TABLE IF EXISTS #TEMP
	SELECT SE.EmployeeId, SE.LastName, SE.FirstName, SE.Title, SE.ReportsTo, SE.BirthDate, SE.HireDate, SE.[Address], SE.City, SE.[State], SE.Country, SE.PostalCode, SE.Phone, SE.Fax, SE.Email, GETDATE() AS [Start_date]   , CONVERT(datetime, NULL) AS [End_Dte]  , 1 AS [Current_Flag],
			CASE
				WHEN DE.ReportsTo != SE.ReportsTo AND DE.Title = SE.Title THEN 1
				WHEN DE.ReportsTo = SE.ReportsTo AND DE.Title != SE.Title THEN 2
				ELSE 3
			END AS Change_Flag
	INTO #TEMP
	FROM [StorageArea].[dbo].[SA_Employee] SE INNER JOIN [DataWarehouse].dbo.Dim_Employee DE ON (SE.EmployeeId = DE.EmployeeId AND DE.Current_Flag = 1)
	WHERE DE.ReportsTo != SE.ReportsTo OR DE.Title != SE.Title

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'insert Changed data to TEMP (SCD2)', NULL, GETDATE())

	UPDATE [DataWarehouse].dbo.Dim_Employee
	SET [End_Dte] = DATEADD(day, -1, GETDATE()), Current_Flag = 0
	WHERE Current_Flag = 1 AND EmployeeId IN (SELECT EmployeeId
											FROM #TEMP)

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'Update current flag and enddate for old data', NULL, GETDATE())

	INSERT Dim_Employee(EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate,    HireDate,    [Address],    City,    [State],    Country,    PostalCode,    Phone,    Fax,    Email, [Start_date], [End_Dte], [Current_Flag], [Change_Flag] )
	SELECT EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, [Address], City, [State], Country, PostalCode, Phone, Fax, Email, [Start_date]   , [End_Dte]     , [Current_Flag], Change_Flag
	FROM #TEMP

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'insert from temp to dimension', NULL, GETDATE())
	
	DROP TABLE IF EXISTS #SCD1
	SELECT	DE.Id,
			DE.EmployeeId,
			SE.LastName, 
			SE.FirstName, 
			DE.Title, 
			DE.ReportsTo, 
			SE.BirthDate, 
			SE.HireDate, 
			SE.Address, 
			SE.City, 
			SE.State,
			SE.Country,
			SE.PostalCode,
			SE.Phone,
			SE.Fax,
			SE.Email,
			DE.[Start_date],
			DE.[End_Dte],
			DE.[Current_Flag],
			DE.[Change_Flag]
	INTO #SCD1
	FROM [StorageArea].[dbo].[SA_Employee] SE INNER JOIN [DataWarehouse].dbo.Dim_Employee DE ON (SE.EmployeeId = DE.EmployeeId)
	WHERE SE.LastName != DE.LastName OR
			SE.FirstName != DE.FirstName OR
			SE.BirthDate != DE.BirthDate OR
			SE.HireDate != DE.HireDate OR
			SE.Address != DE.Address OR
			SE.City != DE.City OR
			SE.State != DE.State OR
			SE.Country != DE.Country OR
			SE.PostalCode != DE.PostalCode OR
			SE.Phone != DE.Phone OR
			SE.Fax != DE.Fax OR
			SE.Email != DE.Email

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'Insert part of SCD1 for dimension', NULL, GETDATE())

	Delete FROM Dim_Employee
			WHERE Id in (select Id from #SCD1)

  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'Delete part of SCD1 for dimension', NULL, GETDATE())


	SET IDENTITY_INSERT [DataWarehouse].[dbo].Dim_Employee ON
	INSERT INTO Dim_Employee (Id,
			EmployeeId,
			LastName, 
			FirstName, 
			Title, 
			ReportsTo, 
			BirthDate, 
			HireDate, 
			Address, 
			City, 
			State,
			Country,
			PostalCode,
			Phone,
			Fax,
			Email,
			[Start_date],
			[End_Dte],
			[Current_Flag],
			[Change_Flag])
	SELECT Id,
			EmployeeId,
			LastName, 
			FirstName, 
			Title, 
			ReportsTo, 
			BirthDate, 
			HireDate, 
			Address, 
			City, 
			State,
			Country,
			PostalCode,
			Phone,
			Fax,
			Email,
			[Start_date],
			[End_Dte],
			[Current_Flag],
			[Change_Flag]
		FROM #SCD1
  
  INSERT into [DataWarehouse].[dbo].[LogTable]
  VALUES('[DataWarehouse].[dbo].[Dim_Employee]', 'Insert from SCD1 to dimension', NULL, GETDATE())

	SET IDENTITY_INSERT [DataWarehouse].[dbo].Dim_Employee OFF

END



USE [DataWarehouse]
GO
--- insert data to dimension date
bulk INSERT [DataWarehouse].[dbo].[Dim_Date]
FROM '/home/mohammadsgh/Desktop/Date.txt'
WITH (
    fieldterminator = '\t',
    ROWTERMINATOR= '\n'
)

bulk INSERT [DataWarehouse].[dbo].[Dim_Date]
FROM 'C:\Users\Mohammad\Desktop\Chinook_Data_Warehouse\Warehouse\Dimensions\sample data for Date Dimension\changed1.csv'
WITH (
    fieldterminator = ',',
    ROWTERMINATOR= '\n'
)



EXECUTE ETL_DimensionGenre
EXECUTE ETL_DimensionMediaType
EXECUTE ETL_DimensionArtist
EXECUTE ETL_DimensionLocation
EXEC ETL_DimensionCustomer
EXEC ETL_DimensionTrack
exec ETL_DimensionAlbum
exec ETL_DimensionEmployee

SELECT * FROM [DataWarehouse].[dbo].[Dim_Genre]
SELECT * FROM [DataWarehouse].[dbo].[Dim_MediaType]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Artist]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Location]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Customer]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Track]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Album]
SELECT * FROM [DataWarehouse].[dbo].Dim_Employee
