USE [StorageArea]
GO
CREATE OR ALTER PROCEDURE SA_Main_Firsload
AS
	EXEC [StorageArea].[dbo].SA_GenreProcedure
	EXEC [StorageArea].[dbo].SA_MediaTypeProcedure
	EXEC [StorageArea].[dbo].SA_ArtistProcedure
	EXEC [StorageArea].[dbo].SA_EmployeeProcedure
	EXEC [StorageArea].[dbo].SA_Customer_firstload
	EXEC [StorageArea].[dbo].SA_AlbumProcedure
	EXEC [StorageArea].[dbo].SA_Track_firstload
	EXEC [StorageArea].[dbo].SA_Rating_firstload
	--EXEC [StorageArea].[dbo].SA_Playback_FirstLoad


EXEC SA_Main_Firsload


