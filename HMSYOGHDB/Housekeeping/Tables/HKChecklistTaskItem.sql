CREATE TABLE [Housekeeping].[HKChecklistTaskItem] (
    [ChecklistITaskItemId]         INT           IDENTITY (1, 1) NOT NULL,
    [ChecklistTaskId]              INT           NOT NULL,
    [ChecklistTaskItemName]        VARCHAR (50)  NOT NULL,
    [ChecklistTaskItemDescription] VARCHAR (250) NOT NULL,
    [IsActive]                     BIT           NOT NULL,
    [CreatedBy]                    INT           NOT NULL,
    [CreatedOn]                    DATETIME      NOT NULL,
    [ModifiedBy]                   INT           NULL,
    [ModifiedOn]                   DATETIME      NULL,
    CONSTRAINT [PK_HKChecklistTaskItem] PRIMARY KEY CLUSTERED ([ChecklistITaskItemId] ASC) WITH (FILLFACTOR = 90)
);

