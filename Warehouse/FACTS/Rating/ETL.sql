USE [DataWarehouse]
GO
------transaction fact---------
------first load---------------
CREATE OR ALTER PROCEDURE ETL_Rating_firstLoadTransFact
AS
BEGIN

--    TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionOnlinePlayback];

    INSERT INTO [DataWarehouse].[dbo].[FactTransactionRating]
        ( [CustomerID], [CustomerIDN], [TrackID], [TrackIDN], [AlbumID], [GenreID], [ArtistID], [LocationID], [MediaTypeID],[TranDate], Score)
    SELECT DWC.Id, DWC.CustomerId, DWT.[Id], DWT.TrackId, DWAL.[AlbumId], DWG.[GenreId], [DWAR].[ArtistId], [DWL].Id, [DWM].[MediaTypeId], DWD.TimeKey, SAP.Score
    FROM [StorageArea].[dbo].[SA_Rating] as SAP INNER JOIN [DataWarehouse].[dbo].[Dim_Customer] as DWC ON SAP.CustomerId = DWC.CustomerId AND DWC.Current_Flag_SupportRepId = 1
        INNER JOIN [DataWarehouse].[dbo].[Dim_Track] as DWT ON SAP.TrackId = DWT.TrackId AND DWT.Current_Flag_UnitPrice = 1
        INNER JOIN [DataWarehouse].[dbo].[Dim_Album] as DWAL ON DWAL.AlbumId = DWT.AlbumId
        INNER JOIN [DataWarehouse].[dbo].[Dim_Artist] AS DWAR ON DWAR.ArtistId = DWT.ArtistId
        INNER JOIN [DataWarehouse].[dbo].Dim_Genre AS DWG ON DWG.GenreId = DWT.GenreId
        inner join [DataWarehouse].[dbo].Dim_MediaType AS DWM on DWM.MediaTypeId = DWT.MediaTypeId
        inner join [DataWarehouse].[dbo].Dim_Location AS DWL ON DWL.City = DWC.City AND DWL.Country = DWC.Country
        INNER JOIN [DataWarehouse].[dbo].Dim_Date AS DWD ON YEAR(DWD.FullDateAlternateKey) =  YEAR(SAP.ScoreDate) AND MONTH(DWD.FullDateAlternateKey) =  MONTH(SAP.ScoreDate) AND DAY(DWD.FullDateAlternateKey) =  DAY(SAP.ScoreDate)
/*
    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES
        ('[DataWarehouse].[dbo].[FactTransactionOnlinePlayback]', 'FirstLoad, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', NULL, GETDATE())*/
END











exec ETL_Rating_firstLoadTransFact
select * FROM [DataWarehouse].[dbo].[FactTransactionRating]
TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionRating]
