CREATE TABLE [currency].[DenominationType] (
    [DenominationTypeID]      INT          IDENTITY (1, 1) NOT NULL,
    [DenominationType]        VARCHAR (50) NOT NULL,
    [CurrencyID]              INT          NOT NULL,
    [DenominationValueTypeID] INT          NOT NULL,
    [IsActive]                BIT          CONSTRAINT [DF_DenominationType_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DenominationType] PRIMARY KEY CLUSTERED ([DenominationTypeID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DenominationType_DenominationValueType] FOREIGN KEY ([DenominationValueTypeID]) REFERENCES [currency].[DenominationValueType] ([DenominationValueTypeID])
);

