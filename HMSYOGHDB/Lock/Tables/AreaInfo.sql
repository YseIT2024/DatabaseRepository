CREATE TABLE [Lock].[AreaInfo] (
    [AreaCode]   INT           IDENTITY (1, 1) NOT NULL,
    [AreaName]   NVARCHAR (30) NOT NULL,
    [Remark]     NVARCHAR (50) NULL,
    [IsActive]   BIT           NULL,
    [CreatedOn]  DATETIME      NULL,
    [CreatedBy]  INT           NULL,
    [LocationId] INT           NULL
);

