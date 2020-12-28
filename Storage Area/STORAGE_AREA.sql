----CREATE DATABASES
CREATE DATABASE [StorageArea]
GO

USE [StorageArea]
GO
----CREATE TABLES
CREATE TABLE [dbo].[SA_Artist]
(
    [ArtistId] INT NOT NULL,
    [Name] NVARCHAR(120),
    CONSTRAINT [PK_Artist] PRIMARY KEY CLUSTERED ([ArtistId])
);


CREATE TABLE [dbo].[SA_Album]
(
    [AlbumId] INT NOT NULL,
    [Title] NVARCHAR(160) NOT NULL,
    [ArtistId] INT NOT NULL,
    CONSTRAINT [PK_Album] PRIMARY KEY CLUSTERED ([AlbumId]),
	FOREIGN KEY([ArtistId]) REFERENCES [StorageArea].[dbo].[SA_Artist]([ArtistId])
);


CREATE TABLE [dbo].[SA_Employee]
(
    [EmployeeId] INT NOT NULL,
    [LastName] NVARCHAR(20) NOT NULL,
    [FirstName] NVARCHAR(20) NOT NULL,
    [Title] NVARCHAR(30),
    [ReportsTo] INT,
    [BirthDate] DATETIME,
    [HireDate] DATETIME,
    [Address] NVARCHAR(70),
    [City] NVARCHAR(40),
    [State] NVARCHAR(40),
    [Country] NVARCHAR(40),
    [PostalCode] NVARCHAR(10),
    [Phone] NVARCHAR(24),
    [Fax] NVARCHAR(24),
    [Email] NVARCHAR(60),
    CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([EmployeeId]),
	FOREIGN KEY([ReportsTo]) REFERENCES [StorageArea].[dbo].[SA_Employee]([EmployeeId])
);


CREATE TABLE [dbo].[SA_Customer]
(
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(40) NOT NULL,
    [LastName] NVARCHAR(20) NOT NULL,
    [Company] NVARCHAR(80),
    [Address] NVARCHAR(70),
    [City] NVARCHAR(40),
    [State] NVARCHAR(40),
    [Country] NVARCHAR(40),
    [PostalCode] NVARCHAR(10),
    [Phone] NVARCHAR(24),
    [Fax] NVARCHAR(24),
    [Email] NVARCHAR(60) NOT NULL,
    [SupportRepId] INT,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerId]),
	FOREIGN KEY([SupportRepId]) REFERENCES [StorageArea].[dbo].[SA_Employee]([EmployeeId])
);


CREATE TABLE [StorageArea].[dbo].[SA_MediaType]
(
	[MediaTypeId] INT PRIMARY KEY,
	[Name] NVARCHAR(120),
);


CREATE TABLE [StorageArea].[dbo].[SA_Genre]
(
	[GenreId] INT PRIMARY KEY,
	[Name] NVARCHAR(120),
);


CREATE TABLE [dbo].[SA_Track]
(
    [TrackId] INT NOT NULL,
    [Name] NVARCHAR(200) NOT NULL,
    [AlbumId] INT,
    [MediaTypeId] INT NOT NULL,
    [GenreId] INT,
    [Composer] NVARCHAR(220),
    [Milliseconds] INT NOT NULL,
    [Bytes] INT,
    [UnitPrice] NUMERIC(10,2) NOT NULL,
    CONSTRAINT [PK_Track] PRIMARY KEY CLUSTERED ([TrackId]),
	FOREIGN KEY([AlbumId]) REFERENCES [StorageArea].[dbo].[SA_Album]([AlbumId]),
	FOREIGN KEY([MediaTypeId]) REFERENCES [StorageArea].[dbo].[SA_MediaType]([MediaTypeId]),
	FOREIGN KEY([GenreId]) REFERENCES [StorageArea].[dbo].[SA_Genre]([GenreId])
);



CREATE TABLE [StorageArea].[dbo].[SA_Playback](
	[PlayId] BIGINT PRIMARY KEY,
	[CustomerId] INT,
	[TrackId] INT,
	[PlayDate] DATETIME,
	FOREIGN KEY(CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer]([CustomerId]),      ---*
	FOREIGN KEY(TrackId) REFERENCES [StorageArea].[dbo].[SA_Track]([TrackId]),          ---*
);


CREATE TABLE [dbo].[SA_Rating]
(
	[CustomerId] INT,---*
	[TrackId] INT,---*
	[ScoreDate] DATETIME,---*
	[Score] INT,
	
	PRIMARY KEY ([CustomerId], [TrackId]),

	FOREIGN KEY(TrackId) REFERENCES [StorageArea].[dbo].[SA_Track]([TrackId]),  
	FOREIGN KEY(CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer]([CustomerId])
);



CREATE PROCEDURE Storage_Rating_FirstLoad 
AS
	TRUNCATE TABLE [dbo].[Rating_Storage]

	INSERT INTO [dbo].[Rating_Storage] ([CustomerId], [TrackId], [ScoreDate], [Score]) --What if BlowUp somewhere?
		SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
		FROM [Chinook].[dbo].[Rating]
	


