CREATE TABLE [app].[Object] (
    [ObjectID]     INT           IDENTITY (1, 1) NOT NULL,
    [TabGroupID]   INT           NULL,
    [ObjectName]   VARCHAR (100) NOT NULL,
    [DisplayText]  VARCHAR (100) NULL,
    [ObjectPath]   VARCHAR (250) NULL,
    [IsAutoObject] BIT           CONSTRAINT [DF_Object_IsAutoObject] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Object] PRIMARY KEY CLUSTERED ([ObjectID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [U_ObjectName] UNIQUE NONCLUSTERED ([ObjectName] ASC) WITH (FILLFACTOR = 90)
);

