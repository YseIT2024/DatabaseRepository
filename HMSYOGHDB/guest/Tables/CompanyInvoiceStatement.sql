CREATE TABLE [guest].[CompanyInvoiceStatement] (
    [CISID]             INT             IDENTITY (1, 1) NOT NULL,
    [GuestCompanyID]    INT             NOT NULL,
    [CISFromDate]       DATETIME        NOT NULL,
    [CISToDate]         DATETIME        NOT NULL,
    [TotalAmtBeforeTax] DECIMAL (18, 4) NULL,
    [Total Tax]         DECIMAL (18, 4) NULL,
    [TotalAmt]          DECIMAL (18, 4) NOT NULL,
    [CreatedBy]         INT             NOT NULL,
    [CreatedOn]         DATETIME        NOT NULL,
    [LocationId]        INT             NULL,
    [CISStatusID]       INT             NULL,
    CONSTRAINT [PK_CISID] PRIMARY KEY CLUSTERED ([CISID] ASC) WITH (FILLFACTOR = 90)
);