CREATE PROCEDURE Storage_Rating
AS
	DECLARE @EndDate date;
	DECLARE @StartDate date;
	DECLARE @CurrDate date;
	
	SET @EndDate = (SELECT MAX(ScoreDate) FROM [Chinook].[dbo].[Rating])
	SET @StartDate = (SELECT MAX(ScoreDate) FROM [dbo].[Rating_Storage]);
	SET @CurrDate = DATEADD(day, 1, @StartDate);

	WHILE @CurrDate <= @EndDate
	BEGIN

		INSERT INTO [dbo].[Rating_Storage] ([CustomerId], [TrackId], [ScoreDate], [Score])
			SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
			FROM [Chinook].[dbo].[Rating]
			WHERE ScoreDate = @CurrDate

		SET @CurrDate = DATEADD(day, 1, @Currdate)
	END
	



---------------------------------
-------------playback------------
---------------------------------
CREATE TABLE [StorageArea].[dbo].[SA_Playback](
	[PlayId] BIGINT PRIMARY KEY,
	[CustomerId] INT,
	[TrackId] INT,
	[PlayDate] DATETIME,
	FOREIGN KEY(CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer](Id),      ---*
	FOREIGN KEY(TrackId) REFERENCES [StorageArea].[dbo].[SA_Track](Id),          ---*
);


CREATE PROCEDURE SA_Playback_FirstLoad
AS
TRUNCATE TABLE [StorageArea].[dbo].[SA_Playback]
INSERT INTO [StorageArea].[dbo].[SA_Playback]
	([PlayId],[CustomerId], [TrackId], [PlayDate])
SELECT [PlayId],[CustomerId], [TrackId], [PlayDate]
FROM [Chinook].[dbo].[play]

CREATE PROCEDURE SA_Playback
AS
DECLARE @EndDate date;
DECLARE @StartDate date;
DECLARE @CurrDate date;

SET @EndDate = (SELECT MAX(PlayDate)
FROM [Chinook].[dbo].[play])
SET @StartDate = (SELECT MAX(ScoreDate)
FROM [StorageArea].[dbo].[SA_Playback]);
SET @CurrDate = DATEADD(day, 1, @StartDate);

WHILE @CurrDate <= @EndDate
	BEGIN
	INSERT INTO [StorageArea].[dbo].[SA_Playback]
		([CustomerId], [TrackId], [ScoreDate], [Score])
	SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
	FROM [Chinook].[dbo].[play]
	WHERE PlayDate = @CurrDate
	SET @CurrDate = DATEADD(day, 1, @Currdate)
END


---------------------------------
-------------Invoice-------------
---------------------------------

CREATE PROCEDURE SA_Invoice_FirstLoad -- * address *
AS
TRUNCATE TABLE [StorageArea].[dbo].[SA_Invoice]
INSERT INTO [StorageArea].[dbo].[SA_Invoice]
	([InvoiceId], [InvoiceLineId],[CustomerId], [TrackId], [InvoiceDate], [UnitPrice], [Quantity], [Total])
SELECT IL.[InvoiceId], IL.[InvoiceLineId],I.[CustomerId], IL.[TrackId], I.[InvoiceDate], IL.[UnitPrice], IL.[Quantity], I.[Total]
FROM [Chinook].[dbo].[Invoice] as I INNER JOIN [Chinook].[dbo].[InvoiceLine] as IL ON I.InvoiceId = IL.InvoiceId  


CREATE PROCEDURE SA_Invoice
AS
DECLARE @EndDate date;
DECLARE @StartDate date;
DECLARE @CurrDate date;

SET @EndDate = (SELECT MAX(PlayDate)
FROM [Chinook].[dbo].[Invoice])
SET @StartDate = (SELECT MAX(ScoreDate)
FROM [StorageArea].[dbo].[SA_Invoice]);
SET @CurrDate = DATEADD(day, 1, @StartDate);

WHILE @CurrDate <= @EndDate
	BEGIN
	INSERT INTO [StorageArea].[dbo].[SA_Invoice]
		([InvoiceId], [InvoiceLineId],[CustomerId], [TrackId], [InvoiceDate], [UnitPrice], [Quantity], [Total])
	SELECT IL.[InvoiceId], IL.[InvoiceLineId], I.[CustomerId], IL.[TrackId], I.[InvoiceDate], IL.[UnitPrice], IL.[Quantity], I.[Total]
	FROM [Chinook].[dbo].[Invoice] as I INNER JOIN [Chinook].[dbo].[InvoiceLine] as IL ON I.InvoiceId = IL.InvoiceId  
	WHERE InvoiceDate = @CurrDate

	SET @CurrDate = DATEADD(day, 1, @Currdate)
END



---------------------------------
-------------Genre-------------
---------------------------------
CREATE TABLE [StorageArea].[dbo].[SA_Genre]
(
	[GenreId] INT PRIMARY KEY,
	[Name] NVARCHAR(120),
);

CREATE PROCEDURE SA_Genre
AS
TRUNCATE TABLE [StorageArea].[dbo].[SA_Genre]
INSERT INTO [StorageArea].[dbo].[SA_Genre]
	([GenreId],[Name])
SELECT [GenreId],[Name]
FROM [Chinook].[dbo].[Genre]

---------------------------------
-------------MediaType-------------
---------------------------------
CREATE TABLE [StorageArea].[dbo].[SA_MediaType]
(
	[MediaTypeId] PRIMARY KEY,
	[Name] NVARCHAR(120),
);

CREATE PROCEDURE SA_MediaType
AS
TRUNCATE TABLE [StorageArea].[dbo].[SA_MediaType]
INSERT INTO [StorageArea].[dbo].[SA_MediaType]
	([MediaTypeId],[Name])
SELECT [MediaTypeId], [Name]
FROM [Chinook].[dbo].[MediaType]

