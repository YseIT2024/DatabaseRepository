CREATE TABLE [reservation].[ApprovalWorkflow] (
    [ApprovalWorkflowId] INT IDENTITY (1, 1) NOT NULL,
    [ProcessTypeId]      INT NULL,
    [ApprovalLevel]      INT NULL,
    [UserId]             INT NULL,
    [RoleId]             INT NULL,
    [IsActive]           INT NULL,
    [UserId2]            INT NULL,
    [IsPrimary]          INT NULL,
    CONSTRAINT [PK_ApprovalWorkflow] PRIMARY KEY CLUSTERED ([ApprovalWorkflowId] ASC) WITH (FILLFACTOR = 90)
);

