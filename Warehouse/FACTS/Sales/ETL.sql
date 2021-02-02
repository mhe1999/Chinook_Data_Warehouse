USE [DataWarehouse]
GO
------transaction fact---------
------first load---------------
CREATE OR ALTER PROCEDURE ETL_Sale_firstLoadTransFact
AS
BEGIN

    TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionSale];
    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactTransactionSale]', 'TRUNCATE Transactions fact for first load', NULL, GETDATE())
 
    DECLARE @EndDate date;
    DECLARE @TempDATE INT;
    DECLARE @StartDate date;
    DECLARE @CurrDate date;

    SET @EndDate = (SELECT MAX(InvoiceDate)
    FROM [StorageArea].[dbo].[SA_Sale])
    SET @CurrDate =(SELECT MIN(InvoiceDate)
    FROM [StorageArea].[dbo].[SA_Sale])

    WHILE @CurrDate <= @EndDate
        BEGIN

            INSERT INTO [DataWarehouse].[dbo].[FactTransactionSale]
                ( [CustomerID], [CustomerIDN], [TrackID], [TrackIDN], [AlbumID], [GenreID], [ArtistID], [LocationID], [MediaTypeID], [SupportID], [TranDate], [Price])
            SELECT DWC.Id, DWC.CustomerId, DWT.[Id], DWT.TrackId, DWAL.[AlbumId], DWG.[GenreId], [DWAR].[ArtistId], [DWL].Id, [DWM].[MediaTypeId], DWE.ID ,DWD.TimeKey, SAP.Price
            FROM [StorageArea].[dbo].[SA_Sale] as SAP INNER JOIN [DataWarehouse].[dbo].[Dim_Customer] as DWC ON SAP.CustomerId = DWC.CustomerId AND DWC.Current_Flag_SupportRepId = 1
                INNER JOIN [DataWarehouse].[dbo].[Dim_Track] as DWT ON SAP.TrackId = DWT.TrackId AND DWT.Current_Flag_UnitPrice = 1
                INNER JOIN [DataWarehouse].[dbo].[Dim_Album] as DWAL ON DWAL.AlbumId = DWT.AlbumId
                INNER JOIN [DataWarehouse].[dbo].[Dim_Artist] AS DWAR ON DWAR.ArtistId = DWT.ArtistId
                INNER JOIN [DataWarehouse].[dbo].Dim_Genre AS DWG ON DWG.GenreId = DWT.GenreId
                inner join [DataWarehouse].[dbo].Dim_MediaType AS DWM on DWM.MediaTypeId = DWT.MediaTypeId
                inner join [DataWarehouse].[dbo].Dim_Location AS DWL ON DWL.City = DWC.City AND DWL.Country = DWC.Country
                INNER JOIN [DataWarehouse].[dbo].Dim_Date AS DWD ON YEAR(DWD.FullDateAlternateKey) =  YEAR(SAP.InvoiceDate) AND MONTH(DWD.FullDateAlternateKey) =  MONTH(SAP.InvoiceDate) AND DAY(DWD.FullDateAlternateKey) =  DAY(SAP.InvoiceDate)
                INNER JOIN [DataWarehouse].[dbo].Dim_Employee AS DWE ON DWE.Id = DWC.SupportRepId AND DWE.Current_Flag = 1
                WHERE SAP.InvoiceDate = @CurrDate
        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactTransactionSale]', 'FirstLoad, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @CurrDate, GETDATE())
                SET @CurrDate = DATEADD(day, 1, @Currdate)
        END
END



