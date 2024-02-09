CREATE TYPE [app].[dtTableStructures] AS TABLE (
    [LocationID]      INT           NOT NULL,
    [NoOfTables]      INT           NOT NULL,
    [TableID]         INT           NOT NULL,
    [StructureID]     INT           NOT NULL,
    [TableNo]         INT           NOT NULL,
    [MaxCapacity]     INT           NOT NULL,
    [Description]     VARCHAR (100) NULL,
    [StatusID]        INT           NOT NULL,
    [Status]          VARCHAR (100) NOT NULL,
    [BookingCapacity] INT           NOT NULL);

