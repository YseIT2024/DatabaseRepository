CREATE TABLE [app].[UserAndLocation] (
    [UserAndLocationID] INT IDENTITY (1, 1) NOT NULL,
    [UserID]            INT NOT NULL,
    [LocationID]        INT NOT NULL,
    [IsPrimary]         BIT NULL,
    CONSTRAINT [PK_UserAndLocation] PRIMARY KEY CLUSTERED ([UserAndLocationID] ASC) WITH (FILLFACTOR = 90)
);

