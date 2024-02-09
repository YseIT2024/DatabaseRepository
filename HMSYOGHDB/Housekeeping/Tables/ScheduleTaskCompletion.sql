CREATE TABLE [Housekeeping].[ScheduleTaskCompletion] (
    [TaskCompletionId] INT            IDENTITY (1, 1) NOT NULL,
    [AllocationId]     INT            NOT NULL,
    [TaskItemId]       INT            NOT NULL,
    [Remarks]          VARCHAR (100)  NULL,
    [Status]           VARCHAR (100)  NULL,
    [CompletedBy]      NVARCHAR (150) NULL,
    [VerifiedBy]       NVARCHAR (150) NULL,
    [LocationId]       INT            NULL,
    [CreatedBy]        INT            NOT NULL,
    [CreatedOn]        DATETIME       NOT NULL,
    [ModifiedBy]       INT            NULL,
    [ModifiedOn]       DATETIME       NULL,
    CONSTRAINT [PK__Schedule__C6F7B4DEE47F78EE] PRIMARY KEY CLUSTERED ([TaskCompletionId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__ScheduleT__Alloc__0A6952D9] FOREIGN KEY ([AllocationId]) REFERENCES [Housekeeping].[ScheduleTaskAllocation] ([AllocationId]),
    CONSTRAINT [FK__ScheduleT__Alloc__0F2E07F6] FOREIGN KEY ([AllocationId]) REFERENCES [Housekeeping].[ScheduleTaskAllocation] ([AllocationId])
);

