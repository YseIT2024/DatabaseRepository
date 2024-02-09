CREATE TABLE [Housekeeping].[HKRoomStatusLogs] (
    [HKStatusLogID] INT            IDENTITY (1, 1) NOT NULL,
    [RoomID]        INT            NOT NULL,
    [RoomStatusID]  INT            NOT NULL,
    [AttendedBy]    INT            NOT NULL,
    [Remarks]       NVARCHAR (200) NULL,
    [CreatedBy]     INT            NOT NULL,
    [CreateDate]    DATETIME       NOT NULL,
    CONSTRAINT [PK_HKRoomStatusLogs] PRIMARY KEY CLUSTERED ([HKStatusLogID] ASC) WITH (FILLFACTOR = 90)
);

