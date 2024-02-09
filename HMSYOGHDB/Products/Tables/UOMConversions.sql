CREATE TABLE [Products].[UOMConversions] (
    [UOMConversionID]    INT             IDENTITY (1, 1) NOT NULL,
    [UOMClassID]         INT             NOT NULL,
    [UOMBaseID]          INT             NOT NULL,
    [UOMID]              INT             NOT NULL,
    [ConversionFactorID] INT             NOT NULL,
    [ConversionValue]    NUMERIC (18, 4) NOT NULL,
    [Predefined]         BIT             NOT NULL,
    CONSTRAINT [PK_UOMConversions] PRIMARY KEY CLUSTERED ([UOMConversionID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UOMConversions_UOMClass] FOREIGN KEY ([UOMClassID]) REFERENCES [Products].[UOMClass] ([UOMClassID])
);

