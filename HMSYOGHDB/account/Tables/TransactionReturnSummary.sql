CREATE TABLE [account].[TransactionReturnSummary] (
    [TranSummaryID]     INT             IDENTITY (1, 1) NOT NULL,
    [TransactionTypeID] INT             NOT NULL,
    [TransactionID]     INT             NOT NULL,
    [CurrencyID]        INT             NULL,
    [DenominationID]    INT             NULL,
    [Quantity]          INT             NULL,
    [Amount]            DECIMAL (18, 6) NOT NULL,
    [PaymentTypeID]     INT             NULL,
    [Rate]              DECIMAL (18, 6) NULL,
    CONSTRAINT [PK_TransactionReturnSummary] PRIMARY KEY CLUSTERED ([TranSummaryID] ASC) WITH (FILLFACTOR = 90)
);

