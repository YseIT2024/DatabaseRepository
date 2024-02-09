CREATE TABLE [todo].[ToDo] (
    [ToDoID]              INT           IDENTITY (1, 1) NOT NULL,
    [ToDoTypeID]          INT           NOT NULL,
    [LocationID]          INT           NOT NULL,
    [DueDateTime]         DATETIME      NOT NULL,
    [Description]         VARCHAR (MAX) NOT NULL,
    [EnteredOn]           DATETIME      NOT NULL,
    [EnteredBy]           INT           NOT NULL,
    [PriorityID]          INT           NULL,
    [AssignTo_EmployeeID] INT           NULL,
    [RSHistoryID]         INT           NULL,
    [AssignTo_Name]       VARCHAR (80)  NULL,
    [IsCompleted]         BIT           CONSTRAINT [DF_ToDo_IsCompleted] DEFAULT ((0)) NOT NULL,
    [CompletedOn]         DATETIME      NULL,
    [UpdatedBy]           INT           NULL,
    CONSTRAINT [PK_ToDo_1] PRIMARY KEY CLUSTERED ([ToDoID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ToDo_Priority] FOREIGN KEY ([PriorityID]) REFERENCES [todo].[Priority] ([PriorityID]),
    CONSTRAINT [FK_ToDo_Type] FOREIGN KEY ([ToDoTypeID]) REFERENCES [todo].[Type] ([ToDoTypeID])
);

