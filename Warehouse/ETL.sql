USE [DataWarehouse]
GO
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

GO
CREATE OR ALTER PROCEDURE ETL_DimensionLocation
AS
BEGIN
  INSERT INTO [DataWarehouse].[dbo].[Dim_Location]
 SELECT DISTINCT City, Country
FROM [StorageArea].[dbo].[SA_Customer] AS SAC
WHERE NOT exists (SELECT DISTINCT City, Country
                  FROM [DataWarehouse].[dbo].[Dim_Location] AS DWL
                  WHERE
                  DWL.City = [SAC].City AND DWL.Country = SAC.Country)

END




EXECUTE ETL_DimensionGenre
EXECUTE ETL_DimensionMediaType
EXECUTE ETL_DimensionArtist
EXECUTE ETL_DimensionLocation

SELECT * FROM [DataWarehouse].[dbo].[Dim_Genre]
SELECT * FROM [DataWarehouse].[dbo].[Dim_MediaType]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Artist]
SELECT * FROM [DataWarehouse].[dbo].[Dim_Location]