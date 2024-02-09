CREATE TABLE [currency].[DenominationValueType] (
    [DenominationValueTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [DenominationValueType]   VARCHAR (25) NOT NULL,
    [IsActive]                BIT          NULL,
    CONSTRAINT [PK_DenominationValueType] PRIMARY KEY CLUSTERED ([DenominationValueTypeID] ASC) WITH (FILLFACTOR = 90)
);

