CREATE TABLE [general].[Tax] (
    [TaxID]      INT            IDENTITY (1, 1) NOT NULL,
    [TaxName]    VARCHAR (100)  NULL,
    [TaxRate]    DECIMAL (8, 2) NULL,
    [CreatedBy]  INT            NULL,
    [CreateDate] DATETIME       NULL,
    [IsActive]   BIT            NULL,
    CONSTRAINT [PK__Tax__6A50EC5B82B11D88] PRIMARY KEY CLUSTERED ([TaxID] ASC) WITH (FILLFACTOR = 90)
);

