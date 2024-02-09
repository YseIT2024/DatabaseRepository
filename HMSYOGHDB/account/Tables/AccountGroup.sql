CREATE TABLE [account].[AccountGroup] (
    [AccountGroupID]     INT           IDENTITY (1, 1) NOT NULL,
    [AccountGroup]       VARCHAR (250) NOT NULL,
    [AccountGroupNumber] INT           NULL,
    [MainAccountTypeID]  INT           NOT NULL,
    [DisplayOrder]       INT           CONSTRAINT [DF_AccountGroup_DisplayOrder] DEFAULT ((1)) NOT NULL,
    [Description]        VARCHAR (100) NULL,
    CONSTRAINT [PK_AccountGroup] PRIMARY KEY CLUSTERED ([AccountGroupID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AccountGroup_MainAccountType] FOREIGN KEY ([MainAccountTypeID]) REFERENCES [account].[MainAccountType] ([MainAccountTypeID])
);

