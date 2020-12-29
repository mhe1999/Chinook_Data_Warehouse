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
-------------Rating-------------
---------------------------------

CREATE OR ALTER PROCEDURE Storage_Rating_FirstLoad
AS
TRUNCATE TABLE [StorageArea].[dbo].[SA_Rating]

INSERT INTO [StorageArea].[dbo].[SA_Rating]
    ([CustomerId], [TrackId], [ScoreDate], [Score])
--What if BlowUp somewhere?
SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
FROM [Chinook].[dbo].[Rating]


CREATE PROCEDURE Storage_Rating
AS
DECLARE @EndDate date;
DECLARE @StartDate date;
DECLARE @CurrDate date;

SET @EndDate = (SELECT MAX(ScoreDate)
FROM [Chinook].[dbo].[Rating])
SET @StartDate = (SELECT MAX(ScoreDate)
FROM [dbo].[Rating_Storage]);
SET @CurrDate = DATEADD(day, 1, @StartDate);

WHILE @CurrDate <= @EndDate
	BEGIN

    INSERT INTO [dbo].[Rating_Storage]
        ([CustomerId], [TrackId], [ScoreDate], [Score])
    SELECT [CustomerId], [TrackId], [ScoreDate], [Score]
    FROM [Chinook].[dbo].[Rating]
    WHERE ScoreDate = @CurrDate

    SET @CurrDate = DATEADD(day, 1, @Currdate)
END
	

