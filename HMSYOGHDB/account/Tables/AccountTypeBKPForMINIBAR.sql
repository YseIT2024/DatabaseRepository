CREATE TABLE [account].[AccountTypeBKPForMINIBAR] (
    [AccountTypeID]     INT          IDENTITY (1, 1) NOT NULL,
    [AccountType]       VARCHAR (60) NOT NULL,
    [AccountNumber]     INT          NOT NULL,
    [AccountGroupID]    INT          NOT NULL,
    [ShowInUI]          BIT          NOT NULL,
    [DisplayOrder]      INT          NOT NULL,
    [TransactionTypeID] INT          NULL,
    [Description]       VARCHAR (50) NULL
);

