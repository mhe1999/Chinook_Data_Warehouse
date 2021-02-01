USE [DataWarehouse]
GO
------transaction fact---------
------first load---------------
CREATE OR ALTER PROCEDURE ETL_Sale_firstLoadTransFact
AS
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
/*    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES
        ('[DataWarehouse].[dbo].[FactTransactionOnlinePlayback]', 'FirstLoad, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', NULL, GETDATE())*/
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

    SET @EndDate = (SELECT MAX(PlayDate)
    FROM [StorageArea].[dbo].[SA_Playback])
    SET @TempDATE = (SELECT MAX(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]);
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
/*        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactTransactionOnlinePlayback]', 'Incremental Load, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @Currdate, GETDATE())*/
        SET @CurrDate = DATEADD(day, 1, @Currdate)


    END

END











EXEC ETL_Sale_firstLoadTransFact
EXEC ETL_Sale_incrementalTransFact


--TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionSale];

select * from [DataWarehouse].[dbo].[FactTransactionSale]