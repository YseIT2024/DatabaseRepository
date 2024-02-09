CREATE TABLE [shift].[ShiftAllocation] (
    [ShiftAllocationID]  INT IDENTITY (1, 1) NOT NULL,
    [LocationID]         INT NOT NULL,
    [DateID]             INT NOT NULL,
    [ShiftID]            INT NULL,
    [ExceptionalShiftID] INT NULL,
    [JobTitleID]         INT NOT NULL,
    [EmployeeID]         INT NOT NULL,
    [UserID]             INT NOT NULL,
    [ShiftStatusID]      INT CONSTRAINT [DF_ShiftAllocation_ShiftStatusID] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_ShiftAllocation_1] PRIMARY KEY CLUSTERED ([ShiftAllocationID] ASC) WITH (FILLFACTOR = 90)
);

