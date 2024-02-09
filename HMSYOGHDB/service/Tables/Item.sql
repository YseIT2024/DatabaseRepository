CREATE TABLE [service].[Item] (
    [ItemID]        INT           IDENTITY (1, 1) NOT NULL,
    [LocationID]    INT           NOT NULL,
    [ServiceTypeID] INT           NOT NULL,
    [FoodTypeID]    INT           NULL,
    [Name]          VARCHAR (100) NOT NULL,
    [ItemNumber]    INT           NOT NULL,
    [Description]   VARCHAR (150) NULL,
    [Note]          VARCHAR (200) NULL,
    [IsAvailable]   BIT           CONSTRAINT [DF_Item_IsAvailable] DEFAULT ((1)) NOT NULL,
    [UOMID]         INT           NULL,
    CONSTRAINT [PK_Item] PRIMARY KEY CLUSTERED ([ItemID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Item_Type] FOREIGN KEY ([ServiceTypeID]) REFERENCES [service].[Type] ([ServiceTypeID])
);

