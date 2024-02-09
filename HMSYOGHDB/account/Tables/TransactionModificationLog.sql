CREATE TABLE [account].[TransactionModificationLog] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [TransactionID]        INT           NOT NULL,
    [TransactionTypeID]    INT           NOT NULL,
    [NewTransactionTypeID] INT           NULL,
    [AccountTypeID]        INT           NOT NULL,
    [NewAccountTypeID]     INT           NULL,
    [LocationID]           INT           NOT NULL,
    [Remarks]              VARCHAR (MAX) NOT NULL,
    [DateTime]             DATETIME      NOT NULL,
    [DrawerID]             INT           NOT NULL,
    [UserID]               INT           NOT NULL,
    CONSTRAINT [PK_TransactionModificationLog] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

