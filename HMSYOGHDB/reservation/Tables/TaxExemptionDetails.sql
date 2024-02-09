CREATE TABLE [reservation].[TaxExemptionDetails] (
    [TaxExemptionDetailsId] INT           IDENTITY (1, 1) NOT NULL,
    [TaxRefNo]              VARCHAR (150) NULL,
    [CreatedDate]           DATETIME      NULL,
    [UserId]                INT           NULL,
    [ReservationID]         INT           NULL,
    PRIMARY KEY CLUSTERED ([TaxExemptionDetailsId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID])
);

