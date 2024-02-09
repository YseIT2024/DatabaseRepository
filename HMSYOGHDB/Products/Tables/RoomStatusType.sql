CREATE TABLE [Products].[RoomStatusType] (
    [RoomStatusTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [RoomStatusType]   VARCHAR (100) NOT NULL,
    [Remarks]          VARCHAR (200) NULL,
    [CreatedBy]        INT           NULL,
    [CreateDate]       DATETIME      NULL,
    [ModifiedBy]       INT           NULL,
    [ModifiedOn]       DATETIME      NULL,
    [DisplayOrder]     INT           NULL,
    CONSTRAINT [PK__RoomStatusType] PRIMARY KEY CLUSTERED ([RoomStatusTypeID] ASC) WITH (FILLFACTOR = 90)
);

