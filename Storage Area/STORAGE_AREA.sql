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
	CONSTRAINT FkArtistId FOREIGN KEY([ArtistId]) REFERENCES [StorageArea].[dbo].[SA_Artist]([ArtistId])
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
	CONSTRAINT FkReportsTo FOREIGN KEY([ReportsTo]) REFERENCES [StorageArea].[dbo].[SA_Employee]([EmployeeId])
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
	JoinDate DATE NOT NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerId]),
	CONSTRAINT FkSupportRepId FOREIGN KEY([SupportRepId]) REFERENCES [StorageArea].[dbo].[SA_Employee]([EmployeeId])
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
	AddDate DATE not null,
    CONSTRAINT [PK_Track] PRIMARY KEY CLUSTERED ([TrackId]),
	CONSTRAINT FkAlbumId FOREIGN KEY([AlbumId]) REFERENCES [StorageArea].[dbo].[SA_Album]([AlbumId]),
	CONSTRAINT FkMediaTypeId FOREIGN KEY([MediaTypeId]) REFERENCES [StorageArea].[dbo].[SA_MediaType]([MediaTypeId]),
	CONSTRAINT FkGenreId FOREIGN KEY([GenreId]) REFERENCES [StorageArea].[dbo].[SA_Genre]([GenreId])
);



CREATE TABLE [StorageArea].[dbo].[SA_Playback](
	[PlayId] BIGINT PRIMARY KEY,
	[CustomerId] INT,
	[TrackId] INT,
	[PlayDate] DATETIME,
	CONSTRAINT FkCustomerId FOREIGN KEY(CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer]([CustomerId]),      ---*
	CONSTRAINT FkTrackId FOREIGN KEY(TrackId) REFERENCES [StorageArea].[dbo].[SA_Track]([TrackId]),          ---*
);


CREATE TABLE [dbo].[SA_Rating]
(
	[CustomerId] INT,---*
	[TrackId] INT,---*
	[ScoreDate] DATETIME,---*
	[Score] INT,
	
	PRIMARY KEY ([CustomerId], [TrackId]),

	CONSTRAINT FkTrackIdR FOREIGN KEY(TrackId) REFERENCES [StorageArea].[dbo].[SA_Track]([TrackId]),  
	CONSTRAINT FkCustomerIdR FOREIGN KEY(CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer]([CustomerId])
);



