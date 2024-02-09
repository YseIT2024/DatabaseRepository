CREATE TABLE [guest].[GuestWallet] (
    [WalletID]            INT             IDENTITY (1, 1) NOT NULL,
    [AccountTypeID]       INT             NOT NULL,
    [TransactionTypeID]   INT             NOT NULL,
    [GuestID]             INT             NOT NULL,
    [ReservationID]       INT             NULL,
    [ReservedRoomRateID]  INT             NULL,
    [DateID]              INT             NULL,
    [Amount]              DECIMAL (18, 6) NOT NULL,
    [RateCurrencyID]      INT             NOT NULL,
    [IsVoid]              BIT             CONSTRAINT [DF_GuestWallet_IsVoid] DEFAULT ((0)) NOT NULL,
    [AccountingDateID]    INT             NOT NULL,
    [TransactionDateTime] DATETIME        NOT NULL,
    [TransactionID]       INT             NULL,
    [Remarks]             VARCHAR (MAX)   NULL,
    [UserID]              INT             NULL,
    [ServiceID]           INT             NULL,
    CONSTRAINT [PK_GuestWallet] PRIMARY KEY CLUSTERED ([WalletID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_GuestWallet_AccountType] FOREIGN KEY ([AccountTypeID]) REFERENCES [account].[AccountType] ([AccountTypeID]),
    CONSTRAINT [FK_GuestWallet_Guest] FOREIGN KEY ([GuestID]) REFERENCES [guest].[Guest] ([GuestID]),
    CONSTRAINT [FK_GuestWallet_Reservation] FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID]),
    CONSTRAINT [FK_GuestWallet_Transaction] FOREIGN KEY ([TransactionID]) REFERENCES [account].[Transaction] ([TransactionID])
);

