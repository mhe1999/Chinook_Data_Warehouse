USE [DataWarehouse]
GO
------transaction fact---------
------first load---------------
CREATE OR ALTER PROCEDURE ETL_Rating_firstLoadTransFact
AS
BEGIN

    TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionRating];

    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES
        ('[DataWarehouse].[dbo].[FactTransactionRating]', 'TRUNCATE for first load', NULL, GETDATE())

    DECLARE @EndDate date;
    DECLARE @CurrDate date;

    SET @EndDate = (SELECT MAX(ScoreDate)
                    FROM [StorageArea].[dbo].[SA_Rating])
    SET @CurrDate = (SELECT MIN(ScoreDate)
                    FROM [StorageArea].[dbo].[SA_Rating])
    WHILE @CurrDate <= @EndDate
    BEGIN

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
            WHERE SAP.ScoreDate = @CurrDate

        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES
            ('[DataWarehouse].[dbo].[FactTransactionRating]', 'FirstLoad, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @CurrDate, GETDATE())

        SET @CurrDate = DATEADD(day, 1, @Currdate)

    END
END



-------incremental------------
GO
CREATE OR ALTER PROCEDURE ETL_Rating_incrementalTransFact
AS
BEGIN
    DECLARE @EndDate date;
    DECLARE @TempDATE INT;
    DECLARE @StartDate date;
    DECLARE @CurrDate date;

    SET @EndDate = (SELECT MAX(ScoreDate)
    FROM [StorageArea].[dbo].[SA_Rating])
    SET @TempDATE = (SELECT MAX(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionRating]);
    SET @StartDate = (select DWD.FullDateAlternateKey
    FROM [DataWarehouse].[dbo].Dim_Date  as DWD
    WHERE DWD.TimeKey = @TempDATE )
    SET @CurrDate = DATEADD(day, 1, @StartDate);

    WHILE @CurrDate <= @EndDate
        BEGIN

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
                WHERE SAP.ScoreDate = @CurrDate
                    INSERT into [DataWarehouse].[dbo].[LogTable]
                    VALUES('[DataWarehouse].[dbo].[FactTransactionRating]', 'Incremental Load, joined from Dim_Customer, Dim_Track, Dim_Album, Dim_Artist, Dim_Genre, Dim_MediaType, Dim_Location, Dim_Date', @Currdate, GETDATE())
        
        SET @CurrDate = DATEADD(day, 1, @Currdate)
        END

END





------------------------
---DailyFact------------
------------------------

GO
CREATE OR ALTER PROCEDURE ETL_Rating_DailyFact
AS
BEGIN

    DECLARE @EndDate INT;
    DECLARE @TempDATE INT;
    DECLARE @StartDate INT;
    DECLARE @CurrDate INT;

    SET @EndDate = (SELECT MAX(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionRating]);
    SET @TempDATE = (SELECT MIN(TranDate)
    FROM [DataWarehouse].[dbo].[FactTransactionRating])
--    SET @StartDate = @TempDATE;
    SET @CurrDate =(select isnull(max(TranDate),@TempDATE - 1)
    FROM [DataWarehouse].[dbo].[FactDailySnapshotRating]);

    SET @CurrDate = @CurrDate + 1;

    WHILE @CurrDate <= @EndDate
        BEGIN
        TRUNCATE TABLE [DataWarehouse].[dbo].tmp_CurrDate_all_Votes
        TRUNCATE TABLE [DataWarehouse].[dbo].[tmp_LastDay_Votes]

        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Truncacte tmp_CurrDate_all_Votes', NULL, GETDATE())

        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Truncate tmp_LastDay_Votes', NULL, GETDATE())

        insert into [DataWarehouse].[dbo].[tmp_CurrDate_all_Votes]
        select TrackID, LocationID, COUNT(*) AS NumOfVotes, AVG(Score) 
        FROM [DataWarehouse].[dbo].[FactTransactionRating]
        WHERE TranDate >= @CurrDate AND TranDate< @CurrDate + 1
        GROUP BY TrackID, LocationID

        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Insert Today Data to temp table', NULL, GETDATE())

        if not exists(select *
        from [DataWarehouse].[dbo].[FactDailySnapshotRating]
        WHERE TranDate < @CurrDate AND TranDate >= @CurrDate - 1)
                
        BEGIN
            --first load
            INSERT INTO [DataWarehouse].[dbo].[tmp_LastDay_Votes]
            SELECT TrackId, LocationID, 0, 0, 0
            FROM TrackAndLocation

            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Insert Yesterday Data to temp table(first load)', NULL, GETDATE())

        END


            ELSE
                BEGIN
            --incremental
            INSERT INTO [DataWarehouse].[dbo].[tmp_LastDay_Votes]
            SELECT TL.TrackID, TL.LocationID, isnull(FD.Number_Of_Votes, 0), isnull(FD.Number_Of_Votes_untillToday, 0), isnull(FD.Track_AVG_Score, 0)
            FROM TrackAndLocation as TL
                LEFT JOIN [DataWarehouse].[dbo].[FactDailySnapshotRating] as FD
                ON TL.TrackID = FD.TrackID AND TL.LocationID = FD.LocationID
            WHERE TranDate < @CurrDate AND TranDate >= @CurrDate - 1
    
    
            INSERT into [DataWarehouse].[dbo].[LogTable]
            VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Insert Yesterday Data to temp table(incremental)', NULL, GETDATE())


        END



        insert into [DataWarehouse].[dbo].[FactDailySnapshotRating]
            (TrackId, LocationID, GenreId, AlbumId, ArtistId, MediaTypeId, Number_Of_Votes, Number_Of_Votes_untillToday, Track_AVG_Score, TranDate)
        SELECT TL.TrackId, TL.LocationID, T.GenreId, T.AlbumId, T.ArtistId, T.MediaTypeId,

            ISNULL(CT.NumOfVotes, 0) as NumOfVotes,
            ISNULL(CT.NumOfVotes, 0) + TL.NumOfVotesUntillToday as NumberOfVotesUntillToday,
            CASE WHEN ISNULL(CT.NumOfVotes, 0) = 0 AND TL.NumOfVotesUntillToday = 0 THEN 0
                 WHEN ISNULL(CT.NumOfVotes, 0) = 0 AND TL.NumOfVotesUntillToday <> 0 THEN TL.AVGofVotes
                 WHEN ISNULL(CT.NumOfVotes, 0) <> 0 AND TL.NumOfVotesUntillToday = 0 THEN ISNULL(CT.AVGofVotes, 0)
                 ELSE ((ISNULL(CT.NumOfVotes, 0) * ISNULL(CT.AVGofVotes, 0)) + (TL.AVGofVotes * TL.NumOfVotesUntillToday) )/(ISNULL(CT.NumOfVotes, 0) + TL.NumOfVotesUntillToday) END AS AverageNumOfScore
            , @CurrDate


        FROM [DataWarehouse].[dbo].[tmp_LastDay_Votes] as TL
            LEFT JOIN [DataWarehouse].[dbo].[tmp_CurrDate_all_Votes] as CT
            ON TL.TrackId = CT.TrackID AND TL.LocationID = CT.LocationID
            INNER JOIN [DataWarehouse].[dbo].[Dim_Track] AS T ON TL.TrackID = T.Id


        INSERT into [DataWarehouse].[dbo].[LogTable]
        VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Insert Data to Facttable', NULL, GETDATE())

 

        SET @CurrDate = @CurrDate + 1;

    END



END


------------------first load-------------------
GO
CREATE OR ALTER PROCEDURE ETL_Rating_firstLoadDailyFact
AS
BEGIN

    TRUNCATE table [DataWarehouse].[dbo].[FactDailySnapshotRating]

    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactDailySnapshotRating]', 'Truncate table for first load', NULL, GETDATE())

    EXEC ETL_Rating_DailyFact

