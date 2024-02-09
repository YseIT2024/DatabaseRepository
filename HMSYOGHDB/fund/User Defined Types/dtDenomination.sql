CREATE TYPE [fund].[dtDenomination] AS TABLE (
    [ID]                       INT             NOT NULL,
    [DenominationStatisticsID] INT             NULL,
    [DenominationID]           INT             NOT NULL,
    [Denomination]             DECIMAL (18, 2) NOT NULL,
    [DenomQuantity]            INT             NOT NULL,
    [CurrencyID]               INT             NULL);

