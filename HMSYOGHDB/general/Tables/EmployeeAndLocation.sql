CREATE TABLE [general].[EmployeeAndLocation] (
    [EmployeeAndLocationID] INT IDENTITY (1, 1) NOT NULL,
    [EmployeeID]            INT NOT NULL,
    [LocationID]            INT NOT NULL,
    CONSTRAINT [PK_EmployeeAndLocation] PRIMARY KEY CLUSTERED ([EmployeeAndLocationID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_EmployeeAndLocation_Employee] FOREIGN KEY ([EmployeeID]) REFERENCES [general].[Employee] ([EmployeeID])
);

