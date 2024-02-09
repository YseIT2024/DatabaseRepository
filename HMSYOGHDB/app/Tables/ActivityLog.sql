CREATE TABLE [app].[ActivityLog] (
    [LogID]          INT            IDENTITY (1, 1) NOT NULL,
    [ActivityTypeID] INT            NOT NULL,
    [LocationID]     INT            NOT NULL,
    [DateTime]       DATETIME       CONSTRAINT [DF_ActivityLog_DateTime] DEFAULT (getdate()) NOT NULL,
    [Activity]       VARCHAR (MAX)  NOT NULL,
    [UserID]         INT            NULL,
    [ActivityTitle]  NVARCHAR (250) NULL,
    [ReferenceNo]    INT            NULL,
    CONSTRAINT [PK_ActivityLog] PRIMARY KEY CLUSTERED ([LogID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ActivityLog_ActivityType] FOREIGN KEY ([ActivityTypeID]) REFERENCES [app].[ActivityType] ([ActivityTypeID])
);

