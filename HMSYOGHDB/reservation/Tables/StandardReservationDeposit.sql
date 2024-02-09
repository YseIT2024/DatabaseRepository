CREATE TABLE [reservation].[StandardReservationDeposit] (
    [StandardReservationDepositId]      INT            IDENTITY (1, 1) NOT NULL,
    [ReservationModeId]                 INT            NULL,
    [ReservationTypeId]                 INT            NULL,
    [SubcategoryId]                     INT            NULL,
    [StandardReservationDepositPercent] DECIMAL (5, 2) NOT NULL,
    [EffectiveFrom]                     DATETIME       NOT NULL,
    [EffectiveTo]                       DATETIME       NOT NULL,
    [IsActive]                          INT            NOT NULL,
    [ReservationDayFrom]                INT            NOT NULL,
    [ReservationDayTo]                  INT            NULL,
    CONSTRAINT [PK_StandardReservationDeposit] PRIMARY KEY CLUSTERED ([StandardReservationDepositId] ASC) WITH (FILLFACTOR = 90)
);

