USE [DataWarehouse]
GO

DROP Table [DataWarehouse].[dbo].[FactTransactionOnlinePlayback]
DROP Table [DataWarehouse].[dbo].FactDailySnapshotOnlinePlayback
DROP Table [DataWarehouse].[dbo].FactACCOnlinePlayback

CREATE TABLE [DataWarehouse].[dbo].[FactTransactionOnlinePlayback](

    ID BIGINT PRIMARY KEY IDENTITY(1,1),
    CustomerID BIGINT,
    CustomerIDN INT,
    TrackID BIGINT,
    TrackIDN INT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    TranDate int,


);

CREATE TABLE dbo.FactDailySnapshotOnlinePlayback --in this periodic table we investigate **Track** statistics
(

    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    TranDate INT,
    PRIMARY KEY(TrackID, TranDate, LocationID),
    -- measures
    NumberOfPlaybackToday INT,
    MaxNum INT,
    MinNum INT,
    NumberOfPlaybackUntillToday INT,-- today + past days
    AverageNumOfPlaybackUntillToday INT,-- today + past days


);

CREATE TABLE dbo.FactACCOnlinePlayback --ACC Fact table
(

    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    PRIMARY KEY(TrackID, LocationID),

    -- measures
    MaxNum INT,
    MinNum INT,
    NumberOfPlayback INT,
    AverageNumOfPlayback INT,


);


CREATE TABLE [DataWarehouse].[dbo].tmp_CurrDate_all_Track(
    TrackID BIGINT,
    LocationID INT,
    NumOfPlayBack INT,
    PRIMARY KEY(TrackID, LocationID),
);




CREATE TABLE [DataWarehouse].[dbo].[tmp_LastDay_tracks]
(
    [TrackID] [bigint] NOT NULL,
    [LocationID] [int] NOT NULL,
    [NumberOfPlaybackToday] [int] NULL,
    [MaxNum] [int] NULL,
    [MinNum] [int] NULL,
    [NumberOfPlaybackUntillToday] [int] NULL,
    [AverageNumOfPlaybackUntillToday] [int] NULL,
    PRIMARY KEY(TrackID, LocationID)

);

GO
CREATE or ALTER view TrackAndLocation
as
    (
    SELECT T.Id as TrackId, L.Id as LocationID
    FROM [DataWarehouse].[dbo].[Dim_Location] as L, [DataWarehouse].[dbo].Dim_Track as T
    WHERE T.Current_Flag_UnitPrice = 1)
