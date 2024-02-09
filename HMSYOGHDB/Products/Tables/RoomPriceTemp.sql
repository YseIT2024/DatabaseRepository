CREATE TABLE [Products].[RoomPriceTemp] (
    [PriceID]             INT             NOT NULL,
    [ItemID]              INT             NOT NULL,
    [PriceTypeID]         INT             NOT NULL,
    [LocationID]          INT             NOT NULL,
    [FromDate]            DATE            NOT NULL,
    [CurrencyID]          INT             NOT NULL,
    [BasePrice]           DECIMAL (18, 4) NOT NULL,
    [BasePriceSingleOcc]  DECIMAL (18, 4) NULL,
    [Commission]          DECIMAL (12, 2) NULL,
    [Discount]            DECIMAL (12, 2) NULL,
    [AddPax]              DECIMAL (12, 4) NULL,
    [AddChild]            DECIMAL (12, 4) NULL,
    [SalePrice]           DECIMAL (18, 4) NOT NULL,
    [SalesPriceSingleOcc] DECIMAL (18, 4) NULL,
    [Remarks]             VARCHAR (200)   NULL,
    [IsOnDemand]          BIT             NULL,
    [IsWeekEnd]           BIT             NULL,
    [Priority]            INT             NULL,
    [CreatedBy]           INT             NULL,
    [CreateDate]          DATETIME        NULL,
    CONSTRAINT [PK_RoomPriceTemp] PRIMARY KEY CLUSTERED ([PriceID] ASC, [ItemID] ASC) WITH (FILLFACTOR = 90)
);

