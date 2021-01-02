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
    [Id] BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    --very big 
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    --+10
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
    [SupportLastName] NVARCHAR(30),
    [SupportTitle] NVARCHAR(30),
    ----SCD2
    [Start_Date_SupportRepId] DATE,
    [End_Date_SupportRepId] DATE,
    [Current_Flag_SupportRepId] bit,
    -- 1-64
);



CREATE TABLE [dbo].[Dim_Customer_temp]
(
    [Id] BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    --very big 
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    --+10
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
    [SupportLastName] NVARCHAR(30),
    [SupportTitle] NVARCHAR(40),
    ----SCD2
    [Start_Date_SupportRepId] DATE,
    [End_Date_SupportRepId] DATE,
    [Current_Flag_SupportRepId] bit,
    -- 1-64
);



CREATE TABLE [dbo].[Dim_Album]
(
    [AlbumId] INT PRIMARY KEY NOT NULL,
    [Title] NVARCHAR(160) NOT NULL,
    [ArtistId] INT NOT NULL,
	[ArtistName] NVARCHAR(130)
);

CREATE TABLE DataWarehouse.[dbo].[Dim_Track]
(
	[Id] BIGINT PRIMARY KEY IDENTITY(1,1),  --Surrogate key for SCD2
    [TrackId] INT NOT NULL,
    [Name] NVARCHAR(210) NOT NULL,
    [AlbumId] INT,
	[AlbumTitle] NVARCHAR(160) NOT NULL,
    [ArtistId] INT NOT NULL,
	[ArtistName] NVARCHAR(130),
    [MediaTypeId] INT NOT NULL,
	[MediaTypeName] NVARCHAR(130),
    [GenreId] INT,
	[GenreName] NVARCHAR(130),
    [Composer] NVARCHAR(220),
    [Milliseconds] INT NOT NULL,
    [Bytes] INT,
    [UnitPrice] NUMERIC(20,2) NOT NULL,
	[AddDate] DATE,
	----SCD2
	[Start_Date_UnitPrice] DATE,
	[End_Date_UnitPrice] DATE,
	[Current_Flag_UnitPrice] bit
);

CREATE TABLE [dbo].[Dim_Date]
(
    [TimeKey] [int] NOT NULL PRIMARY KEY,
    [FullDateAlternateKey] [datetime] NULL,
    [PersianFullDateAlternateKey] [nvarchar](15) NULL,
    [DayNumberOfWeek] [int] NULL,
    [PersianDayNumberOfWeek] [int] NULL,
    [EnglishDayNameOfWeek] [nvarchar](15) NULL,
    [PersianDayNameOfWeek] [nvarchar](50) NULL,
    [DayNumberOfMonth] [int] NULL,
    [PersianDayNumberOfMonth] [int] NULL,
    [DayNumberOfYear] [int] NULL,
    [PersianDayNumberOfYear] [int] NULL,
    [WeekNumberOfYear] [int] NULL,
    [PersianWeekNumberOfYear] [int] NULL,
    [EnglishMonthName] [nvarchar](20) NULL,
    [PersianMonthName] [nvarchar](20) NULL,
    [MonthNumberOfYear] [int] NULL,
    [PersianMonthNumberOfYear] [int] NULL,
    [CalendarQuarter] [int] NULL,
    [PersianCalendarQuarter] [int] NULL,
    [CalendarYear] [int] NULL,
    [PersianCalendarYear] [int] NULL,
    [CalendarSemester] [int] NULL,
    [PersianCalendarSemester] [int] NULL,
)