END


-------------------------------
------------------------------
-----------ACC-----------------
-------------------------------
-------------------------------
GO
CREATE OR ALTER PROCEDURE ETL_Sale_ACCFact
AS
BEGIN
    DECLARE @TempDate INT;
    SET @TempDate = (select max(TranDate)
    from [DataWarehouse].[dbo].[FactDailySnapshotRating])
    TRUNCATE TABLE [DataWarehouse].[dbo].[FactACCRating]
    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactACCRating]', 'TRUNCATE ACC fact', (select FullDateAlternateKey
            from Dim_Date
            where TimeKey= @TempDate), GETDATE())

 
    INSERT INTO [DataWarehouse].[dbo].[FactACCRating]
    SELECT TrackID, AlbumID, GenreID, ArtistID, LocationID, MediaTypeID, Track_AVG_Score, Number_Of_Votes_untillToday
    FROM [DataWarehouse].[dbo].[FactDailySnapshotRating]
    WHERE TranDate = @TempDate

    INSERT into [DataWarehouse].[dbo].[LogTable]
    VALUES('[DataWarehouse].[dbo].[FactACCRating]', 'Load data to ACC fact', (select FullDateAlternateKey
            from Dim_Date
            where TimeKey= @TempDate), GETDATE())


END


SELECT * from Dim_Date





exec ETL_Rating_firstLoadTransFact
exec ETL_Rating_incrementalTransFact
EXEC ETL_Rating_firstLoadDailyFact
EXEC ETL_Rating_DailyFact
EXEC ETL_Sale_ACCFact




select * FROM [DataWarehouse].[dbo].[FactTransactionRating]
--TRUNCATE TABLE [DataWarehouse].[dbo].[FactTransactionRating]

SELECT * FROM [DataWarehouse].[dbo].[tmp_CurrDate_all_Votes]
SELECT * FROM [DataWarehouse].[dbo].[FactDailySnapshotRating]
WHERE TranDate =20130120 and Number_Of_Votes_untillToday >0
--TRUNCATE table [DataWarehouse].[dbo].[FactDailySnapshotRating]

select *
from DataWarehouse.dbo.FactACCRating

SELECT * from LogTable