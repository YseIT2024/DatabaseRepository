CREATE TABLE [currency].[Currency] (
    [CurrencyID]                 INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CurrencySymbol]             VARCHAR (3)   NOT NULL,
    [CurrencyCode]               VARCHAR (50)  NOT NULL,
    [Description]                VARCHAR (100) NOT NULL,
    [IsMain]                     BIT           CONSTRAINT [DF_Currency_IsMain] DEFAULT ((0)) NOT NULL,
    [IsLocal]                    BIT           CONSTRAINT [DF_Currency_IsLocal] DEFAULT ((0)) NOT NULL,
    [IsStrongerThanMainCurrency] BIT           CONSTRAINT [DF_Currency_IsValuableThanMainCurrency] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED ([CurrencyID] ASC) WITH (FILLFACTOR = 90)
);

