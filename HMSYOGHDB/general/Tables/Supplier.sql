CREATE TABLE [general].[Supplier] (
    [SupplierID]    INT           IDENTITY (1, 1) NOT NULL,
    [SupplierNo]    VARCHAR (50)  NULL,
    [ContactID]     INT           NOT NULL,
    [AccountID]     INT           NULL,
    [Remarks]       VARCHAR (255) NULL,
    [CreatedBy]     INT           NULL,
    [CreatedDate]   DATETIME      NULL,
    [ContactPerson] VARCHAR (50)  NULL,
    [Designation]   VARCHAR (50)  NULL,
    CONSTRAINT [PK_Supplier_1] PRIMARY KEY CLUSTERED ([SupplierID] ASC) WITH (FILLFACTOR = 90)
);

