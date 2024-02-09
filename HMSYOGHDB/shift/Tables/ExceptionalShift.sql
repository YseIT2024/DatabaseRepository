CREATE TABLE [shift].[ExceptionalShift] (
    [ExceptionalShiftID] INT           IDENTITY (1, 1) NOT NULL,
    [LocationID]         INT           NOT NULL,
    [Description]        VARCHAR (250) NOT NULL,
    [StartAt]            TIME (7)      NOT NULL,
    [EndAt]              TIME (7)      NOT NULL,
    [Minutes]            INT           NOT NULL,
    CONSTRAINT [PK_ExceptionalShift] PRIMARY KEY CLUSTERED ([ExceptionalShiftID] ASC) WITH (FILLFACTOR = 90)
);

