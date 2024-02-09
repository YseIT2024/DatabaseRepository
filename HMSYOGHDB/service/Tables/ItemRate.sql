CREATE TABLE [service].[ItemRate] (
    [ItemRateID]     INT      IDENTITY (1, 1) NOT NULL,
    [ItemID]         INT      NOT NULL,
    [PriceID]        INT      NOT NULL,
    [IsActive]       BIT      CONSTRAINT [DF_ItemRate_IsActive] DEFAULT ((1)) NOT NULL,
    [ActivateDate]   DATETIME CONSTRAINT [DF_ItemRate_ActivateDate] DEFAULT (getdate()) NOT NULL,
    [DeactivateDate] DATETIME NULL,
    CONSTRAINT [PK_ItemRate] PRIMARY KEY CLUSTERED ([ItemRateID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ItemRate_Item] FOREIGN KEY ([ItemID]) REFERENCES [service].[Item] ([ItemID])
);

