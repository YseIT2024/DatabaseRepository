CREATE TYPE [general].[dtWarehouseLocationMap] AS TABLE (
    [LocationMapID] INT           NULL,
    [LocationName]  VARCHAR (100) NULL,
    [LocationID]    INT           NOT NULL,
    [WarehouseID]   INT           NOT NULL);

