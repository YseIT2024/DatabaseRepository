CREATE TYPE [Housekeeping].[dtScheduleCompletionDetails] AS TABLE (
    [TaskCompletionId] INT           NULL,
    [AllocationId]     INT           NULL,
    [TaskItemId]       INT           NULL,
    [Remarks]          VARCHAR (250) NULL,
    [Status]           VARCHAR (250) NULL);

