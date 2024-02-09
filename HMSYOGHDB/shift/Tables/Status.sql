CREATE TABLE [shift].[Status] (
    [ShiftStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [ShiftStatus]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED ([ShiftStatusID] ASC) WITH (FILLFACTOR = 90)
);

