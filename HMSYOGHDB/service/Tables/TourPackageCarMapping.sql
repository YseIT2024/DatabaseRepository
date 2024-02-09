CREATE TABLE [service].[TourPackageCarMapping] (
    [CarMappingID]         INT      IDENTITY (1, 1) NOT NULL,
    [TourPackageServiceID] INT      NOT NULL,
    [CarServiceID]         INT      NOT NULL,
    [CreatedBy]            INT      NULL,
    [CreateDate]           DATETIME NULL,
    CONSTRAINT [PK_TourPackageCarMapping] PRIMARY KEY CLUSTERED ([CarMappingID] ASC) WITH (FILLFACTOR = 90)
);

