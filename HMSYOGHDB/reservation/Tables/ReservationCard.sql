CREATE TABLE [reservation].[ReservationCard] (
    [FormID]        INT          IDENTITY (1, 1) NOT NULL,
    [CardNo]        INT          NOT NULL,
    [DocumentType]  VARCHAR (16) NULL,
    [ReservationID] INT          NULL,
    [LocationID]    INT          NOT NULL,
    [CreatedBy]     INT          NOT NULL,
    [CreatedOn]     DATETIME     NULL,
    [ModifiedBy]    INT          NULL,
    [ModifiedOn]    DATETIME     NULL,
    CONSTRAINT [PK_ReservationCard] PRIMARY KEY CLUSTERED ([FormID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Reservation_ReservationId] FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID]),
    CONSTRAINT [FK_Reservation_User] FOREIGN KEY ([CreatedBy]) REFERENCES [app].[User] ([UserID])
);

