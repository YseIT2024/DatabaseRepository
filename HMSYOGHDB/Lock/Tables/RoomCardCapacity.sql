CREATE TABLE [Lock].[RoomCardCapacity] (
    [RoomTypeId]      INT           NOT NULL,
    [MaxCardCount]    INT           NULL,
    [DefaultMakeCard] INT           NULL,
    [Remark]          NVARCHAR (50) NULL,
    [IsActive]        BIT           NOT NULL,
    [CreatedOn]       DATETIME      NOT NULL,
    [CreatedBy]       INT           NOT NULL,
    [LocationId]      INT           NOT NULL,
    [RecordId]        INT           IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC),
    CONSTRAINT [FK__RoomCardC__RoomT__49259F61] FOREIGN KEY ([RoomTypeId]) REFERENCES [Products].[SubCategory] ([SubCategoryID])
);

