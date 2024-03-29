﻿CREATE TYPE [account].[BOTranTbl] AS TABLE (
    [CompanyId]              INT              NOT NULL,
    [AccountReferenceNumber] INT              NOT NULL,
    [AccountingDate]         DATE             NOT NULL,
    [ContactID]              INT              NOT NULL,
    [FinancialTypeId]        TINYINT          NOT NULL,
    [CurrencyId]             INT              NOT NULL,
    [MainCurrencyRate]       NUMERIC (18, 10) NOT NULL,
    [LocalCurrencyRate]      NUMERIC (18, 10) NOT NULL,
    [Amount]                 NUMERIC (18, 2)  NOT NULL,
    [ReferenceId]            INT              NULL,
    [ReferenceTypeId]        INT              NOT NULL,
    [InvoiceNumber]          VARCHAR (50)     NULL,
    [TransactionUserId]      INT              NULL,
    [Description]            VARCHAR (MAX)    NULL,
    [Comments]               VARCHAR (MAX)    NULL,
    [CollectorId]            INT              NULL,
    [ContactTypeId]          INT              NULL,
    [AdditionalColumns]      VARCHAR (MAX)    NULL,
    [AdditionalColumnValues] VARCHAR (MAX)    NULL);

