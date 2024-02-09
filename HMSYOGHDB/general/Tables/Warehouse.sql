CREATE TABLE [general].[Warehouse] (
    [WarehouseID] INT           IDENTITY (1, 1) NOT NULL,
    [Code]        VARCHAR (5)   NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [Address]     VARCHAR (255) NULL,
    [Remarks]     VARCHAR (255) NULL,
    [IsActive]    BIT           NOT NULL,
    [CreatedBy]   INT           NULL,
    [CreatedDate] DATETIME      NULL,
    CONSTRAINT [PK_Warehouse] PRIMARY KEY CLUSTERED ([WarehouseID] ASC) WITH (FILLFACTOR = 90)
);

