CREATE TABLE [Housekeeping].[HKChecklistScheduleDetails] (
    [ScheduleDetailId]    INT      IDENTITY (1, 1) NOT NULL,
    [ChecklistScheduleId] INT      NOT NULL,
    [ChecklistId]         INT      NOT NULL,
    [ScheduleDate]        DATETIME NOT NULL,
    [ScheduleFromTime]    DATETIME NULL,
    [ScheduleToTime]      DATETIME NULL,
    [StatusId]            INT      NOT NULL,
    [IsActive]            BIT      NOT NULL,
    [CreatedBy]           INT      NOT NULL,
    [CreatedOn]           DATETIME NOT NULL,
    [ModifiedBy]          INT      NULL,
    [ModifiedOn]          DATETIME NULL,
    CONSTRAINT [PK_HKChecklistScheduleDetails] PRIMARY KEY CLUSTERED ([ScheduleDetailId] ASC) WITH (FILLFACTOR = 90)
);

