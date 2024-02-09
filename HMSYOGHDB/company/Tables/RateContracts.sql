CREATE TABLE [company].[RateContracts] (
    [RateContractID] INT      IDENTITY (1, 1) NOT NULL,
    [CompanyID]      INT      NOT NULL,
    [ItemId]         INT      NOT NULL,
    [ContractFrom]   DATE     NULL,
    [ContractTo]     DATE     NULL,
    [IsActive]       BIT      NULL,
    [CreatedBy]      INT      NULL,
    [CreatedOn]      DATETIME NULL,
    [ModifiedBy]     DATETIME NULL,
    [ModifiedOn]     DATETIME NULL,
    CONSTRAINT [PK_RateContracts] PRIMARY KEY CLUSTERED ([RateContractID] ASC)
);

