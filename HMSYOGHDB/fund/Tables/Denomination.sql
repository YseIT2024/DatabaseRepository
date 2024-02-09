CREATE TABLE [fund].[Denomination] (
    [FlowDenominationID]       INT             IDENTITY (1, 1) NOT NULL,
    [FundFlowID]               INT             NOT NULL,
    [DenominationID]           INT             NOT NULL,
    [Quantity]                 INT             NOT NULL,
    [TotalValue]               DECIMAL (18, 6) NOT NULL,
    [TotalValueInMainCurrency] DECIMAL (18, 6) NOT NULL,
    [AccountingDateID]         INT             NOT NULL,
    [DrawerID]                 INT             NOT NULL,
    CONSTRAINT [PK_Denomination_1] PRIMARY KEY CLUSTERED ([FlowDenominationID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Denomination_Flow] FOREIGN KEY ([FundFlowID]) REFERENCES [fund].[Flow] ([FundFlowID])
);

