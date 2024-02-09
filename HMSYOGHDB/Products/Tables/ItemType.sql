CREATE TABLE [Products].[ItemType] (
    [ItemTypeID]  INT           NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [CreatedBy]   INT           NULL,
    [CreateDate]  DATETIME      NULL,
    CONSTRAINT [PK_ItemType] PRIMARY KEY CLUSTERED ([ItemTypeID] ASC) WITH (FILLFACTOR = 90)
);

