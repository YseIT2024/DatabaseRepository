CREATE TABLE [Housekeeping].[HKChecklistSchedule] (
    [ChecklistScheduleId] INT          IDENTITY (1, 1) NOT NULL,
    [ChecklistId]         INT          NOT NULL,
    [FromDate]            DATETIME     NOT NULL,
    [ToDate]              DATETIME     NOT NULL,
    [ScheduleType]        BIT          NULL,
    [Repeat]              BIT          NULL,
    [Frequency]           VARCHAR (50) NULL,
    [StatusId]            INT          NOT NULL,
    [IsActive]            BIT          NOT NULL,
    [CreatedBy]           INT          NOT NULL,
    [CreatedOn]           DATETIME     NOT NULL,
    [ModifiedBy]          INT          NULL,
    [ModifiedOn]          DATETIME     NULL,
    [LocationId]          INT          NULL,
    CONSTRAINT [PK_HKChecklistSchedule] PRIMARY KEY CLUSTERED ([ChecklistScheduleId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_HKChecklist_ChecklistId] FOREIGN KEY ([ChecklistId]) REFERENCES [Housekeeping].[HKChecklist] ([ChecklistId]),
    CONSTRAINT [FK_HKChecklist_ChecklistScheduleId] FOREIGN KEY ([ChecklistScheduleId]) REFERENCES [Housekeeping].[HKChecklistSchedule] ([ChecklistScheduleId])
);

