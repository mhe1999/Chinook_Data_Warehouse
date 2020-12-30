USE [StorageArea]
GO
---------------------------------
-------------Genre-------------
---------------------------------
CREATE OR ALTER PROCEDURE SA_GenreProcedure
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Track] DROP CONSTRAINT FkGenreId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Genre];

	INSERT INTO [StorageArea].[dbo].[SA_Genre]
		([GenreId],[Name])
	SELECT [GenreId],[Name]
	FROM [Chinook].[dbo].[Genre]

	ALTER TABLE [StorageArea].[dbo].[SA_Track] ADD CONSTRAINT FkGenreId FOREIGN KEY([GenreId]) REFERENCES [StorageArea].[dbo].[SA_Genre]([GenreId]);


--EXEC SA_GenreProcedure
--select * from [StorageArea].[dbo].[SA_Genre]

---------------------------------
-------------MediaType-------------
---------------------------------
GO
CREATE OR ALTER PROCEDURE SA_MediaTypeProcedure
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Track] DROP CONSTRAINT FkMediaTypeId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_MediaType]

	INSERT INTO [StorageArea].[dbo].[SA_MediaType]
		([MediaTypeId],[Name])
	SELECT [MediaTypeId], [Name]
	FROM [Chinook].[dbo].[MediaType]

	ALTER TABLE [StorageArea].[dbo].[SA_Track] ADD CONSTRAINT FkMediaTypeId FOREIGN KEY([MediaTypeId]) REFERENCES [StorageArea].[dbo].[SA_MediaType]([MediaTypeId])


--EXEC SA_MediaTypeProcedure
--select * FROM [StorageArea].[dbo].SA_MediaType

---------------------------------
-------------SA_Artist-------------
---------------------------------
GO
CREATE OR ALTER PROCEDURE SA_ArtistProcedure
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Album] DROP CONSTRAINT FkArtistId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Artist];
	
	INSERT INTO [StorageArea].[dbo].[SA_Artist]
		([ArtistId],[Name])
	SELECT [ArtistId],[Name]
	FROM [Chinook].[dbo].[Artist]

	ALTER TABLE [StorageArea].[dbo].[SA_Album] ADD CONSTRAINT FkArtistId FOREIGN KEY([ArtistId]) REFERENCES [StorageArea].[dbo].[SA_Artist]([ArtistId]);


--EXEC SA_ArtistProcedure
--select * from [StorageArea].[dbo].[SA_Artist]

---------------------------------
-------------Album-------------
---------------------------------
GO
CREATE OR ALTER PROCEDURE SA_AlbumProcedure
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Track] DROP CONSTRAINT FkAlbumId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Album];
	
	INSERT INTO [StorageArea].[dbo].[SA_Album]
		([AlbumId], [Title], [ArtistId])
	SELECT [AlbumId], [Title], [ArtistId]
	FROM [Chinook].[dbo].[Album]

	ALTER TABLE [StorageArea].[dbo].[SA_Track] ADD CONSTRAINT FkAlbumId FOREIGN KEY([AlbumId]) REFERENCES [StorageArea].[dbo].[SA_Album]([AlbumId])
	

--EXEC SA_AlbumProcedure
--select * from [StorageArea].[dbo].[SA_Album]

---------------------------------
-------------Employee-------------
---------------------------------

GO
CREATE OR ALTER PROCEDURE SA_EmployeeProcedure
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Customer] DROP CONSTRAINT FkToSupportRepId;

	TRUNCATE TABLE [StorageArea].[dbo].[SA_Employee];

	INSERT INTO [StorageArea].[dbo].[SA_Employee]
		([EmployeeId], [FirstName], [LastName], [Title], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [ReportsTo], [BirthDate], [HireDate])
	SELECT [EmployeeId], [FirstName], [LastName], [Title], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [ReportsTo], [BirthDate], [HireDate]
	FROM [Chinook].[dbo].[Employee]

ALTER TABLE [StorageArea].[dbo].[SA_Customer] ADD CONSTRAINT FkToSupportRepId FOREIGN KEY([SupportRepId]) REFERENCES [StorageArea].[dbo].[SA_Employee]([EmployeeId])

