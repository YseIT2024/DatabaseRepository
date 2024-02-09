CREATE TABLE [reservation].[ReservationType] (
    [ReservationTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [ReservationType]   VARCHAR (50) NOT NULL,
    [Text]              VARCHAR (50) NULL,
    [IsActive]          BIT          NULL,
    CONSTRAINT [PK_ReservationType] PRIMARY KEY CLUSTERED ([ReservationTypeID] ASC) WITH (FILLFACTOR = 90)
);

