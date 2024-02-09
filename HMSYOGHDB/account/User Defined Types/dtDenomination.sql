CREATE TYPE [account].[dtDenomination] AS TABLE (
    [DenominationID] INT             NULL,
    [Denomination]   DECIMAL (18, 2) NULL,
    [Quantity]       INT             NULL,
    [Total]          DECIMAL (18, 4) NULL,
    [CurrencyID]     INT             NULL);

