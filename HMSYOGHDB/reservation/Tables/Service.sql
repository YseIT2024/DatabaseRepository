CREATE TABLE [reservation].[Service] (
    [ServiceID]     INT      IDENTITY (1, 1) NOT NULL,
    [ReservationID] INT      NOT NULL,
    [ServiceTypeID] INT      NOT NULL,
    [InvoiceNo]     INT      NOT NULL,
    [CurrencyID]    INT      NOT NULL,
    [DateTime]      DATETIME NOT NULL,
    CONSTRAINT [PK_Service] PRIMARY KEY CLUSTERED ([ServiceID] ASC) WITH (FILLFACTOR = 90)
);

