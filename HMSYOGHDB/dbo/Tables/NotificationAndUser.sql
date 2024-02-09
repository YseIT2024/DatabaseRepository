CREATE TABLE [dbo].[NotificationAndUser] (
    [ID]             BIGINT   IDENTITY (1, 1) NOT NULL,
    [LocationID]     INT      NOT NULL,
    [NotificationID] BIGINT   NOT NULL,
    [UserID]         INT      NOT NULL,
    [HasSeen]        BIT      NOT NULL,
    [DateTime]       DATETIME NOT NULL,
    CONSTRAINT [PK_NotificationAndUser] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

