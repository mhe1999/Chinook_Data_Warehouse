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

