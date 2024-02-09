CREATE TABLE [general].[CustomerWallet] (
    [WalletID]            INT             IDENTITY (1, 1) NOT NULL,
    [AccountTypeID]       INT             NOT NULL,
    [TransactionTypeID]   INT             NOT NULL,
    [CustomerID]          INT             NOT NULL,
    [ReservationID]       INT             NULL,
    [ReservedRoomRateID]  INT             NULL,
    [DateID]              INT             NULL,
    [Amount]              DECIMAL (18, 6) NOT NULL,
    [RateCurrencyID]      INT             NOT NULL,
    [IsVoid]              BIT             CONSTRAINT [DF_CustomerWallet_IsVoid] DEFAULT ((0)) NOT NULL,
    [AccountingDateID]    INT             NOT NULL,
    [TransactionDateTime] DATETIME        NOT NULL,
    [TransactionID]       INT             NULL,
    [Remarks]             VARCHAR (MAX)   NULL,
    [UserID]              INT             NULL,
    [ServiceID]           INT             NULL,
    CONSTRAINT [PK_CustomerWallet] PRIMARY KEY CLUSTERED ([WalletID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CustomerWallet_Guest] FOREIGN KEY ([CustomerID]) REFERENCES [general].[Customer] ([CustomerID])
);

