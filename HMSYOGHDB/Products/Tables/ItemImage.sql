CREATE TABLE [Products].[ItemImage] (
    [ItemImageID] INT           IDENTITY (1, 1) NOT NULL,
    [ItemID]      INT           NOT NULL,
    [FilePath]    VARCHAR (255) NOT NULL,
    [CreatedBy]   INT           NULL,
    [CreateDate]  DATETIME      NULL,
    CONSTRAINT [FK_ItemImage_Item] FOREIGN KEY ([ItemID]) REFERENCES [Products].[Item] ([ItemID])
);

