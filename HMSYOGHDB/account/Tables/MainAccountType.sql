CREATE TABLE [account].[MainAccountType] (
    [MainAccountTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [MainAccountType]   VARCHAR (50)  NOT NULL,
    [MainAccountNumber] INT           NULL,
    [DisplayOrder]      INT           CONSTRAINT [DF_MainAccountType_DisplayOrder] DEFAULT ((1)) NOT NULL,
    [Description]       VARCHAR (100) NULL,
    CONSTRAINT [PK_MainAccountType] PRIMARY KEY CLUSTERED ([MainAccountTypeID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [IX_MainAccountType] UNIQUE NONCLUSTERED ([MainAccountNumber] ASC) WITH (FILLFACTOR = 90)
);

