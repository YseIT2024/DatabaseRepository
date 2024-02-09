CREATE TABLE [currency].[ExchangeRate] (
    [ID]             INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MainCurrencyID] INT             NOT NULL,
    [CurrencyID]     INT             NOT NULL,
    [Rate]           DECIMAL (12, 6) NOT NULL,
    [AccountingDate] DATE            NOT NULL,
    [CreatedBy]      INT             NOT NULL,
    [CreatedDate]    DATETIME        NOT NULL,
    [AuthorizedFlag] INT             NULL,
    [BRate]          DECIMAL (12, 6) NULL,
    CONSTRAINT [PK_ExchangeRate] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

