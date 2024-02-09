CREATE TABLE [app].[ActivityType] (
    [ActivityTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [ActivityType]   VARCHAR (50)  NOT NULL,
    [ActivityGroup]  VARCHAR (50)  NULL,
    [ActivityTitle]  VARCHAR (250) NULL,
    CONSTRAINT [PK_ActivityType] PRIMARY KEY CLUSTERED ([ActivityTypeID] ASC) WITH (FILLFACTOR = 90)
);

