CREATE TABLE [reservation].[ReservationDetails] (
    [ReservationDetailID]     INT             IDENTITY (1, 1) NOT NULL,
    [ReservationID]           INT             NOT NULL,
    [ItemID]                  INT             NOT NULL,
    [NightDate]               DATE            NULL,
    [Rooms]                   INT             NULL,
    [Adults]                  INT             NULL,
    [ExtraAdults]             INT             NULL,
    [Children]                INT             NULL,
    [ExtraChildren]           INT             NULL,
    [UnitPriceBeforeDiscount] DECIMAL (18, 4) NULL,
    [Discount]                DECIMAL (5, 2)  NULL,
    [UnitPriceAfterDiscount]  DECIMAL (18, 4) NULL,
    [TotalTax]                DECIMAL (5, 2)  NULL,
    [TotalTaxAmount]          DECIMAL (18, 4) NULL,
    [UnitPriceAfterTax]       DECIMAL (18, 4) NULL,
    [LineTotal]               DECIMAL (18, 4) NULL,
    [TaxDetailID]             INT             NULL,
    [ExtraChildrenSr]         INT             NULL,
    [DiscountPercentage]      DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_reservation.ReservationDetails] PRIMARY KEY CLUSTERED ([ReservationDetailID] ASC) WITH (FILLFACTOR = 90)
);

