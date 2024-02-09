CREATE TABLE [general].[WarehouseLocationMap] (
    [ID]          INT      IDENTITY (1, 1) NOT NULL,
    [LocationID]  INT      NOT NULL,
    [WarehouseID] INT      NOT NULL,
    [CreatedBy]   INT      NULL,
    [CreatedDate] DATETIME NULL,
    CONSTRAINT [PK_WarehouseLocation] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_WarehouseLocationMap_Warehouse] FOREIGN KEY ([WarehouseID]) REFERENCES [general].[Warehouse] ([WarehouseID])
);

