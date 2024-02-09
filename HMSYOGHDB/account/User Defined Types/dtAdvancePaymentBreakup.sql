CREATE TYPE [account].[dtAdvancePaymentBreakup] AS TABLE (
    [CurrencyID]    INT             NULL,
    [Amount]        DECIMAL (18, 6) NULL,
    [PaymentTypeID] INT             NULL,
    [Rate]          DECIMAL (18, 6) NULL);

