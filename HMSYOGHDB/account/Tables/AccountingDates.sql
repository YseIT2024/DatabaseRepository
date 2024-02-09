CREATE TABLE [account].[AccountingDates] (
    [AccountingDateId] INT  IDENTITY (1, 1) NOT NULL,
    [AccountingDate]   DATE NOT NULL,
    [DrawerID]         INT  NOT NULL,
    [IsActive]         BIT  NOT NULL,
    [OpeningDateTime]  AS   (getdate()),
    CONSTRAINT [PK_AccountingDates] PRIMARY KEY CLUSTERED ([AccountingDateId] ASC) WITH (FILLFACTOR = 90)
);

