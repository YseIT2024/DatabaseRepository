CREATE TABLE [currency].[Denomination] (
    [DenominationID]     INT             IDENTITY (1, 1) NOT NULL,
    [DenominationTypeID] INT             NOT NULL,
    [DenominationValue]  DECIMAL (10, 2) NOT NULL,
    [IsActive]           BIT             NOT NULL,
    CONSTRAINT [FK_Denomination_DenominationType] FOREIGN KEY ([DenominationTypeID]) REFERENCES [currency].[DenominationType] ([DenominationTypeID])
);

