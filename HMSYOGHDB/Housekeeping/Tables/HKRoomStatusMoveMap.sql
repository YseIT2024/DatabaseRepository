CREATE TABLE [Housekeeping].[HKRoomStatusMoveMap] (
    [HHKRoomStatusMoveMapID] INT            IDENTITY (1, 1) NOT NULL,
    [RoomStatusIDFrom]       INT            NOT NULL,
    [RoomStatusIDTo]         INT            NOT NULL,
    [Remarks]                NVARCHAR (200) NULL,
    [CreatedBy]              INT            NOT NULL,
    [CreateDate]             DATETIME       NOT NULL,
    CONSTRAINT [PK_HKRoomStatusMoveMap] PRIMARY KEY CLUSTERED ([HHKRoomStatusMoveMapID] ASC) WITH (FILLFACTOR = 90)
);

