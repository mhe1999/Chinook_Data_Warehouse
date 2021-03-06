USE [DataWarehouse]
GO
------transaction fact---------
------first load---------------
CREATE OR ALTER PROCEDURE ETL_OP_firstLoadTransFact
AS
BEGIN

TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionOnlinePlayback];

DECLARE @EndDate date;
DECLARE @CurrDate date;

SET @EndDate = (SELECT MAX(PlayDate)
FROM [StorageArea].[dbo].[SA_Playback])
SET @CurrDate = (SELECT MIN(PlayDate) FROM [StorageArea].[dbo].[SA_Playback]);

WHILE @CurrDate <= @EndDate
        BEGIN
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
                WHERE SAP.PlayDate = @CurrDate
            INSERT into [DataWarehouse].[dbo].[LogTable] VALUES ('[DataWarehouse].[dbo].[FactTransactionOnlinePlayback]','FirstLoad, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @CurrDate,GETDATE())

            SET @CurrDate = DATEADD(day, 1, @Currdate)

        END
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
                INSERT into [DataWarehouse].[dbo].[LogTable] VALUES('[DataWarehouse].[dbo].[FactTransactionOnlinePlayback]', 'Incremental Load, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @Currdate, GETDATE())
                SET @CurrDate = DATEADD(day, 1, @Currdate)


        END

END






------------------------
---DailyFact------------
------------------------



GO
CREATE OR ALTER PROCEDURE ETL_OP_DailyFact
AS
BEGIN

DECLARE @EndDate INT;
DECLARE @TempDATE INT;
DECLARE @StartDate INT;
DECLARE @CurrDate INT;

SET @EndDate = (SELECT MAX(TranDate)FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]);
SET @TempDATE = (SELECT MIN(TranDate)FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback])
SET @StartDate = @TempDATE;
SET @CurrDate =(select isnull(max(TranDate),@TempDATE - 1) FROM [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]);
SET @CurrDate = @CurrDate + 1;

WHILE @CurrDate <= @EndDate
        BEGIN        
            TRUNCATE TABLE [DataWarehouse].[dbo].tmp_CurrDate_all_Track 
            TRUNCATE TABLE [DataWarehouse].[dbo].[tmp_LastDay_tracks]
            
            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Truncacte tmp_CurrDate_all_Track', NULL, GETDATE())

            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Truncate tmp_LastDay_tracks', NULL, GETDATE())

            insert into [DataWarehouse].[dbo].[tmp_CurrDate_all_Track]
            select TrackID, LocationID, COUNT(*) AS NumOfPlayBack 
            FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]
            WHERE TranDate >= @CurrDate AND TranDate< @CurrDate + 1 
            GROUP BY TrackID, LocationID

            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Insert Today Data to temp table', NULL, GETDATE())

            if not exists(select * 
                            from [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback] 
                            WHERE TranDate < @CurrDate AND TranDate >= @CurrDate - 1)
                            
                BEGIN --first load
                    INSERT INTO [DataWarehouse].[dbo].[tmp_LastDay_tracks]
                    SELECT TrackId, LocationID, 0, 0, 0, 0, 0
                    FROM TrackAndLocation

                    INSERT into [DataWarehouse].[dbo].[LogTable]
                    VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Insert Yesterday Data to temp table(first load)', NULL, GETDATE())

                END


            ELSE
                BEGIN --incremental
                    INSERT INTO [DataWarehouse].[dbo].[tmp_LastDay_tracks]
                    SELECT TL.TrackID, TL.LocationID, isnull(FD.NumberOfPlaybackToday, 0), isnull(MaxNum, 0), isnull(MinNum, 0), isnull(NumberOfPlaybackUntillToday, 0), isnull(AverageNumOfPlaybackUntillToday, 0)
                    FROM TrackAndLocation as TL 
                                    LEFT JOIN  [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback] as FD 
                                            ON TL.TrackID = FD.TrackID AND TL.LocationID = FD.LocationID
                    WHERE TranDate < @CurrDate AND TranDate >= @CurrDate - 1

                    INSERT into [DataWarehouse].[dbo].[LogTable]
                    VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Insert Yesterday Data to temp table(incremental)', NULL, GETDATE())

                END

     
     
            insert into [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback](TrackId, LocationID, GenreId, AlbumId, ArtistId, MediaTypeId, NumberOfPlaybackToday, MaxNum, MinNum, NumberOfPlaybackUntillToday, AverageNumOfPlaybackUntillToday, TranDate)
            SELECT TL.TrackId, TL.LocationID, T.GenreId, T.AlbumId, T.ArtistId, T.MediaTypeId,
    
                ISNULL(CT.NumOfPlayBack, 0) as NumOfPlayBack, 
                CASE 
                    when TL.MaxNum >= ISNULL(CT.NumOfPlayBack, 0) then TL.MaxNum
                    else  ISNULL(CT.NumOfPlayBack, 0) END AS MaxNum,

                CASE 
                    when TL.MinNum = 0 AND ISNULL(CT.NumOfPlayBack, 0) = 0 then 0
                    when TL.MinNum = 0 AND ISNULL(CT.NumOfPlayBack, 0) <> 0 then ISNULL(CT.NumOfPlayBack, 0)
                    when TL.MinNum <> 0 AND ISNULL(CT.NumOfPlayBack, 0) = 0 then TL.MinNum
                    when TL.MinNum <= ISNULL(CT.NumOfPlayBack, 0) then TL.MinNum
                    else  ISNULL(CT.NumOfPlayBack, 0) END AS MinNum,

                    ISNULL(CT.NumOfPlayBack, 0) + TL.NumberOfPlaybackUntillToday as NumberOfPlaybackUntillToday,
                    ((ISNULL(CT.NumOfPlayBack, 0) + TL.NumberOfPlaybackUntillToday)/(1+(@CurrDate -@StartDate))) AS AverageNumOfPlayback 
                    ,@CurrDate
                    
                
                FROM  [DataWarehouse].[dbo].[tmp_LastDay_tracks] as TL 
                        LEFT JOIN [DataWarehouse].[dbo].[tmp_CurrDate_all_Track] as CT
                                ON TL.TrackId = CT.TrackID AND TL.LocationID = CT.LocationID
                        INNER JOIN [DataWarehouse].[dbo].[Dim_Track] AS T ON TL.TrackID = T.Id 


        
            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Insert Data to Facttable', NULL, GETDATE())

        SET @CurrDate = @CurrDate + 1;

        END



