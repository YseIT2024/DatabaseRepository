CREATE TABLE [service].[ServiceTax] (
    [ServiceTaxID]  INT      IDENTITY (1, 1) NOT NULL,
    [ServiceTypeID] INT      NOT NULL,
    [TaxID]         INT      NOT NULL,
    [ValidFrom]     DATETIME NOT NULL,
    [ValidTo]       DATETIME NOT NULL,
    [IsActive]      BIT      NOT NULL,
    [CreatedBy]     INT      NOT NULL,
    [CreatedOn]     DATETIME NOT NULL,
    [ModifiedBy]    INT      NULL,
    [ModifiedOn]    DATETIME NULL,
    CONSTRAINT [PK_ServiceTax] PRIMARY KEY CLUSTERED ([ServiceTaxID] ASC) WITH (FILLFACTOR = 90)
);

