CREATE TYPE [reservation].[ReservationDetails_New] AS TABLE (
    [ItemID]                  INT             NULL,
    [NightDate]               DATE            NULL,
    [Rooms]                   INT             NULL,
    [Adults]                  INT             NULL,
    [ExtraAdults]             INT             NULL,
    [Children]                INT             NULL,
    [ExtraChildren]           INT             NULL,
    [UnitPriceBeforeDiscount] DECIMAL (18, 2) NULL,
    [Discount]                DECIMAL (18, 2) NULL,
    [UnitPriceAfterDiscount]  DECIMAL (18, 2) NULL,
    [TotalTax]                DECIMAL (18, 2) NULL,
    [TotalTaxAmount]          DECIMAL (18, 2) NULL,
    [UnitPriceAfterTax]       DECIMAL (18, 2) NULL,
    [LineTotal]               DECIMAL (18, 2) NULL,
    [ExChildSr]               INT             NULL,
    [DiscountPercentage]      DECIMAL (18, 2) NULL);

