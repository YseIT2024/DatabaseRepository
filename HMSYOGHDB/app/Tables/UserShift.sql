CREATE TABLE [app].[UserShift] (
    [UserShiftID] INT      IDENTITY (1, 1) NOT NULL,
    [EmployeeID]  INT      NOT NULL,
    [UserID]      INT      NULL,
    [ShiftID]     INT      NOT NULL,
    [DrawerID]    INT      NULL,
    [StartAt]     DATETIME NOT NULL,
    [EndAt]       DATETIME NULL,
    CONSTRAINT [PK_UserShift] PRIMARY KEY CLUSTERED ([UserShiftID] ASC) WITH (FILLFACTOR = 90)
);

