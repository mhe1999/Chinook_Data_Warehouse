CREATE TABLE [dbo].[Rating]
(
	[CustomerId] INT NOT NULL,
	[TrackId] INT NOT NULL,
	[ScoreDate] DATE NOT NULL,
	[Score] INT NOT NULL,
	
	PRIMARY KEY ([CustomerId], [TrackId]),

	FOREIGN KEY([CustomerId]) REFERENCES [dbo].[Customer]([CustomerId]),
    FOREIGN KEY([TrackId]) REFERENCES [dbo].[Track]([TrackId])
);


create TABLE dbo.OnlinePlayback
(
	PlayId BIGINT PRIMARY KEY IDENTITY(1,1),
	CustomerId INT,
	TrackId INT,
	PlayDate date,
	FOREIGN KEY(CustomerId) REFERENCES dbo.Customer (CustomerId),
	FOREIGN KEY(TrackId) REFERENCES dbo.Track (TrackId),
);


ALTER TABLE Customer
ADD JoinDate Date DEFAULT '2013-01-01' not null;

ALTER TABLE Track
ADD AddDate Date DEFAULT '2013-01-01' not null;