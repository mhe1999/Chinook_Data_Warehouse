USE [StorageArea]
GO
CREATE OR ALTER PROCEDURE SA_Main
AS
	EXEC [StorageArea].[dbo].SA_GenreProcedure
	EXEC [StorageArea].[dbo].SA_MediaTypeProcedure
	EXEC [StorageArea].[dbo].SA_ArtistProcedure
	EXEC [StorageArea].[dbo].SA_AlbumProcedure
	EXEC [StorageArea].[dbo].SA_EmployeeProcedure

select * from SA_Playback

CREATE OR ALTER PROCEDURE SA_Main_Firstload
AS
EXEC SA_Main
EXEC [StorageArea].[dbo].SA_Customer_firstload
EXEC [StorageArea].[dbo].SA_Track_firstload
EXEC [StorageArea].[dbo].SA_Rating_firstload
EXEC [StorageArea].[dbo].SA_playback_Firstload

EXEC SA_Main_Firstload




CREATE OR ALTER PROCEDURE SA_Main_Incremental
AS
EXEC SA_Main
EXECUTE SA_Track_incremental
EXECUTE SA_Playback_incremental
EXECUTE SA_Rating_incremental
EXECUTE SA_Customer_incremental

EXECUTE SA_Main_Incremental