CREATE TABLE [reservation].[ReservationTaxDetails] (
    [TaxDetailID]   INT IDENTITY (1, 1) NOT NULL,
    [ReservationID] INT NOT NULL,
    [ItemID]        INT NOT NULL,
    [TaxID]         INT NOT NULL,
    CONSTRAINT [PK_[reservation]].ReservationTaxDetails] PRIMARY KEY CLUSTERED ([TaxDetailID] ASC) WITH (FILLFACTOR = 90)
);

