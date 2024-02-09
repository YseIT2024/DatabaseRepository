CREATE TABLE [service].[ActivityLog] (
    [LogID]       INT           IDENTITY (1, 1) NOT NULL,
    [ItemID]      INT           NULL,
    [ItemRateID]  INT           NULL,
    [ServiceID]   INT           NULL,
    [DrawerID]    INT           NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [DateTime]    DATETIME      NOT NULL,
    [UserID]      INT           NOT NULL,
    CONSTRAINT [PK_ActivityLog_1] PRIMARY KEY CLUSTERED ([LogID] ASC) WITH (FILLFACTOR = 90)
);

