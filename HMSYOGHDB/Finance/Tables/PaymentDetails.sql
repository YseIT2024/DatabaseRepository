CREATE TABLE [Finance].[PaymentDetails] (
    [PaymentDetailId]     INT             IDENTITY (1, 1) NOT NULL,
    [PaymentId]           INT             NOT NULL,
    [CurrencyId]          INT             NULL,
    [PaymentTypeId]       INT             NULL,
    [Amount]              DECIMAL (18, 4) NULL,
    [AmountInMain]        DECIMAL (18, 4) NULL,
    [ExchangeRate]        DECIMAL (18, 8) NULL,
    [IsActive]            BIT             NULL,
    [BankDetails]         INT             NULL,
    [AccountDetails]      INT             NULL,
    [OtherPaymentDetails] NVARCHAR (50)   NULL,
    [OtherCharges]        DECIMAL (18, 4) NULL,
    [OtherChargesinMain]  DECIMAL (18, 4) NULL,
    [ExtraDiffAmount]     DECIMAL (18, 4) NULL,
    [ExtraDiffAmountMain] DECIMAL (18, 4) NULL,
    CONSTRAINT [PK_PaymentDetails_1] PRIMARY KEY CLUSTERED ([PaymentDetailId] ASC) WITH (FILLFACTOR = 90)
);

