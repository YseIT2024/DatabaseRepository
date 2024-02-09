CREATE TABLE [reservation].[ApprovalLog] (
    [ApprovalLogId]       INT            IDENTITY (1, 1) NOT NULL,
    [ProcessTypeId]       INT            NULL,
    [LocatioId]           INT            NULL,
    [CreatedOn]           DATETIME       NULL,
    [CreatedBy]           INT            NULL,
    [ApprovalDescription] NVARCHAR (250) NULL,
    [RefrenceNo]          INT            NULL,
    [ApprovalStatus]      INT            NULL,
    [ModifiedOn]          DATETIME       NULL,
    [ModifiedBy]          INT            NULL,
    [ToRoleId]            INT            NULL,
    [ToUserId]            INT            NULL,
    [LogLevel]            INT            NULL,
    [Remark]              NVARCHAR (250) NULL,
    [OldRate]             NVARCHAR (50)  NULL,
    [NewRate]             NVARCHAR (50)  NULL,
    [IsApprovalVisible]   INT            NULL,
    CONSTRAINT [PK_ApprovalLog] PRIMARY KEY CLUSTERED ([ApprovalLogId] ASC) WITH (FILLFACTOR = 90)
);

