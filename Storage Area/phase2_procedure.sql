--- for final project need this procedures


----*** need to edit ***-----

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
-------------playback------------
--------------------------------- 
GO
CREATE PROCEDURE SA_Playback_FirstLoad
AS
	TRUNCATE TABLE [StorageArea].[dbo].[SA_Playback]
	INSERT INTO [StorageArea].[dbo].[SA_Playback]
		([PlayId],[CustomerId], [TrackId], [PlayDate])
	SELECT [PlayId], [CustomerId], [TrackId], [PlayDate]
	FROM [Chinook].[dbo].[play]

GO
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
	






	

