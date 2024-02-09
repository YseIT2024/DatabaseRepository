CREATE TABLE [guest].[RemovedGuest] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [RemovedGuestID]    INT           NOT NULL,
    [MergedIntoGuestID] INT           NOT NULL,
    [LocationID]        INT           NOT NULL,
    [UserID]            INT           NOT NULL,
    [Comment]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_RemovedGuest] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

