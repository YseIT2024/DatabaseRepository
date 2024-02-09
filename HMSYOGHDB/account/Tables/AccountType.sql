CREATE TABLE [account].[AccountType] (
    [AccountTypeID]     INT          IDENTITY (1, 1) NOT NULL,
    [AccountType]       VARCHAR (60) NOT NULL,
    [AccountNumber]     INT          NOT NULL,
    [AccountGroupID]    INT          NOT NULL,
    [ShowInUI]          BIT          CONSTRAINT [DF_AccountType_ShowInUI] DEFAULT ((1)) NOT NULL,
    [DisplayOrder]      INT          CONSTRAINT [DF_AccountType_DisplayOrder] DEFAULT ((1)) NOT NULL,
    [TransactionTypeID] INT          NULL,
    [Description]       VARCHAR (50) NULL,
    CONSTRAINT [PK_AccountType] PRIMARY KEY CLUSTERED ([AccountTypeID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AccountType_AccountGroup] FOREIGN KEY ([AccountGroupID]) REFERENCES [account].[AccountGroup] ([AccountGroupID]),
    CONSTRAINT [FK_AccountType_TransactionType] FOREIGN KEY ([TransactionTypeID]) REFERENCES [account].[TransactionType] ([TransactionTypeID]),
    CONSTRAINT [IX_AccountType] UNIQUE NONCLUSTERED ([AccountNumber] ASC) WITH (FILLFACTOR = 90)
);

