CREATE TABLE [dbo].[Rating]
(
	[CustomerId] INT NOT NULL,
	[TrackId] INT NOT NULL,
	[ScoreDate] DATETIME NOT NULL,
	[Score] INT NOT NULL,
	
	PRIMARY KEY ([CustomerId], [TrackId]),

	FOREIGN KEY([CustomerId]) REFERENCES [dbo].[Customer]([CustomerId]),
    FOREIGN KEY([TrackId]) REFERENCES [dbo].[Track]([TrackId])
);