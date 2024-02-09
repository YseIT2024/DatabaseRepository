CREATE TABLE [guest].[Voucher] (
    [VoucherID]           INT             IDENTITY (1, 1) NOT NULL,
    [VoucherNumber]       VARCHAR (100)   NOT NULL,
    [ReservationID]       INT             NOT NULL,
    [GuestID]             INT             NOT NULL,
    [Amount]              DECIMAL (18, 6) NOT NULL,
    [CurrencyID]          INT             NOT NULL,
    [ExchangeRate]        DECIMAL (18, 6) NOT NULL,
    [Description]         VARCHAR (MAX)   NULL,
    [ValidFrom]           DATETIME        NOT NULL,
    [ValidTo]             DATE            NOT NULL,
    [RedeemLocationID]    INT             NULL,
    [RedeemReservationID] INT             NULL,
    [RedeemGuestID]       INT             NULL,
    [RedeemUserID]        INT             NULL,
    [RedeemOn]            DATETIME        NULL,
    CONSTRAINT [PK_Voucher] PRIMARY KEY CLUSTERED ([VoucherID] ASC) WITH (FILLFACTOR = 90)
);

