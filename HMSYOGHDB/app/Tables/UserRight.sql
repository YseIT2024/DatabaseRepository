CREATE TABLE [app].[UserRight] (
    [UserRightID] INT IDENTITY (1, 1) NOT NULL,
    [UserID]      INT NOT NULL,
    [ObjectID]    INT NOT NULL,
    [OperationID] INT NOT NULL,
    CONSTRAINT [PK_UserRight] PRIMARY KEY CLUSTERED ([UserRightID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UserRight_Operation] FOREIGN KEY ([OperationID]) REFERENCES [app].[Operation] ([OperationID])
);

