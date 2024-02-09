CREATE TABLE [app].[Audit] (
    [AuditID]     INT           IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (MAX) NOT NULL,
    [DateTime]    DATETIME      NOT NULL,
    CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED ([AuditID] ASC) WITH (FILLFACTOR = 90)
);

