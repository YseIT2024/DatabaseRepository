CREATE TABLE [Housekeeping].[ScheduleTaskAllocation] (
    [AllocationId]      INT          IDENTITY (0, 1) NOT NULL,
    [ScheduleDetailId]  INT          NOT NULL,
    [AllocatedTo]       INT          NOT NULL,
    [AllocatedLocation] VARCHAR (50) NOT NULL,
    [LocationId]        INT          NULL,
    [Supervisor]        INT          NOT NULL,
    [CreatedBy]         INT          NOT NULL,
    [CreatedOn]         DATETIME     NOT NULL,
    [ModifiedBy]        INT          NULL,
    [ModifiedOn]        DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([AllocationId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId]),
    FOREIGN KEY ([ScheduleDetailId]) REFERENCES [Housekeeping].[HKChecklistScheduleDetails] ([ScheduleDetailId])
);

