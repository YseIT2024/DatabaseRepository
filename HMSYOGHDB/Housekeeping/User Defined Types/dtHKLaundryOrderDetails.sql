CREATE TYPE [Housekeeping].[dtHKLaundryOrderDetails] AS TABLE (
    [ItemId]        INT            NULL,
    [Quantity]      INT            NULL,
    [Rate]          DECIMAL (6, 2) NULL,
    [RateClean]     DECIMAL (6, 2) NULL,
    [RatePress]     DECIMAL (6, 2) NULL,
    [RateRepair]    DECIMAL (6, 2) NULL,
    [TaxId]         INT            NULL,
    [TaxPer]        DECIMAL (6, 2) NULL,
    [ExpresCharge]  DECIMAL (6, 2) NULL,
    [ServiceCharge] DECIMAL (6, 2) NULL,
    [ReturnStatus]  INT            NULL,
    [Remarks]       VARCHAR (250)  NULL,
    [Clean]         BIT            NULL,
    [Press]         BIT            NULL,
    [Repair]        BIT            NULL,
    [ItemRateChild] DECIMAL (6, 2) NULL,
    [Child]         BIT            NULL);

