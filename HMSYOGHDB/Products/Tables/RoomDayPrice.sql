CREATE TABLE [Products].[RoomDayPrice] (
    [PriceID]         INT            IDENTITY (1, 1) NOT NULL,
    [ItemID]          INT            NOT NULL,
    [LocationID]      INT            NOT NULL,
    [Day]             VARCHAR (10)   NOT NULL,
    [BasePrice]       DECIMAL (8, 2) NOT NULL,
    [BasePriceSingle] DECIMAL (8, 2) NULL,
    [Commission]      DECIMAL (4, 2) NULL,
    [Discount]        DECIMAL (4, 2) NULL,
    [AddPax]          DECIMAL (8, 2) NULL,
    [AddChild]        DECIMAL (8, 2) NULL,
    [CreatedBy]       INT            NULL,
    [CreateDate]      DATE           NULL,
    [IsActive]        BIT            NULL,
    [AddChildSr]      DECIMAL (8, 2) NULL,
    [ModifiedBy]      INT            NULL,
    [ModifiedDate]    DATE           NULL,
    [AuthorizedFlag]  INT            NULL,
    [IsRateChanged]   INT            NULL,
    CONSTRAINT [PK_RoomDayPrice] PRIMARY KEY CLUSTERED ([PriceID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RoomDayPrice_Item] FOREIGN KEY ([ItemID]) REFERENCES [Products].[Item] ([ItemID])
);