END

GO
CREATE OR ALTER PROCEDURE ETL_OP_firstLoadDailyFact
AS 
BEGIN
    TRUNCATE TABLE [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]

    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]', 'Truncate table first load', NULL, GETDATE())
    EXEC ETL_OP_DailyFact

END



-------------------------
-------------------------
---------ACC-------------
-------------------------
-------------------------
GO
CREATE OR ALTER PROCEDURE ETL_OP_ACCFact
AS
BEGIN
    DECLARE @TempDate INT;
    SET @TempDate = (select max(TranDate) from [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback])
    TRUNCATE TABLE [DataWarehouse].[dbo].[FactACCOnlinePlayback]

    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactACCOnlinePlayback]', 'Truncate ACC fact', (select FullDateAlternateKey
            from Dim_Date
            where TimeKey= @TempDate), GETDATE())

    INSERT INTO [DataWarehouse].[dbo].[FactACCOnlinePlayback]
    SELECT TrackID, AlbumID, GenreID, ArtistID, LocationID, MediaTypeID, MaxNum, MinNum, NumberOfPlaybackUntillToday, AverageNumOfPlaybackUntillToday
    FROM [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]
    WHERE TranDate = @TempDate
    
    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactACCOnlinePlayback]', 'ACC Load data', (select FullDateAlternateKey from Dim_Date where TimeKey= @TempDate), GETDATE())

END




















EXEC ETL_OP_firstLoadTransFact
exec ETL_OP_incrementalTransFact
exec ETL_OP_firstLoadDailyFact
EXEC ETL_OP_DailyFact
EXEC ETL_OP_ACCFact

--TRUNCATE TABLE [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback]

select * FROM [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]
select * FROM [DataWarehouse].[dbo].[LogTable]
SELECT * FROM [DataWarehouse].[dbo].[FactDailySnapshotOnlinePlayback] ORDER by TrackID,LocationID
select * FROM [DataWarehouse].[dbo].[FactACCOnlinePlayback] WHERE AverageNumOfPlayback > 0
