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



EXECUTE ETL_DimensionGenre
EXECUTE ETL_DimensionMediaType

SELECT * FROM [DataWarehouse].[dbo].[Dim_Genre]
SELECT * FROM [DataWarehouse].[dbo].[Dim_MediaType]