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


CREATE TABLE [dbo].[Dim_Customer]
(
    [Id] BIGINT PRIMARY KEY NOT NULL,    --very big 
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,  --+10
    [LastName] NVARCHAR(30) NOT NULL,
    [Company] NVARCHAR(90),
    [Address] NVARCHAR(80),
    [City] NVARCHAR(50),
    [State] NVARCHAR(50),
    [Country] NVARCHAR(50),
    [PostalCode] NVARCHAR(10),
    [Phone] NVARCHAR(24),
    [Fax] NVARCHAR(24),
    [Email] NVARCHAR(70) NOT NULL,
    [SupportRepId] INT,
	----SCD2
	[Start_Date_SupportRepId] DATE,
	[End_Date_SupportRepId] DATE,
	[Current_Flag_SupportRepId] bit, -- 1-64
);