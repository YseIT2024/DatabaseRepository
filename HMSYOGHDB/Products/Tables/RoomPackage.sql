CREATE TABLE [Products].[RoomPackage] (
    [PackageID]          INT           IDENTITY (1, 1) NOT NULL,
    [PackageName]        VARCHAR (100) NOT NULL,
    [PackageDescription] VARCHAR (250) NOT NULL,
    [IsActive]           BIT           NOT NULL,
    [CreatedBy]          INT           NULL,
    [CreateDate]         DATETIME      NULL,
    [BusinessRule]       VARCHAR (500) NULL,
    [DisplayOrder]       NCHAR (10)    NULL,
    [ShortName]          VARCHAR (50)  NULL,
    CONSTRAINT [PK__RoomPackage] PRIMARY KEY CLUSTERED ([PackageID] ASC) WITH (FILLFACTOR = 90)
);