-----incremental---------
GO
CREATE OR ALTER PROCEDURE ETL_Sale_incrementalTransFact
AS
BEGIN
    DECLARE @EndDate date;
    DECLARE @TempDATE INT;
    DECLARE @StartDate date;
    DECLARE @CurrDate date;

    SET @EndDate = (SELECT MAX(InvoiceDate)
    FROM [StorageArea].[dbo].[SA_Sale])
    SET @TempDATE = (SELECT MAX(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionSale]);
    SET @StartDate = (select DWD.FullDateAlternateKey
    FROM [DataWarehouse].[dbo].Dim_Date  as DWD
    WHERE DWD.TimeKey = @TempDATE )
    SET @CurrDate = DATEADD(day, 1, @StartDate);

    WHILE @CurrDate <= @EndDate
    BEGIN


        INSERT INTO [DataWarehouse].[dbo].[FactTransactionSale]
            ( [CustomerID], [CustomerIDN], [TrackID], [TrackIDN], [AlbumID], [GenreID], [ArtistID], [LocationID], [MediaTypeID], [SupportID], [TranDate], [Price])
        SELECT DWC.Id, DWC.CustomerId, DWT.[Id], DWT.TrackId, DWAL.[AlbumId], DWG.[GenreId], [DWAR].[ArtistId], [DWL].Id, [DWM].[MediaTypeId], DWE.ID , DWD.TimeKey, SAP.Price
        FROM [StorageArea].[dbo].[SA_Sale] as SAP INNER JOIN [DataWarehouse].[dbo].[Dim_Customer] as DWC ON SAP.CustomerId = DWC.CustomerId AND DWC.Current_Flag_SupportRepId = 1
            INNER JOIN [DataWarehouse].[dbo].[Dim_Track] as DWT ON SAP.TrackId = DWT.TrackId AND DWT.Current_Flag_UnitPrice = 1
            INNER JOIN [DataWarehouse].[dbo].[Dim_Album] as DWAL ON DWAL.AlbumId = DWT.AlbumId
            INNER JOIN [DataWarehouse].[dbo].[Dim_Artist] AS DWAR ON DWAR.ArtistId = DWT.ArtistId
            INNER JOIN [DataWarehouse].[dbo].Dim_Genre AS DWG ON DWG.GenreId = DWT.GenreId
            inner join [DataWarehouse].[dbo].Dim_MediaType AS DWM on DWM.MediaTypeId = DWT.MediaTypeId
            inner join [DataWarehouse].[dbo].Dim_Location AS DWL ON DWL.City = DWC.City AND DWL.Country = DWC.Country
            INNER JOIN [DataWarehouse].[dbo].Dim_Date AS DWD ON YEAR(DWD.FullDateAlternateKey) =  YEAR(SAP.InvoiceDate) AND MONTH(DWD.FullDateAlternateKey) =  MONTH(SAP.InvoiceDate) AND DAY(DWD.FullDateAlternateKey) =  DAY(SAP.InvoiceDate)
            INNER JOIN [DataWarehouse].[dbo].Dim_Employee AS DWE ON DWE.Id = DWC.SupportRepId AND DWE.Current_Flag = 1
                WHERE SAP.InvoiceDate = @CurrDate
                INSERT into [DataWarehouse].[dbo].[LogTable]
                VALUES('[DataWarehouse].[dbo].[FactTransactionSale]', 'Incremental Load, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @Currdate, GETDATE())
                SET @CurrDate = DATEADD(day, 1, @Currdate)


    END

END




-------------------------------------
-------------------------------------
-------------fact daily--------------
-------------------------------------
-------------------------------------
GO
CREATE OR ALTER PROCEDURE ETL_Sale_FactDaily
AS
BEGIN

    DECLARE @EndDate INT;
    DECLARE @TempDATE INT;
    DECLARE @StartDate INT;
    DECLARE @CurrDate INT;

    SET @EndDate = (SELECT MAX(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionSale]);
    SET @TempDATE = (SELECT MIN(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionSale])
    SET @StartDate = @TempDATE
    SET @CurrDate =(select isnull(max(TranDate),@TempDATE - 1)
    FROM [DataWarehouse].[dbo].[FactDailySnapshotSale]);

    SET @CurrDate = @CurrDate + 1;
    WHILE @CurrDate <= @EndDate
        BEGIN
        TRUNCATE TABLE [DataWarehouse].[dbo].tmp_CurrDate_all_Sale
        TRUNCATE TABLE [DataWarehouse].[dbo].tmp_LastDay_Sales

        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Truncacte tmp_CurrDate_all_Sale', NULL, GETDATE())

        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Truncate tmp_LastDay_Sales', NULL, GETDATE())

        insert into [DataWarehouse].[dbo].[tmp_CurrDate_all_Sale]
        select TrackID, LocationID, SupportID, COUNT(*) AS NumOfSale, Sum(Price)
        FROM [DataWarehouse].[dbo].[FactTransactionSale]
        WHERE TranDate >= @CurrDate AND TranDate< @CurrDate + 1
        GROUP BY TrackID, LocationID, SupportID


        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Insert Today Data to temp table', NULL, GETDATE())

 

        if not exists(select *
                    from [DataWarehouse].[dbo].[FactDailySnapshotSale]
                    WHERE TranDate < @CurrDate AND TranDate >= @CurrDate - 1)
        BEGIN
            --first load
            INSERT INTO [DataWarehouse].[dbo].[tmp_LastDay_Sales]
            SELECT TrackId, LocationID, EmployeeID, 0, 0, 0, 0, 0
            FROM LocationAndTrackAndEmployee

            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Insert Yesterday Data to temp table(first load)', NULL, GETDATE())

 
        END


        
        ELSE
        
        BEGIN
            --incremental
            INSERT INTO [DataWarehouse].[dbo].[tmp_LastDay_Sales]
            SELECT TL.TrackId, TL.LocationID, TL.EmployeeId, isnull(FD.sumSaletoday, 0), ISNULL(FD.numberofSaleToday,0), ISNULL(FD.averageSaleUntillToday, 0), isnull(FD.MaxNum, 0), isnull(FD.MinNum, 0)
            FROM LocationAndTrackAndEmployee as TL
                LEFT JOIN [DataWarehouse].[dbo].[FactDailySnapshotSale] as FD
                ON TL.TrackID = FD.TrackID AND TL.LocationID = FD.LocationID AND TL.EmployeeId = FD.SupportID
            WHERE TranDate < @CurrDate AND TranDate >= @CurrDate - 1

            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Insert Yesterday Data to temp table(incremental)', NULL, GETDATE())
        END



        insert into [DataWarehouse].[dbo].[FactDailySnapshotSale]
            (TrackId, LocationID, SupportID, GenreId, AlbumId, ArtistId, MediaTypeId, sumSaletoday, numberofSaleToday, averageSaleUntillToday, MaxNum, MinNum, TranDate)
        SELECT TL.TrackId, TL.LocationID, TL.EmployeeID,T.GenreId, T.AlbumId, T.ArtistId, T.MediaTypeId,

            ISNULL(CT.SumSale, 0)  as numberofSaleToday,
            ISNULL(CT.NumOfSale, 0) as numberofSaleToday,
            ((ISNULL(CT.SumSale, 0) + ((TL.AverageSaleUntillToday)*(@CurrDate-@StartDate)) )/(1+(@CurrDate -@StartDate))) AS AverageSaleUntillToday, 
            CASE 
                when TL.MaxNum >= ISNULL(CT.NumOfSale, 0) then TL.MaxNum
                else  ISNULL(CT.NumOfSale, 0) END AS MaxNum,

            CASE 
                when TL.MinNum = 0 AND ISNULL(CT.NumOfSale, 0) = 0 then 0
                when TL.MinNum = 0 AND ISNULL(CT.NumOfSale, 0) <> 0 then ISNULL(CT.NumOfSale, 0)
                when TL.MinNum <> 0 AND ISNULL(CT.NumOfSale, 0) = 0 then TL.MinNum
                when TL.MinNum <= ISNULL(CT.NumOfSale, 0) then TL.MinNum
                else  ISNULL(CT.NumOfSale, 0) END AS MinNum,
            @CurrDate


        FROM [DataWarehouse].[dbo].[tmp_LastDay_Sales] as TL
            LEFT JOIN [DataWarehouse].[dbo].[tmp_CurrDate_all_Sale] as CT
            ON TL.TrackID = CT.TrackID AND TL.LocationID = CT.LocationID AND TL.EmployeeID = CT.EmployeeID
            INNER JOIN [DataWarehouse].[dbo].[Dim_Track] AS T ON TL.TrackID = T.Id 


            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Insert Data to Facttable', NULL, GETDATE())

        SET @CurrDate = @CurrDate + 1;

    END



END


--------------first load ----------------

GO
CREATE OR ALTER PROCEDURE ETL_Sale_firstLoadFactDaily
AS
BEGIN
    TRUNCATE TABLE [DataWarehouse].[dbo].[FactDailySnapshotSale];
    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactDailySnapshotSale]', 'Truncate table first load', NULL, GETDATE())
    EXEC ETL_Sale_FactDaily