--EXECUTE SA_EmployeeProcedure
--SELECT *
--FROM [StorageArea].[dbo].[SA_Employee]

---------------------------------
-------------Customer-------------
---------------------------------

------firstload---------
GO
CREATE OR ALTER PROCEDURE SA_Customer_firstload
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Playback] DROP CONSTRAINT FkCustomerId;
	ALTER TABLE [StorageArea].[dbo].[SA_Rating] DROP CONSTRAINT FkCustomerIdR;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Customer];

	INSERT INTO [StorageArea].[dbo].[SA_Customer]
		([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [SupportRepId], [JoinDate])
	SELECT [CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [SupportRepId], [JoinDate]
	FROM [Chinook].[dbo].[Customer]
	ALTER TABLE [StorageArea].[dbo].[SA_Rating] ADD CONSTRAINT FkCustomerIdR FOREIGN KEY (CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer]([CustomerId])
	ALTER TABLE [StorageArea].[dbo].[SA_Playback] ADD CONSTRAINT FkCustomerId FOREIGN KEY(CustomerId) REFERENCES [StorageArea].[dbo].[SA_Customer]([CustomerId])


--EXECUTE SA_Customer_firstload
--SELECT * FROM [StorageArea].[dbo].[SA_Customer]

----- incremental --------
GO
CREATE OR ALTER PROCEDURE SA_Customer_incremental
AS
	DECLARE @EndDate date;
	DECLARE @StartDate date;
	DECLARE @CurrDate date;

	SET @EndDate = (SELECT MAX(JoinDate)
	FROM [Chinook].[dbo].[Customer])
	SET @StartDate = (SELECT MAX(JoinDate)
	FROM [StorageArea].[dbo].[SA_Customer]);
	SET @CurrDate = DATEADD(day, 1, @StartDate);

	WHILE @CurrDate <= @EndDate
		BEGIN
			INSERT INTO [StorageArea].[dbo].[SA_Customer]
				([CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [SupportRepId], [JoinDate])
			SELECT [CustomerId], [FirstName], [LastName], [Company], [Address], [City], [State], [Country], [PostalCode], [Phone], [Fax], [Email], [SupportRepId], [JoinDate]
			FROM [Chinook].[dbo].[Customer]
			WHERE JoinDate = @CurrDate
			SET @CurrDate = DATEADD(day, 1, @Currdate)
		END


--EXECUTE SA_Customer_incremental

---------------------------------
-------------Track-------------
---------------------------------

------firstload---------
GO
CREATE OR ALTER PROCEDURE SA_Track_firstload
AS
	ALTER TABLE [StorageArea].[dbo].[SA_Playback] DROP CONSTRAINT FkTrackToplayback;
	ALTER TABLE [StorageArea].[dbo].[SA_Rating] DROP CONSTRAINT FkTrackIdR;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Track];

	INSERT INTO [StorageArea].[dbo].[SA_Track]
		([TrackId], [Name], [AlbumId], [MediaTypeId], [GenreId], [Composer], [Milliseconds], [Bytes],[UnitPrice], AddDate)
	SELECT [TrackId], [Name], [AlbumId], [MediaTypeId], [GenreId], [Composer], [Milliseconds], [Bytes],[UnitPrice], AddDate
	FROM [Chinook].[dbo].[Track]
	ALTER TABLE [StorageArea].[dbo].[SA_Playback] ADD CONSTRAINT FkTrackToplayback FOREIGN KEY(TrackId) REFERENCES [StorageArea].[dbo].[SA_Track](TrackId)
	ALTER TABLE [StorageArea].[dbo].[SA_Rating] ADD CONSTRAINT FkTrackIdR FOREIGN KEY (TrackId) REFERENCES [StorageArea].[dbo].[SA_Track](TrackId)


--EXECUTE SA_Track_firstload
--SELECT * FROM [StorageArea].[dbo].[SA_Track]

----- incremental --------
GO
CREATE OR ALTER PROCEDURE SA_Track_incremental
AS
	DECLARE @EndDate date;
	DECLARE @StartDate date;
	DECLARE @CurrDate date;

	SET @EndDate = (SELECT MAX(AddDate)
	FROM [Chinook].[dbo].[Track])
	SET @StartDate = (SELECT MAX(AddDate)
	FROM [StorageArea].[dbo].[SA_Track]);
	SET @CurrDate = DATEADD(day, 1, @StartDate);

	WHILE @CurrDate <= @EndDate
		BEGIN
			INSERT INTO [StorageArea].[dbo].[SA_Track]
				([TrackId], [Name], [AlbumId], [MediaTypeId], [GenreId], [Composer], [Milliseconds], [Bytes],[UnitPrice], AddDate)
			SELECT [TrackId], [Name], [AlbumId], [MediaTypeId], [GenreId], [Composer], [Milliseconds], [Bytes],[UnitPrice], AddDate
			FROM [Chinook].[dbo].Track
			WHERE AddDate = @CurrDate
			SET @CurrDate = DATEADD(day, 1, @Currdate)
		END


--EXECUTE SA_Track_incremental

---------------------------------
-------------Rating-------------
---------------------------------

------firstload---------
go
CREATE OR ALTER PROCEDURE SA_Rating_firstload
AS
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Rating]

	INSERT INTO [StorageArea].[dbo].[SA_Rating]
		([CustomerId], [TrackId], [ScoreDate], [Score])
	--What if BlowUp somewhere?
	SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
	FROM [Chinook].[dbo].[Rating]

----- incremental --------
GO
CREATE OR ALTER PROCEDURE SA_Rating_incremental
	AS
	DECLARE @EndDate date;
	DECLARE @StartDate date;
	DECLARE @CurrDate date;

	SET @EndDate = (SELECT MAX(ScoreDate)
	FROM [Chinook].[dbo].[Rating])
	SET @StartDate = (SELECT MAX(ScoreDate)
	FROM [StorageArea].[dbo].[SA_Rating]);
	SET @CurrDate = DATEADD(day, 1, @StartDate);

	WHILE @CurrDate <= @EndDate
		BEGIN

		INSERT INTO [StorageArea].[dbo].[SA_Rating]
			([CustomerId], [TrackId], [ScoreDate], [Score])
		SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
		FROM [Chinook].[dbo].[Rating]
		WHERE ScoreDate = @CurrDate

		SET @CurrDate = DATEADD(day, 1, @Currdate)
	END


---------------------------------
-------------playback------------
---------------------------------
GO
CREATE OR ALTER PROCEDURE SA_Playback_FirstLoad
AS

TRUNCATE TABLE [StorageArea].[dbo].[SA_Playback]
INSERT INTO [StorageArea].[dbo].[SA_Playback]
	([PlayId],[CustomerId], [TrackId], [PlayDate])
SELECT [PlayId], [CustomerId], [TrackId], [PlayDate]
FROM [Chinook].[dbo].[OnlinePlayback]


--EXECUTE SA_Playback_FirstLoad


GO
CREATE OR ALTER PROCEDURE SA_Playback_incremental
AS
DECLARE @EndDate date;
DECLARE @StartDate date;
DECLARE @CurrDate date;

SET @EndDate = (SELECT MAX(PlayDate)
FROM [Chinook].[dbo].[OnlinePlayback])
SET @StartDate = (SELECT MAX(PlayDate)
FROM [StorageArea].[dbo].[SA_Playback]);
SET @CurrDate = DATEADD(day, 1, @StartDate);

WHILE @CurrDate <= @EndDate
	BEGIN
	INSERT INTO [StorageArea].[dbo].[SA_Playback]
		([PlayId],[CustomerId], [TrackId], [PlayDate])
	SELECT [PlayId], [CustomerId], [TrackId], [PlayDate]
	FROM [Chinook].[dbo].[OnlinePlayback]
	WHERE PlayDate = @CurrDate
	SET @CurrDate = DATEADD(day, 1, @Currdate)
END

--EXECUTE SA_Playback_incremental
