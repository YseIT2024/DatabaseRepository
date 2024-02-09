CREATE TABLE [reservation].[ReservationStatus] (
    [ReservationStatusID]       INT           NOT NULL,
    [ReservationStatus]         VARCHAR (50)  NOT NULL,
    [Text]                      VARCHAR (50)  NOT NULL,
    [Description]               VARCHAR (100) NOT NULL,
    [IsActualReservationStatus] BIT           CONSTRAINT [DF_ReservationStatus_IsActualReservationStatus] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ReservationStatus] PRIMARY KEY CLUSTERED ([ReservationStatusID] ASC) WITH (FILLFACTOR = 90)
);

