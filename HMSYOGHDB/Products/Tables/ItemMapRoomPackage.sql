CREATE TABLE [Products].[ItemMapRoomPackage] (
    [ItemPackageMapId] INT      IDENTITY (1, 1) NOT NULL,
    [ItemID]           INT      NOT NULL,
    [PackageId]        INT      NOT NULL,
    [IsActive]         BIT      NULL,
    [CreatedBy]        INT      NULL,
    [CreateDate]       DATETIME NULL,
    CONSTRAINT [PK__ItemMapRoomPackage] PRIMARY KEY CLUSTERED ([ItemPackageMapId] ASC) WITH (FILLFACTOR = 90)
);

