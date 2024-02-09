CREATE TABLE [general].[Designation] (
    [DesignationID] INT          IDENTITY (1, 1) NOT NULL,
    [Designation]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK__Designat__BABD603EB60FA5FC] PRIMARY KEY CLUSTERED ([DesignationID] ASC) WITH (FILLFACTOR = 90)
);

