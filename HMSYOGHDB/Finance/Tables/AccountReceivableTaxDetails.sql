CREATE TABLE [Finance].[AccountReceivableTaxDetails] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [AccountReceivableId] INT             NULL,
    [TaxId]               INT             NULL,
    [TaxRate]             DECIMAL (18, 2) NULL,
    [Amount]              DECIMAL (18, 4) NULL,
    [AddedOn]             DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);

