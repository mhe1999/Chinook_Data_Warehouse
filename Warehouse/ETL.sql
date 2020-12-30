CREATE OR ALTER PROCEDURE ETL_DimensionGenre
AS
BEGIN
  INSERT INTO [DataWarehouse].[dbo].[Dim_Genre]
  SELECT GenreId, Name
  FROM [StorageArea].[dbo].[SA_Genre]
  WHERE GenreId not in (SELECT GenreId
  FROM [DataWarehouse].[dbo].[Dim_Genre])
END


CREATE OR ALTER PROCEDURE ETL_DimensionMediaType
AS
BEGIN
    INSERT INTO [DataWarehouse].[dbo].[Dim_MediaType]
    SELECT MediaTypeId, Name
    FROM [StorageArea].[dbo].[SA_MediaType]
    WHERE MediaTypeId not in (SELECT MediaTypeId
    FROM [DataWarehouse].[dbo].[Dim_MediaType])
END

CREATE OR ALTER PROCEDURE ETL_DimensionArtist
AS
BEGIN
    INSERT INTO [DataWarehouse].[dbo].[Dim_Artist]
    SELECT ArtistId, Name
    FROM [StorageArea].[dbo].[SA_Artist]
    WHERE ArtistId not in (SELECT ArtistId
    FROM [DataWarehouse].[dbo].[Dim_Artist])
END


EXECUTE ETL_DimensionGenre
EXECUTE ETL_DimensionMediaType
EXECUTE ETL_DimensionArtist

SELECT * FROM [DataWarehouse].[dbo].[Dim_Genre]
SELECT * FROM [DataWarehouse].[dbo].[Dim_MediaType]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Artist]