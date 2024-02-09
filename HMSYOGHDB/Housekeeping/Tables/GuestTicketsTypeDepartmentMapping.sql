CREATE TABLE [Housekeeping].[GuestTicketsTypeDepartmentMapping] (
    [MapId]        INT      NOT NULL,
    [ConfigId]     INT      NOT NULL,
    [DepartmentId] INT      NOT NULL,
    [CreatedBy]    INT      NOT NULL,
    [CreatedOn]    DATETIME NOT NULL,
    [IsActive]     BIT      NOT NULL,
    [ModifiedBy]   INT      NULL,
    [ModifiedOn]   DATETIME NULL,
    PRIMARY KEY CLUSTERED ([MapId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([ConfigId]) REFERENCES [Housekeeping].[GuestTicketsConfig] ([ConfigId]),
    FOREIGN KEY ([DepartmentId]) REFERENCES [general].[Department] ([DepartmentID])
);

