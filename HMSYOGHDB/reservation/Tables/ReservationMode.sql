CREATE TABLE [reservation].[ReservationMode] (
    [ReservationModeID] INT          IDENTITY (1, 1) NOT NULL,
    [ReservationMode]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ReservationMode] PRIMARY KEY CLUSTERED ([ReservationModeID] ASC) WITH (FILLFACTOR = 90)
);

