CREATE TABLE [Lock].[CardLog] (
    [CardLogID]  INT            IDENTITY (1, 1) NOT NULL,
    [RoomNumber] INT            NULL,
    [CardStatus] NVARCHAR (150) NULL,
    [LockNumber] NVARCHAR (150) NULL,
    [Message]    NVARCHAR (MAX) NULL,
    [UserId]     INT            NULL,
    [Datetime]   DATETIME       NULL,
    CONSTRAINT [PK_CardLog] PRIMARY KEY CLUSTERED ([CardLogID] ASC)
);

