CREATE TABLE [general].[Department] (
    [DepartmentID] INT          IDENTITY (1, 1) NOT NULL,
    [Department]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK__Departme__B2079BCDC5167B3E] PRIMARY KEY CLUSTERED ([DepartmentID] ASC) WITH (FILLFACTOR = 90)
);

