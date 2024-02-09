CREATE TYPE [dbo].[RateContractsTableType] AS TABLE (
    [CompanyID]    INT      NULL,
    [ItemID]       INT      NULL,
    [ContractFrom] DATETIME NULL,
    [ContractTo]   DATETIME NULL,
    [IsActive]     BIT      NULL);

