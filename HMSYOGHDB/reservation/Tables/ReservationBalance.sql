CREATE TABLE [reservation].[ReservationBalance] (
    [ReservationBalanceId] INT             IDENTITY (1, 1) NOT NULL,
    [ReservationID]        INT             NULL,
    [CheckOutDate]         DATE            NULL,
    [BalanceAmount]        DECIMAL (18, 3) NULL,
    [CreditPeriod]         INT             NULL,
    [FollowupDate]         DATE            NULL,
    [InterestPercentage]   INT             NULL,
    [CreatedDate]          DATETIME        NULL,
    [ModifiedDate]         DATETIME        NULL,
    CONSTRAINT [PK_ReservationBalance] PRIMARY KEY CLUSTERED ([ReservationBalanceId] ASC) WITH (FILLFACTOR = 90)
);

