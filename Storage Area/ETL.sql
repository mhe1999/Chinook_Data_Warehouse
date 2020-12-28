USE [StorageArea]
GO


---------------------------------
-------------Genre-------------
---------------------------------

CREATE OR ALTER PROCEDURE SA_Genre
AS

alter table [StorageArea].[dbo].[SA_Track] drop constraint FkGenreId;
TRUNCATE TABLE [StorageArea].[dbo].[SA_Genre];
alter table [StorageArea].[dbo].[SA_Track] add constraint FkGenreId FOREIGN KEY([GenreId]) REFERENCES [StorageArea].[dbo].[SA_Genre]([GenreId]);

INSERT INTO [StorageArea].[dbo].[SA_Genre]
	([GenreId],[Name])
SELECT [GenreId],[Name]
FROM [Chinook].[dbo].[Genre]

EXEC SA_Genre

select * from [StorageArea].[dbo].[SA_Genre]
---------------------------------
-------------MediaType-------------
---------------------------------

CREATE OR ALTER PROCEDURE SA_MediaType
AS

alter table [StorageArea].[dbo].[SA_Track] drop constraint FkMediaTypeId;
TRUNCATE TABLE [StorageArea].[dbo].[SA_MediaType]
alter table [StorageArea].[dbo].[SA_Track] add constraint FkMediaTypeId FOREIGN KEY([MediaTypeId]) REFERENCES [StorageArea].[dbo].[SA_MediaType]([MediaTypeId])

INSERT INTO [StorageArea].[dbo].[SA_MediaType]
	([MediaTypeId],[Name])
SELECT [MediaTypeId], [Name]
FROM [Chinook].[dbo].[MediaType]


EXEC SA_MediaType


CREATE OR ALTER PROCEDURE Storage_Rating_FirstLoad 
AS
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Rating]

	INSERT INTO [StorageArea].[dbo].[SA_Rating] ([CustomerId], [TrackId], [ScoreDate], [Score]) --What if BlowUp somewhere?
		SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
		FROM [Chinook].[dbo].[Rating]
	

---------------------------------
-------------Rating-------------
---------------------------------
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
-------------SA_Artist-------------
---------------------------------
CREATE OR ALTER PROCEDURE SA_Artist
AS

	alter table [StorageArea].[dbo].[SA_Album] drop constraint FkArtistId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Artist];
	alter table [StorageArea].[dbo].[SA_Album] add constraint FkArtistId FOREIGN KEY([ArtistId]) REFERENCES [StorageArea].[dbo].[SA_Artist]([ArtistId]);
	INSERT INTO [StorageArea].[dbo].[SA_Artist]
		([ArtistId],[Name])
	SELECT [ArtistId],[Name]
	FROM [Chinook].[dbo].[Artist]

EXEC SA_Artist

select * from [StorageArea].[dbo].[SA_Artist]


---------------------------------
-------------playback------------
---------------------------------

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
-------------Track-------------
---------------------------------

------------------------------------------

---------------------------------
-------------Employee-------------
---------------------------------

-----------------------------------------

---------------------------------
-------------Customer-------------
---------------------------------

-----------------------------------------


---------------------------------
-------------Album-------------
---------------------------------

-----------------------------------------

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







