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

	/*
    FOREIGN KEY(TrackID) REFERENCES [DataWarehouse].[dbo].[Dim_Track](Id),
--    FOREIGN KEY(TrackIDN) REFERENCES [DataWarehouse].[dbo].[Dim_Track](TrackId),
    FOREIGN KEY(AlbumID) REFERENCES [DataWarehouse].[dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [DataWarehouse].[dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [DataWarehouse].[dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [DataWarehouse].[dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [DataWarehouse].[dbo].[Dim_MediaType](MediaTypeId),
    FOREIGN KEY(CustomerID) REFERENCES [DataWarehouse].[dbo].[Dim_Customer](Id),
--    FOREIGN KEY(CustomerIDN) REFERENCES [DataWarehouse].[dbo].[Dim_Customer](CustomerId),
    FOREIGN KEY(TranDate) REFERENCES [DataWarehouse].[dbo].[Dim_Date](TimeKey)*/
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

/*
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(TrackID) REFERENCES [dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [dbo].[Dim_Artist](ArtistId),
   FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [dbo].[Dim_MediaType](MediaTypeId),
    FOREIGN KEY(TranDate) REFERENCES [dbo].[Dim_Date](TimeKey)-- date dimension must be create*/

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

	/*
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(TrackID) REFERENCES [dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [dbo].[Dim_MediaType](MediaTypeId),*/

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

CREATE TABLE [DataWarehouse].[dbo].[LogTable](

    ID BIGINT PRIMARY KEY IDENTITY(1,1),
    [TableName] NVARCHAR(210) NOT NULL,
    Descriptions NVARCHAR(210) NOT NULL,
    CurrDate date,
    LogDate DATETIME,
);

GO
CREATE or ALTER view TrackAndLocation
as
    (
    SELECT T.Id as TrackId, L.Id as LocationID
    FROM [DataWarehouse].[dbo].[Dim_Location] as L, [DataWarehouse].[dbo].Dim_Track as T
    WHERE T.Current_Flag_UnitPrice = 1)
