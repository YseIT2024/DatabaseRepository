CREATE TABLE [general].[Vehicle] (
    [SegmentId]      INT           NOT NULL,
    [VehicleNo]      VARCHAR (100) NOT NULL,
    [VehicleName]    VARCHAR (100) NOT NULL,
    [OpeningReading] INT           NOT NULL,
    [DriverId]       INT           NULL,
    [DriverName]     VARCHAR (100) NOT NULL,
    [isActive]       BIT           NULL,
    [CreatedBy]      INT           NOT NULL,
    [CreatedOn]      DATETIME      NOT NULL,
    CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED ([VehicleNo] ASC) WITH (FILLFACTOR = 90)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ItemId column of [HMSYOGH].[service].[Item] ', @level0type = N'SCHEMA', @level0name = N'general', @level1type = N'TABLE', @level1name = N'Vehicle', @level2type = N'COLUMN', @level2name = N'SegmentId';

