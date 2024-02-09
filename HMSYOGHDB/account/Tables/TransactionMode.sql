CREATE TABLE [account].[TransactionMode] (
    [TransactionModeID] INT          IDENTITY (1, 1) NOT NULL,
    [TransactionMode]   VARCHAR (30) NOT NULL,
    [ShowInUI]          BIT          CONSTRAINT [DF_TransactionMode_ShowInUI] DEFAULT ((1)) NOT NULL,
    [Description]       VARCHAR (50) NULL,
    CONSTRAINT [PK_TransactionMode] PRIMARY KEY CLUSTERED ([TransactionModeID] ASC) WITH (FILLFACTOR = 90)
);

