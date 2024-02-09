CREATE TYPE [account].[dtCurrencyBreakup] AS TABLE (
    [ID]         INT             NULL,
    [CurrencyID] INT             NULL,
    [Amount]     DECIMAL (18, 6) NULL);

