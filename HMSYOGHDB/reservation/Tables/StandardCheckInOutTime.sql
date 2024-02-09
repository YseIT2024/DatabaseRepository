CREATE TABLE [reservation].[StandardCheckInOutTime] (
    [StandardCheckInOutTimeID]    INT      IDENTITY (1, 1) NOT NULL,
    [StandardCheckInTime]         TIME (7) NOT NULL,
    [StandardCheckInTimeCloseAt]  TIME (7) NOT NULL,
    [StandardCheckOutTime]        TIME (7) NOT NULL,
    [StandardCheckOutTimeCloseAt] TIME (7) NULL,
    CONSTRAINT [PK_StandardCheckInOutTime] PRIMARY KEY CLUSTERED ([StandardCheckInOutTimeID] ASC) WITH (FILLFACTOR = 90)
);

