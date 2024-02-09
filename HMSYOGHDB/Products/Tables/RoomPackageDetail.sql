CREATE TABLE [Products].[RoomPackageDetail] (
    [PackageDetailID] INT           IDENTITY (1, 1) NOT NULL,
    [PackageID]       INT           NOT NULL,
    [FeatureId]       INT           NOT NULL,
    [PackageDetail]   VARCHAR (250) NOT NULL,
    [IsActive]        BIT           NOT NULL,
    [CreatedBy]       INT           NULL,
    [CreateDate]      DATETIME      NULL,
    CONSTRAINT [PK__RoomPackageDetail] PRIMARY KEY CLUSTERED ([PackageDetailID] ASC) WITH (FILLFACTOR = 90)
);

