CREATE TABLE [general].[Employee] (
    [EmployeeID]      INT           NOT NULL,
    [ContactID]       INT           NOT NULL,
    [OfficialEmail]   VARCHAR (50)  NULL,
    [JoiningDate]     DATE          NOT NULL,
    [ResignationDate] DATE          NULL,
    [IsActive]        BIT           NOT NULL,
    [Remarks]         VARCHAR (255) NULL,
    [CreatedBy]       INT           NULL,
    [CreatedDate]     DATETIME      NULL,
    [HrmsEmpID]       INT           NULL,
    CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([EmployeeID] ASC) WITH (FILLFACTOR = 90)
);