END



-------------------------
-------------------------
---------ACC-------------
-------------------------
-------------------------
GO
CREATE OR ALTER PROCEDURE ETL_Sale_ACCFact
AS
BEGIN
    DECLARE @TempDate INT;
    SET @TempDate = (select max(TranDate)
    from [DataWarehouse].[dbo].[FactDailySnapshotSale])

    TRUNCATE TABLE [DataWarehouse].[dbo].[FactACCSale]
    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactACCSale]', 'TRUNCATE ACC fact', (select FullDateAlternateKey from Dim_Date where TimeKey= @TempDate), GETDATE())

    INSERT INTO [DataWarehouse].[dbo].[FactACCSale](TrackID, AlbumID, SupportID,GenreID, ArtistID, LocationID, MediaTypeID, sumSale, numberofSale, averageSale, MaxNum, MinNum)
    SELECT TrackID, AlbumID, SupportID,GenreID, ArtistID, LocationID, MediaTypeID,  sumSaletoday, numberofSaleToday, averageSaleUntillToday, MaxNum, MinNum
    FROM [DataWarehouse].[dbo].[FactDailySnapshotSale]
    WHERE TranDate = @TempDate

    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactACCSale]', 'Load Data ACC fact', (select FullDateAlternateKey
            from Dim_Date
            where TimeKey= @TempDate), GETDATE())

END



EXEC ETL_Sale_firstLoadTransFact
EXEC ETL_Sale_incrementalTransFact
exec ETL_Sale_firstLoadFactDaily
EXEC ETL_Sale_FactDaily
EXEC ETL_Sale_ACCFact


--TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionSale];

select * from [DataWarehouse].[dbo].[FactTransactionSale]

truncate table [DataWarehouse].[dbo].[FactDailySnapshotSale]
select * from [DataWarehouse].[dbo].[tmp_CurrDate_all_Sale]
select * from [DataWarehouse].[dbo].tmp_LastDay_Sales
select * from [DataWarehouse].[dbo].[FactTransactionSale]
select * from [DataWarehouse].[dbo].[FactDailySnapshotSale]

where sumSaletoday > 0

select * from [DataWarehouse].[dbo].[LogTable]
select * from  [DataWarehouse].[dbo].[FactACCSale]
WHERE numberofSale>0    