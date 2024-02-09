CREATE TABLE [dbo].[Notification] (
    [NotificationID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [LocationID]     INT           NOT NULL,
    [Title]          VARCHAR (200) NOT NULL,
    [Description]    VARCHAR (MAX) NOT NULL,
    [DateTime]       DATETIME      NOT NULL,
    CONSTRAINT [PK_Notification] PRIMARY KEY CLUSTERED ([NotificationID] ASC) WITH (FILLFACTOR = 90)
);

