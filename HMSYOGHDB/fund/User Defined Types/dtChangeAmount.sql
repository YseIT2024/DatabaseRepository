CREATE TYPE [fund].[dtChangeAmount] AS TABLE (
    [CurrencyID] INT             NOT NULL,
    [Amount]     DECIMAL (18, 2) NOT NULL);

