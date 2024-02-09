CREATE TABLE [app].[Shift] (
    [ShiftID]      INT          NOT NULL,
    [Shift]        VARCHAR (30) NOT NULL,
    [ShiftStartAt] TIME (7)     NOT NULL,
    [ShiftEndAt]   TIME (7)     NOT NULL,
    CONSTRAINT [PK_Shift] PRIMARY KEY CLUSTERED ([ShiftID] ASC) WITH (FILLFACTOR = 90)
);

