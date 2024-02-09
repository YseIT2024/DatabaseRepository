CREATE TABLE [Housekeeping].[HKChecklistTask] (
    [ChecklistTaskId]          INT           IDENTITY (1, 1) NOT NULL,
    [ChecklistId]              INT           NOT NULL,
    [ChecklistTaskName]        VARCHAR (50)  NOT NULL,
    [ChecklistTaskDescription] VARCHAR (250) NOT NULL,
    [IsActive]                 BIT           NOT NULL,
    [CreatedBy]                INT           NOT NULL,
    [CreatedOn]                DATETIME      NOT NULL,
    [ModifiedBy]               INT           NULL,
    [ModifiedOn]               DATETIME      NULL,
    CONSTRAINT [PK_HKChecklistITask] PRIMARY KEY CLUSTERED ([ChecklistTaskId] ASC) WITH (FILLFACTOR = 90)
);

