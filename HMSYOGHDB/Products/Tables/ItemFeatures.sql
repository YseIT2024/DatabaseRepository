CREATE TABLE [Products].[ItemFeatures] (
    [ItemFeatureID] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ItemID]        INT          NOT NULL,
    [FeatureID]     INT          NOT NULL,
    [FeatureValue]  VARCHAR (50) NULL,
    [IsActive]      BIT          NULL,
    [CreatedBy]     INT          NULL,
    [CreateDate]    DATETIME     NULL,
    CONSTRAINT [PK__Item_Fea__A69F327BFC1DDEB0] PRIMARY KEY CLUSTERED ([ItemFeatureID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ItemFeatures_Features] FOREIGN KEY ([FeatureID]) REFERENCES [Products].[Features] ([FeatureID]),
    CONSTRAINT [FK_ItemFeatures_Item] FOREIGN KEY ([ItemID]) REFERENCES [Products].[Item] ([ItemID])
);

