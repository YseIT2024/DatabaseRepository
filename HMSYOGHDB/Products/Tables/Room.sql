CREATE TABLE [Products].[Room] (
    [RoomID]           INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SubCategoryID]    INT           NOT NULL,
    [RoomNo]           INT           NOT NULL,
    [FloorID]          INT           NOT NULL,
    [LocationID]       INT           NOT NULL,
    [Dimension]        VARCHAR (20)  NULL,
    [BedSize]          VARCHAR (20)  NULL,
    [MaxAdultCapacity] INT           NULL,
    [MaxChildCapacity] INT           NULL,
    [Remarks]          VARCHAR (200) NULL,
    [RoomStatusID]     INT           NOT NULL,
    [IsActive]         BIT           NOT NULL,
    [CreatedBy]        INT           NULL,
    [CreateDate]       DATETIME      NULL,
    [ResId]            INT           NULL,
    CONSTRAINT [PK__Room__19EE6A739874D550] PRIMARY KEY CLUSTERED ([RoomID] ASC) WITH (FILLFACTOR = 90)
);

