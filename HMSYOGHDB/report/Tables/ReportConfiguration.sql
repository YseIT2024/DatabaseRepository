CREATE TABLE [report].[ReportConfiguration] (
    [ReportConfigId]      INT           IDENTITY (1, 1) NOT NULL,
    [DocumentTypeId]      INT           NOT NULL,
    [DocumentName]        NVARCHAR (50) NULL,
    [Prefix]              NVARCHAR (50) NULL,
    [PostFix]             NVARCHAR (50) NULL,
    [DocSeq]              INT           NULL,
    [FinancialYear]       NVARCHAR (50) NULL,
    [IsActive]            INT           NULL,
    [FirstCreateDatetime] DATETIME      NULL,
    [LastCreateDatetime]  DATETIME      NULL,
    CONSTRAINT [PK_ReportConfiguration] PRIMARY KEY CLUSTERED ([ReportConfigId] ASC, [DocumentTypeId] ASC) WITH (FILLFACTOR = 90)
);

