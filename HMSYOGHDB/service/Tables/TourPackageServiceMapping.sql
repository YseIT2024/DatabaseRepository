CREATE TABLE [service].[TourPackageServiceMapping] (
    [ServiceMappingID]       INT      IDENTITY (1, 1) NOT NULL,
    [TourPackageServiceID]   INT      NOT NULL,
    [ComplimentaryServiceID] INT      NOT NULL,
    [CreatedBy]              INT      NULL,
    [CreateDate]             DATETIME NULL,
    CONSTRAINT [PK_TourPackageServiceMapping] PRIMARY KEY CLUSTERED ([ServiceMappingID] ASC) WITH (FILLFACTOR = 90)
);

