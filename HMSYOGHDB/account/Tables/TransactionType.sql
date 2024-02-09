CREATE TABLE [account].[TransactionType] (
    [TransactionTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [TransactionType]   VARCHAR (50) NOT NULL,
    [Description]       VARCHAR (50) NOT NULL,
    [TransactionFactor] INT          NOT NULL,
    [ShowInUI]          BIT          CONSTRAINT [DF_TransactionType_ShowInUI] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TransactionType] PRIMARY KEY CLUSTERED ([TransactionTypeID] ASC) WITH (FILLFACTOR = 90)
);

