CREATE TABLE [Products].[RoomStatus] (
    [RoomStatusID] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RoomStatus]   VARCHAR (100) NOT NULL,
    [Remarks]      VARCHAR (200) NULL,
    [IsPrimary]    BIT           NULL,
    [IsSecondary]  BIT           NULL,
    [CreatedBy]    INT           NULL,
    [CreateDate]   DATETIME      NULL,
    [DisplayOrder] INT           NULL,
    [HKStatusName] VARCHAR (200) NULL,
    CONSTRAINT [PK__Room_Sta__78526B22D9A43EA9] PRIMARY KEY CLUSTERED ([RoomStatusID] ASC) WITH (FILLFACTOR = 90)
);

