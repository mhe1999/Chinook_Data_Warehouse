USE [StorageArea]
GO


---------------------------------
-------------Genre-------------
---------------------------------

CREATE OR ALTER PROCEDURE SA_GenreProcedure
AS

alter table [StorageArea].[dbo].[SA_Track] drop constraint FkGenreId;
TRUNCATE TABLE [StorageArea].[dbo].[SA_Genre];
alter table [StorageArea].[dbo].[SA_Track] add constraint FkGenreId FOREIGN KEY([GenreId]) REFERENCES [StorageArea].[dbo].[SA_Genre]([GenreId]);

INSERT INTO [StorageArea].[dbo].[SA_Genre]
	([GenreId],[Name])
SELECT [GenreId],[Name]
FROM [Chinook].[dbo].[Genre]

EXEC SA_GenreProcedure

select * from [StorageArea].[dbo].[SA_Genre]
---------------------------------
-------------MediaType-------------
---------------------------------

CREATE OR ALTER PROCEDURE SA_MediaTypeProcedure
AS

alter table [StorageArea].[dbo].[SA_Track] drop constraint FkMediaTypeId;
TRUNCATE TABLE [StorageArea].[dbo].[SA_MediaType]
alter table [StorageArea].[dbo].[SA_Track] add constraint FkMediaTypeId FOREIGN KEY([MediaTypeId]) REFERENCES [StorageArea].[dbo].[SA_MediaType]([MediaTypeId])

INSERT INTO [StorageArea].[dbo].[SA_MediaType]
	([MediaTypeId],[Name])
SELECT [MediaTypeId], [Name]
FROM [Chinook].[dbo].[MediaType]

EXEC SA_MediaTypeProcedure
select * FROM [StorageArea].[dbo].SA_MediaType


---------------------------------
-------------SA_Artist-------------
---------------------------------
CREATE OR ALTER PROCEDURE SA_ArtistProcedure
AS

	alter table [StorageArea].[dbo].[SA_Album] drop constraint FkArtistId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Artist];
	alter table [StorageArea].[dbo].[SA_Album] add constraint FkArtistId FOREIGN KEY([ArtistId]) REFERENCES [StorageArea].[dbo].[SA_Artist]([ArtistId]);
	INSERT INTO [StorageArea].[dbo].[SA_Artist]
		([ArtistId],[Name])
	SELECT [ArtistId],[Name]
	FROM [Chinook].[dbo].[Artist]

EXEC SA_ArtistProcedure

select * from [StorageArea].[dbo].[SA_Artist]


---------------------------------
-------------Album-------------
---------------------------------

CREATE OR ALTER PROCEDURE SA_AlbumProcedure
AS

	alter table [StorageArea].[dbo].[SA_Track] drop constraint FkAlbumId;
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Album];
	alter table [StorageArea].[dbo].[SA_Track] add CONSTRAINT FkAlbumId FOREIGN KEY([AlbumId]) REFERENCES [StorageArea].[dbo].[SA_Album]([AlbumId])
	INSERT INTO [StorageArea].[dbo].[SA_Album]
		([AlbumId], [Title], [ArtistId])
	SELECT [AlbumId], [Title], [ArtistId]
	FROM [Chinook].[dbo].[Album]
	
EXEC SA_AlbumProcedure

select *
from [StorageArea].[dbo].[SA_Album]



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



-----------------------------------------





---------------------------------
-------------playback------------
---------------------------------

CREATE PROCEDURE SA_Playback_FirstLoad
AS
TRUNCATE TABLE [StorageArea].[dbo].[SA_Playback]
INSERT INTO [StorageArea].[dbo].[SA_Playback]
	([PlayId],[CustomerId], [TrackId], [PlayDate])
SELECT [PlayId], [CustomerId], [TrackId], [PlayDate]
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
