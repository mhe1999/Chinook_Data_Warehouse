USE [DataWarehouse]
GO
CREATE OR ALTER PROCEDURE DW_dimensions
AS
BEGIN
    ----------dimensions-------------
    EXECUTE ETL_DimensionGenre
    EXECUTE ETL_DimensionMediaType
    EXECUTE ETL_DimensionArtist
    EXECUTE ETL_DimensionLocation
    EXEC ETL_DimensionCustomer
    EXEC ETL_DimensionTrack
    exec ETL_DimensionAlbum
    exec ETL_DimensionEmployee
END
GO

CREATE OR ALTER PROCEDURE DW_Mart_onlinePlayBack
AS
BEGIN
    --------------mart online playback ------------------
    EXEC ETL_OP_firstLoadTransFact
    exec ETL_OP_incrementalTransFact
    exec ETL_OP_firstLoadDailyFact
    EXEC ETL_OP_DailyFact
    EXEC ETL_OP_ACCFact
END


GO

CREATE OR ALTER PROCEDURE DW_Mart_Rating
AS
BEGIN
    ----------------mart rating-----------------------------
    exec ETL_Rating_firstLoadTransFact
    exec ETL_Rating_incrementalTransFact
    EXEC ETL_Rating_firstLoadDailyFact
    EXEC ETL_Rating_DailyFact
    EXEC ETL_Sale_ACCFact
END



GO
CREATE OR ALTER PROCEDURE DW_Mart_Sale
AS
BEGIN

    ------ mart sale----------------------------------------
    EXEC ETL_Sale_firstLoadTransFact
    EXEC ETL_Sale_incrementalTransFact
    exec ETL_Sale_firstLoadFactDaily
    EXEC ETL_Sale_FactDaily
    EXEC ETL_Sale_ACCFact
END


GO
CREATE OR ALTER PROCEDURE DW_Main_Procedure
AS
BEGIN
    EXEC DW_dimensions
    exec DW_Mart_onlinePlayBack
    exec DW_Mart_Rating
    exec DW_Mart_Sale
END





EXEC DW_Main_Procedure




