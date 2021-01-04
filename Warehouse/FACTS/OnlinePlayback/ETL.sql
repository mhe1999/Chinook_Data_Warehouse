USE [DataWarehouse]
GO
------transaction fact---------
------first load---------------
CREATE OR ALTER PROCEDURE ETL_OP_firstLoadTransFact
AS
BEGIN

--TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionOnlinePlayback];

    INSERT INTO [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]
    ( [CustomerID], [CustomerIDN], [TrackID], [TrackIDN], [AlbumID], [GenreID], [ArtistID], [LocationID], [MediaTypeID],[TranDate])
SELECT DWC.Id, DWC.CustomerId, DWT.[Id], DWT.TrackId, DWAL.[AlbumId], DWG.[GenreId], [DWAR].[ArtistId], [DWL].Id, [DWM].[MediaTypeId], DWD.TimeKey
FROM [StorageArea].[dbo].[SA_Playback] as SAP INNER JOIN [DataWarehouse].[dbo].[Dim_Customer] as DWC ON SAP.CustomerId = DWC.CustomerId AND DWC.Current_Flag_SupportRepId = 1
                                              INNER JOIN [DataWarehouse].[dbo].[Dim_Track] as DWT ON SAP.TrackId = DWT.TrackId AND DWT.Current_Flag_UnitPrice = 1
                                              INNER JOIN [DataWarehouse].[dbo].[Dim_Album] as DWAL ON DWAL.AlbumId = DWT.AlbumId 
                                              INNER JOIN [DataWarehouse].[dbo].[Dim_Artist] AS DWAR ON DWAR.ArtistId = DWT.ArtistId 
                                              INNER JOIN [DataWarehouse].[dbo].Dim_Genre AS DWG ON DWG.GenreId = DWT.GenreId
                                              inner join [DataWarehouse].[dbo].Dim_MediaType AS DWM on DWM.MediaTypeId = DWT.MediaTypeId
                                              inner join [DataWarehouse].[dbo].Dim_Location AS DWL ON DWL.City = DWC.City AND DWL.Country = DWC.Country
                                              INNER JOIN [DataWarehouse].[dbo].Dim_Date AS DWD ON YEAR(DWD.FullDateAlternateKey) =  YEAR(SAP.PlayDate)  AND  MONTH(DWD.FullDateAlternateKey) =  MONTH(SAP.PlayDate)   AND DAY(DWD.FullDateAlternateKey) =  DAY(SAP.PlayDate)                                       
END


-------incremental------------
GO
CREATE OR ALTER PROCEDURE ETL_OP_incrementalTransFact
AS
BEGIN
    DECLARE @EndDate date;
    DECLARE @TempDATE INT;
    DECLARE @StartDate date;
    DECLARE @CurrDate date;

    SET @EndDate = (SELECT MAX(PlayDate) FROM [StorageArea].[dbo].[SA_Playback])
    SET @TempDATE = (SELECT MAX(TranDate) FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]);
    SET @StartDate = (select DWD.FullDateAlternateKey FROM [DataWarehouse].[dbo].Dim_Date  as DWD WHERE DWD.TimeKey = @TempDATE )
    SET @CurrDate = DATEADD(day, 1, @StartDate);

    WHILE @CurrDate <= @EndDate
        BEGIN

            INSERT INTO [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]
                ( [CustomerID], [CustomerIDN], [TrackID], [TrackIDN], [AlbumID], [GenreID], [ArtistID], [LocationID], [MediaTypeID],[TranDate])
            SELECT DWC.Id, DWC.CustomerId,DWT.[Id], DWT.TrackId, DWAL.[AlbumId], DWG.[GenreId], [DWAR].[ArtistId], [DWL].Id, [DWM].[MediaTypeId], DWD.TimeKey
            FROM [StorageArea].[dbo].[SA_Playback] as SAP INNER JOIN [DataWarehouse].[dbo].[Dim_Customer] as DWC ON SAP.CustomerId = DWC.CustomerId AND DWC.Current_Flag_SupportRepId = 1
                INNER JOIN [DataWarehouse].[dbo].[Dim_Track] as DWT ON SAP.TrackId = DWT.TrackId AND DWT.Current_Flag_UnitPrice = 1
                INNER JOIN [DataWarehouse].[dbo].[Dim_Album] as DWAL ON DWAL.AlbumId = DWT.AlbumId
                INNER JOIN [DataWarehouse].[dbo].[Dim_Artist] AS DWAR ON DWAR.ArtistId = DWT.ArtistId
                INNER JOIN [DataWarehouse].[dbo].Dim_Genre AS DWG ON DWG.GenreId = DWT.GenreId
                inner join [DataWarehouse].[dbo].Dim_MediaType AS DWM on DWM.MediaTypeId = DWT.MediaTypeId
                inner join [DataWarehouse].[dbo].Dim_Location AS DWL ON DWL.City = DWC.City AND DWL.Country = DWC.Country                                                                                             
                INNER JOIN [DataWarehouse].[dbo].Dim_Date AS DWD ON YEAR(DWD.FullDateAlternateKey) =  YEAR(SAP.PlayDate)  AND  MONTH(DWD.FullDateAlternateKey) =  MONTH(SAP.PlayDate)   AND DAY(DWD.FullDateAlternateKey) =  DAY(SAP.PlayDate)                                       
                WHERE SAP.PlayDate = @CurrDate
                SET @CurrDate = DATEADD(day, 1, @Currdate)
        END

END










EXEC ETL_OP_firstLoadTransFact
exec ETL_OP_incrementalTransFact
select * FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]