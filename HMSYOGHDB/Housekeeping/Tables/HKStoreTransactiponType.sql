CREATE TABLE [Housekeeping].[HKStoreTransactiponType] (
    [LocationId]          INT           NOT NULL,
    [StoreId]             INT           NOT NULL,
    [TransactionType]     INT           IDENTITY (1, 1) NOT NULL,
    [TransactionTypeName] VARCHAR (250) NOT NULL,
    [IsActive]            BIT           NOT NULL,
    [CreatedBy]           INT           NOT NULL,
    [CreatedOn]           DATETIME      NOT NULL,
    CONSTRAINT [PK_HKStoreTransactiponType] PRIMARY KEY CLUSTERED ([TransactionType] ASC) WITH (FILLFACTOR = 90)
);

