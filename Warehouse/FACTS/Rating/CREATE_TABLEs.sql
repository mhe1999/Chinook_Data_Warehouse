USE [DataWarehouse]

CREATE TABLE dbo.FactTransactionRating
(

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
    TranDate INT,

	---Measures
	Score INT,

/*
    FOREIGN KEY(TrackID) REFERENCES [DataWarehouse].[dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [DataWarehouse].[dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [DataWarehouse].[dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [DataWarehouse].[dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [DataWarehouse].[dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [DataWarehouse].[dbo].[Dim_MediaType](MediaTypeId),
    FOREIGN KEY(CustomerID) REFERENCES [DataWarehouse].[dbo].[Dim_Customer](Id),
    FOREIGN KEY(TranDate) REFERENCES [DataWarehouse].[dbo].[Dim_Date](TimeKey)
*/
);


CREATE TABLE dbo.FactDailySnapshotRating
(

    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    TranDate INT,
    PRIMARY KEY(TrackID, LocationID, TranDate),
	---Measures
	Track_AVG_Score DECIMAL(2,1),
	Number_Of_Votes int,
    Number_Of_Votes_untillToday int,
/*
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(TrackID) REFERENCES [dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [dbo].[Dim_MediaType](MediaTypeId),
	FOREIGN KEY(TranDate) REFERENCES [dbo].[Dim_Date](TimeKey)-- date dimension must be create
*/
);


CREATE TABLE dbo.FactACCRating(

    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    PRIMARY KEY(TrackID, LocationID),

	---Measures
	Track_AVG_Score DECIMAL(2,1),
	Number_Of_Votes int,

/*	Last_30Day_Average DECIMAL(2,1),
	Max_Average_Rate DECIMAL(2,1),
    MaxAvgDate INT,
	Min_Average_Rate DECIMAL(2,1),
    MinAvgDate INT

    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(TrackID) REFERENCES [dbo].[Dim_Track](Id),
    FOREIGN KEY(AlbumID) REFERENCES [dbo].[Dim_Album](AlbumId),
    FOREIGN KEY(GenreID) REFERENCES [dbo].[Dim_Genre](GenreId),
    FOREIGN KEY(ArtistID) REFERENCES [dbo].[Dim_Artist](ArtistId),
    FOREIGN KEY(LocationID) REFERENCES [dbo].[Dim_Location](Id),
    FOREIGN KEY(MediaTypeID) REFERENCES [dbo].[Dim_MediaType](MediaTypeId),
*/
);








CREATE TABLE [DataWarehouse].[dbo].tmp_CurrDate_all_Votes
(
    TrackID BIGINT,
    LocationID INT,
    NumOfVotes INT,
    AVGofVotes DECIMAL(2,1),
    PRIMARY KEY(TrackID, LocationID),
);



CREATE TABLE [DataWarehouse].[dbo].tmp_LastDay_Votes
(
    TrackID BIGINT,
    LocationID INT,
    NumOfVotes INT,
    NumOfVotesUntillToday INT,
    AVGofVotes DECIMAL(2,1),
    PRIMARY KEY(TrackID, LocationID),
);

