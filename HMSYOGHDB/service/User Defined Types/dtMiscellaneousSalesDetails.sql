CREATE TYPE [service].[dtMiscellaneousSalesDetails] AS TABLE (
    [InvoiceNo]       INT            NULL,
    [ItemDescription] VARCHAR (100)  NULL,
    [Quantity]        INT            NULL,
    [Rate]            DECIMAL (6, 2) NULL,
    [Tax]             DECIMAL (6, 2) NULL,
    [TotalRate]       DECIMAL (6, 2) NULL);

