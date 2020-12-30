CREATE PROCEDURE ETL_DimensionGenre
AS
BEGIN

  INSERT INTO [DataWarehouse].[dbo].[Dim_Genre]
  SELECT GenreId, Name
  FROM [StorageArea].[dbo].[SA_Genre]
  WHERE Name not in (SELECT Name
  FROM [DataWarehouse].[dbo].[Dim_Genre])


END

EXECUTE ETL_DimensionGenre
SELECT * FROM [DataWarehouse].[dbo].[Dim_Genre]