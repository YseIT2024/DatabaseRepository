CREATE TABLE [general].[VehicleSegment] (
    [SegmentId]   INT           IDENTITY (1, 1) NOT NULL,
    [SegmentName] VARCHAR (100) NOT NULL,
    [AvailableNo] INT           NULL,
    [IsActive]    BIT           NULL,
    [CreatedBy]   INT           NOT NULL,
    [CreatedOn]   DATETIME      NOT NULL,
    CONSTRAINT [PK_VehicleSegment] PRIMARY KEY CLUSTERED ([SegmentId] ASC) WITH (FILLFACTOR = 90)
);

