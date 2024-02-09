CREATE TABLE [account].[DrawerDates] (
    [AccountingDateId] INT             NOT NULL,
    [DrawerID]         INT             NOT NULL,
    [OpeningBalance]   DECIMAL (18, 4) NULL,
    [ClosingBalance]   DECIMAL (18, 4) NULL,
    [IsActive]         BIT             NOT NULL
);

