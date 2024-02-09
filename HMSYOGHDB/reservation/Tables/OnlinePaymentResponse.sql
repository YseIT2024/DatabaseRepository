CREATE TABLE [reservation].[OnlinePaymentResponse] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [ReferenceId]    INT             NULL,
    [ReferenceNo]    VARCHAR (100)   NULL,
    [Status]         NVARCHAR (MAX)  NULL,
    [IndentId]       NVARCHAR (MAX)  NULL,
    [PaymentMode]    NVARCHAR (100)  NULL,
    [CreateDateTime] DATETIME        NULL,
    [Amount]         DECIMAL (18, 2) NULL,
    [CustomerName]   NVARCHAR (100)  NULL,
    [MethodType]     NVARCHAR (100)  NULL,
    [Brand]          NVARCHAR (100)  NULL,
    [FourDigit]      NVARCHAR (100)  NULL,
    [PaymentGateway] NVARCHAR (250)  NULL,
    CONSTRAINT [PK_OnlinePaymentResponse] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

