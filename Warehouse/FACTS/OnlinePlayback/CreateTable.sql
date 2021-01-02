USE [DataWarehouse]
GO


CREATE TABLE [DataWarehouse].[dbo].[FactTransactionOnlinePlayback](

    ID BIGINT PRIMARY KEY IDENTITY(1,1),
    CustomerID BIGINT,
    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    TranDate date,-- need to connect dimension, but now temproray worked with source

    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(TrackID) REFERENCES [dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [dbo].[Dim_MediaType](MediaTypeId),
    FOREIGN KEY(CustomerID) REFERENCES [dbo].[Dim_Customer](Id),
--    FOREIGN KEY(TranDate) REFERENCES [dbo].[date](ID)-- date dimension must be create

);

