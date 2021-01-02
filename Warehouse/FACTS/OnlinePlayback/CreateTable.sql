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
    TranDate int,

    FOREIGN KEY(LocationID) REFERENCES [DataWarehouse].[dbo].[Dim_Location](Id),
    FOREIGN KEY(TrackID) REFERENCES [DataWarehouse].[dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [DataWarehouse].[dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [DataWarehouse].[dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [DataWarehouse].[dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [DataWarehouse].[dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [DataWarehouse].[dbo].[Dim_MediaType](MediaTypeId),
    FOREIGN KEY(CustomerID) REFERENCES [DataWarehouse].[dbo].[Dim_Customer](Id),
    FOREIGN KEY(TranDate) REFERENCES [DataWarehouse].[dbo].[Dim_Date](TimeKey)
);

