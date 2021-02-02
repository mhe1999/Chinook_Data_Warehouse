USE [DataWarehouse]
GO
DROP TABLE FactTransactionSale
DROP TABLE FactDailySnapshotSale
DROP TABLE FactACCSale

CREATE TABLE dbo.FactTransactionSale
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
    SupportID BIGINT,
    TranDate INT,

    ---Measures
    Price NUMERIC(10,2),
);


CREATE TABLE dbo.FactDailySnapshotSale
(

    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    TranDate INT,
    SupportID BIGINT,
    PRIMARY KEY(TrackID, LocationID, TranDate,SupportID),
    ---Measures
    sumSaletoday NUMERIC(15,2),
    numberofSaleToday int,
    averageSaleUntillToday NUMERIC(15,2),
    MaxNum int,
    MinNum int,


);


CREATE TABLE dbo.FactACCSale
(

    TrackID BIGINT,
    AlbumID INT,
    GenreID INT,
    ArtistID INT,
    LocationID INT,
    MediaTypeID INT,
    SupportID BIGINT,
    PRIMARY KEY(TrackID, LocationID,SupportID),

    ---Measures

    sumSale NUMERIC(30,2),
	numberofSale INT,
    averageSale NUMERIC(15,2),
    MaxNum int,
    MinNum int,
);




CREATE or ALTER VIEW LocationAndTrackAndEmployee as(
    SELECT T.Id as TrackId, L.Id as LocationID, E.Id as EmployeeId
    from [DataWarehouse].[dbo].[Dim_Location] as L,
     [DataWarehouse].[dbo].Dim_Track as T,
     [DataWarehouse].[dbo].Dim_Employee as E
     WHERE T.Current_Flag_UnitPrice = 1 AND E.Current_Flag =1
);

--SELECT * FROM LocationAndTrackAndEmployee



CREATE TABLE [DataWarehouse].[dbo].tmp_CurrDate_all_Sale
(
    TrackID BIGINT,
    LocationID INT,
    EmployeeID BIGINT,
    NumOfSale INT,
    SumSale NUMERIC(15,2),
    PRIMARY KEY(TrackID, LocationID, EmployeeID),
);




CREATE TABLE [DataWarehouse].[dbo].[tmp_LastDay_Sales]
(
    [TrackID] [bigint] NOT NULL,
    [LocationID] [int] NOT NULL,
    EmployeeID BIGINT,
    SumSaleToday NUMERIC(15,2),
    [NumberOfSaleToday] int, 
    [AverageSaleUntillToday] NUMERIC(15,2), 
    [MaxNum] [int] NULL,
    [MinNum] [int] NULL,
    PRIMARY KEY(TrackID, LocationID, EmployeeID)

);