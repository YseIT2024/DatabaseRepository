CREATE TABLE [Housekeeping].[HKChecklist] (
    [ChecklistId]           INT           IDENTITY (1, 1) NOT NULL,
    [ChecklistName]         VARCHAR (50)  NOT NULL,
    [ChecklistDescription]  VARCHAR (250) NOT NULL,
    [IsActive]              BIT           NOT NULL,
    [CreatedBy]             INT           NOT NULL,
    [CreatedOn]             DATETIME      NOT NULL,
    [ModifiedBy]            INT           NULL,
    [ModifiedOn]            DATETIME      NULL,
    [LocationId]            INT           NULL,
    [ChecklistDepartmentId] INT           NULL,
    [UserRoleId]            INT           NULL,
    CONSTRAINT [PK_HKChecklist] PRIMARY KEY CLUSTERED ([ChecklistId] ASC) WITH (FILLFACTOR = 90)
);

