CREATE TABLE [account].[PaymentType] (
    [PaymentTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [PaymentType]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_PaymentType] PRIMARY KEY CLUSTERED ([PaymentTypeId] ASC) WITH (FILLFACTOR = 90)
);

