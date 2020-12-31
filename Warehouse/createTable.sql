CREATE DATABASE DataWarehouse
USE [DataWarehouse]
GO
CREATE TABLE [dbo].[Dim_Genre](
    [GenreId] INT PRIMARY KEY,
    [Name] NVARCHAR(130),
);

CREATE TABLE [dbo].[Dim_MediaType](
    [MediaTypeId] INT PRIMARY KEY,
    [Name] NVARCHAR(130),
);


CREATE TABLE [dbo].[Dim_Artist](
    [ArtistId] INT PRIMARY KEY,
    [Name] NVARCHAR(130),
);

CREATE TABLE [dbo].[Dim_Location]
(
    [Id] INT PRIMARY KEY IDENTITY(1,1),
    [City] NVARCHAR(50),
    [Country] NVARCHAR(50),
);
