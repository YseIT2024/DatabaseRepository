CREATE TABLE [Products].[Brand] (
    [BrandID]     INT           IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [CreatedBy]   INT           NULL,
    [CreateDate]  DATETIME      NULL,
    CONSTRAINT [PK_Brand] PRIMARY KEY CLUSTERED ([BrandID] ASC) WITH (FILLFACTOR = 90)
);

