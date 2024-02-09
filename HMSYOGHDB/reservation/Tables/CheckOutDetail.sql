CREATE TABLE [reservation].[CheckOutDetail] (
    [CheckOutID]          INT      IDENTITY (1, 1) NOT NULL,
    [ReservationID]       INT      NOT NULL,
    [KeyReturned]         BIT      NOT NULL,
    [ReservationStatusID] INT      NOT NULL,
    [CreatedBy]           INT      NULL,
    [CreatedDate]         DATETIME NULL,
    CONSTRAINT [PK_reservation.CheckOutDetail] PRIMARY KEY CLUSTERED ([CheckOutID] ASC) WITH (FILLFACTOR = 90)
);

